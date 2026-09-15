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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Driver Document Review Requests',
                    style: AppTextStyle.text20Medium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review submitted driver licenses, vehicle registration, insurance, and identity proofs.',
                    style: AppTextStyle.text12MediumOrSmall.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: controller.pendingCount > 0
                          ? const Color(0xFFFFF7ED)
                          : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: controller.pendingCount > 0
                            ? const Color(0xFFFFD8A8)
                            : const Color(0xFF86EFAC),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.pending_actions_rounded,
                          color: controller.pendingCount > 0
                              ? const Color(0xFFEA580C)
                              : const Color(0xFF16A34A),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${controller.pendingCount} Pending Reviews',
                          style: TextStyle(
                            color: controller.pendingCount > 0
                                ? const Color(0xFFC2410C)
                                : const Color(0xFF15803D),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),

          const SizedBox(height: 24),

          // Overview Stats Banner
          Obx(() => Row(
                children: [
                  _buildMetricTile(
                    title: 'Pending Verifications',
                    value: '${controller.pendingCount}',
                    icon: Icons.hourglass_top_rounded,
                    color: const Color(0xFFEA580C),
                    bgColor: const Color(0xFFFFF7ED),
                  ),
                  const SizedBox(width: 16),
                  _buildMetricTile(
                    title: 'Approved Drivers',
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
                ],
              )),

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
                // Status Tabs
                Obx(() => Row(
                      children: [
                        _buildTabChip('Pending', 'Pending (${controller.pendingCount})'),
                        _buildTabChip('All', 'All Requests (${controller.totalCount})'),
                        _buildTabChip('Approved', 'Approved (${controller.approvedCount})'),
                        _buildTabChip('Rejected', 'Rejected (${controller.rejectedCount})'),
                      ],
                    )),

                const Spacer(),

                // Search Field
                SizedBox(
                  width: 320,
                  height: 44,
                  child: TextField(
                    onChanged: (val) => controller.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Search driver name, phone, plate #...',
                      hintStyle: AppTextStyle.text12MediumOrSmall.copyWith(color: const Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
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
                final list = controller.filteredRequests;

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified_rounded, size: 48, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        Text(
                          'No driver verification requests found',
                          style: AppTextStyle.text16Medium.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try changing the status tab or search keywords.',
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
                    columnSpacing: 20,
                    horizontalMargin: 20,
                    headingRowHeight: 52,
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    columns: const [
                      DataColumn(label: Text('DRIVER INFO', style: _headerStyle)),
                      DataColumn(label: Text('CONTACT', style: _headerStyle)),
                      DataColumn(label: Text('VEHICLE DETAILS', style: _headerStyle)),
                      DataColumn(label: Text('SUBMITTED DATE', style: _headerStyle)),
                      DataColumn(label: Text('DOCUMENTS', style: _headerStyle)),
                      DataColumn(label: Text('STATUS', style: _headerStyle)),
                      DataColumn(label: Text('ACTION', style: _headerStyle)),
                    ],
                    rows: list.map((req) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(req.profileImageUrl),
                                  backgroundColor: const Color(0xFFCBD5E1),
                                ),
                                const SizedBox(width: 12),
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
                                      style: AppTextStyle.text12MediumOrSmall.copyWith(
                                        color: const Color(0xFF64748B),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  req.driverEmail,
                                  style: AppTextStyle.text14Medium.copyWith(
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                                Text(
                                  req.driverPhone,
                                  style: AppTextStyle.text12MediumOrSmall.copyWith(
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  req.vehicleModel,
                                  style: AppTextStyle.text14Medium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  'Plate: ${req.vehiclePlateNumber} (${req.vehicleType})',
                                  style: AppTextStyle.text12MediumOrSmall.copyWith(
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
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.file_present_rounded, size: 14, color: Color(0xFF2563EB)),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${req.documents.length} Submitted',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
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
                              icon: const Icon(Icons.rate_review_rounded, size: 16, color: Colors.white),
                              label: const Text('Review Docs', style: TextStyle(color: Colors.white, fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: req.status == 'Pending'
                                    ? AppColors.primaryColor
                                    : const Color(0xFF475569),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
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
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
