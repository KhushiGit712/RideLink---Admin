import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/dashboard/controllers/community_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/dashboard_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/driver_document_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/support_ticket_controller.dart';
import 'package:ridelink_admin/views/dashboard/widgets/driver_review_drawer.dart';
import 'package:ridelink_admin/views/dashboard/widgets/edit_user_profile_dialog.dart';
import 'package:ridelink_admin/views/dashboard/widgets/ticket_conversation_dialog.dart';

class OverviewTabView extends StatelessWidget {
  const OverviewTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardCtrl = Get.find<DashboardController>();
    final driverCtrl = Get.find<DriverDocumentController>();
    final ticketCtrl = Get.find<SupportTicketController>();
    final communityCtrl = Get.isRegistered<CommunityController>()
        ? Get.find<CommunityController>()
        : Get.put(CommunityController());

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 1200;
        final isMediumScreen = constraints.maxWidth >= 768;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Banner Welcome & Operations Status Card
              _buildCommandCenterBanner(dashboardCtrl),

              const SizedBox(height: 28),

              // 2. Real-Time Platform Numbers Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REAL-TIME PLATFORM METRICS',
                        style: AppTextStyle.text12MediumOrSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Live counts synchronized from Firebase Firestore collections',
                        style: AppTextStyle.text12MediumOrSmall.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => OutlinedButton.icon(
                      onPressed: () => dashboardCtrl.refreshMetrics(),
                      icon: dashboardCtrl.isLoadingStats.value
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.refresh_rounded,
                              size: 16,
                              color: Color(0xFF2563EB),
                            ),
                      label: Text(
                        dashboardCtrl.isLoadingStats.value
                            ? 'Syncing...'
                            : 'Refresh Numbers',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 3. Primary Numbers Grid (8 Core Platform Metrics)
              Obx(() {
                final cards = [
                  _MetricCardData(
                    title: 'Total Users',
                    value: '${dashboardCtrl.totalUsers.value}',
                    subtitle: 'Combined user base',
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF2563EB),
                    bgColor: const Color(0xFFEFF6FF),
                    badgeText: '+${dashboardCtrl.newUsersToday.value} Today',
                    badgeColor: const Color(0xFF10B981),
                  ),
                  _MetricCardData(
                    title: 'Total Riders',
                    value: '${dashboardCtrl.totalRiders.value}',
                    subtitle: 'Commuters & passengers',
                    icon: Icons.person_rounded,
                    color: const Color(0xFF0284C7),
                    bgColor: const Color(0xFFE0F2FE),
                  ),
                  _MetricCardData(
                    title: 'Total Drivers',
                    value: '${dashboardCtrl.totalDrivers.value}',
                    subtitle: 'Registered carpool drivers',
                    icon: Icons.drive_eta_rounded,
                    color: const Color(0xFF059669),
                    bgColor: const Color(0xFFECFDF5),
                  ),
                  _MetricCardData(
                    title: 'Verified Drivers',
                    value: '${dashboardCtrl.verifiedDrivers.value}',
                    subtitle: 'KYC documents approved',
                    icon: Icons.verified_user_rounded,
                    color: const Color(0xFF16A34A),
                    bgColor: const Color(0xFFDCFCE7),
                    onTap: () => dashboardCtrl.changeTab(1),
                  ),
                  _MetricCardData(
                    title: 'Pending KYC Review',
                    value: '${driverCtrl.pendingCount}',
                    subtitle: 'Awaiting admin review',
                    icon: Icons.pending_actions_rounded,
                    color: const Color(0xFFEA580C),
                    bgColor: const Color(0xFFFFF7ED),
                    onTap: () => dashboardCtrl.changeTab(1),
                  ),
                  _MetricCardData(
                    title: 'Total Rides',
                    value: '${dashboardCtrl.totalRides.value}',
                    subtitle: 'Published across system',
                    icon: Icons.route_rounded,
                    color: const Color(0xFF7C3AED),
                    bgColor: const Color(0xFFF5F3FF),
                  ),
                  _MetricCardData(
                    title: 'Active Rides',
                    value: '${dashboardCtrl.activeRides.value}',
                    subtitle: 'In-progress & scheduled',
                    icon: Icons.local_taxi_rounded,
                    color: const Color(0xFF9333EA),
                    bgColor: const Color(0xFFFAF5FF),
                  ),
                  _MetricCardData(
                    title: 'Commuter Communities',
                    value: '${communityCtrl.totalCount}',
                    subtitle: '${communityCtrl.activeCount} active corridors',
                    icon: Icons.groups_rounded,
                    color: const Color(0xFF0D9488),
                    bgColor: const Color(0xFFCCFBF1),
                    onTap: () => dashboardCtrl.changeTab(4),
                  ),
                  _MetricCardData(
                    title: 'Support Tickets',
                    value: '${ticketCtrl.tickets.length}',
                    subtitle: '${ticketCtrl.unresolvedCount} open queries',
                    icon: Icons.headset_mic_rounded,
                    color: const Color(0xFFDC2626),
                    bgColor: const Color(0xFFFEF2F2),
                    onTap: () => dashboardCtrl.changeTab(2),
                  ),
                ];

                // Responsive Grid Columns
                int crossAxisCount = 4;
                if (!isWideScreen && isMediumScreen) crossAxisCount = 3;
                if (!isMediumScreen) crossAxisCount = 2;

                return _buildResponsiveGrid(cards, crossAxisCount);
              }),

