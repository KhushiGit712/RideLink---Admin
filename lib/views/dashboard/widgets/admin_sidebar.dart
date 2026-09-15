import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/auth_flow/auth_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/dashboard_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/driver_document_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/location_controller.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardCtrl = Get.find<DashboardController>();
    final driverCtrl = Get.isRegistered<DriverDocumentController>()
        ? Get.find<DriverDocumentController>()
        : null;
    final locCtrl = Get.isRegistered<LocationController>()
        ? Get.find<LocationController>()
        : null;
    final authCtrl = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : null;

    return Obx(() {
      final isCollapsed = dashboardCtrl.isSidebarCollapsed.value;
      final selectedIdx = dashboardCtrl.selectedIndex.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isCollapsed ? 76 : 260,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Premium Dark Slate background for sidebar
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(4, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // App Header / Logo
            Container(
              height: 70,
              padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 12 : 20),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.directions_car_filled_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  if (!isCollapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RideLink',
                            style: AppTextStyle.text16Medium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'ADMIN PORTAL',
                            style: AppTextStyle.text12MediumOrSmall.copyWith(
                              color: const Color(0xFF38BDF8),
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(color: Color(0xFF1E293B), height: 1),

            const SizedBox(height: 16),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  if (!isCollapsed) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 8),
                      child: Text(
                        'MAIN MENU',
                        style: AppTextStyle.text12MediumOrSmall.copyWith(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                  _buildMenuItem(
                    context: context,
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard Overview',
                    isSelected: selectedIdx == 0,
                    isCollapsed: isCollapsed,
                    onTap: () => dashboardCtrl.changeTab(0),
                  ),
                  const SizedBox(height: 6),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.location_on_rounded,
                    label: 'Locations',
                    badgeText: locCtrl != null ? '${locCtrl.totalCount}' : null,
                    badgeColor: const Color(0xFF3B82F6),
                    isSelected: selectedIdx == 1,
                    isCollapsed: isCollapsed,
                    onTap: () => dashboardCtrl.changeTab(1),
                  ),
                  const SizedBox(height: 6),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.assignment_ind_rounded,
                    label: 'Driver Verification',
                    badgeText: driverCtrl != null && driverCtrl.pendingCount > 0
                        ? '${driverCtrl.pendingCount}'
                        : null,
                    badgeColor: const Color(0xFFF97316),
                    isSelected: selectedIdx == 2,
                    isCollapsed: isCollapsed,
                    onTap: () => dashboardCtrl.changeTab(2),
                  ),
                  const SizedBox(height: 6),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    isSelected: selectedIdx == 3,
                    isCollapsed: isCollapsed,
                    onTap: () => dashboardCtrl.changeTab(3),
                  ),
                ],
              ),
            ),

            // Bottom Profile / Collapse Bar
            const Divider(color: Color(0xFF1E293B), height: 1),
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  if (!isCollapsed)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primaryColor,
                            child: Text(
                              'AD',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'System Admin',
                                  style: AppTextStyle.text14Medium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'admin@ridelink.com',
                                  style: AppTextStyle.text12MediumOrSmall.copyWith(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFEF4444),
                              size: 20,
                            ),
                            tooltip: 'Logout',
                            onPressed: () {
                              if (authCtrl != null) {
                                authCtrl.onLogout();
                              } else {
                                Get.find<AuthController>().onLogout();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => dashboardCtrl.toggleSidebar(),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCollapsed
                                ? Icons.chevron_right_rounded
                                : Icons.chevron_left_rounded,
                            color: const Color(0xFF94A3B8),
                          ),
                          if (!isCollapsed) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Collapse Sidebar',
                              style: AppTextStyle.text12MediumOrSmall.copyWith(
                                color: const Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool isCollapsed,
    required VoidCallback onTap,
    String? badgeText,
    Color? badgeColor,
  }) {
    return Tooltip(
      message: isCollapsed ? label : '',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment:
                  isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF94A3B8),
                  size: 22,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyle.text14Medium.copyWith(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFCBD5E1),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor ?? AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
