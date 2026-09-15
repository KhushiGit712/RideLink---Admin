import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/utils/app_snack_bar.dart';
import 'package:ridelink_admin/data/models/data/driver_document_request_model.dart';

class DriverDocumentController extends GetxController {
  final RxList<DriverDocumentRequestModel> requests = <DriverDocumentRequestModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatusTab = 'Pending'.obs; // All, Pending, Approved, Rejected

  final Rx<DriverDocumentRequestModel?> selectedRequest = Rx<DriverDocumentRequestModel?>(null);

  final TextEditingController rejectionReasonController = TextEditingController();
  final RxString selectedPredefinedReason = 'Blurry document image'.obs;

  final List<String> predefinedRejectionReasons = [
    'Blurry document image',
    'Expired document date',
    'Name mismatch on ID',
    'Unclear license number',
    'Incomplete vehicle insurance',
    'Other / Custom reason',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadInitialMockRequests();
  }

  void _loadInitialMockRequests() {
    requests.assignAll([
      DriverDocumentRequestModel(
        id: 'REQ-2026-001',
        driverId: 'DRV-8801',
        driverName: 'Alexander Wright',
        driverEmail: 'alex.wright@example.com',
        driverPhone: '+1 (415) 892-3341',
        profileImageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        vehicleType: 'Sedan',
        vehicleModel: '2023 Toyota Camry Hybrid',
        vehiclePlateNumber: '7XYZ890',
        status: 'Pending',
        submittedAt: DateTime.now().subtract(const Duration(hours: 3)),
        documents: [
          DriverDocumentItem(
            id: 'DOC-101',
            docType: 'Driving License',
            documentNumber: 'DL-SF-9948201',
            expiryDate: '2028-11-15',
            fileUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600',
            status: 'Pending',
          ),
          DriverDocumentItem(
            id: 'DOC-102',
            docType: 'Vehicle RC / Registration',
            documentNumber: 'RC-CA-8837190',
            expiryDate: '2026-08-30',
            fileUrl: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?w=600',
            status: 'Pending',
          ),
          DriverDocumentItem(
            id: 'DOC-103',
            docType: 'Insurance Policy',
            documentNumber: 'INS-GEICO-77492',
            expiryDate: '2027-02-14',
            fileUrl: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?w=600',
            status: 'Pending',
          ),
          DriverDocumentItem(
            id: 'DOC-104',
            docType: 'National ID Card',
            documentNumber: 'SSN-XXX-XX-9182',
            expiryDate: '2030-05-20',
            fileUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600',
            status: 'Pending',
          ),
        ],
      ),
      DriverDocumentRequestModel(
        id: 'REQ-2026-002',
        driverId: 'DRV-8802',
        driverName: 'Sophia Martinez',
        driverEmail: 'sophia.m@example.com',
        driverPhone: '+1 (415) 761-9022',
        profileImageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        vehicleType: 'SUV',
        vehicleModel: '2024 Honda CR-V',
        vehiclePlateNumber: '8ABC123',
        status: 'Pending',
        submittedAt: DateTime.now().subtract(const Duration(hours: 7)),
        documents: [
          DriverDocumentItem(
            id: 'DOC-201',
            docType: 'Driving License',
            documentNumber: 'DL-CA-4491029',
            expiryDate: '2027-04-10',
            fileUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600',
            status: 'Pending',
          ),
          DriverDocumentItem(
            id: 'DOC-202',
            docType: 'Vehicle RC / Registration',
            documentNumber: 'RC-CA-1102938',
            expiryDate: '2026-12-01',
            fileUrl: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?w=600',
            status: 'Pending',
          ),
          DriverDocumentItem(
            id: 'DOC-203',
            docType: 'Insurance Policy',
            documentNumber: 'INS-STATEFARM-993',
            expiryDate: '2027-09-15',
            fileUrl: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?w=600',
            status: 'Pending',
          ),
        ],
      ),
      DriverDocumentRequestModel(
        id: 'REQ-2026-003',
        driverId: 'DRV-8803',
        driverName: 'Michael Chen',
        driverEmail: 'mchen.rides@example.com',
        driverPhone: '+1 (415) 321-4567',
        profileImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        vehicleType: 'Electric',
        vehicleModel: '2023 Tesla Model 3',
        vehiclePlateNumber: '9EV456',
        status: 'Approved',
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        documents: [
          DriverDocumentItem(
            id: 'DOC-301',
            docType: 'Driving License',
            documentNumber: 'DL-CA-7718290',
            expiryDate: '2029-01-22',
            fileUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600',
            status: 'Approved',
          ),
          DriverDocumentItem(
            id: 'DOC-302',
            docType: 'Vehicle RC / Registration',
            documentNumber: 'RC-CA-9920192',
            expiryDate: '2027-05-10',
            fileUrl: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?w=600',
            status: 'Approved',
          ),
        ],
      ),
      DriverDocumentRequestModel(
        id: 'REQ-2026-004',
        driverId: 'DRV-8804',
        driverName: 'David Miller',
        driverEmail: 'david.miller@example.com',
        driverPhone: '+1 (510) 998-1122',
        profileImageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        vehicleType: 'Van',
        vehicleModel: '2022 Ford Transit Express',
        vehiclePlateNumber: '6VAN991',
        status: 'Rejected',
        rejectionReason: 'Blurry document image (Driving license is illegible)',
        submittedAt: DateTime.now().subtract(const Duration(days: 2)),
        documents: [
          DriverDocumentItem(
            id: 'DOC-401',
            docType: 'Driving License',
            documentNumber: 'DL-CA-XXXXXXX',
            expiryDate: '2025-01-01',
            fileUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600',
            status: 'Rejected',
            rejectionNote: 'Image is out of focus and expired',
          ),
        ],
      ),
    ]);
  }

