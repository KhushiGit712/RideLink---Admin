import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/dashboard/controllers/driver_document_controller.dart';
import 'package:ridelink_admin/widgets/app_button.dart';

class DriverReviewDrawer extends StatelessWidget {
  const DriverReviewDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final driverCtrl = Get.find<DriverDocumentController>();

    return Obx(() {
      final req = driverCtrl.selectedRequest.value;
      if (req == null) return const SizedBox.shrink();

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Container(
          width: 820,
          constraints: const BoxConstraints(maxHeight: 780),
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(req.profileImageUrl),
                    backgroundColor: const Color(0xFFE2E8F0),
                  ),
                  const SizedBox(width: 16),
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
                            _buildStatusBadge(req.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Driver ID: ${req.driverId} • Submitted: ${req.formattedSubmittedDate}',
                          style: AppTextStyle.text12MediumOrSmall.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => driverCtrl.closeReviewModal(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                      size: 26,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 20),

              // Driver & Vehicle Overview Info Cards
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      title: 'Contact Details',
                      icon: Icons.contact_phone_rounded,
                      items: [
                        {'label': 'Email Address', 'value': req.driverEmail},
                        {'label': 'Phone Number', 'value': req.driverPhone},
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      title: 'Vehicle Information',
                      icon: Icons.directions_car_filled_rounded,
                      items: [
                        {
                          'label': 'Vehicle Model',
                          'value': '${req.vehicleModel} (${req.vehicleType})',
                        },
                        {
                          'label': 'License Plate',
                          'value': req.vehiclePlateNumber,
                        },
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Text(
                'SUBMITTED VERIFICATION DOCUMENTS (${req.documents.length})',
                style: AppTextStyle.text12MediumOrSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF475569),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),

              // Scrollable Documents List
              Expanded(
                child: ListView.separated(
                  itemCount: req.documents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final doc = req.documents[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: doc.status == 'Approved'
                              ? const Color(0xFF86EFAC)
                              : doc.status == 'Rejected'
                              ? const Color(0xFFFCA5A5)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Thumbnail Preview Box
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 80,
                              height: 60,
                              color: const Color(0xFFCBD5E1),
                              child: Stack(
                                children: [
                                  Image.network(
                                    doc.fileUrl,
                                    width: 80,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(
                                        Icons.description_rounded,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    bottom: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.zoom_in,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      doc.docType,
                                      style: AppTextStyle.text16Medium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _buildDocStatusBadge(doc.status),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Doc #: ${doc.documentNumber} • Exp: ${doc.expiryDate}',
                                  style: AppTextStyle.text12MediumOrSmall
                                      .copyWith(color: const Color(0xFF64748B)),
                                ),
                                if (doc.rejectionNote != null &&
                                    doc.rejectionNote!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Note: ${doc.rejectionNote}',
                                    style: AppTextStyle.text12MediumOrSmall
                                        .copyWith(
                                          color: const Color(0xFFDC2626),
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Individual Approve / Reject Buttons
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.check_circle_rounded,
                                  color: doc.status == 'Approved'
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFF94A3B8),
                                  size: 28,
                                ),
                                tooltip: 'Approve Document',
                                onPressed: () {
                                  driverCtrl.toggleDocItemStatus(
                                    doc.id,
                                    'Approved',
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.cancel_rounded,
                                  color: doc.status == 'Rejected'
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF94A3B8),
                                  size: 28,
                                ),
                                tooltip: 'Reject Document',
                                onPressed: () {
                                  driverCtrl.toggleDocItemStatus(
                                    doc.id,
                                    'Rejected',
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 20),

              // Overall Action Bar (Approve All or Reject Request)
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () =>
                        _showRejectionDialog(context, driverCtrl, req.id),
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: Color(0xFFDC2626),
                    ),
                    label: Text(
                      'Reject Application',
                      style: AppTextStyle.text14Medium.copyWith(
                        color: const Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => driverCtrl.closeReviewModal(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      'Close',
                      style: AppTextStyle.text14Medium.copyWith(
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 220,
                    child: AppButton(
                      label: 'Approve & Verify Driver',
                      backgroundColor: const Color(0xFF16A34A),
                      onPressed: () {
                        driverCtrl.approveRequest(req.id);
                        driverCtrl.closeReviewModal();
                      },
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

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Map<String, String>> items,
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
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
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

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFFEF3C7);
    Color fg = const Color(0xFFD97706);
    if (status == 'Approved') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (status == 'Rejected') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDocStatusBadge(String status) {
    Color bg = const Color(0xFFF1F5F9);
    Color fg = const Color(0xFF64748B);

    if (status == 'Approved') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (status == 'Rejected') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showRejectionDialog(
    BuildContext context,
    DriverDocumentController driverCtrl,
    String requestId,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFDC2626),
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Reject Verification Request',
                    style: AppTextStyle.text18Semibold.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Please select or enter the primary reason for rejecting this driver verification application.',
                style: AppTextStyle.text14Medium.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Rejection Reason',
                style: AppTextStyle.text14Medium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.stroke),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: driverCtrl.selectedPredefinedReason.value,
                      isExpanded: true,
                      items: driverCtrl.predefinedRejectionReasons.map((
                        reason,
                      ) {
                        return DropdownMenuItem(
                          value: reason,
                          child: Text(reason),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          driverCtrl.selectedPredefinedReason.value = val;
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: driverCtrl.rejectionReasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'Add optional additional feedback notes for the driver...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                    ),
                    onPressed: () {
                      final customNote = driverCtrl
                          .rejectionReasonController
                          .text
                          .trim();
                      final reason = customNote.isNotEmpty
                          ? '${driverCtrl.selectedPredefinedReason.value} - $customNote'
                          : driverCtrl.selectedPredefinedReason.value;

                      driverCtrl.rejectRequest(requestId, reason);
                      Get.back(); // close reason dialog
                      driverCtrl.closeReviewModal(); // close review modal
                    },
                    child: const Text(
                      'Confirm Rejection',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
