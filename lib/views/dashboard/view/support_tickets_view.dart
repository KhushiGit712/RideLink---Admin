import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';
import 'package:ridelink_admin/core/utils/app_snack_bar.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/dashboard/controllers/support_ticket_controller.dart';
import 'package:ridelink_admin/views/dashboard/widgets/ticket_conversation_dialog.dart';

class SupportTicketsView extends GetView<SupportTicketController> {
  const SupportTicketsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Metric Cards
          Obx(
            () => Row(
              children: [
                _buildMetricTile(
                  title: 'Open Queries',
                  value: '${controller.openCount}',
                  icon: Icons.chat_bubble_outline_rounded,
                  color: const Color(0xFFEA580C),
                  bgColor: const Color(0xFFFFF7ED),
                ),
                const SizedBox(width: 16),
                _buildMetricTile(
                  title: 'Resolved',
                  value: '${controller.resolvedCount}',
                  icon: Icons.check_circle_outline_rounded,
                  color: const Color(0xFF16A34A),
                  bgColor: const Color(0xFFF0FDF4),
                ),
                const SizedBox(width: 16),
                _buildMetricTile(
                  title: 'Total Tickets',
                  value: '${controller.totalCount}',
                  icon: Icons.all_inbox_rounded,
                  color: const Color(0xFF0F172A),
                  bgColor: const Color(0xFFF1F5F9),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Filters Bar (Section 4.1)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                // Filter by Role: All, Driver, Passenger
                Obx(
                  () => Row(
                    children: ['All', 'Driver', 'Passenger'].map((role) {
                      final isSelected =
                          controller.selectedRoleFilter.value == role;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(role == 'All' ? 'All Roles' : '${role}s'),
                          selected: isSelected,
                          onSelected: (_) => controller.setRoleFilter(role),
                          selectedColor: const Color(0xFF0F172A),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF475569),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(width: 12),
                const SizedBox(
                  height: 28,
                  child: VerticalDivider(color: Color(0xFFCBD5E1), width: 1),
                ),
                const SizedBox(width: 12),

                // Filter by Status: All, Open, Resolved
                Obx(
                  () => Row(
                    children: ['All', 'Open', 'Resolved'].map((
                      status,
                    ) {
                      final isSelected =
                          controller.selectedStatusFilter.value == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (_) => controller.setStatusFilter(status),
                          selectedColor: const Color(0xFF2563EB),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(width: 12),

                const Spacer(),

                // Search field
                SizedBox(
                  width: 280,
                  height: 40,
                  child: TextField(
                    onChanged: (val) => controller.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Search tickets, user, subject...',
                      hintStyle: AppTextStyle.text12MediumOrSmall.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Main Tickets Table (Section 4.1)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                final list = controller.filteredTickets;

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 54,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          controller.tickets.isEmpty
                              ? 'No Support Tickets in Firebase'
                              : 'No support tickets match your filters',
                          style: AppTextStyle.text16Medium.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          controller.tickets.isEmpty
                              ? 'Real-time inquiries submitted by drivers and passengers will appear here.'
                              : 'Try clearing filter chips or searching different keywords.',
                          style: AppTextStyle.text12MediumOrSmall.copyWith(
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        if (controller.tickets.isEmpty) ...[
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: () => _showCreateTicketDialog(context),
                            icon: const Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Create Sample Ticket',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 22,
                    horizontalMargin: 20,
                    headingRowHeight: 52,
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFFF8FAFC),
                    ),
                    columns: const [
                      DataColumn(label: Text('TICKET ID', style: _headerStyle)),
                      DataColumn(label: Text('USER NAME', style: _headerStyle)),
                      DataColumn(
                        label: Text('ROLE BADGE', style: _headerStyle),
                      ),
                      DataColumn(label: Text('CATEGORY', style: _headerStyle)),
                      DataColumn(label: Text('SUBJECT', style: _headerStyle)),
                      DataColumn(
                        label: Text('DATE SUBMITTED', style: _headerStyle),
                      ),
                      DataColumn(label: Text('STATUS', style: _headerStyle)),
                      DataColumn(label: Text('ACTION', style: _headerStyle)),
                    ],
                    rows: list.map((t) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '#${t.id.length > 8 ? t.id.substring(0, 8) : t.id}',
                              style: AppTextStyle.text14Medium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.userName,
                                  style: AppTextStyle.text14Medium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  t.userEmail,
                                  style: AppTextStyle.text12MediumOrSmall
                                      .copyWith(
                                        color: const Color(0xFF64748B),
                                        fontSize: 11,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(_buildRoleBadge(t.userRole)),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                t.category,
                                style: const TextStyle(
                                  color: Color(0xFF334155),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.subject,
                                    style: AppTextStyle.text14Medium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    t.message,
                                    style: AppTextStyle.text12MediumOrSmall
                                        .copyWith(
                                          color: const Color(0xFF64748B),
                                          fontSize: 11,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              t.formattedCreatedDate,
                              style: AppTextStyle.text12MediumOrSmall.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          DataCell(_buildStatusBadge(t.displayStatus)),
                          DataCell(
                            ElevatedButton.icon(
                              onPressed: () {
                                controller.selectTicket(t);
                                Get.dialog(const TicketConversationDialog()).then((_) {
                                  controller.closeTicketModal();
                                });
                              },
                              icon: const Icon(
                                Icons.chat_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'View',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F172A),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateTicketDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    final tripIdCtrl = TextEditingController();

    String selectedRole = 'passenger';
    String selectedCat = 'Ride Issue';
    bool isSubmitting = false;

    Get.dialog(
      StatefulBuilder(
        builder: (ctx, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 540,
            padding: const EdgeInsets.all(28),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Create New Support Ticket',
                          style: AppTextStyle.text18Semibold.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (Navigator.of(ctx).canPop()) {
                              Navigator.of(ctx).pop();
                            } else {
                              Get.back();
                            }
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Directly register a driver or passenger ticket into Cloud Firestore.',
                      style: AppTextStyle.text12MediumOrSmall.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // User Name & Role
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'User Full Name *',
                              hintText: 'e.g. Alex Morgan',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Name is required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'User Role *',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'passenger',
                                child: Text('Passenger'),
                              ),
                              DropdownMenuItem(
                                value: 'driver',
                                child: Text('Driver'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => selectedRole = v);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Email & Phone
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: emailCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Email Address *',
                              hintText: 'alex@example.com',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null || !v.contains('@')
                                ? 'Valid email required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextFormField(
                            controller: phoneCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              hintText: '+1 555-0199',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Category & Trip ID
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedCat,
                            decoration: const InputDecoration(
                              labelText: 'Category *',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Fare / Payment',
                                child: Text('Fare / Payment'),
                              ),
                              DropdownMenuItem(
                                value: 'Ride Issue',
                                child: Text('Ride Issue'),
                              ),
                              DropdownMenuItem(
                                value: 'Account / Profile',
                                child: Text('Account / Profile'),
                              ),
                              DropdownMenuItem(
                                value: 'Other',
                                child: Text('Other'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => selectedCat = v);
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextFormField(
                            controller: tripIdCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Trip ID (Optional)',
                              hintText: 'e.g. TRIP-8921',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Subject
                    TextFormField(
                      controller: subjectCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Subject *',
                        hintText: 'Summary of the issue',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Subject is required'
                          : null,
                    ),

                    const SizedBox(height: 14),

                    // Initial Message
                    TextFormField(
                      controller: messageCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Message / Description *',
                        hintText: 'Describe details of query or complaint...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Message is required'
                          : null,
                    ),

                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (Navigator.of(ctx).canPop()) {
                              Navigator.of(ctx).pop();
                            } else {
                              Get.back();
                            }
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (formKey.currentState?.validate() !=
                                      true) {
                                    return;
                                  }
                                  setState(() => isSubmitting = true);
                                  final ok = await controller.createTicket(
                                    userName: nameCtrl.text,
                                    userEmail: emailCtrl.text,
                                    userPhone: phoneCtrl.text,
                                    userRole: selectedRole,
                                    category: selectedCat,
                                    subject: subjectCtrl.text,
                                    message: messageCtrl.text,
                                    tripId: tripIdCtrl.text,
                                  );
                                  setState(() => isSubmitting = false);
                                  if (ok) {
                                    if (Navigator.of(ctx).canPop()) {
                                      Navigator.of(ctx).pop();
                                    } else {
                                      Get.back();
                                    }
                                    AppSnackBar.success(
                                      message:
                                          'Support ticket created successfully!',
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Submit Ticket to Firebase',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    color: Color(0xFF475569),
    fontWeight: FontWeight.bold,
    fontSize: 11,
    letterSpacing: 0.5,
  );

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyle.text20Medium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  title,
                  style: AppTextStyle.text12MediumOrSmall.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final isDriver = role.toLowerCase() == 'driver';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDriver ? const Color(0xFFFFF7ED) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDriver ? const Color(0xFFFFD8A8) : const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDriver ? Icons.drive_eta_rounded : Icons.person_rounded,
            size: 13,
            color: isDriver ? const Color(0xFFEA580C) : const Color(0xFF2563EB),
          ),
          const SizedBox(width: 4),
          Text(
            isDriver ? 'Driver' : 'Passenger',
            style: TextStyle(
              color: isDriver
                  ? const Color(0xFFC2410C)
                  : const Color(0xFF1D4ED8),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFFFF7ED);
    Color text = const Color(0xFFC2410C);
    Color border = const Color(0xFFFFD8A8);

    if (status == 'In Progress') {
      bg = const Color(0xFFEFF6FF);
      text = const Color(0xFF1D4ED8);
      border = const Color(0xFFBFDBFE);
    } else if (status == 'Resolved') {
      bg = const Color(0xFFF0FDF4);
      text = const Color(0xFF15803D);
      border = const Color(0xFF86EFAC);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
