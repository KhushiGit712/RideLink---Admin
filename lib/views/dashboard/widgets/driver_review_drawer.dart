import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/dashboard/controllers/driver_document_controller.dart';
import 'package:ridelink_admin/views/dashboard/widgets/image_zoom_dialog.dart';
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Container(
          width: 900,
          constraints: const BoxConstraints(maxHeight: 820),
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

              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 18),

              // Driver & Vehicle Information (Section 3.2.1)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      title: 'Driver Details',
                      icon: Icons.person_rounded,
                      items: [
                        {'label': 'Full Name', 'value': req.driverName},
                        {'label': 'Phone Number', 'value': req.driverPhone},
                        {'label': 'Email Address', 'value': req.driverEmail},
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard(
                      title: 'Vehicle Details',
                      icon: Icons.directions_car_filled_rounded,
                      items: [
                        {
                          'label': 'Make & Model',
                          'value': '${req.vehicleMake} ${req.vehicleModel} (${req.vehicleYear})',
                        },
                        {'label': 'License Plate', 'value': req.vehiclePlate},
                        {'label': 'Passenger Seats', 'value': '${req.passengerSeats} Seats (${req.vehicleType})'},
                      ],
                    ),
                  ),
                ],
              ),

              if (req.rejectionReason != null && req.rejectionReason!.isNotEmpty) ...[
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
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 20),
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
              Text(
                'DOCUMENT REVIEW & VERIFICATION (LICENSE, RC, INSURANCE)',
                style: AppTextStyle.text12MediumOrSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF475569),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),

              // Document Viewer Cards (Section 3.2.2)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Driver's License: Front & Back
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.badge_rounded, color: Color(0xFF2563EB), size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  "Driver's License (Front & Back)",
                                  style: AppTextStyle.text16Medium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Number: ${req.licenseNumber}',
                                    style: const TextStyle(
                                      color: Color(0xFF2563EB),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDocPreviewCard(
                                    label: "License Front Preview",
                                    imageUrl: req.licenseFrontUrl,
                                    subLabel: 'Click to zoom front image',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDocPreviewCard(
                                    label: "License Back Preview",
                                    imageUrl: req.licenseBackUrl,
                                    subLabel: 'Click to zoom back image',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // RC Document & Vehicle Insurance Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Registration Certificate (RC)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.file_copy_rounded, color: Color(0xFF0284C7), size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Vehicle Registration (RC)',
                                          style: AppTextStyle.text14Medium.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Plate: ${req.vehiclePlate}',
                                    style: AppTextStyle.text12MediumOrSmall.copyWith(
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildDocPreviewCard(
                                    label: 'Registration Certificate',
                                    imageUrl: req.rcDocumentUrl,
                                    subLabel: 'RC document preview',
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Vehicle Insurance
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Vehicle Insurance',
                                          style: AppTextStyle.text14Medium.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Exp: ${req.insuranceExpiryDate}',
                                          style: const TextStyle(
                                            color: Color(0xFF15803D),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Policy expiry: ${req.insuranceExpiryDate}',
                                    style: AppTextStyle.text12MediumOrSmall.copyWith(
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildDocPreviewCard(
                                    label: 'Insurance Policy',
                                    imageUrl: req.insuranceDocUrl,
                                    subLabel: 'Insurance policy document preview',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 18),

              // Admin Action Buttons (Section 3.2.3)
              Row(
                children: [
                  // Reject Application Button
                  OutlinedButton.icon(
                    onPressed: () => _showRejectionDialog(context, driverCtrl, req.id),
                    icon: const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626)),
                    label: Text(
                      'Reject Application',
                      style: AppTextStyle.text14Medium.copyWith(
                        color: const Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => driverCtrl.closeReviewModal(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  // Approve Driver Button
                  SizedBox(
                    width: 220,
                    child: AppButton(
                      label: 'Approve Driver',
                      backgroundColor: const Color(0xFF16A34A),
                      onPressed: () async {
                        await driverCtrl.approveRequest(req.id);
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

  Widget _buildDocPreviewCard({
    required String label,
    required String imageUrl,
    required String subLabel,
  }) {
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
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.description_outlined, color: Color(0xFF94A3B8), size: 32),
                      const SizedBox(height: 4),
                      Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
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
                        child: const Icon(Icons.zoom_in, color: Colors.white, size: 14),
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

  void _showRejectionDialog(
    BuildContext context,
    DriverDocumentController driverCtrl,
    String requestId,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 480,
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
                    'Reject Application',
                    style: AppTextStyle.text18Semibold.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Select a reason for rejection. This notification will be delivered directly to the driver with instructions to re-upload.',
                style: AppTextStyle.text14Medium.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Rejection Reason *',
                style: AppTextStyle.text14Medium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.stroke),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: driverCtrl.selectedPredefinedReason.value,
                      isExpanded: true,
                      items: driverCtrl.predefinedRejectionReasons.map((reason) {
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
              Text(
                'Optional Note for Driver',
                style: AppTextStyle.text14Medium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: driverCtrl.rejectionReasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g. Please upload a clear photo of your driver license front and back...',
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
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    onPressed: () async {
                      final customNote =
                          driverCtrl.rejectionReasonController.text.trim();
                      final reason = customNote.isNotEmpty
                          ? '${driverCtrl.selectedPredefinedReason.value} - $customNote'
                          : driverCtrl.selectedPredefinedReason.value;

                      Get.back(); // close reason dialog
                      await driverCtrl.rejectRequest(requestId, reason);
                      driverCtrl.closeReviewModal(); // close review modal
                    },
                    child: const Text(
                      'Confirm Rejection',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
