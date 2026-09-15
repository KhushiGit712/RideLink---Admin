import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/utils/app_snack_bar.dart';
import 'package:ridelink_admin/core/utils/validation_mixin.dart';
import 'package:ridelink_admin/routes/routes_name.dart';

class AuthController extends GetxController with ValidationMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoggedIn = false.obs;

  // Static Admin Credentials for prototype
  static const String staticEmail = "admin@ridelink.com";
  static const String staticPassword = "admin123";

  @override
  void onInit() {
    super.onInit();

    // Auto fill default admin email & password for convenient testing
    emailController.text = staticEmail;
    passwordController.text = staticPassword;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void fillDemoCredentials() {
    emailController.text = staticEmail;
    passwordController.text = staticPassword;
    AppSnackBar.success(message: 'Demo admin credentials loaded!');
  }

  Future<void> onLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (loginFormKey.currentState != null &&
        !loginFormKey.currentState!.validate()) {
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      AppSnackBar.error(message: 'Please enter both email and password.');
      return;
    }

    isLoading(true);

    // Simulate authentication processing
    await Future.delayed(const Duration(milliseconds: 600));

    isLoading(false);

    if (email == staticEmail && password == staticPassword) {
      isLoggedIn(true);
      AppSnackBar.success(message: 'Login successful! Welcome back, Admin.');
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      isLoggedIn(true);
      AppSnackBar.success(message: 'Logged in as $email');
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }

  void onLogout() {
    isLoggedIn(false);
    emailController.text = staticEmail;
    passwordController.text = staticPassword;
    AppSnackBar.success(message: 'Logged out successfully');
    Get.offAllNamed(AppRoutes.loginView);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