  List<DriverDocumentRequestModel> get filteredRequests {
    return requests.where((req) {
      final query = searchQuery.value.toLowerCase();
      final matchesSearch = query.isEmpty ||
          req.driverName.toLowerCase().contains(query) ||
          req.driverEmail.toLowerCase().contains(query) ||
          req.driverPhone.toLowerCase().contains(query) ||
          req.vehiclePlateNumber.toLowerCase().contains(query) ||
          req.id.toLowerCase().contains(query);

      final matchesTab = selectedStatusTab.value == 'All' ||
          req.status == selectedStatusTab.value;

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

  void toggleDocItemStatus(String docId, String newStatus) {
    if (selectedRequest.value == null) return;
    final req = selectedRequest.value!;

    final updatedDocs = req.documents.map((doc) {
      if (doc.id == docId) {
        return doc.copyWith(status: newStatus);
      }
      return doc;
    }).toList();

    final updatedReq = req.copyWith(documents: updatedDocs);
    selectedRequest.value = updatedReq;

    // Update in main list as well
    final index = requests.indexWhere((r) => r.id == req.id);
    if (index != -1) {
      requests[index] = updatedReq;
    }
  }

  void approveRequest(String requestId) {
    final index = requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final current = requests[index];

      // Mark all documents as approved
      final approvedDocs = current.documents.map((d) => d.copyWith(status: 'Approved')).toList();

      final updated = current.copyWith(
        status: 'Approved',
        documents: approvedDocs,
        rejectionReason: null,
      );

      requests[index] = updated;
      if (selectedRequest.value?.id == requestId) {
        selectedRequest.value = updated;
      }

      AppSnackBar.success(
        message: 'Driver ${current.driverName} has been approved and verified!',
      );
    }
  }

  void rejectRequest(String requestId, String reason) {
    final index = requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final current = requests[index];

      final updated = current.copyWith(
        status: 'Rejected',
        rejectionReason: reason.isNotEmpty ? reason : selectedPredefinedReason.value,
      );

      requests[index] = updated;
      if (selectedRequest.value?.id == requestId) {
        selectedRequest.value = updated;
      }

      AppSnackBar.error(
        message: 'Driver ${current.driverName} verification rejected.',
      );
    }
  }

  @override
  void onClose() {
    rejectionReasonController.dispose();
    super.onClose();
  }
}
