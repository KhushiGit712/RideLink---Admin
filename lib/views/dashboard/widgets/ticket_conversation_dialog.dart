import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';
import 'package:ridelink_admin/data/models/data/support_ticket_model.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/dashboard/controllers/support_ticket_controller.dart';
import 'package:ridelink_admin/views/dashboard/widgets/image_zoom_dialog.dart';

class TicketConversationDialog extends StatelessWidget {
  const TicketConversationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final ticketCtrl = Get.find<SupportTicketController>();

    return Obx(() {
      final ticket = ticketCtrl.selectedTicket.value;
      if (ticket == null) return const SizedBox.shrink();

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Container(
          width: 920,
          constraints: const BoxConstraints(maxHeight: 820),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    // Role Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: ticket.isDriver
                            ? const Color(0xFFFFF7ED)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ticket.isDriver
                              ? const Color(0xFFFFD8A8)
                              : const Color(0xFFBFDBFE),
                        ),
                      ),
                      child: Icon(
                        ticket.isDriver
                            ? Icons.drive_eta_rounded
                            : Icons.person_rounded,
                        color: ticket.isDriver
                            ? const Color(0xFFEA580C)
                            : const Color(0xFF2563EB),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                ticket.subject,
                                style: AppTextStyle.text18Semibold.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildCategoryBadge(ticket.category),
                              const SizedBox(width: 8),
                              _buildStatusBadge(ticket.displayStatus),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ticket #${ticket.id} • Submitted by ${ticket.userName} (${ticket.userRole.toUpperCase()}) • ${ticket.formattedCreatedDate}',
                            style: AppTextStyle.text12MediumOrSmall.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quick Status Dropdown (Section 4.2 Status Controls)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value:
                              ['open', 'in_progress', 'resolved'].contains(
                                ticket.status.toLowerCase().replaceAll(
                                  ' ',
                                  '_',
                                ),
                              )
                              ? ticket.status.toLowerCase().replaceAll(' ', '_')
                              : 'open',
                          items: const [
                            DropdownMenuItem(
                              value: 'open',
                              child: Text(
                                'Status: Open',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'in_progress',
                              child: Text(
                                'Status: In Progress',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'resolved',
                              child: Text(
                                'Status: Mark Resolved',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              ticketCtrl.updateTicketStatus(ticket.id, val);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    IconButton(
                      onPressed: () => ticketCtrl.closeTicketModal(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF64748B),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Body: Left User Metadata Sidebar & Right Conversation Thread
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Column: User details, Trip info, Attachments
                    Container(
                      width: 290,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        border: Border(
                          right: BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'USER INFORMATION',
                            style: AppTextStyle.text12MediumOrSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF475569),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            Icons.person_outline_rounded,
                            'Name',
                            ticket.userName,
                          ),
                          _buildDetailRow(
                            Icons.email_outlined,
                            'Email',
                            ticket.userEmail,
                          ),
                          _buildDetailRow(
                            Icons.phone_outlined,
                            'Phone',
                            ticket.userPhone,
                          ),
                          _buildDetailRow(
                            Icons.badge_outlined,
                            'Role',
                            ticket.userRole.toUpperCase(),
                            badgeColor: ticket.isDriver
                                ? const Color(0xFFEA580C)
                                : const Color(0xFF2563EB),
                          ),

                          const SizedBox(height: 16),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          const SizedBox(height: 16),

                          Text(
                            'RIDE CONTEXT',
                            style: AppTextStyle.text12MediumOrSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF475569),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            Icons.route_outlined,
                            'Trip ID',
                            ticket.tripId != null
                                ? ticket.tripId!
                                : 'None (General query)',
                          ),

                          if (ticket.attachmentUrl != null) ...[
                            const SizedBox(height: 16),
                            const Divider(height: 1, color: Color(0xFFE2E8F0)),
                            const SizedBox(height: 16),
                            Text(
                              'ATTACHMENT',
                              style: AppTextStyle.text12MediumOrSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF475569),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () {
                                ImageZoomDialog.show(
                                  title: 'Ticket #${ticket.id} Attachment',
                                  imageUrl: ticket.attachmentUrl!,
                                  subtitle: 'Submitted by ${ticket.userName}',
                                );
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 110,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        ticket.attachmentUrl!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Center(
                                              child: Icon(
                                                Icons.broken_image_rounded,
                                                color: Color(0xFF94A3B8),
                                              ),
                                            ),
                                      ),
                                      Positioned(
                                        bottom: 6,
                                        right: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.7,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.zoom_in,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Zoom',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Get.defaultDialog(
                                  title: 'Delete Ticket',
                                  middleText:
                                      'Are you sure you want to permanently delete Ticket #${ticket.id} from Firebase?',
                                  textConfirm: 'Delete',
                                  textCancel: 'Cancel',
                                  confirmTextColor: Colors.white,
                                  buttonColor: const Color(0xFFEF4444),
                                  onConfirm: () {
                                    Get.back();
                                    ticketCtrl.deleteTicket(ticket.id);
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: Color(0xFFEF4444),
                              ),
                              label: const Text(
                                'Delete Ticket',
                                style: TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFFCA5A5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right Column: Conversation Thread & Reply Bar
                    Expanded(
                      child: Column(
                        children: [
                          // Messages List
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(24),
                              itemCount: ticket.messages.length,
                              itemBuilder: (context, idx) {
                                final msg = ticket.messages[idx];
                                return _buildMessageBubble(msg, ticket);
                              },
                            ),
                          ),

                          // Text Input for Admin to reply directly (Section 4.2)
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                top: BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: TextField(
                                      controller: ticketCtrl.replyController,
                                      maxLines: 2,
                                      decoration: InputDecoration(
                                        hintText:
                                            'Type reply to ${ticket.userName} (delivered to mobile app)...',
                                        hintStyle: AppTextStyle.text14Medium
                                            .copyWith(
                                              color: const Color(0xFF94A3B8),
                                            ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.all(
                                          12,
                                        ),
                                      ),
                                      onSubmitted: (val) {
                                        ticketCtrl.sendReply(ticket.id, val);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                IconButton(
                                  onPressed: () {
                                    ticketCtrl.sendReply(
                                      ticket.id,
                                      ticketCtrl.replyController.text,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMessageBubble(TicketMessage msg, SupportTicketModel ticket) {
    final isAdmin = msg.isAdmin;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisAlignment: isAdmin
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isAdmin) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: ticket.isDriver
                  ? const Color(0xFFF97316)
                  : const Color(0xFF2563EB),
              child: Text(
                ticket.userName.isNotEmpty
                    ? ticket.userName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isAdmin
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isAdmin ? 'RideLink Admin Operations' : ticket.userName,
                      style: AppTextStyle.text12MediumOrSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      msg.formattedTime,
                      style: AppTextStyle.text12MediumOrSmall.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: Radius.circular(isAdmin ? 14 : 2),
                      bottomRight: Radius.circular(isAdmin ? 2 : 14),
                    ),
                  ),
                  child: Text(
                    msg.message,
                    style: TextStyle(
                      color: isAdmin ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(width: 12),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF0F172A),
              child: Icon(
                Icons.admin_panel_settings_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: badgeColor ?? const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String cat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        cat,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
