import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/dashboard/controllers/dashboard_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/driver_document_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/support_ticket_controller.dart';
import 'package:ridelink_admin/views/dashboard/widgets/driver_review_drawer.dart';
import 'package:ridelink_admin/views/dashboard/widgets/ticket_conversation_dialog.dart';

class OverviewTabView extends StatelessWidget {
  const OverviewTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardCtrl = Get.find<DashboardController>();
    final driverCtrl = Get.find<DriverDocumentController>();
    final ticketCtrl = Get.find<SupportTicketController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Welcome Card
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF38BDF8).withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          'RIDELINK OPERATIONS COMMAND CENTER',
                          style: AppTextStyle.text12MediumOrSmall.copyWith(
                            color: const Color(0xFF38BDF8),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'RideLink Platform Overview & Operations',
                        style: AppTextStyle.text20Medium.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'High-level overview across passenger rides, pending driver verifications, support helpdesk queries, and allowed service corridors.',
                        style: AppTextStyle.text14Medium.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => dashboardCtrl.changeTab(1),
                            icon: const Icon(
                              Icons.assignment_ind_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              'Review Driver KYC',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          OutlinedButton.icon(
                            onPressed: () => dashboardCtrl.changeTab(2),
                            icon: const Icon(
                              Icons.support_agent_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              'Support Ticket Inbox',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              side: const BorderSide(color: Color(0xFF475569)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Color(0xFF38BDF8),
                    size: 80,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Key Metric Cards (KPIs) (Section 2)
          // 1. Total Passengers, 2. Total Drivers, 3. Pending Verifications, 4. Active Rides Today, 5. Open Support Tickets
          Text(
            'KEY PLATFORM METRICS (KPIS)',
            style: AppTextStyle.text12MediumOrSmall.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF475569),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),

          Obx(
            () => Row(
              children: [
                _buildKpiCard(
                  title: 'Total Passengers',
                  value: '${dashboardCtrl.totalPassengers.value}',
                  subtitle: 'Registered accounts',
                  icon: Icons.people_alt_rounded,
                  color: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                ),
                const SizedBox(width: 14),
                _buildKpiCard(
                  title: 'Total Drivers',
                  value: '${dashboardCtrl.totalDrivers.value}',
                  subtitle: 'Approved & active',
                  icon: Icons.drive_eta_rounded,
                  color: const Color(0xFF059669),
                  bgColor: const Color(0xFFECFDF5),
                ),
                const SizedBox(width: 14),
                _buildKpiCard(
                  title: 'Pending Verifications',
                  value: '${driverCtrl.pendingCount}',
                  subtitle: 'Needs admin review',
                  icon: Icons.pending_actions_rounded,
                  color: const Color(0xFFEA580C),
                  bgColor: const Color(0xFFFFF7ED),
                  onTap: () => dashboardCtrl.changeTab(1),
                ),
                const SizedBox(width: 14),
                _buildKpiCard(
                  title: 'Active Rides Today',
                  value: '${dashboardCtrl.activeRidesToday.value}',
                  subtitle: 'Ongoing & scheduled',
                  icon: Icons.local_taxi_rounded,
                  color: const Color(0xFF7C3AED),
                  bgColor: const Color(0xFFF5F3FF),
                ),
                const SizedBox(width: 14),
                _buildKpiCard(
                  title: 'Open Support Tickets',
                  value: '${ticketCtrl.unresolvedCount}',
                  subtitle: 'Pending assistance',
                  icon: Icons.headset_mic_rounded,
                  color: const Color(0xFFDC2626),
                  bgColor: const Color(0xFFFEF2F2),
                  onTap: () => dashboardCtrl.changeTab(2),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Two Quick Lists from Section 2:
          // 1. Recent Driver Registrations (Latest 5 drivers who submitted KYC documents)
          // 2. Recent Support Tickets (Latest 5 unanswered tickets from drivers or passengers)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Recent Driver Registrations
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.assignment_ind_rounded,
                                  color: Color(0xFFEA580C),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Recent Driver Registrations',
                                style: AppTextStyle.text16Medium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => dashboardCtrl.changeTab(1),
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        final recents = driverCtrl.requests.take(5).toList();
                        if (recents.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'No driver verification submissions yet.',
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: recents.map((req) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundImage: NetworkImage(
                                        req.profileImageUrl,
                                      ),
                                      backgroundColor: const Color(0xFFCBD5E1),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            req.driverName,
                                            style: AppTextStyle.text14Medium
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(
                                                    0xFF0F172A,
                                                  ),
                                                ),
                                          ),
                                          Text(
                                            '${req.vehicleMake} ${req.vehicleModel} • ${req.vehiclePlate}',
                                            style: AppTextStyle
                                                .text12MediumOrSmall
                                                .copyWith(
                                                  color: const Color(
                                                    0xFF64748B,
                                                  ),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildStatusBadge(req.status),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        driverCtrl.selectRequestForReview(req);
                                        Get.dialog(const DriverReviewDrawer());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: req.status == 'Pending'
                                            ? AppColors.primaryColor
                                            : const Color(0xFF475569),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        minimumSize: Size.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Review',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // Column 2: Recent Support Tickets
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.support_agent_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Recent Support Tickets',
                                style: AppTextStyle.text16Medium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => dashboardCtrl.changeTab(2),
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        final recents = ticketCtrl.tickets.take(5).toList();
                        if (recents.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text('No support tickets currently.'),
                            ),
                          );
                        }

                        return Column(
                          children: recents.map((ticket) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ticket.isDriver
                                            ? const Color(0xFFFFF7ED)
                                            : const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        ticket.isDriver ? 'DRV' : 'PSG',
                                        style: TextStyle(
                                          color: ticket.isDriver
                                              ? const Color(0xFFEA580C)
                                              : const Color(0xFF2563EB),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ticket.subject,
                                            style: AppTextStyle.text14Medium
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(
                                                    0xFF0F172A,
                                                  ),
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${ticket.userName} • ${ticket.category}',
                                            style: AppTextStyle
                                                .text12MediumOrSmall
                                                .copyWith(
                                                  color: const Color(
                                                    0xFF64748B,
                                                  ),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildTicketStatusBadge(
                                      ticket.displayStatus,
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        ticketCtrl.selectTicket(ticket);
                                        Get.dialog(
                                          const TicketConversationDialog(),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ticket.isOpen
                                            ? AppColors.primaryColor
                                            : const Color(0xFF475569),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 16,
                                        ),
                                        minimumSize: Size.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Open',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  if (onTap != null)
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: Color(0xFF94A3B8),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: AppTextStyle.text20Medium.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: AppTextStyle.text14Medium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF334155),
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: AppTextStyle.text12MediumOrSmall.copyWith(
                  color: const Color(0xFF64748B),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFFEF3C7);
    Color fg = const Color(0xFFD97706);
    if (status == 'Approved') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (status == 'Rejected') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTicketStatusBadge(String status) {
    Color bg = const Color(0xFFFEF3C7);
    Color fg = const Color(0xFFD97706);
    if (status == 'Resolved') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (status == 'In Progress') {
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF2563EB);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
