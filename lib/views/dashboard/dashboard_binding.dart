import 'package:get/get.dart';
import 'package:ridelink_admin/views/auth_flow/auth_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/community_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/dashboard_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/driver_document_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/support_ticket_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<DriverDocumentController>(() => DriverDocumentController());
    Get.lazyPut<SupportTicketController>(() => SupportTicketController());
    Get.lazyPut<CommunityController>(() => CommunityController());
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
  }
}