              const SizedBox(height: 32),

              // 4. In-Depth Numeric Operations Breakdown ("Everything Only Numbers")
              Text(
                'NUMERIC OPERATIONS BREAKDOWN',
                style: AppTextStyle.text12MediumOrSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF475569),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 14),

              Obx(
                () => _buildNumericBreakdownGrid(
                  dashboardCtrl: dashboardCtrl,
                  driverCtrl: driverCtrl,
                  communityCtrl: communityCtrl,
                  ticketCtrl: ticketCtrl,
                  isWideScreen: isWideScreen,
                ),
              ),

              const SizedBox(height: 32),

              // 5. Quick Lists: Recent KYC Submissions & Recent Support Tickets
              if (isWideScreen)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildRecentDriversList(dashboardCtrl, driverCtrl),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: _buildRecentTicketsList(dashboardCtrl, ticketCtrl),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildRecentDriversList(dashboardCtrl, driverCtrl),
                    const SizedBox(height: 24),
                    _buildRecentTicketsList(dashboardCtrl, ticketCtrl),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  // --- Widget Builders ---

  Widget _buildCommandCenterBanner(DashboardController dashboardCtrl) {
    return Container(
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
            color: Colors.black.withValues(alpha: 0.08),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
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
                    const SizedBox(width: 12),
                    // Live Firestore Sync Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'LIVE FIRESTORE SYNC',
                            style: AppTextStyle.text12MediumOrSmall.copyWith(
                              color: const Color(0xFF34D399),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                  'Complete real-time platform statistics for registered users, active riders, carpool drivers, corridors, and open inquiries.',
                  style: AppTextStyle.text14Medium.copyWith(
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
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
                    OutlinedButton.icon(
                      onPressed: () => dashboardCtrl.changeTab(4),
                      icon: const Icon(
                        Icons.groups_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'Manage Communities',
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
                    OutlinedButton.icon(
                      onPressed: () => dashboardCtrl.changeTab(2),
                      icon: const Icon(
                        Icons.support_agent_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'Support Tickets',
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
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Color(0xFF38BDF8),
              size: 72,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveGrid(List<_MetricCardData> cards, int crossAxisCount) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final itemWidth = (constraints.maxWidth - ((crossAxisCount - 1) * spacing)) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards.map((card) {
            return SizedBox(
              width: itemWidth,
              child: _buildKpiCard(
                title: card.title,
                value: card.value,
                subtitle: card.subtitle,
                icon: card.icon,
                color: card.color,
                bgColor: card.bgColor,
                badgeText: card.badgeText,
                badgeColor: card.badgeColor,
                onTap: card.onTap,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    String? badgeText,
    Color? badgeColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? color).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeColor ?? color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (onTap != null)
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
                fontSize: 28,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
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
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyle.text12MediumOrSmall.copyWith(
                color: const Color(0xFF64748B),
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // --- Section 4: Numeric Operations Breakdown ---

  Widget _buildNumericBreakdownGrid({
    required DashboardController dashboardCtrl,
    required DriverDocumentController driverCtrl,
    required CommunityController communityCtrl,
    required SupportTicketController ticketCtrl,
    required bool isWideScreen,
  }) {
    final totalU = dashboardCtrl.totalUsers.value;
    final totalR = dashboardCtrl.totalRiders.value;
    final totalD = dashboardCtrl.totalDrivers.value;
    final verifiedD = dashboardCtrl.verifiedDrivers.value;

    final riderPercent = totalU > 0 ? ((totalR / totalU) * 100).toStringAsFixed(1) : '0';
    final driverPercent = totalU > 0 ? ((totalD / totalU) * 100).toStringAsFixed(1) : '0';
    final verifiedDriverPercent = totalD > 0 ? ((verifiedD / totalD) * 100).toStringAsFixed(1) : '0';

    final totalRides = dashboardCtrl.totalRides.value;
    final completedRides = dashboardCtrl.completedRides.value;
    final activeRides = dashboardCtrl.activeRides.value;
    final scheduledRides = dashboardCtrl.scheduledRides.value;
    final cancelledRides = dashboardCtrl.cancelledRides.value;
    final rideCompletionRate = totalRides > 0
        ? ((completedRides / totalRides) * 100).toStringAsFixed(1)
        : '0';

    final totalReq = driverCtrl.requests.length;
    final approvedReq = driverCtrl.approvedCount;
    final pendingReq = driverCtrl.pendingCount;
    final rejectedReq = driverCtrl.rejectedCount;
    final approvalRate = totalReq > 0
        ? ((approvedReq / totalReq) * 100).toStringAsFixed(1)
        : '0';

    final totalTickets = ticketCtrl.tickets.length;
    final unresolvedTickets = ticketCtrl.unresolvedCount;
    final resolvedTickets = ticketCtrl.resolvedCount;
    final resolutionRate = totalTickets > 0
        ? ((resolvedTickets / totalTickets) * 100).toStringAsFixed(1)
        : '0';

    final panels = [
      _buildBreakdownPanel(
        title: 'User Composition',
        mainNumber: '$totalU',
        mainLabel: 'Total Registered Users',
        accentColor: const Color(0xFF2563EB),
        icon: Icons.people_outline_rounded,
        rows: [
          _BreakdownRow('Riders / Commuters', '$totalR', '$riderPercent% of total'),
          _BreakdownRow('Carpool Drivers', '$totalD', '$driverPercent% of total'),
          _BreakdownRow('Verified Drivers', '$verifiedD', '$verifiedDriverPercent% of drivers'),
          _BreakdownRow('New Today', '+${dashboardCtrl.newUsersToday.value}', 'Last 24h'),
        ],
      ),
      _buildBreakdownPanel(
        title: 'Ride Trip Lifecycle',
        mainNumber: '$totalRides',
        mainLabel: 'Total Platform Rides',
        accentColor: const Color(0xFF7C3AED),
        icon: Icons.alt_route_rounded,
        rows: [
          _BreakdownRow('Active & Live', '$activeRides', 'In transit / ready'),
          _BreakdownRow('Completed Trips', '$completedRides', '$rideCompletionRate% completion'),
          _BreakdownRow('Scheduled Trips', '$scheduledRides', 'Upcoming'),
          _BreakdownRow('Cancelled Trips', '$cancelledRides', 'Terminated'),
        ],
      ),
      _buildBreakdownPanel(
        title: 'Driver KYC Pipeline',
        mainNumber: '$totalReq',
        mainLabel: 'Verification Submissions',
        accentColor: const Color(0xFFEA580C),
        icon: Icons.badge_outlined,
        rows: [
          _BreakdownRow('Approved & Active', '$approvedReq', '$approvalRate% approved'),
          _BreakdownRow('Pending Admin Review', '$pendingReq', 'Action required'),
          _BreakdownRow('Rejected Documents', '$rejectedReq', 'Requires resubmission'),
          _BreakdownRow('Total Active Drivers', '$totalD', 'On road'),
        ],
      ),
      _buildBreakdownPanel(
        title: 'Communities & Helpdesk',
        mainNumber: '${communityCtrl.totalCount}',
        mainLabel: 'Commuter Corridors',
        accentColor: const Color(0xFF0D9488),
        icon: Icons.hub_outlined,
        rows: [
          _BreakdownRow('Active Corridors', '${communityCtrl.activeCount}', 'Live in mobile app'),
          _BreakdownRow('Open Tickets', '$unresolvedTickets', 'Pending review'),
          _BreakdownRow('Community Members', '${communityCtrl.totalPassengers + communityCtrl.totalDrivers}', 'Joined corridors'),
          _BreakdownRow('Support Resolution', '$resolvedTickets / $totalTickets', '$resolutionRate% resolved'),
        ],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int cols = 4;
        if (constraints.maxWidth < 1300 && constraints.maxWidth >= 850) {
          cols = 2;
        } else if (constraints.maxWidth < 850) {
          cols = 1;
        }

        const spacing = 16.0;
        final itemWidth = (constraints.maxWidth - ((cols - 1) * spacing)) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: panels.map((panel) {
            return SizedBox(
              width: itemWidth,
              child: panel,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBreakdownPanel({
    required String title,
    required String mainNumber,
    required String mainLabel,
    required Color accentColor,
    required IconData icon,
    required List<_BreakdownRow> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon & title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyle.text14Medium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Large Lead Metric Number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEDF2F7)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mainNumber,
                      style: AppTextStyle.text20Medium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: accentColor,
                      ),
                    ),
                    Text(
                      mainLabel,
                      style: AppTextStyle.text12MediumOrSmall.copyWith(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Live Count',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Itemized Numbers Breakdown
          ...rows.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      row.label,
                      style: AppTextStyle.text12MediumOrSmall.copyWith(
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        row.value,
                        style: AppTextStyle.text14Medium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          row.tag,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- Section 5: Recent Lists ---

  Widget _buildRecentDriversList(
    DashboardController dashboardCtrl,
    DriverDocumentController driverCtrl,
  ) {
    return Container(
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
                  child: Text('No driver verification submissions yet.'),
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
                          backgroundColor: const Color(0xFFEFF6FF),
                          backgroundImage: req.profileImageUrl.trim().isNotEmpty
                              ? NetworkImage(req.profileImageUrl.trim())
                              : null,
                          child: req.profileImageUrl.trim().isEmpty
                              ? Text(
                                  req.driverName.trim().isNotEmpty
                                      ? req.driverName.trim()[0].toUpperCase()
                                      : 'D',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563EB),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                req.driverName,
                                style: AppTextStyle.text14Medium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                '${req.vehicleMake} ${req.vehicleModel} • ${req.vehiclePlate}',
                                style: AppTextStyle.text12MediumOrSmall.copyWith(
                                  color: const Color(0xFF64748B),
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
                            Get.dialog(const DriverReviewDrawer()).then((_) {
                              driverCtrl.closeReviewModal();
                            });
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
                              borderRadius: BorderRadius.circular(6),
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
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: 'Edit Driver Profile',
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: Color(0xFF2563EB),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          onPressed: () {
                            Get.dialog(
                              EditUserProfileDialog.fromDriver(driver: req),
                            );
                          },
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
    );
  }

  Widget _buildRecentTicketsList(
    DashboardController dashboardCtrl,
    SupportTicketController ticketCtrl,
  ) {
    return Container(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.subject,
                                style: AppTextStyle.text14Medium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${ticket.userName} • ${ticket.category}',
                                style: AppTextStyle.text12MediumOrSmall.copyWith(
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildTicketStatusBadge(ticket.displayStatus),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            ticketCtrl.selectTicket(ticket);
                            Get.dialog(const TicketConversationDialog()).then((_) {
                              ticketCtrl.closeTicketModal();
                            });
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
                              borderRadius: BorderRadius.circular(6),
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

class _MetricCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String? badgeText;
  final Color? badgeColor;
  final VoidCallback? onTap;

  _MetricCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.badgeText,
    this.badgeColor,
    this.onTap,
  });
}

class _BreakdownRow {
  final String label;
  final String value;
  final String tag;

  _BreakdownRow(this.label, this.value, this.tag);
}
