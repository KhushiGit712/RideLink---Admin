import 'package:get/get.dart';
import 'package:ridelink_admin/views/auth_flow/auth_controller.dart';

class AuthBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController());
  }
}
