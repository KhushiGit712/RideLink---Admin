import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/auth_flow/auth_controller.dart';

class AdminSettingsView extends StatelessWidget {
  const AdminSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Settings & Configuration',
            style: AppTextStyle.text20Medium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage administrator account, session parameters, and platform connectivity.',
            style: AppTextStyle.text12MediumOrSmall.copyWith(
              color: const Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 24),

          // Admin Profile Card
          Container(
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
                  children: [
                    Obx(
                      () => CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFF2563EB),
                        child: Text(
                          authCtrl.userInitials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            authCtrl.currentUserName,
                            style: AppTextStyle.text18Semibold.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Obx(
                          () => Text(
                            '${authCtrl.currentUserEmail} • Firebase Authenticated',
                            style: AppTextStyle.text14Medium.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Active Session',
                            style: TextStyle(
                              color: Color(0xFF15803D),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () => authCtrl.onLogout(),
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFEF4444),
                      ),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(color: Color(0xFFEF4444)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Firebase Project Status Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.cloud_done_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Firebase Production Environment',
                        style: AppTextStyle.text16Medium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0369A1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Connected Project: ridelink-d4408 • Authentication Provider: Firebase Auth (Email/Password)',
                        style: AppTextStyle.text14Medium.copyWith(
                          color: const Color(0xFF0C4A6E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
