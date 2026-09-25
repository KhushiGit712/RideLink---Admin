import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/dashboard/controllers/location_controller.dart';
import 'package:ridelink_admin/views/dashboard/widgets/add_edit_location_dialog.dart';

class LocationManagementView extends GetView<LocationController> {
  const LocationManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header + Action Button (Section 5.1)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Allowed Locations & Service Areas',
                    style: AppTextStyle.text20Medium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Defines cities and operating corridors where RideLink operates. Rides outside active areas will be prevented.',
                    style: AppTextStyle.text12MediumOrSmall.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  controller.prepareAddLocation();
                  Get.dialog(const AddEditLocationDialog());
                },
                icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
                label: Text(
                  '+ Add New Location',
                  style: AppTextStyle.text14Medium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stat Overview Banner
          Obx(
            () => Row(
              children: [
                _buildStatCard(
                  title: 'Total Service Areas',
                  value: '${controller.totalCount}',
                  icon: Icons.public_rounded,
                  color: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  title: 'Active Operating Zones',
                  value: '${controller.activeCount}',
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF16A34A),
                  bgColor: const Color(0xFFF0FDF4),
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  title: 'Inactive / Expansion Areas',
                  value: '${controller.inactiveCount}',
                  icon: Icons.pause_circle_rounded,
                  color: const Color(0xFFEA580C),
                  bgColor: const Color(0xFFFFF7ED),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Controls & Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                // Search Input Field
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      onChanged: (val) => controller.setSearchQuery(val),
                      decoration: const InputDecoration(
                        hintText: 'Search city name, state, or location ID...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Status Filter Chips
                Obx(
                  () => Row(
                    children: ['All', 'Active', 'Inactive'].map((status) {
                      final isSelected =
                          controller.selectedStatusFilter.value == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (_) => controller.setStatusFilter(status),
                          selectedColor: const Color(0xFF2563EB),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Service Areas Table (Section 5.1)
          // Columns: City/Area Name, State/Region, Operating Radius, Center Coordinates, Status (Active/Inactive), Action (Edit/Delete)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Obx(() {
                final list = controller.filteredLocations;

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_off_rounded,
                          size: 48,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No service locations match your search criteria',
                          style: AppTextStyle.text16Medium.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try clearing filters or adding a new operating area',
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
                    columnSpacing: 24,
                    horizontalMargin: 20,
                    headingRowHeight: 52,
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFFF8FAFC),
                    ),
                    columns: const [
                      DataColumn(
                        label: Text('AREA ID', style: _headerStyle),
                      ),
                      DataColumn(
                        label: Text('CITY / AREA NAME', style: _headerStyle),
                      ),
                      DataColumn(
                        label: Text('STATE / REGION', style: _headerStyle),
                      ),
                      DataColumn(
                        label: Text('OPERATING RADIUS', style: _headerStyle),
                      ),
                      DataColumn(
                        label: Text('CENTER LAT & LNG', style: _headerStyle),
                      ),
                      DataColumn(label: Text('STATUS', style: _headerStyle)),
                      DataColumn(label: Text('ACTIONS', style: _headerStyle)),
                    ],
                    rows: list.map((loc) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              loc.id,
                              style: AppTextStyle.text14Medium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.location_city_rounded, color: Color(0xFF2563EB), size: 18),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  loc.cityName,
                                  style: AppTextStyle.text14Medium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              loc.state,
                              style: AppTextStyle.text14Medium.copyWith(
                                color: const Color(0xFF334155),
                                fontWeight: FontWeight.w500,
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
                                  const Icon(Icons.radar_rounded, size: 14, color: Color(0xFF2563EB)),
                                  const SizedBox(width: 6),
                                  Text(
                                    loc.radiusFormatted,
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
                          DataCell(
                            Row(
                              children: [
                                const Icon(
                                  Icons.my_location_rounded,
                                  size: 14,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  loc.coordinatesFormatted,
                                  style: AppTextStyle.text12MediumOrSmall
                                      .copyWith(
                                        color: const Color(0xFF475569),
                                        fontFamily: 'monospace',
                                      ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                Switch(
                                  value: loc.isActive,
                                  activeColor: const Color(0xFF2563EB),
                                  onChanged: (_) =>
                                      controller.toggleLocationStatus(loc.id),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  loc.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: loc.isActive
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_rounded,
                                    color: Color(0xFF2563EB),
                                    size: 20,
                                  ),
                                  tooltip: 'Edit Location',
                                  onPressed: () {
                                    controller.prepareEditLocation(loc);
                                    Get.dialog(const AddEditLocationDialog());
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 20,
                                  ),
                                  tooltip: 'Delete Location',
                                  onPressed: () =>
                                      _confirmDelete(context, loc.id, loc.cityName),
                                ),
                              ],
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

  Widget _buildStatCard({
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

  void _confirmDelete(BuildContext context, String id, String name) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Service Area'),
        content: Text(
          'Are you sure you want to delete "$name"? Rides will no longer be allowed in this corridor.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () {
              controller.deleteLocation(id);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
