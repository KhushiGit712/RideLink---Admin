import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/dashboard/controllers/dashboard_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/driver_document_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/location_controller.dart';

class OverviewTabView extends StatelessWidget {
  const OverviewTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardCtrl = Get.find<DashboardController>();
    final locCtrl = Get.find<LocationController>();
    final driverCtrl = Get.find<DriverDocumentController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Welcome Card
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.4)),
                        ),
                        child: Text(
                          'RIDELINK ADMIN CONTROL CENTER',
                          style: AppTextStyle.text12MediumOrSmall.copyWith(
                            color: const Color(0xFF38BDF8),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Manage Service Hubs & Review Driver Documents',
                        style: AppTextStyle.text20Medium.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Monitor location hubs, review submitted driver licenses, approve onboarded drivers, and configure platform settings.',
                        style: AppTextStyle.text14Medium.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => dashboardCtrl.changeTab(1),
                            icon: const Icon(Icons.location_on_rounded, color: Colors.white, size: 18),
                            label: const Text('Manage Locations', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          OutlinedButton.icon(
                            onPressed: () => dashboardCtrl.changeTab(2),
                            icon: const Icon(Icons.assignment_ind_rounded, color: Colors.white, size: 18),
                            label: const Text('Review Driver Requests', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              side: const BorderSide(color: Color(0xFF475569)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Color(0xFF38BDF8),
                    size: 80,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Quick Metric Cards
          Obx(() => Row(
                children: [
                  _buildQuickCard(
                    title: 'Service Locations',
                    value: '${locCtrl.totalCount}',
                    subtitle: '${locCtrl.activeCount} Active Hubs',
                    icon: Icons.location_city_rounded,
                    color: const Color(0xFF2563EB),
                    bgColor: const Color(0xFFEFF6FF),
                    onTap: () => dashboardCtrl.changeTab(1),
                  ),
                  const SizedBox(width: 16),
                  _buildQuickCard(
                    title: 'Pending Driver Reviews',
                    value: '${driverCtrl.pendingCount}',
                    subtitle: 'Requires admin document review',
                    icon: Icons.pending_actions_rounded,
                    color: const Color(0xFFEA580C),
                    bgColor: const Color(0xFFFFF7ED),
                    onTap: () => dashboardCtrl.changeTab(2),
                  ),
                  const SizedBox(width: 16),
                  _buildQuickCard(
                    title: 'Approved Drivers',
                    value: '${driverCtrl.approvedCount}',
                    subtitle: 'Active on platform',
                    icon: Icons.verified_user_rounded,
                    color: const Color(0xFF16A34A),
                    bgColor: const Color(0xFFF0FDF4),
                    onTap: () => dashboardCtrl.changeTab(2),
                  ),
                ],
              )),

          const SizedBox(height: 28),

          // Two Column Widgets: Locations Summary & Recent Driver Verification Requests
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Locations Preview Box
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.pin_drop_rounded, color: Color(0xFF2563EB)),
                              const SizedBox(width: 10),
                              Text(
                                'Active Locations Summary',
                                style: AppTextStyle.text16Medium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => dashboardCtrl.changeTab(1),
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        final locations = locCtrl.locations.take(4).toList();
                        return Column(
                          children: locations.map((loc) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.business_rounded, color: Color(0xFF2563EB), size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            loc.name,
                                            style: AppTextStyle.text14Medium.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                          Text(
                                            '${loc.city} • ${loc.type}',
                                            style: AppTextStyle.text12MediumOrSmall.copyWith(
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: loc.isActive
                                            ? const Color(0xFFDCFCE7)
                                            : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        loc.isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          color: loc.isActive
                                              ? const Color(0xFF15803D)
                                              : const Color(0xFF64748B),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // Column 2: Recent Driver Verification Activity
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.assignment_ind_rounded, color: Color(0xFFEA580C)),
                              const SizedBox(width: 10),
                              Text(
                                'Pending Driver Review Requests',
                                style: AppTextStyle.text16Medium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => dashboardCtrl.changeTab(2),
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        final reqs = driverCtrl.requests.take(4).toList();
                        return Column(
                          children: reqs.map((req) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage: NetworkImage(req.profileImageUrl),
                                      backgroundColor: const Color(0xFFCBD5E1),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
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
                                            '${req.vehicleModel} • ${req.documents.length} Docs',
                                            style: AppTextStyle.text12MediumOrSmall.copyWith(
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => dashboardCtrl.changeTab(2),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2563EB),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        minimumSize: Size.zero,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      child: const Text('Review', style: TextStyle(color: Colors.white, fontSize: 11)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: AppTextStyle.text20Medium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      title,
                      style: AppTextStyle.text14Medium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyle.text12MediumOrSmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
