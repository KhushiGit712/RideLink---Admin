import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/auth_flow/auth_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/community_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/dashboard_controller.dart';
import 'package:ridelink_admin/views/dashboard/widgets/add_edit_community_dialog.dart';

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
    final communityController = Get.find<CommunityController>();

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
            color: Colors.black.withValues(alpha: 0.02),
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
              subtitle =
                  'Review and verify driver identity, license, and vehicle documents.';
            } else if (idx == 2) {
              title = 'Support System (Driver & Passenger Tickets)';
              subtitle =
                  'Manage helpdesk queries, ride issues, and user conversation threads.';
            } else if (idx == 3) {
              title = 'Community Management';
              subtitle =
                  'Manage commuter corridor communities and ridership networks.';
            } else if (idx == 4) {
              title = 'System Settings';
              subtitle =
                  'Configure application preferences and administrator portal settings.';
            }

            return Expanded(
              child: Column(
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
              ),
            );
          }),

          Obx(() {
            if (dashboardCtrl.selectedIndex.value == 3) {
              return AddCommunityCommonButton(
                onTap: () {
                  communityController.prepareAddCommunity();
                  Get.dialog(const AddEditCommunityDialog());
                },
              );
            } else {
              return SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }
}

class AddCommunityCommonButton extends StatelessWidget {
  const AddCommunityCommonButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
      label: Text(
        'Create Community',
        style: AppTextStyle.text14Medium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
