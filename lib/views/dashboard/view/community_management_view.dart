import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';
import 'package:ridelink_admin/data/models/data/community_model.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/dashboard/controllers/community_controller.dart';
import 'package:ridelink_admin/views/dashboard/widgets/add_edit_community_dialog.dart';
import 'package:ridelink_admin/views/dashboard/widgets/community_details_modal.dart';

class CommunityManagementView extends GetView<CommunityController> {
  const CommunityManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1180;

        return Container(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section: Header & Create Community Action
              _buildTopHeader(context),

              const SizedBox(height: 20),

              // Overview Metric Stat Cards
              _buildMetricCards(constraints.maxWidth),

              const SizedBox(height: 20),

              // Controls & Filter Bar
              _buildControlsBar(),

              const SizedBox(height: 20),

              // Responsive Content Area (Left Table/Cards + Right Inspector Panel)
              Expanded(
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Pane: Communities List (Table or Cards)
                          Expanded(
                            flex: 5,
                            child: _buildCommunitiesListContainer(context, isWide: true),
                          ),
                          const SizedBox(width: 20),
                          // Right Pane: Live Corridor Inspector & Members Panel
                          Expanded(
                            flex: 3,
                            child: _buildRightInspectorPanel(context),
                          ),
                        ],
                      )
                    : _buildCommunitiesListContainer(context, isWide: false),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Top Header ---
  Widget _buildTopHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Commute Communities',
              style: AppTextStyle.text20Medium.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage commuter corridor networks connecting passengers and drivers across transit routes.',
              style: AppTextStyle.text12MediumOrSmall.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            controller.prepareAddCommunity();
            Get.dialog(const AddEditCommunityDialog());
          },
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          label: Text(
            'Create Community',
            style: AppTextStyle.text14Medium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  // --- Metric Cards ---
  Widget _buildMetricCards(double availableWidth) {
    return Obx(() {
      final cards = [
        _buildStatCard(
          title: 'Total Communities',
          value: '${controller.totalCount}',
          icon: Icons.groups_rounded,
          color: const Color(0xFF2563EB),
          bgColor: const Color(0xFFEFF6FF),
        ),
        _buildStatCard(
          title: 'Active Corridors',
          value: '${controller.activeCount}',
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF16A34A),
          bgColor: const Color(0xFFF0FDF4),
        ),
        _buildStatCard(
          title: 'Joined Passengers',
          value: '${controller.totalPassengers}',
          icon: Icons.person_pin_circle_rounded,
          color: const Color(0xFF9333EA),
          bgColor: const Color(0xFFFAF5FF),
        ),
        _buildStatCard(
          title: 'Joined Drivers',
          value: '${controller.totalDrivers}',
          icon: Icons.directions_car_rounded,
          color: const Color(0xFFEA580C),
          bgColor: const Color(0xFFFFF7ED),
        ),
      ];

      return Row(
        children: cards
            .map((c) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: c,
                  ),
                ))
            .toList(),
      );
    });
  }

  // --- Controls & Filter Bar ---
  Widget _buildControlsBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Search Input
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                onChanged: (val) => controller.setSearchQuery(val),
                decoration: const InputDecoration(
                  hintText: 'Search community by name or route corridor...',
                  prefixIcon:
                      Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Category Filter Dropdown
          Obx(() => Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedCategoryFilter.value,
                    items: [
                      const DropdownMenuItem(
                          value: 'All', child: Text('All Categories')),
                      ...CommunityController.availableCategories.map((cat) =>
                          DropdownMenuItem(
                            value: cat,
                            child:
                                Text(cat[0].toUpperCase() + cat.substring(1)),
                          )),
                    ],
                    onChanged: (val) {
                      if (val != null) controller.setCategoryFilter(val);
                    },
                  ),
                ),
              )),
          const SizedBox(width: 10),

          // Status Filter Dropdown
          Obx(() => Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedStatusFilter.value,
                    items: const [
                      DropdownMenuItem(
                          value: 'All', child: Text('All Statuses')),
                      DropdownMenuItem(
                          value: 'Active', child: Text('Active Only')),
                      DropdownMenuItem(
                          value: 'Inactive', child: Text('Inactive Only')),
                    ],
                    onChanged: (val) {
                      if (val != null) controller.setStatusFilter(val);
                    },
                  ),
                ),
              )),
          const SizedBox(width: 10),

          // View Switch (Table vs Grid Cards)
          Obx(() => Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.table_chart_rounded,
                        size: 18,
                        color: !controller.isCardView.value
                            ? AppColors.primaryColor
                            : const Color(0xFF64748B),
                      ),
                      tooltip: 'Table View',
                      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                      padding: EdgeInsets.zero,
                      onPressed: () => controller.isCardView.value = false,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.grid_view_rounded,
                        size: 18,
                        color: controller.isCardView.value
                            ? AppColors.primaryColor
                            : const Color(0xFF64748B),
                      ),
                      tooltip: 'Card Corridor View',
                      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                      padding: EdgeInsets.zero,
                      onPressed: () => controller.isCardView.value = true,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // --- Left Pane: Communities List Container ---
  Widget _buildCommunitiesListContainer(BuildContext context, {required bool isWide}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = controller.filteredCommunities;

        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.group_off_rounded,
                    size: 48, color: Color(0xFF94A3B8)),
                const SizedBox(height: 12),
                Text(
                  'No commute communities found',
                  style: AppTextStyle.text16Medium.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Click "+ Create Community" above to create a new commuter corridor.',
                  style: AppTextStyle.text12MediumOrSmall.copyWith(
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.isCardView.value) {
          return _buildCardsGridView(context, list, isWide);
        }

        return _buildDataTable(context, list, isWide);
      }),
    );
  }

  // --- Data Table View ---
  Widget _buildDataTable(
      BuildContext context, List<CommunityModel> list, bool isWide) {
    return Obx(() {
      final selectedId = controller.selectedCommunity.value?.id;

      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
          showCheckboxColumn: false,
          columnSpacing: 18,
          horizontalMargin: 16,
          headingRowHeight: 50,
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          columns: const [
            DataColumn(label: Text('ICON & NAME', style: _headerStyle)),
            DataColumn(label: Text('ROUTE CORRIDOR', style: _headerStyle)),
            DataColumn(label: Text('PEAK COMMUTE', style: _headerStyle)),
            DataColumn(label: Text('CATEGORY', style: _headerStyle)),
            DataColumn(label: Text('COUNTS', style: _headerStyle)),
            DataColumn(label: Text('STATUS', style: _headerStyle)),
            DataColumn(label: Text('ACTIONS', style: _headerStyle)),
          ],
          rows: list.map((com) {
            final isSelected = com.id == selectedId;

            return DataRow(
              selected: isSelected,
              onSelectChanged: (_) {
                controller.openCommunityMembers(com);
              },
              color: WidgetStateProperty.resolveWith<Color?>((states) {
                if (isSelected) return const Color(0xFFEFF6FF);
                return null;
              }),
              cells: [
                // 1. Icon & Name
                DataCell(
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFDBEAFE)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          CommunityController.getIconData(com.icon),
                          color: AppColors.primaryColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            com.name,
                            style: AppTextStyle.text14Medium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? const Color(0xFF1D4ED8)
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'ID: ${com.id}',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. Route Corridor
                DataCell(
                  _buildRouteCorridorBadge(com),
                ),

                // 3. Peak Commute Hours
                DataCell(
                  Text(
                    com.commonTime,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),

                // 4. Category
                DataCell(
                  _buildCategoryBadge(com.category),
                ),

                // 5. Counts
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '${com.driversCount} D',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC2410C),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5FF),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '${com.passengersCount} P',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7E22CE),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 6. Status Switch
                DataCell(
                  Switch(
                    value: com.isActive,
                    activeTrackColor: const Color(0xFF2563EB),
                    onChanged: (_) =>
                        controller.toggleCommunityStatus(com.id),
                  ),
                ),

                // 7. Actions
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.people_alt_rounded,
                            color: Color(0xFF10B981), size: 18),
                        tooltip: 'View Members',
                        onPressed: () {
                          controller.openCommunityMembers(com);
                          if (!isWide) {
                            Get.dialog(const CommunityDetailsModal());
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded,
                            color: Color(0xFF2563EB), size: 18),
                        tooltip: 'Edit Community',
                        onPressed: () {
                          controller.prepareEditCommunity(com);
                          Get.dialog(const AddEditCommunityDialog());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: Color(0xFFEF4444), size: 18),
                        tooltip: 'Delete',
                        onPressed: () =>
                            _confirmDelete(context, com.id, com.name),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  // --- Grid / Cards View ---
  Widget _buildCardsGridView(
      BuildContext context, List<CommunityModel> list, bool isWide) {
    return Obx(() {
      final selectedId = controller.selectedCommunity.value?.id;

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isWide ? 2 : 3,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.45,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final com = list[index];
          final isSelected = com.id == selectedId;

          return InkWell(
            onTap: () {
              controller.openCommunityMembers(com);
              if (!isWide) {
                Get.dialog(const CommunityDetailsModal());
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.8 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Icon, Category & Status toggle
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          CommunityController.getIconData(com.icon),
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              com.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            _buildCategoryBadge(com.category),
                          ],
                        ),
                      ),
                      Switch(
                        value: com.isActive,
                        activeTrackColor: const Color(0xFF2563EB),
                        onChanged: (_) =>
                            controller.toggleCommunityStatus(com.id),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Route Corridor
                  _buildRouteCorridorBadge(com, isCompact: true),

                  const SizedBox(height: 8),

                  // Bottom info: Peak Hours & Counts
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 12, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            com.commonTime,
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      Text(
                        '${com.driversCount} Drivers • ${com.passengersCount} Pass.',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  // --- Right Pane: Live Corridor Inspector & Members Hub ---
  Widget _buildRightInspectorPanel(BuildContext context) {
    return Obx(() {
      final com = controller.selectedCommunity.value;

      if (com == null) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(28),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.alt_route_rounded,
                    size: 40, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 14),
              const Text(
                'Corridor Live Inspector',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select any community from the left to inspect its live route corridor, peak commute schedule, and joined members in real-time.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
              ),
            ],
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panel Header Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Icon(
                          CommunityController.getIconData(com.icon),
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              com.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                _buildCategoryBadge(com.category),
                                const SizedBox(width: 8),
                                Text(
                                  com.id,
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
                      // Status Switch
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Switch(
                            value: com.isActive,
                            activeTrackColor: const Color(0xFF2563EB),
                            onChanged: (_) =>
                                controller.toggleCommunityStatus(com.id),
                          ),
                          Text(
                            com.isActive ? 'ACTIVE' : 'INACTIVE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: com.isActive
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Panel Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Corridor Route Visual Stepper Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.alt_route_rounded,
                                      size: 16, color: Color(0xFF2563EB)),
                                  SizedBox(width: 6),
                                  Text(
                                    'ROUTE CORRIDOR',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF475569),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: com.fixedLocationType == 'dropoff'
                                          ? const Color(0xFFFEE2E2)
                                          : (com.fixedLocationType == 'pickup'
                                              ? const Color(0xFFDCFCE7)
                                              : const Color(0xFFF1F5F9)),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: com.fixedLocationType == 'dropoff'
                                            ? const Color(0xFFFECACA)
                                            : (com.fixedLocationType == 'pickup'
                                                ? const Color(0xFFBBF7D0)
                                                : const Color(0xFFE2E8F0)),
                                      ),
                                    ),
                                    child: Text(
                                      com.fixedLocationTitle,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: com.fixedLocationType == 'dropoff'
                                            ? const Color(0xFFDC2626)
                                            : (com.fixedLocationType == 'pickup'
                                                ? const Color(0xFF16A34A)
                                                : const Color(0xFF475569)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: const Color(0xFFBFDBFE)),
                                    ),
                                    child: Text(
                                      com.isActive
                                          ? 'Active Corridor'
                                          : 'Inactive Corridor',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: com.isActive
                                            ? const Color(0xFF1D4ED8)
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildCorridorStepper(com),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded,
                                        size: 14, color: Color(0xFF64748B)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        com.commonTime,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF334155)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.repeat_rounded,
                                        size: 14, color: Color(0xFF2563EB)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        com.recurringOption,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1D4ED8)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subcollection Members Live Stream
                    Text(
                      'COMMUNITY MEMBERS (${controller.communityMembers.length})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Members List
                    if (controller.isLoadingMembers.value)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else if (controller.communityMembers.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Icon(Icons.group_outlined,
                                size: 30, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 6),
                            const Text(
                              'No members joined yet',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Members join directly via the RideLink mobile app.',
                              style: TextStyle(
                                  fontSize: 10, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.communityMembers.length > 5
                              ? 5
                              : controller.communityMembers.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          itemBuilder: (context, idx) {
                            final mbr = controller.communityMembers[idx];
                            final isDriver = mbr.isDriver;

                            return ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              leading: CircleAvatar(
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
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                mbr.name,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                mbr.phone?.isNotEmpty == true
                                    ? mbr.phone!
                                    : (mbr.email ?? mbr.userId),
                                style: const TextStyle(
                                    fontSize: 10, color: Color(0xFF64748B)),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDriver
                                          ? const Color(0xFFDCFCE7)
                                          : const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isDriver ? 'DRIVER' : 'PASSENGER',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isDriver
                                            ? const Color(0xFF15803D)
                                            : const Color(0xFF1D4ED8),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        Icons.remove_circle_outline_rounded,
                                        size: 16,
                                        color: Color(0xFFEF4444)),
                                    onPressed: () => controller
                                        .removeMemberFromCommunity(com.id, mbr),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Panel Bottom Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        controller.prepareEditCommunity(com);
                        Get.dialog(const AddEditCommunityDialog());
                      },
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: const Text('Edit Details'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.dialog(const CommunityDetailsModal());
                    },
                    icon: const Icon(Icons.fullscreen_rounded,
                        color: Colors.white, size: 16),
                    label: const Text('All Members',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // --- Helpers ---

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: Color(0xFF475569),
    letterSpacing: 0.8,
  );

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyle.text20Medium.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
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
    );
  }

  Widget _buildCategoryBadge(String category) {
    Color bg = const Color(0xFFEFF6FF);
    Color fg = const Color(0xFF2563EB);

    switch (category.toLowerCase()) {
      case 'corporate':
        bg = const Color(0xFFF0FDF4);
        fg = const Color(0xFF16A34A);
        break;
      case 'healthcare':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        break;
      case 'metro':
        bg = const Color(0xFFFAF5FF);
        fg = const Color(0xFF9333EA);
        break;
      case 'corridor':
        bg = const Color(0xFFFFF7ED);
        fg = const Color(0xFFEA580C);
        break;
      case 'university':
      default:
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        break;
    }

    final label = category.isNotEmpty
        ? category[0].toUpperCase() + category.substring(1)
        : 'General';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRouteCorridorBadge(CommunityModel com, {bool isCompact = false}) {
    final pickup = com.pickupLocation;
    final dropoff = com.dropOffLocation;
    final hasBoth = pickup != dropoff &&
        dropoff.isNotEmpty &&
        dropoff != 'Corridor Destination' &&
        pickup != 'Corridor Origin';

    return Tooltip(
      message: 'Transit Corridor: ${com.routeSummary}',
      child: Container(
        constraints: BoxConstraints(maxWidth: isCompact ? 320 : 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF16A34A),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                hasBoth ? pickup : com.routeSummary,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasBoth) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 13,
                  color: Color(0xFF2563EB),
                ),
              ),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  dropoff,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            if (com.fixedLocationType == 'dropoff') ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '🎯 Drop Fixed',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ] else if (com.fixedLocationType == 'pickup') ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '🛫 Pick Fixed',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCorridorStepper(CommunityModel com) {
    final pickup = com.pickupLocation;
    final dropoff = com.dropOffLocation;
    final hasBoth = pickup != dropoff &&
        dropoff.isNotEmpty &&
        dropoff != 'Corridor Destination' &&
        pickup != 'Corridor Origin';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Departure Stop
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF16A34A), width: 2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'ORIGIN / PICK-UP',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: com.isPickupFixed
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            com.isPickupFixed ? '📌 FIXED' : '📍 FLEXIBLE',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: com.isPickupFixed
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      hasBoth ? pickup : com.routeSummary,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Connector Line
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Container(
              width: 2,
              height: 20,
              color: const Color(0xFFCBD5E1),
            ),
          ),

          // Arrival Stop
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDC2626), width: 2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'DESTINATION / DROP-OFF',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC2626),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: com.isDropOffFixed
                                ? const Color(0xFFFEE2E2)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            com.isDropOffFixed ? '📌 FIXED' : '📍 FLEXIBLE',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: com.isDropOffFixed
                                  ? const Color(0xFFB91C1C)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      hasBoth ? dropoff : com.routeSummary,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Full Route Summary Badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.alt_route_rounded,
                    size: 13, color: Color(0xFF2563EB)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    com.routeSummary,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String name) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Community'),
        content: Text(
            'Are you sure you want to delete community "$name"? All subcollection member links and data will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              controller.deleteCommunity(id);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
