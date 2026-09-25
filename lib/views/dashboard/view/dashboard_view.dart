import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/views/dashboard/controllers/dashboard_controller.dart';
import 'package:ridelink_admin/views/dashboard/view/admin_settings_view.dart';
import 'package:ridelink_admin/views/dashboard/view/community_management_view.dart';
import 'package:ridelink_admin/views/dashboard/view/driver_document_review_view.dart';
import 'package:ridelink_admin/views/dashboard/view/location_management_view.dart';
import 'package:ridelink_admin/views/dashboard/view/overview_tab_view.dart';
import 'package:ridelink_admin/views/dashboard/view/support_tickets_view.dart';
import 'package:ridelink_admin/views/dashboard/widgets/admin_header.dart';
import 'package:ridelink_admin/views/dashboard/widgets/admin_sidebar.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Left Navigation Sidebar
          const AdminSidebar(),

          // Right Main Area
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                const AdminHeader(),

                // Main Section Body switching based on active tab
                Expanded(
                  child: Obx(() {
                    final idx = controller.selectedIndex.value;
                    switch (idx) {
                      case 0:
                        return const OverviewTabView();
                      case 1:
                        return const DriverDocumentReviewView();
                      case 2:
                        return const SupportTicketsView();
                      case 3:
                        return const LocationManagementView();
                      case 4:
                        return const CommunityManagementView();
                      case 5:
                        return const AdminSettingsView();
                      default:
                        return const OverviewTabView();
                    }
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
