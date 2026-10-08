import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/constants/app_assets.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';
import 'package:ridelink_admin/routes/routes_name.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/auth_flow/auth_controller.dart';

class SplashView extends GetView<AuthController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 1500), () {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.offAllNamed(AppRoutes.loginView);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Slate
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.appLogo, height: 140, width: 140),
            const SizedBox(height: 16),
            Text(
              'RideLink',
              style: AppTextStyle.text20Medium.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'ADMIN PORTAL CONTROL CENTER',
              style: AppTextStyle.text12MediumOrSmall.copyWith(
                color: const Color(0xFF38BDF8),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 48),
            // Loader
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
