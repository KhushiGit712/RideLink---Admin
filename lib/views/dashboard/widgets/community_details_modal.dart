import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/dashboard/controllers/community_controller.dart';
import 'package:ridelink_admin/data/models/data/community_model.dart';
import 'package:ridelink_admin/widgets/app_button.dart';

class CommunityDetailsModal extends StatelessWidget {
  const CommunityDetailsModal({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunityController>();

    return Obx(() {
      final com = controller.selectedCommunity.value;
      if (com == null) return const SizedBox.shrink();

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Container(
          width: 880,
          constraints: const BoxConstraints(maxHeight: 840),
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      CommunityController.getIconData(com.icon),
                      color: AppColors.primaryColor,
                      size: 28,
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
                              com.name,
                              style: AppTextStyle.text20Medium.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildStatusBadge(com.isActive),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${com.id} • Route: ${com.routeSummary} • Peak: ${com.commonTime}',
                          style: AppTextStyle.text12MediumOrSmall.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.closeCommunityMembers(),
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF64748B), size: 24),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),

              // Summary Info Tiles
              Row(
                children: [
                  _buildDetailTile(
                    label: 'ROUTE CORRIDOR',
                    value: com.routeSummary,
                    icon: Icons.alt_route_rounded,
                    color: const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 12),
                  _buildDetailTile(
                    label: 'PEAK COMMUTE HOURS',
                    value: com.commonTime,
                    icon: Icons.access_time_filled_rounded,
                    color: const Color(0xFF7C3AED),
                  ),
                  const SizedBox(width: 12),
                  _buildDetailTile(
                    label: 'DRIVERS / PASSENGERS',
                    value:
                        '${com.driversCount} Drivers • ${com.passengersCount} Passengers',
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF16A34A),
                  ),
                ],
              ),

              if (com.description.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    com.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Members List Header + Add Member Button
              Row(
                children: [
                  const Icon(Icons.group_rounded,
                      size: 20, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Text(
                    'COMMUNITY MEMBERS (${controller.communityMembers.length})',
                    style: AppTextStyle.text14Medium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Members DataTable (Section 6.3)
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingMembers.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final membersList = controller.communityMembers;

                  if (membersList.isEmpty) {
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_off_rounded,
                              size: 40, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 8),
                          Text(
                            'No members found in /communities/${com.id}/members',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Members join via the mobile app, or click "Add Member" above to add one manually.',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: 20,
                        horizontalMargin: 16,
                        headingRowHeight: 46,
                        headingRowColor:
                            WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                        columns: const [
                          DataColumn(label: Text('MEMBER', style: _headerStyle)),
                          DataColumn(label: Text('ROLE', style: _headerStyle)),
                          DataColumn(
                              label: Text('CONTACT INFO', style: _headerStyle)),
                          DataColumn(
                              label: Text('DATE JOINED', style: _headerStyle)),
                          DataColumn(
                              label: Text('ACTION', style: _headerStyle)),
                        ],
                        rows: membersList.map((mbr) {
                          final isDriver = mbr.isDriver;
                          return DataRow(
                            cells: [
                              // Member Name & UID
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: isDriver
                                          ? const Color(0xFFEA580C)
                                          : const Color(0xFF2563EB),
                                      child: Text(
                                        mbr.name.isNotEmpty
                                            ? mbr.name[0].toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mbr.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        Text(
                                          mbr.userId,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Role Badge (Passenger [Blue] / Driver [Green])
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDriver
                                        ? const Color(0xFFDCFCE7)
                                        : const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isDriver ? 'DRIVER' : 'PASSENGER',
                                    style: TextStyle(
                                      color: isDriver
                                          ? const Color(0xFF15803D)
                                          : const Color(0xFF1D4ED8),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              // Contact info (email, phone)
                              DataCell(
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    if (mbr.email != null &&
                                        mbr.email!.isNotEmpty)
                                      Text(mbr.email!,
                                          style: const TextStyle(fontSize: 12)),
                                    if (mbr.phone != null &&
                                        mbr.phone!.isNotEmpty)
                                      Text(mbr.phone!,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B))),
                                    if ((mbr.email == null ||
                                            mbr.email!.isEmpty) &&
                                        (mbr.phone == null ||
                                            mbr.phone!.isEmpty))
                                      const Text('No contact info',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF94A3B8))),
                                  ],
                                ),
                              ),

                              // Date Joined
                              DataCell(
                                Text(
                                  mbr.formattedJoinedDate,
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFF475569)),
                                ),
                              ),

                              // Action: Remove from community
                              DataCell(
                                IconButton(
                                  icon: const Icon(
                                      Icons.remove_circle_outline_rounded,
                                      color: Color(0xFFEF4444),
                                      size: 18),
                                  tooltip: 'Remove from community',
                                  onPressed: () => _confirmRemoveMember(
                                      context, controller, com.id, mbr),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 14),

              // Footer Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => controller.closeCommunityMembers(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: Color(0xFF475569),
    letterSpacing: 0.8,
  );

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(
          color: isActive ? const Color(0xFF15803D) : const Color(0xFF64748B),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveMember(BuildContext context,
      CommunityController controller, String communityId, CommunityMemberModel member) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Member'),
        content: Text(
            'Are you sure you want to remove "${member.name}" from this community?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              controller.removeMemberFromCommunity(communityId, member);
              Get.back();
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
