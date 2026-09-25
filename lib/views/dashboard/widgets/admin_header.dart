import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/auth_flow/auth_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/dashboard_controller.dart';

class AdminHeader extends StatelessWidget implements PreferredSizeWidget {
  const AdminHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final dashboardCtrl = Get.find<DashboardController>();
    final authCtrl = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : null;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Title & Breadcrumb based on active tab
          Obx(() {
            final idx = dashboardCtrl.selectedIndex.value;
            String title = 'Dashboard Overview';
            String subtitle = 'Welcome back! Here is what is happening today.';

            if (idx == 1) {
              title = 'Driver KYC Verification';
              subtitle = 'Review and verify driver identity, license, and vehicle documents.';
            } else if (idx == 2) {
              title = 'Support System (Driver & Passenger Tickets)';
              subtitle = 'Manage helpdesk queries, ride issues, and user conversation threads.';
            } else if (idx == 3) {
              title = 'Allowed Locations & Service Areas';
              subtitle = 'Configure operating cities, center coordinates, and service radius.';
            } else if (idx == 4) {
              title = 'Community Management';
              subtitle = 'Manage registered user communities and ridership networks.';
            } else if (idx == 5) {
              title = 'System Settings';
              subtitle = 'Configure application preferences and administrator portal settings.';
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.text20Medium.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyle.text12MediumOrSmall.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            );
          }),

          const Spacer(),

          // Live System Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF86EFAC)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'System Online',
                  style: AppTextStyle.text12MediumOrSmall.copyWith(
                    color: const Color(0xFF15803D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Notification Bell Icon with Badge
          Obx(() {
            final count = dashboardCtrl.unreadNotifications;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF475569),
                    size: 24,
                  ),
                  onPressed: () {
                    Get.snackbar(
                      'Support Notifications',
                      count > 0
                          ? '$count open support inquiries pending admin reply.'
                          : 'All support inquiries and requests are resolved.',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.white,
                      colorText: Colors.black,
                    );
                  },
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),

          const SizedBox(width: 12),

          // User Profile Quick Card
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryColor,
                child: Text(
                  authCtrl?.userInitials ?? 'AD',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authCtrl?.currentUserName ?? 'Admin User',
                    style: AppTextStyle.text14Medium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    authCtrl?.currentUserEmail ?? 'Super Administrator',
                    style: AppTextStyle.text12MediumOrSmall.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
                tooltip: 'Sign Out',
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
        ],
      ),
    );
  }
}
