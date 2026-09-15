import 'package:get/get.dart';
import 'package:ridelink_admin/views/auth_flow/auth_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/dashboard_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/driver_document_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/location_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<LocationController>(() => LocationController());
    Get.lazyPut<DriverDocumentController>(() => DriverDocumentController());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
