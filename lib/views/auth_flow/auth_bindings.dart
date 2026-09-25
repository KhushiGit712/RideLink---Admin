import 'package:get/get.dart';
import 'package:ridelink_admin/views/auth_flow/auth_controller.dart';

class AuthBindings implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
  }
}
