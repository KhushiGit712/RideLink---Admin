import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/utils/app_snack_bar.dart';
import 'package:ridelink_admin/core/utils/preferences.dart';
import 'package:ridelink_admin/core/utils/validation_mixin.dart';
import 'package:ridelink_admin/routes/routes_name.dart';

class AuthController extends GetxController with ValidationMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoggedIn = false.obs;
  final Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _auth.currentUser;
    isLoggedIn.value = _auth.currentUser != null;

    // Listen to Firebase auth state changes
    _auth.authStateChanges().listen((User? user) {
      currentUser.value = user;
      isLoggedIn.value = user != null;
      if (user != null) {
        Preferences.isLogged = true;
      }
    });
  }

  String get currentUserEmail =>
      currentUser.value?.email ?? _auth.currentUser?.email ?? 'admin@ridelink.com';

  String get currentUserName {
    final user = currentUser.value ?? _auth.currentUser;
    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      return user.displayName!;
    }
    if (user?.email != null) {
      final prefix = user!.email!.split('@').first;
      return prefix.isNotEmpty
          ? '${prefix[0].toUpperCase()}${prefix.substring(1)}'
          : 'Admin';
    }
    return 'Admin';
  }

  String get userInitials {
    final name = currentUserName;
    if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    } else if (name.isNotEmpty) {
      return name.toUpperCase();
    }
    return 'AD';
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
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

    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        currentUser.value = user;
        isLoggedIn(true);
        Preferences.isLogged = true;
        try {
          Preferences.token = await user.getIdToken();
        } catch (_) {}

        AppSnackBar.success(
          message: 'Login successful! Welcome, ${user.email ?? 'Admin'}.',
        );
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email address.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please verify and try again.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is improperly formatted.';
          break;
        case 'user-disabled':
          errorMessage = 'This administrator account has been disabled.';
          break;
        case 'invalid-credential':
          errorMessage =
              'Invalid credentials provided. Please check your email and password.';
          break;
        case 'too-many-requests':
          errorMessage =
              'Too many failed attempts. Temporary access lock enabled. Try again later.';
          break;
        case 'network-request-failed':
          errorMessage =
              'Network error. Please check your internet connectivity.';
          break;
        default:
          errorMessage = e.message ?? 'Authentication failed (${e.code}).';
      }
      AppSnackBar.error(message: errorMessage);
    } catch (e) {
      AppSnackBar.error(message: 'An unexpected error occurred: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> onLogout() async {
    try {
      await _auth.signOut();
      Preferences.logout();
      currentUser.value = null;
      isLoggedIn(false);
      emailController.clear();
      passwordController.clear();
      AppSnackBar.success(message: 'Logged out successfully.');
      Get.offAllNamed(AppRoutes.loginView);
    } catch (e) {
      AppSnackBar.error(message: 'Failed to log out: $e');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
