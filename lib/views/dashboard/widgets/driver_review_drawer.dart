import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';
import 'package:ridelink_admin/core/utils/app_snack_bar.dart';
import 'package:ridelink_admin/data/models/data/driver_document_request_model.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/dashboard/controllers/driver_document_controller.dart';
import 'package:ridelink_admin/views/dashboard/widgets/edit_user_profile_dialog.dart';
import 'package:ridelink_admin/views/dashboard/widgets/image_zoom_dialog.dart';
import 'package:ridelink_admin/views/dashboard/widgets/smart_doc_image.dart';

class DriverReviewDrawer extends StatefulWidget {
  const DriverReviewDrawer({super.key});

  @override
  State<DriverReviewDrawer> createState() => _DriverReviewDrawerState();
}

class _DriverReviewDrawerState extends State<DriverReviewDrawer> {
  DriverDocumentRequestModel? _cachedReq;
  List<DriverDocumentItem> _localDocs = [];
  String? _loadedDriverId;
  bool _isSaving = false;

  void _closeModal(BuildContext context) {
    _loadedDriverId = null;
    _localDocs.clear();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Get.back();
    }
  }

  void _initLocalDocs(DriverDocumentRequestModel req) {
    if (_loadedDriverId == req.driverId) return;
    _loadedDriverId = req.driverId;

    List<DriverDocumentItem> docs = List.from(req.documents);
    if (docs.isEmpty) {
      final defaultStatus = req.isVerified
          ? 'verified'
          : (req.isRejected ? 'rejected' : 'pending');

      docs = [
        DriverDocumentItem(
          id: DriverDocumentType.drivingLicence,
          title: DriverDocumentType.getTitle(DriverDocumentType.drivingLicence),
          fileUrl: req.licenseFrontUrl,
          status: defaultStatus,
        ),
        DriverDocumentItem(
          id: DriverDocumentType.vehicleRegistration,
          title: DriverDocumentType.getTitle(
              DriverDocumentType.vehicleRegistration),
          fileUrl: req.rcDocumentUrl,
          status: defaultStatus,
        ),
        DriverDocumentItem(
          id: DriverDocumentType.vehicleInsurance,
          title: DriverDocumentType.getTitle(DriverDocumentType.vehicleInsurance),
          fileUrl: req.insuranceDocUrl,
          status: defaultStatus,
        ),
        DriverDocumentItem(
          id: DriverDocumentType.policeCheck,
          title: DriverDocumentType.getTitle(DriverDocumentType.policeCheck),
          fileUrl: req.policeCheckUrl,
          status: defaultStatus,
        ),
      ];
    } else {
      for (final reqKey in DriverDocumentType.allDocIds) {
        if (!docs.any((d) => d.id == reqKey || d.docType == reqKey)) {
          docs.add(
            DriverDocumentItem(
              id: reqKey,
              title: DriverDocumentType.getTitle(reqKey),
              fileUrl: '',
              status: 'pending',
            ),
          );
        }
      }
    }
    _localDocs = docs;
  }

  void _updateDocStatus(String docId, String newStatus, [String? rejectionReason]) {
    setState(() {
      final idx =
          _localDocs.indexWhere((d) => d.id == docId || d.docType == docId);
      if (idx != -1) {
        final old = _localDocs[idx];
        _localDocs[idx] = old.copyWith(
          status: newStatus.toLowerCase(),
          rejectionReason:
              newStatus.toLowerCase() == 'rejected' ? rejectionReason : null,
          verifiedAt:
              newStatus.toLowerCase() == 'verified' ? DateTime.now() : null,
          verifiedBy: newStatus.toLowerCase() == 'verified' ? 'admin' : null,
        );
      }
    });
  }

  Future<void> _onSaveChanges(
    BuildContext context,
    DriverDocumentRequestModel req,
    DriverDocumentController driverCtrl,
  ) async {
    setState(() => _isSaving = true);
    final driverId = req.driverId;
    final docsToSave = List<DriverDocumentItem>.from(_localDocs);

    // 1. Close modal FIRST (following strict project rule)
    _closeModal(context);

    // 2. Perform save in controller
    final success = await driverCtrl.saveKycReview(
      driverId: driverId,
      documents: docsToSave,
    );

    // 3. Show message AFTER modal is closed
    if (success) {
      AppSnackBar.success(
        message:
            'KYC review updates for ${req.driverName} saved successfully.',
      );
    }
  }

  Widget _buildResultingStatusBadge() {
    final rejectedDocs = _localDocs.where((d) => d.isRejected).toList();
    final verifiedDocs = _localDocs.where((d) => d.isVerified).toList();
    final requiredTotal = DriverDocumentType.requiredDocIds.length;
    final allRequiredVerified = DriverDocumentType.requiredDocIds.every((key) {
      final d = _localDocs
          .firstWhereOrNull((x) => x.id == key || x.docType == key);
      return d != null && d.isVerified;
    });

    if (rejectedDocs.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.gpp_bad_rounded,
                color: Color(0xFFDC2626), size: 18),
            const SizedBox(width: 8),
            Text(
              'Resulting Status: Rejected (${rejectedDocs.length} ${rejectedDocs.length == 1 ? "document" : "documents"} rejected)',
              style: const TextStyle(
                color: Color(0xFFB91C1C),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (allRequiredVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.verified_user_rounded,
                color: Color(0xFF16A34A), size: 18),
            SizedBox(width: 8),
            Text(
              'Resulting Status: Verified (All KYC requirements approved)',
              style: TextStyle(
                color: Color(0xFF15803D),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.hourglass_top_rounded,
              color: Color(0xFFD97706), size: 18),
          const SizedBox(width: 8),
          Text(
            'Resulting Status: Pending (${verifiedDocs.length}/$requiredTotal verified)',
            style: const TextStyle(
              color: Color(0xFFB45309),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driverCtrl = Get.find<DriverDocumentController>();

    return Obx(() {
      final current = driverCtrl.selectedRequest.value;
      if (current != null) {
        _cachedReq = current;
      }
      final req = _cachedReq;
      if (req == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && Get.isDialogOpen == true) {
            Get.back();
          }
        });
        return const SizedBox.shrink();
      }
      _initLocalDocs(req);

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Container(
          width: 960,
          constraints: const BoxConstraints(maxHeight: 860),
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              req.driverName,
                              style: AppTextStyle.text20Medium.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildDriverStatusBadge(req.status),
                            const SizedBox(width: 8),
                            // Online status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: req.isOnline
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: req.isOnline
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFF94A3B8),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    req.isOnline ? 'Online' : 'Offline',
                                    style: TextStyle(
                                      color: req.isOnline
                                          ? const Color(0xFF15803D)
                                          : const Color(0xFF64748B),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Driver UID: ${req.driverId} • Rating: ${req.driverRating} ★ (${req.driverTripsCompleted} rides) • Submitted: ${req.formattedSubmittedDate}',
                          style: AppTextStyle.text12MediumOrSmall.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Get.dialog(EditUserProfileDialog.fromDriver(driver: req));
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: Color(0xFF2563EB),
                    ),
                    label: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      side: const BorderSide(color: Color(0xFFBFDBFE)),
                      backgroundColor: const Color(0xFFEFF6FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _closeModal(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                      size: 26,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 18),

              // 2. Driver & Vehicle Information (Section 3.1)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      title: 'Driver Details',
                      icon: Icons.person_rounded,
                      onEdit: () {
                        Get.dialog(
                            EditUserProfileDialog.fromDriver(driver: req));
                      },
                      items: [
                        {'label': 'Full Name', 'value': req.driverName},
                        {
                          'label': 'Phone Number',
                          'value': req.driverPhone.isNotEmpty
                              ? req.driverPhone
                              : 'Not provided',
                        },
                        {'label': 'Email Address', 'value': req.driverEmail},
                        {'label': 'Active Role', 'value': 'Driver'},
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      title: 'Vehicle Details',
                      icon: Icons.directions_car_filled_rounded,
                      onEdit: () {
                        Get.dialog(
                            EditUserProfileDialog.fromDriver(driver: req));
                      },
                      items: [
                        {
                          'label': 'Make & Model',
                          'value': () {
                            final makeModel =
                                '${req.vehicleMake} ${req.vehicleModel}'.trim();
                            return makeModel.isNotEmpty
                                ? makeModel
                                : 'Not provided';
                          }(),
                        },
                        {
                          'label': 'License Plate',
                          'value': req.vehiclePlate.isNotEmpty
                              ? req.vehiclePlate
                              : 'Pending',
                        },
                        {
                          'label': 'Color',
                          'value': req.vehicleColor.isNotEmpty
                              ? req.vehicleColor
                              : 'Not provided',
                        },
                        {
                          'label': 'Passenger Seats',
                          'value':
                              '${req.passengerSeats} Seats (${req.vehicleType})',
                        },
                      ],
                    ),
                  ),
                ],
              ),

              if (req.rejectionReason != null &&
                  req.rejectionReason!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFDC2626),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Previous Rejection Reason: ${req.rejectionReason}',
                          style: const TextStyle(
                            color: Color(0xFFB91C1C),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DOCUMENT REVIEW & VERIFICATION',
                    style: AppTextStyle.text12MediumOrSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'Verified: ${_localDocs.where((d) => d.isVerified).length} / ${_localDocs.length} Documents',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 3. Document Cards List (Section 3.2: users/{userId}/docs subcollection)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Render grid of documents
                      _buildDocumentGrid(context, req, driverCtrl),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 18),

              // 4. Action Footer: Resulting status indicator, Cancel and Save buttons
              Row(
                children: [
                  _buildResultingStatusBadge(),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => _closeModal(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.text14Medium.copyWith(
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () => _onSaveChanges(context, req, driverCtrl),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                    label: Text(
                      _isSaving ? 'Saving...' : 'Save',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDocumentGrid(
    BuildContext context,
    DriverDocumentRequestModel req,
    DriverDocumentController driverCtrl,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;
        const spacing = 16.0;
        final itemWidth =
            (constraints.maxWidth - ((crossAxisCount - 1) * spacing)) /
            crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _localDocs.map((doc) {
            return SizedBox(
              width: itemWidth,
              child: _buildDocCard(context, doc, driverCtrl),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDocCard(
    BuildContext context,
    DriverDocumentItem doc,
    DriverDocumentController driverCtrl,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      _getDocIcon(doc.docType),
                      color: const Color(0xFF2563EB),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        doc.displayTitle,
                        style: AppTextStyle.text14Medium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDocStatusBadge(doc.status),
            ],
          ),
          const SizedBox(height: 12),

          // Document Image Preview
          _buildDocPreviewCard(
            label: doc.displayTitle,
            imageUrl: doc.fileUrl,
            subLabel: 'Click to zoom document',
          ),
          if (doc.isRejected) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.cancel_outlined,
                      color: Color(0xFFDC2626),
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'REJECTION REASON (SAVED TO DB & SHOWN ON APP)',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF991B1B),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          (doc.rejectionReason != null &&
                                  doc.rejectionReason!.trim().isNotEmpty)
                              ? doc.rejectionReason!
                              : 'No specific reason specified by admin.',
                          style: const TextStyle(
                            color: Color(0xFFB91C1C),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Individual Action Buttons (Update single doc status in local state)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!doc.isVerified)
                OutlinedButton.icon(
                  onPressed: () => _updateDocStatus(doc.docType, 'verified'),
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF16A34A),
                    size: 16,
                  ),
                  label: Text(
                    doc.isRejected ? 'Verify Instead' : 'Verify',
                    style: const TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    side: const BorderSide(color: Color(0xFF86EFAC)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              if (!doc.isVerified && !doc.isRejected) const SizedBox(width: 8),
              if (!doc.isRejected)
                OutlinedButton.icon(
                  onPressed: () => _showRejectDocumentDialog(
                    context,
                    driverCtrl,
                    doc,
                  ),
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: Color(0xFFDC2626),
                    size: 16,
                  ),
                  label: const Text(
                    'Reject',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              if (doc.isRejected) ...[
                OutlinedButton.icon(
                  onPressed: () => _showRejectDocumentDialog(
                    context,
                    driverCtrl,
                    doc,
                    initialReason: doc.rejectionReason,
                  ),
                  icon: const Icon(
                    Icons.edit_note_rounded,
                    color: Color(0xFFDC2626),
                    size: 16,
                  ),
                  label: const Text(
                    'Edit Reason',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
              if (doc.isVerified || doc.isRejected) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _updateDocStatus(doc.docType, 'pending'),
                  icon: const Icon(
                    Icons.restart_alt_rounded,
                    color: Color(0xFF64748B),
                    size: 14,
                  ),
                  label: const Text(
                    'Reset',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  IconData _getDocIcon(String docType) {
    final lower = docType.toLowerCase();
    if (lower.contains('licence') || lower.contains('license')) {
      return Icons.badge_rounded;
    }
    if (lower.contains('registration') || lower == 'rc') {
      return Icons.directions_car_rounded;
    }
    if (lower.contains('insurance')) {
      return Icons.verified_user_rounded;
    }
    if (lower.contains('police')) {
      return Icons.local_police_rounded;
    }
    return Icons.description_rounded;
  }

  Widget _buildDocPreviewCard({
    required String label,
    required String imageUrl,
    required String subLabel,
  }) {
    if (imageUrl.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFCBD5E1),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFF94A3B8),
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              'No file attached',
              style: AppTextStyle.text12MediumOrSmall.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () {
        ImageZoomDialog.show(
          title: label,
          imageUrl: imageUrl,
          subtitle: subLabel,
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SmartDocImage(
                imageUrl: imageUrl,
                label: label,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                showOpenButton: true,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Map<String, String>> items,
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: const Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: AppTextStyle.text14Medium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              if (onEdit != null)
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.edit_outlined,
                            size: 13, color: Color(0xFF2563EB)),
                        SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Text(
                    '${item['label']}: ',
                    style: AppTextStyle.text12MediumOrSmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item['value'] ?? '',
                      style: AppTextStyle.text12MediumOrSmall.copyWith(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStatusBadge(String status) {
    Color bg = const Color(0xFFFEF3C7);
    Color fg = const Color(0xFFD97706);
    String label = status.toUpperCase();

    if (status.toLowerCase() == 'verified') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
      label = 'VERIFIED';
    } else if (status.toLowerCase() == 'rejected') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
      label = 'REJECTED';
    } else if (status.toLowerCase() == 'unsubmitted') {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
      label = 'NO DOCS';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDocStatusBadge(String status) {
    Color bg = const Color(0xFFFEF3C7);
    Color fg = const Color(0xFFD97706);
    String label = 'PENDING';

    if (status.toLowerCase() == 'verified') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
      label = 'VERIFIED';
    } else if (status.toLowerCase() == 'rejected') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
      label = 'REJECTED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showRejectDocumentDialog(
    BuildContext context,
    DriverDocumentController driverCtrl,
    DriverDocumentItem doc, {
    String? initialReason,
  }) {
    final reasonController = TextEditingController(text: initialReason ?? '');
    final selectedChip = RxString(
      driverCtrl.predefinedRejectionReasons.contains(initialReason)
          ? initialReason!
          : '',
    );

    Get.dialog(
      Builder(
        builder: (dialogCtx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.cancel_outlined,
                      color: Color(0xFFDC2626),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reject Document',
                          style: AppTextStyle.text18Semibold.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          doc.displayTitle,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (Navigator.of(dialogCtx).canPop()) {
                        Navigator.of(dialogCtx).pop();
                      } else {
                        Get.back();
                      }
                    },
                    icon: const Icon(Icons.close,
                        size: 20, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Please specify the reason why this document is rejected. This message will be saved to the database and shown to the driver in the app.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Quick preset chips
              const Text(
                'Quick Select Reason',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  'Image is blurry or unreadable',
                  'Document has expired',
                  'Details do not match profile',
                  'Document is cropped / incomplete',
                  'Wrong document type uploaded',
                ].map((reason) {
                  return Obx(() {
                    final isSel = selectedChip.value == reason;
                    return InkWell(
                      onTap: () {
                        selectedChip.value = reason;
                        reasonController.text = reason;
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSel
                              ? const Color(0xFFDC2626)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel
                                ? const Color(0xFFDC2626)
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Text(
                          reason,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isSel ? FontWeight.bold : FontWeight.w500,
                            color:
                                isSel ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),

              const SizedBox(height: 16),
              const Text(
                'Rejection Message (Text Box) *',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: reasonController,
                maxLines: 3,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText:
                      'e.g. Please upload a clearer photo where your full name, licence number, and expiry date are visible...',
                  hintStyle:
                      const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFDC2626)),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      if (Navigator.of(dialogCtx).canPop()) {
                        Navigator.of(dialogCtx).pop();
                      } else {
                        Get.back();
                      }
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final reason = reasonController.text.trim();
                      if (reason.isEmpty) {
                        AppSnackBar.error(
                          message: 'Please enter or select a rejection reason',
                        );
                        return;
                      }
                      if (Navigator.of(dialogCtx).canPop()) {
                        Navigator.of(dialogCtx).pop();
                      } else {
                        Get.back();
                      }
                      _updateDocStatus(
                        doc.docType,
                        'rejected',
                        reason,
                      );
                    },
                    icon: const Icon(Icons.cancel_outlined,
                        size: 16, color: Colors.white),
                    label: const Text(
                      'Confirm Rejection',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
