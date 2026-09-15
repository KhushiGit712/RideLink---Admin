import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/utils/validation_mixin.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/auth_flow/auth_controller.dart';
import 'package:ridelink_admin/widgets/app_button.dart';
import 'package:ridelink_admin/widgets/app_text_field.dart';

class LoginView extends GetView<AuthController> with ValidationMixin {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF0F172A,
      ), // Dark slate web admin background
      body: Stack(
        children: [
          // Background ambient decorative shapes
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2563EB).withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
              ),
            ),
          ),

          // Centered Web Admin Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: 460,
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: controller.loginFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // App Logo & Brand Header
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.directions_car_filled_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        'RideLink Admin Portal',
                        style: AppTextStyle.text20Medium.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to manage locations & driver requests',
                        style: AppTextStyle.text14Medium.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Demo Auto-fill Helper Banner
                      InkWell(
                        onTap: () => controller.fillDemoCredentials(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.bolt_rounded,
                                color: Color(0xFF2563EB),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Click to Auto-fill Demo Credentials',
                                  style: AppTextStyle.text12MediumOrSmall
                                      .copyWith(
                                        color: const Color(0xFF1D4ED8),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              const Icon(
                                Icons.touch_app_rounded,
                                color: Color(0xFF2563EB),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Email Field
                      AppTextFormField1(
                        controller: controller.emailController,
                        label: 'Admin Email',
                        hintText: 'admin@ridelink.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Color(0xFF94A3B8),
                        ),
                        validator: (value) => emailValidator(value),
                      ),

                      const SizedBox(height: 18),

                      // Password Field
                      Obx(
                        () => AppTextFormField1(
                          controller: controller.passwordController,
                          label: 'Password',
                          hintText: '••••••••',
                          obscureText: !controller.isPasswordVisible.value,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xFF94A3B8),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: const Color(0xFF94A3B8),
                            ),
                            onPressed: () =>
                                controller.togglePasswordVisibility(),
                          ),
                          validator: (value) => passwordValidator(value),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login Button
                      Obx(
                        () => AppButton(
                          onPressed: () => controller.onLogin(),
                          label: 'Login to Admin Dashboard',
                          isLoading: controller.isLoading.value,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Credentials Hint Footer
                      Text(
                        'Static Demo Credentials: admin@ridelink.com / admin123',
                        style: AppTextStyle.text12MediumOrSmall.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
