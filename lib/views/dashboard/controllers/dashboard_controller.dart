import 'package:get/get.dart';
import 'package:ridelink_admin/views/dashboard/controllers/support_ticket_controller.dart';

class DashboardController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxBool isSidebarCollapsed = false.obs;

  // Platform KPIs (Reset from mock values)
  final RxInt totalPassengers = 0.obs;
  final RxInt totalDrivers = 0.obs;
  final RxInt activeRidesToday = 0.obs;

  int get unreadNotifications {
    if (Get.isRegistered<SupportTicketController>()) {
      return Get.find<SupportTicketController>().unresolvedCount;
    }
    return 0;
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  void toggleSidebar() {
    isSidebarCollapsed.value = !isSidebarCollapsed.value;
  }
}
