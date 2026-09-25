import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/utils/app_snack_bar.dart';
import 'package:ridelink_admin/data/models/data/driver_document_request_model.dart';
import 'package:ridelink_admin/data/services/firebase_storage_service.dart';

class DriverDocumentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _requestsSubscription;

  final RxList<DriverDocumentRequestModel> requests =
      <DriverDocumentRequestModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxString uploadProgressMessage = ''.obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedStatusTab = 'Pending'.obs; // All, Pending, Approved, Rejected

  final Rx<DriverDocumentRequestModel?> selectedRequest =
      Rx<DriverDocumentRequestModel?>(null);

  final TextEditingController rejectionReasonController =
      TextEditingController();
  final RxString selectedPredefinedReason = 'Blurry document'.obs;

  // Options from Specification:
  final List<String> predefinedRejectionReasons = [
    'Blurry document',
    'Expired license',
    'Invalid insurance',
    'Mismatched vehicle details',
    'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    _initFirestoreListener();
  }

  void _initFirestoreListener() {
    isLoading(true);
    try {
      _requestsSubscription = _firestore
          .collection('driver_verifications')
          .snapshots()
          .listen(
        (snapshot) {
          final List<DriverDocumentRequestModel> loaded = [];
          for (final doc in snapshot.docs) {
            try {
              loaded.add(DriverDocumentRequestModel.fromSnapshot(doc));
            } catch (e) {
              debugPrint('Error parsing driver verification doc ${doc.id}: $e');
            }
          }
          // Sort by submittedAt descending
          loaded.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
          requests.assignAll(loaded);
          isLoading(false);

          // Keep selectedRequest updated if currently open
          if (selectedRequest.value != null) {
            final updated = requests.firstWhereOrNull(
              (r) => r.id == selectedRequest.value!.id,
            );
            selectedRequest.value = updated;
          }
        },
        onError: (err) {
          debugPrint('Firestore driver verifications listener error: $err');
          isLoading(false);
          AppSnackBar.error(message: 'Failed to load driver requests: $err');
        },
      );
    } catch (e) {
      isLoading(false);
      debugPrint('Error initializing driver verifications listener: $e');
    }
  }

  List<DriverDocumentRequestModel> get filteredRequests {
    return requests.where((req) {
      final query = searchQuery.value.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          req.driverName.toLowerCase().contains(query) ||
          req.driverEmail.toLowerCase().contains(query) ||
          req.driverPhone.toLowerCase().contains(query) ||
          req.vehiclePlate.toLowerCase().contains(query) ||
          req.vehicleModel.toLowerCase().contains(query) ||
          req.driverId.toLowerCase().contains(query) ||
          req.id.toLowerCase().contains(query);

      final matchesTab = selectedStatusTab.value == 'All' ||
          (selectedStatusTab.value == 'Pending' && req.status == 'Pending') ||
          (selectedStatusTab.value == 'Approved' && req.status == 'Approved') ||
          (selectedStatusTab.value == 'Rejected' && req.status == 'Rejected');

      return matchesSearch && matchesTab;
    }).toList();
  }

  int get totalCount => requests.length;
  int get pendingCount => requests.where((r) => r.status == 'Pending').length;
  int get approvedCount => requests.where((r) => r.status == 'Approved').length;
  int get rejectedCount => requests.where((r) => r.status == 'Rejected').length;

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setStatusTab(String tab) {
    selectedStatusTab.value = tab;
  }

  void selectRequestForReview(DriverDocumentRequestModel req) {
    selectedRequest.value = req;
    rejectionReasonController.clear();
    selectedPredefinedReason.value = predefinedRejectionReasons.first;
  }

  void closeReviewModal() {
    selectedRequest.value = null;
  }

  Future<void> toggleDocItemStatus(String docId, String newStatus) async {
    if (selectedRequest.value == null) return;
    final req = selectedRequest.value!;

    final updatedDocs = req.documents.map((doc) {
      if (doc.id == docId) {
        return doc.copyWith(status: newStatus);
      }
      return doc;
    }).toList();

    try {
      await _firestore.collection('driver_verifications').doc(req.id).update({
        'documents': updatedDocs.map((e) => e.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppSnackBar.success(message: 'Document status set to $newStatus.');
    } catch (e) {
      AppSnackBar.error(message: 'Failed to update document item: $e');
    }
  }

  Future<void> approveRequest(String requestId) async {
    final req = requests.firstWhereOrNull((r) => r.id == requestId);
    if (req == null) return;

    try {
      // 1. Mark all individual document items as approved
      final approvedDocs =
          req.documents.map((d) => d.copyWith(status: 'Approved')).toList();

      // 2. Update Firestore document under driver_verifications
      await _firestore.collection('driver_verifications').doc(requestId).update({
        'status': 'Approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'rejectionReason': null,
        'documents': approvedDocs.map((e) => e.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3. Update driver user profile in Firestore
      try {
        await _firestore.collection('users').doc(req.driverId).set({
          'isDriverVerified': true,
          'kycStatus': 'Approved',
          'vehicleDetails': {
            'make': req.vehicleMake,
            'model': req.vehicleModel,
            'year': req.vehicleYear,
            'plate': req.vehiclePlate,
            'seats': req.passengerSeats,
            'type': req.vehicleType,
          },
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Note: Could not update users/${req.driverId}: $e');
      }

      AppSnackBar.success(
        message:
            'Driver ${req.driverName} approved! Status updated in Firestore.',
      );
    } catch (e) {
      AppSnackBar.error(message: 'Failed to approve driver: $e');
    }
  }

  Future<void> rejectRequest(String requestId, String reason) async {
    final req = requests.firstWhereOrNull((r) => r.id == requestId);
    if (req == null) return;

    final resolvedReason =
        reason.isNotEmpty ? reason : selectedPredefinedReason.value;

    try {
      // 1. Update Firestore driver_verifications document
      await _firestore.collection('driver_verifications').doc(requestId).update({
        'status': 'Rejected',
        'reviewedAt': FieldValue.serverTimestamp(),
        'rejectionReason': resolvedReason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Update driver user profile in Firestore
      try {
        await _firestore.collection('users').doc(req.driverId).set({
          'isDriverVerified': false,
          'kycStatus': 'Rejected',
          'kycRejectionReason': resolvedReason,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Note: Could not update users/${req.driverId}: $e');
      }

      AppSnackBar.error(
        message: 'Application rejected. Rejection reason saved to Firestore.',
      );
    } catch (e) {
      AppSnackBar.error(message: 'Failed to reject application: $e');
    }
  }

  /// Uploads driver documents to Firebase Storage and registers the verification application in Firestore
  Future<bool> uploadDriverApplication({
    required String driverName,
    required String driverEmail,
    required String driverPhone,
    required String driverId,
    required String vehicleMake,
    required String vehicleModel,
    required String vehicleYear,
    required String vehiclePlate,
    required int passengerSeats,
    required String vehicleType,
    required String licenseNumber,
    required String insuranceExpiryDate,
    required Uint8List licenseFrontBytes,
    required String licenseFrontFileName,
    required Uint8List licenseBackBytes,
    required String licenseBackFileName,
    required Uint8List rcBytes,
    required String rcFileName,
    required Uint8List insuranceBytes,
    required String insuranceFileName,
    Uint8List? profileImageBytes,
    String? profileImageFileName,
  }) async {
    isUploading(true);
    final resolvedDriverId = driverId.isNotEmpty
        ? driverId
        : 'drv_${DateTime.now().millisecondsSinceEpoch}';

    try {
      // Step 1: Upload License Front to Firebase Storage
      uploadProgressMessage.value = 'Uploading License Front to Firebase Storage...';
      final licenseFrontUrl = await FirebaseStorageService.uploadDriverDocument(
        driverId: resolvedDriverId,
        docType: 'license_front',
        fileBytes: licenseFrontBytes,
        fileName: licenseFrontFileName,
      );

      // Step 2: Upload License Back to Firebase Storage
      uploadProgressMessage.value = 'Uploading License Back to Firebase Storage...';
      final licenseBackUrl = await FirebaseStorageService.uploadDriverDocument(
        driverId: resolvedDriverId,
        docType: 'license_back',
        fileBytes: licenseBackBytes,
        fileName: licenseBackFileName,
      );

      // Step 3: Upload Registration Certificate (RC) to Firebase Storage
      uploadProgressMessage.value = 'Uploading Vehicle RC to Firebase Storage...';
      final rcDocumentUrl = await FirebaseStorageService.uploadDriverDocument(
        driverId: resolvedDriverId,
        docType: 'vehicle_rc',
        fileBytes: rcBytes,
        fileName: rcFileName,
      );

      // Step 4: Upload Vehicle Insurance to Firebase Storage
      uploadProgressMessage.value = 'Uploading Vehicle Insurance to Firebase Storage...';
      final insuranceDocUrl = await FirebaseStorageService.uploadDriverDocument(
        driverId: resolvedDriverId,
        docType: 'vehicle_insurance',
        fileBytes: insuranceBytes,
        fileName: insuranceFileName,
      );

      // Step 5: Upload Profile Photo if provided
      String profileImageUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop';
      if (profileImageBytes != null && profileImageFileName != null) {
        uploadProgressMessage.value = 'Uploading Profile Photo to Firebase Storage...';
        profileImageUrl = await FirebaseStorageService.uploadDriverDocument(
          driverId: resolvedDriverId,
          docType: 'profile_image',
          fileBytes: profileImageBytes,
          fileName: profileImageFileName,
        );
      }

      // Step 6: Create application record in Cloud Firestore
      uploadProgressMessage.value = 'Saving verification record to Cloud Firestore...';
      final docRef = _firestore.collection('driver_verifications').doc();
      final newApp = DriverDocumentRequestModel(
        id: docRef.id,
        driverId: resolvedDriverId,
        driverName: driverName,
        driverEmail: driverEmail,
        driverPhone: driverPhone,
        profileImageUrl: profileImageUrl,
        vehicleMake: vehicleMake,
        vehicleModel: vehicleModel,
        vehicleYear: vehicleYear,
        vehiclePlate: vehiclePlate,
        passengerSeats: passengerSeats,
        vehicleType: vehicleType,
        licenseNumber: licenseNumber,
        licenseFrontUrl: licenseFrontUrl,
        licenseBackUrl: licenseBackUrl,
        rcDocumentUrl: rcDocumentUrl,
        insuranceDocUrl: insuranceDocUrl,
        insuranceExpiryDate: insuranceExpiryDate,
        status: 'Pending',
        submittedAt: DateTime.now(),
      );

      await docRef.set(newApp.toFirestore());

      // Also set/update user record
      try {
        await _firestore.collection('users').doc(resolvedDriverId).set({
          'name': driverName,
          'email': driverEmail,
          'phone': driverPhone,
          'userType': 'driver',
          'kycStatus': 'Pending',
          'isDriverVerified': false,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}

      isUploading(false);
      uploadProgressMessage.value = '';
      AppSnackBar.success(
        message: 'Driver documents successfully uploaded to Firebase Storage and submitted for verification!',
      );
      return true;
    } catch (e) {
      isUploading(false);
      uploadProgressMessage.value = '';
      debugPrint('Error uploading driver application: $e');
      AppSnackBar.error(message: 'Upload failed: $e');
      return false;
    }
  }

  @override
  void onClose() {
    _requestsSubscription?.cancel();
    rejectionReasonController.dispose();
    super.onClose();
  }
}
