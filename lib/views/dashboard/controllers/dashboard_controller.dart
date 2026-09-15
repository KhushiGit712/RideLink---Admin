import 'package:get/get.dart';

class DashboardController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxBool isSidebarCollapsed = false.obs;
  final RxInt unreadNotifications = 3.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  void toggleSidebar() {
    isSidebarCollapsed.value = !isSidebarCollapsed.value;
  }
}
