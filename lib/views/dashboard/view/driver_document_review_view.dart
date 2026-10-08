import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/dashboard/controllers/driver_document_controller.dart';
import 'package:ridelink_admin/views/dashboard/widgets/driver_review_drawer.dart';

class DriverDocumentReviewView extends GetView<DriverDocumentController> {
  const DriverDocumentReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Stats Banner
          Obx(
            () => Row(
              children: [
                _buildMetricTile(
                  title: 'Pending Verification',
                  value: '${controller.pendingCount}',
                  icon: Icons.hourglass_top_rounded,
                  color: const Color(0xFFEA580C),
                  bgColor: const Color(0xFFFFF7ED),
                ),
                const SizedBox(width: 16),
                _buildMetricTile(
                  title: 'Verified Drivers',
                  value: '${controller.approvedCount}',
                  icon: Icons.verified_user_rounded,
                  color: const Color(0xFF16A34A),
                  bgColor: const Color(0xFFF0FDF4),
                ),
                const SizedBox(width: 16),
                _buildMetricTile(
                  title: 'Rejected Applications',
                  value: '${controller.rejectedCount}',
                  icon: Icons.gpp_bad_rounded,
                  color: const Color(0xFFDC2626),
                  bgColor: const Color(0xFFFEF2F2),
                ),
                const SizedBox(width: 16),
                _buildMetricTile(
                  title: 'All Drivers Registered',
                  value: '${controller.totalCount}',
                  icon: Icons.directions_car_filled_rounded,
                  color: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Filters & Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                // Filter Tabs
                Obx(
                  () => Row(
                    children: [
                      _buildTabChip(
                        'Pending',
                        'Pending (${controller.pendingCount})',
                      ),
                      _buildTabChip(
                        'Verified',
                        'Verified (${controller.verifiedCount})',
                      ),
                      _buildTabChip(
                        'Rejected',
                        'Rejected (${controller.rejectedCount})',
                      ),
                      _buildTabChip(
                        'Unsubmitted',
                        'Missing Docs (${controller.unsubmittedCount})',
                      ),
                      _buildTabChip('All', 'All (${controller.totalCount})'),
                    ],
                  ),
                ),

                const Spacer(),

                // Search Field
                SizedBox(
                  width: 320,
                  height: 44,
                  child: TextField(
                    onChanged: (val) => controller.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Search driver, phone, plate #...',
                      hintStyle: AppTextStyle.text12MediumOrSmall.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF94A3B8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Main Table of Requests
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = controller.filteredRequests;

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 48,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No driver applications found in this category',
                          style: AppTextStyle.text16Medium.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Drivers submit their KYC verification documents directly through the RideLink mobile app.',
                          style: AppTextStyle.text12MediumOrSmall.copyWith(
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 22,
                    horizontalMargin: 20,
                    headingRowHeight: 52,
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFFF8FAFC),
                    ),
                    columns: const [
                      DataColumn(
                        label: Text('DRIVER NAME', style: _headerStyle),
                      ),
                      DataColumn(label: Text('EMAIL', style: _headerStyle)),
                      DataColumn(label: Text('PHONE', style: _headerStyle)),
                      DataColumn(
                        label: Text('VEHICLE DETAILS', style: _headerStyle),
                      ),
                      DataColumn(
                        label: Text('SUBMISSION DATE', style: _headerStyle),
                      ),
                      DataColumn(label: Text('STATUS', style: _headerStyle)),
                      DataColumn(label: Text('ACTION', style: _headerStyle)),
                    ],
                    rows: list.map((req) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  req.driverName,
                                  style: AppTextStyle.text14Medium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  'ID: ${req.driverId}',
                                  style: AppTextStyle.text12MediumOrSmall
                                      .copyWith(
                                        color: const Color(0xFF64748B),
                                        fontSize: 11,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              req.driverEmail,
                              style: AppTextStyle.text14Medium.copyWith(
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              req.driverPhone,
                              style: AppTextStyle.text14Medium.copyWith(
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ),
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${req.vehicleMake} ${req.vehicleModel}',
                                  style: AppTextStyle.text14Medium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  'Plate: ${req.vehiclePlate} (${req.passengerSeats} seats)',
                                  style: AppTextStyle.text12MediumOrSmall
                                      .copyWith(
                                        color: const Color(0xFF2563EB),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              req.formattedSubmittedDate,
                              style: AppTextStyle.text12MediumOrSmall.copyWith(
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                          DataCell(_buildStatusChip(req.status)),
                          DataCell(
                            ElevatedButton.icon(
                              onPressed: () {
                                controller.selectRequestForReview(req);
                                Get.dialog(const DriverReviewDrawer());
                              },
                              icon: const Icon(
                                Icons.rate_review_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(
                                req.isUnsubmitted ? 'Inspect' : 'Review',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: req.isPending
                                    ? AppColors.primaryColor
                                    : (req.isApproved
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFF475569)),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: Color(0xFF475569),
    letterSpacing: 0.8,
  );

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyle.text20Medium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  title,
                  style: AppTextStyle.text12MediumOrSmall.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(String value, String label) {
    final isSelected = controller.selectedStatusTab.value == value;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () => controller.setStatusTab(value),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0F172A)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF475569),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg = const Color(0xFFFEF3C7);
    Color fg = const Color(0xFFD97706);

    if (status == 'Verified' || status == 'Approved') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (status == 'Rejected') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
    } else if (status == 'Unsubmitted') {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status == 'Unsubmitted' ? 'NO DOCS' : status.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
