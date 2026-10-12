import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/utils/app_snack_bar.dart';
import 'package:ridelink_admin/data/models/data/driver_document_request_model.dart';

class DriverDocumentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _usersSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _docsGroupSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _selectedDriverDocsSubscription;

  final RxList<DriverDocumentRequestModel> requests =
      <DriverDocumentRequestModel>[].obs;
  final RxBool isLoading = false.obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedStatusTab = 'All'.obs; // All, Pending, Verified, Rejected, Unsubmitted

  final Rx<DriverDocumentRequestModel?> selectedRequest =
      Rx<DriverDocumentRequestModel?>(null);

  final TextEditingController rejectionReasonController =
      TextEditingController();
  final RxString selectedPredefinedReason = 'Blurry document'.obs;

  final List<String> predefinedRejectionReasons = [
    'Blurry document',
    'Expired license',
    'Invalid insurance',
    'Mismatched vehicle details',
    'Incomplete documentation',
    'Other',
  ];

  // Raw user document snapshots for registered drivers
  final Map<String, DocumentSnapshot<Map<String, dynamic>>> _userDocsMap = {};

  // Documents mapped by userId loaded from `users/{userId}/docs` subcollection
  final Map<String, List<DriverDocumentItem>> _driverDocsSubcollectionMap = {};

  @override
  void onInit() {
    super.onInit();
    _initFirestoreListeners();
  }

  void _initFirestoreListeners() {
    isLoading(true);

    _usersSubscription?.cancel();
    _docsGroupSubscription?.cancel();

    // 1. Primary Stream: Listen to 'users' collection to retrieve driver profiles (Section 3.1)
    try {
      _usersSubscription = _firestore.collection('users').snapshots().listen(
        (snapshot) {
          _userDocsMap.clear();

          for (final doc in snapshot.docs) {
            final data = doc.data();
            if (_isDriverUser(data)) {
              _userDocsMap[doc.id] = doc;
            }
          }

          _combineAndPublishDrivers();
          isLoading(false);
        },
        onError: (err) {
          debugPrint('Firestore users stream error in DriverDocumentController: $err');
          isLoading(false);
        },
      );
    } catch (e) {
      debugPrint('Error initiating users stream in DriverDocumentController: $e');
      isLoading(false);
    }

    // 2. Collection Group Stream: Listen to all `docs` subcollections across users (Section 3.2)
    try {
      _docsGroupSubscription = _firestore
          .collectionGroup('docs')
          .snapshots()
          .listen(
        (snapshot) {
          _driverDocsSubcollectionMap.clear();

          for (final doc in snapshot.docs) {
            try {
              final item = DriverDocumentItem.fromFirestore(doc);
              String userId = item.userId;
              if (userId.isEmpty) {
                userId = doc.reference.parent.parent?.id ?? '';
              }

              if (userId.isNotEmpty) {
                _driverDocsSubcollectionMap
                    .putIfAbsent(userId, () => [])
                    .add(item);
              }
            } catch (e) {
              debugPrint('Error parsing doc from docs collectionGroup ${doc.id}: $e');
            }
          }

          _combineAndPublishDrivers();
        },
        onError: (err) {
          debugPrint('Firestore collectionGroup("docs") stream warning: $err');
        },
      );
    } catch (e) {
      debugPrint('Error initiating collectionGroup docs listener: $e');
    }
  }

  /// Determines if a user document is registered as a driver in RideLink
  bool _isDriverUser(Map<String, dynamic> data) {
    final activeRole = (data['activeRole'] ?? data['role'] ?? '').toString().toLowerCase();
    final roles = data['roles'] is List
        ? (data['roles'] as List).map((e) => e.toString().toLowerCase()).toList()
        : <String>[];
    final isVerifiedDriver = data['is_verified_driver'] == true;

    return roles.contains('driver') ||
        activeRole == 'driver' ||
        isVerifiedDriver ||
        data['vehicle'] != null;
  }

  /// Combines drivers from `users` and their `docs` subcollection and sorts them
  void _combineAndPublishDrivers() {
    final List<DriverDocumentRequestModel> loaded = [];

    for (final entry in _userDocsMap.entries) {
      final userId = entry.key;
      final docSnap = entry.value;
      final subcollectionDocs = _driverDocsSubcollectionMap[userId] ?? [];

      try {
        final driverModel = DriverDocumentRequestModel.fromUserSnapshot(
          docSnap,
          subcollectionDocs,
        );
        loaded.add(driverModel);
      } catch (e) {
        debugPrint('Error creating driver model for user $userId: $e');
      }
    }

    // Sort order: Pending first, then Rejected, then Verified, then Unsubmitted
    loaded.sort((a, b) {
      int score(DriverDocumentRequestModel m) {
        if (m.isPending) return 1;
        if (m.isRejected) return 2;
        if (m.isVerified) return 3;
        return 4; // unsubmitted
      }

      final sa = score(a);
      final sb = score(b);
      if (sa != sb) return sa.compareTo(sb);
      return b.submittedAt.compareTo(a.submittedAt);
    });

    requests.assignAll(loaded);

    // Keep selectedRequest updated if currently open in review drawer
    if (selectedRequest.value != null) {
      final updated = requests.firstWhereOrNull(
        (r) => r.id == selectedRequest.value!.id || r.driverId == selectedRequest.value!.driverId,
      );
      if (updated != null) {
        selectedRequest.value = updated;
      }
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
          (selectedStatusTab.value == 'Pending' && req.isPending) ||
          ((selectedStatusTab.value == 'Verified' || selectedStatusTab.value == 'Approved') && req.isVerified) ||
          (selectedStatusTab.value == 'Rejected' && req.isRejected) ||
          (selectedStatusTab.value == 'Unsubmitted' && req.isUnsubmitted);

      return matchesSearch && matchesTab;
    }).toList();
  }

  int get totalCount => requests.length;
  int get pendingCount => requests.where((r) => r.isPending).length;
  int get verifiedCount => requests.where((r) => r.isVerified).length;
  int get approvedCount => verifiedCount;
  int get rejectedCount => requests.where((r) => r.isRejected).length;
  int get unsubmittedCount => requests.where((r) => r.isUnsubmitted).length;

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

    // Attach real-time subcollection listener for this driver: `users/{driverId}/docs`
    _subscribeToDriverDocsSubcollection(req.driverId);
  }

  void _subscribeToDriverDocsSubcollection(String driverId) {
    _selectedDriverDocsSubscription?.cancel();
    _selectedDriverDocsSubscription = _firestore
        .collection('users')
        .doc(driverId)
        .collection('docs')
        .snapshots()
        .listen(
      (snapshot) {
        final subDocs = snapshot.docs
            .map((d) => DriverDocumentItem.fromFirestore(d))
            .toList();

        _driverDocsSubcollectionMap[driverId] = subDocs;

        if (selectedRequest.value != null &&
            selectedRequest.value!.driverId == driverId &&
            _userDocsMap.containsKey(driverId)) {
          selectedRequest.value = DriverDocumentRequestModel.fromUserSnapshot(
            _userDocsMap[driverId]!,
            subDocs,
          );
        }

        _combineAndPublishDrivers();
      },
      onError: (e) {
        debugPrint('Error listening to subcollection docs for driver $driverId: $e');
      },
    );
  }

  void closeReviewModal() {
    _selectedDriverDocsSubscription?.cancel();
    _selectedDriverDocsSubscription = null;
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    selectedRequest.value = null;
  }

  /// Updates a single document status in `users/{userId}/docs/{docId}` subcollection (Section 3.2 specification)
  Future<void> toggleDocItemStatus(String docId, String newStatus, [String? rejectionReason]) async {
    if (selectedRequest.value == null) return;
    final req = selectedRequest.value!;

    final normalizedStatus = newStatus.toLowerCase();

    try {
      final docRef = _firestore
          .collection('users')
          .doc(req.driverId)
          .collection('docs')
          .doc(docId);

      final Map<String, dynamic> docUpdate = {
        'id': docId,
        'title': DriverDocumentType.getTitle(docId),
        'user_id': req.driverId,
        'status': normalizedStatus,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (normalizedStatus == 'verified') {
        docUpdate['verified_at'] = DateTime.now().toIso8601String();
        docUpdate['verified_by'] = 'admin';
        docUpdate['rejection_reason'] = null;
      } else if (normalizedStatus == 'rejected') {
        docUpdate['verified_at'] = null;
        docUpdate['verified_by'] = null;
        docUpdate['rejection_reason'] = rejectionReason;
      } else {
        docUpdate['verified_at'] = null;
        docUpdate['verified_by'] = null;
        docUpdate['rejection_reason'] = null;
      }

      await docRef.set(docUpdate, SetOptions(merge: true));

      // Calculate if all required documents are verified
      final updatedDocs = req.documents.map((doc) {
        if (doc.id == docId || doc.docType == docId) {
          return doc.copyWith(
            status: normalizedStatus,
            rejectionReason: normalizedStatus == 'rejected' ? rejectionReason : null,
            verifiedAt: normalizedStatus == 'verified' ? DateTime.now() : null,
            verifiedBy: normalizedStatus == 'verified' ? 'admin' : null,
          );
        }
        return doc;
      }).toList();

      final allRequiredVerified = DriverDocumentType.requiredDocIds.every((key) {
        final d = updatedDocs.firstWhereOrNull((x) => x.id == key);
        return d != null && d.isVerified;
      });

      // Update singular verification flag `is_verified_driver` and rejection details on `users/{userId}`
      final Map<String, dynamic> userUpdate = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (allRequiredVerified) {
        userUpdate['is_verified_driver'] = true;
        userUpdate['status'] = 'verified';
        userUpdate['rejection_reason'] = null;
      } else if (normalizedStatus == 'rejected') {
        userUpdate['is_verified_driver'] = false;
        userUpdate['status'] = 'rejected';
        userUpdate['rejection_reason'] = rejectionReason;
        userUpdate['rejected_doc_id'] = docId;
        userUpdate['rejected_doc_title'] = DriverDocumentType.getTitle(docId);
      } else {
        userUpdate['is_verified_driver'] = false;
        userUpdate['status'] = 'pending';
      }

      await _firestore.collection('users').doc(req.driverId).update(userUpdate);

      // Create notification so the driver gets notified on their app
      if (normalizedStatus == 'rejected') {
        try {
          final docTitle = DriverDocumentType.getTitle(docId);
          await _firestore.collection('notifications').add({
            'userId': req.driverId,
            'title': 'Document Rejected: $docTitle',
            'body': rejectionReason?.trim().isNotEmpty == true
                ? '$docTitle was rejected: ${rejectionReason!.trim()}'
                : 'Your $docTitle was rejected. Please re-upload a clear document.',
            'message': rejectionReason?.trim().isNotEmpty == true
                ? '$docTitle was rejected: ${rejectionReason!.trim()}'
                : 'Your $docTitle was rejected. Please re-upload a clear document.',
            'type': 'document_rejected',
            'docId': docId,
            'docTitle': docTitle,
            'rejection_reason': rejectionReason,
            'isRead': false,
            'read': false,
            'createdAt': FieldValue.serverTimestamp(),
            'timestamp': FieldValue.serverTimestamp(),
            'data': {
              'type': 'document_rejected',
              'docId': docId,
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
          });
        } catch (notifErr) {
          debugPrint('Warning: Could not create document rejection notification: $notifErr');
        }
      }

      selectedRequest.value = req.copyWith(
        documents: updatedDocs,
        isVerifiedDriver: allRequiredVerified,
        rejectionReason: normalizedStatus == 'rejected' ? rejectionReason : (allRequiredVerified ? null : req.rejectionReason),
        status: allRequiredVerified ? 'Verified' : (normalizedStatus == 'rejected' ? 'Rejected' : req.status),
      );

      AppSnackBar.success(message: 'Document status updated to $normalizedStatus');
    } catch (e) {
      AppSnackBar.error(message: 'Failed to update document in subcollection: $e');
    }
  }

  /// Saves the complete KYC review for a driver based on document-level approvals and rejections.
  /// If any document is rejected, the driver status is marked as 'rejected' with the rejection reason.
  /// If all required documents are verified, the driver status is marked as 'verified'.
  /// Otherwise, if some are still pending and none are rejected, the driver status is marked as 'pending'.
  Future<bool> saveKycReview({
    required String driverId,
    required List<DriverDocumentItem> documents,
  }) async {
    try {
      final batch = _firestore.batch();
      final now = DateTime.now().toIso8601String();

      final List<DriverDocumentItem> rejectedDocs = [];

      for (final doc in documents) {
        final docRef = _firestore
            .collection('users')
            .doc(driverId)
            .collection('docs')
            .doc(doc.id);

        final Map<String, dynamic> docData = {
          'id': doc.id,
          'title': doc.title.isNotEmpty
              ? doc.title
              : DriverDocumentType.getTitle(doc.id),
          'user_id': driverId,
          'file_url': doc.fileUrl,
          'file_name': doc.fileName,
          'status': doc.status.toLowerCase(),
          'rejection_reason': doc.isRejected ? doc.rejectionReason : null,
          'updated_at': now,
        };

        if (doc.isVerified) {
          docData['verified_at'] =
              doc.verifiedAt?.toIso8601String() ?? now;
          docData['verified_by'] = doc.verifiedBy ?? 'admin';
        } else {
          docData['verified_at'] = null;
          docData['verified_by'] = null;
        }

        batch.set(docRef, docData, SetOptions(merge: true));

        if (doc.isRejected) {
          rejectedDocs.add(doc);
        }
      }

      await batch.commit();

      // Determine overall status
      final hasRejections = rejectedDocs.isNotEmpty;
      final allRequiredVerified =
          DriverDocumentType.requiredDocIds.every((key) {
        final d = documents
            .firstWhereOrNull((x) => x.id == key || x.docType == key);
        return d != null && d.isVerified;
      });

      final Map<String, dynamic> userUpdate = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      String overallStatus = 'pending';
      String? combinedRejectionReason;

      if (hasRejections) {
        overallStatus = 'rejected';
        userUpdate['is_verified_driver'] = false;
        userUpdate['status'] = 'rejected';

        combinedRejectionReason = rejectedDocs
            .map((d) =>
                '${d.displayTitle}: ${d.rejectionReason ?? "Rejected by administrator"}')
            .join('\n');

        userUpdate['rejection_reason'] = combinedRejectionReason;
        userUpdate['rejected_doc_id'] = rejectedDocs.first.id;
        userUpdate['rejected_doc_title'] = rejectedDocs.first.displayTitle;
      } else if (allRequiredVerified) {
        overallStatus = 'verified';
        userUpdate['is_verified_driver'] = true;
        userUpdate['status'] = 'verified';
        userUpdate['rejection_reason'] = null;
        userUpdate['rejected_doc_id'] = null;
        userUpdate['rejected_doc_title'] = null;
      } else {
        overallStatus = 'pending';
        userUpdate['is_verified_driver'] = false;
        userUpdate['status'] = 'pending';
        userUpdate['rejection_reason'] = null;
        userUpdate['rejected_doc_id'] = null;
        userUpdate['rejected_doc_title'] = null;
      }

      await _firestore
          .collection('users')
          .doc(driverId)
          .update(userUpdate);

      // Create mobile notifications for rejected documents
      for (final rDoc in rejectedDocs) {
        try {
          final reason = rDoc.rejectionReason?.trim();
          await _firestore.collection('notifications').add({
            'userId': driverId,
            'title': 'Document Rejected: ${rDoc.displayTitle}',
            'body': (reason != null && reason.isNotEmpty)
                ? '${rDoc.displayTitle} was rejected: $reason'
                : 'Your ${rDoc.displayTitle} was rejected. Please re-upload a clear document.',
            'message': (reason != null && reason.isNotEmpty)
                ? '${rDoc.displayTitle} was rejected: $reason'
                : 'Your ${rDoc.displayTitle} was rejected. Please re-upload a clear document.',
            'type': 'document_rejected',
            'docId': rDoc.id,
            'docTitle': rDoc.displayTitle,
            'rejection_reason': reason,
            'isRead': false,
            'read': false,
            'createdAt': FieldValue.serverTimestamp(),
            'timestamp': FieldValue.serverTimestamp(),
            'data': {
              'type': 'document_rejected',
              'docId': rDoc.id,
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
          });
        } catch (notifErr) {
          debugPrint(
              'Warning: Could not create rejection notification: $notifErr');
        }
      }

      // If all required documents are verified and no rejection, notify approval
      if (allRequiredVerified && !hasRejections) {
        try {
          await _firestore.collection('notifications').add({
            'userId': driverId,
            'title': 'Driver KYC Verified!',
            'body':
                'Congratulations! Your driver documents have been verified and your profile is approved.',
            'message':
                'Congratulations! Your driver documents have been verified and your profile is approved.',
            'type': 'driver_verified',
            'isRead': false,
            'read': false,
            'createdAt': FieldValue.serverTimestamp(),
            'timestamp': FieldValue.serverTimestamp(),
            'data': {
              'type': 'driver_verified',
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
          });
        } catch (_) {}
      }

      // Optimistically update local observable list and selected item
      final idx = requests.indexWhere(
          (r) => r.driverId == driverId || r.id == driverId);
      if (idx != -1) {
        final updated = requests[idx].copyWith(
          status: overallStatus == 'verified'
              ? 'Verified'
              : (overallStatus == 'rejected' ? 'Rejected' : 'Pending'),
          isVerifiedDriver: overallStatus == 'verified',
          rejectionReason: combinedRejectionReason,
          documents: documents,
        );
        requests[idx] = updated;
        if (selectedRequest.value?.driverId == driverId ||
            selectedRequest.value?.id == driverId) {
          selectedRequest.value = updated;
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error saving KYC review: $e');
      AppSnackBar.error(message: 'Failed to save KYC review: $e');
      return false;
    }
  }

  /// Verifies the driver: marks all documents in subcollection `users/{userId}/docs` as verified
  /// and sets singular flag `is_verified_driver: true` on `users/{userId}` (Section 3.1 & 3.2 specification)
  Future<void> approveRequest(String driverId) async {
    final req = requests.firstWhereOrNull((r) => r.id == driverId || r.driverId == driverId);
    if (req == null) return;

    try {
      // 1. Mark every document in subcollection `users/{userId}/docs/{docId}` as verified
      final batch = _firestore.batch();
      for (final doc in req.documents) {
        final docRef = _firestore
            .collection('users')
            .doc(req.driverId)
            .collection('docs')
            .doc(doc.id);

        batch.set(docRef, {
          'id': doc.id,
          'title': doc.title.isNotEmpty ? doc.title : DriverDocumentType.getTitle(doc.id),
          'user_id': req.driverId,
          'file_url': doc.fileUrl,
          'file_name': doc.fileName,
          'status': 'verified',
          'rejection_reason': null,
          'verified_at': DateTime.now().toIso8601String(),
          'verified_by': 'admin',
          'updated_at': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      }
      await batch.commit();

      // 2. Update singular verification flag `is_verified_driver` on `users/{userId}`
      await _firestore.collection('users').doc(req.driverId).update({
        'is_verified_driver': true,
        'status': 'verified',
        'rejection_reason': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedDocs = req.documents.map((d) => d.copyWith(
        status: 'verified',
        rejectionReason: null,
        verifiedAt: DateTime.now(),
        verifiedBy: 'admin',
      )).toList();

      selectedRequest.value = req.copyWith(
        status: 'Verified',
        isVerifiedDriver: true,
        rejectionReason: null,
        documents: updatedDocs,
      );

      _combineAndPublishDrivers();
      AppSnackBar.success(
        message: 'Driver ${req.driverName} verified successfully!',
      );
    } catch (e) {
      AppSnackBar.error(message: 'Failed to verify driver: $e');
    }
  }

  /// Rejects the driver application: marks documents in subcollection `users/{userId}/docs/{docId}` as rejected
  /// and sets `is_verified_driver: false` on `users/{userId}` (Section 3.1 & 3.2 specification)
  Future<void> rejectRequest(String driverId, String reason) async {
    final req = requests.firstWhereOrNull((r) => r.id == driverId || r.driverId == driverId);
    if (req == null) return;

    final resolvedReason =
        reason.isNotEmpty ? reason : selectedPredefinedReason.value;

    try {
      // 1. Mark unverified documents in subcollection as rejected with rejection reason
      final batch = _firestore.batch();
      for (final doc in req.documents) {
        if (!doc.isVerified) {
          final docRef = _firestore
              .collection('users')
              .doc(req.driverId)
              .collection('docs')
              .doc(doc.id);

          batch.set(docRef, {
            'id': doc.id,
            'title': doc.title.isNotEmpty ? doc.title : DriverDocumentType.getTitle(doc.id),
            'user_id': req.driverId,
            'file_url': doc.fileUrl,
            'file_name': doc.fileName,
            'status': 'rejected',
            'rejection_reason': resolvedReason,
            'updated_at': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        }
      }
      await batch.commit();

      // 2. Update singular verification flag `is_verified_driver` and rejection details on `users/{userId}`
      await _firestore.collection('users').doc(req.driverId).update({
        'is_verified_driver': false,
        'status': 'rejected',
        'rejection_reason': resolvedReason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3. Send notification for overall rejection so the driver app can notify the driver
      try {
        await _firestore.collection('notifications').add({
          'userId': req.driverId,
          'title': 'Driver Application Rejected',
          'body': 'Your driver application was rejected: $resolvedReason',
          'message': 'Your driver application was rejected: $resolvedReason',
          'type': 'driver_application_rejected',
          'rejection_reason': resolvedReason,
          'isRead': false,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
          'timestamp': FieldValue.serverTimestamp(),
          'data': {
            'type': 'driver_application_rejected',
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
        });
      } catch (notifErr) {
        debugPrint('Warning: Could not create rejection notification: $notifErr');
      }

      final updatedDocs = req.documents.map((d) {
        if (!d.isVerified) {
          return d.copyWith(
            status: 'rejected',
            rejectionReason: resolvedReason,
          );
        }
        return d;
      }).toList();

      selectedRequest.value = req.copyWith(
        status: 'Rejected',
        isVerifiedDriver: false,
        rejectionReason: resolvedReason,
        documents: updatedDocs,
      );

      _combineAndPublishDrivers();
      AppSnackBar.error(
        message: 'Driver application rejected with reason: $resolvedReason',
      );
    } catch (e) {
      AppSnackBar.error(message: 'Failed to reject application: $e');
    }
  }

  /// Updates basic driver and vehicle details in Cloud Firestore
  Future<bool> updateDriverBasicDetails({
    required String driverId,
    required String fullName,
    required String phoneNumber,
    String? email,
    required String vehicleMake,
    required String vehicleModel,
    required String vehiclePlate,
    required String vehicleColor,
    String vehicleType = 'Sedan',
  }) async {
    try {
      final Map<String, dynamic> vehicleMap = {
        'make': vehicleMake.trim(),
        'model': vehicleModel.trim(),
        'licensePlate': vehiclePlate.trim().toUpperCase(),
        'color': vehicleColor.trim(),
        'type': vehicleType.trim(),
      };

      final Map<String, dynamic> userUpdate = {
        'fullName': fullName.trim(),
        'name': fullName.trim(),
        'phoneNumber': phoneNumber.trim(),
        'phone': phoneNumber.trim(),
        'vehicle': vehicleMap,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (email != null && email.trim().isNotEmpty) {
        userUpdate['email'] = email.trim();
      }

      await _firestore
          .collection('users')
          .doc(driverId)
          .set(userUpdate, SetOptions(merge: true));

      // Optimistically update memory state
      final index = requests
          .indexWhere((r) => r.driverId == driverId || r.id == driverId);
      if (index != -1) {
        final old = requests[index];
        final updated = old.copyWith(
          driverName: fullName.trim(),
          driverPhone: phoneNumber.trim(),
          driverEmail: (email != null && email.trim().isNotEmpty)
              ? email.trim()
              : old.driverEmail,
          vehicleMake: vehicleMake.trim(),
          vehicleModel: vehicleModel.trim(),
          vehiclePlate: vehiclePlate.trim().toUpperCase(),
          vehicleColor: vehicleColor.trim(),
          vehicleType: vehicleType.trim(),
        );
        requests[index] = updated;
        if (selectedRequest.value?.driverId == driverId ||
            selectedRequest.value?.id == driverId) {
          selectedRequest.value = updated;
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error updating driver details: $e');
      AppSnackBar.error(message: 'Failed to update driver details: $e');
      return false;
    }
  }

  @override
  void onClose() {
    _usersSubscription?.cancel();
    _docsGroupSubscription?.cancel();
    _selectedDriverDocsSubscription?.cancel();
    rejectionReasonController.dispose();
    super.onClose();
  }
}
