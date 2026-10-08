import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/dashboard/controllers/community_controller.dart';
import 'package:ridelink_admin/widgets/app_button.dart';
import 'package:ridelink_admin/widgets/app_text_field.dart';

class AddEditCommunityDialog extends StatelessWidget {
  const AddEditCommunityDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunityController>();
    final isEditing = controller.editingCommunityId.value != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        width: 780,
        constraints: const BoxConstraints(maxHeight: 880),
        padding: const EdgeInsets.all(28),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isEditing
                              ? Icons.edit_road_rounded
                              : Icons.groups_rounded,
                          color: AppColors.primaryColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Edit Community' : 'Create Commuter Community',
                            style: AppTextStyle.text20Medium.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            isEditing
                                ? 'Update corridor route, commuting times, recurring schedule, and details'
                                : 'Setup a commuting corridor community for passengers and drivers',
                            style: AppTextStyle.text12MediumOrSmall.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      if (Navigator.of(context, rootNavigator: true).canPop()) {
                        Navigator.of(context, rootNavigator: true).pop();
                      } else {
                        Get.back();
                      }
                    },
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF64748B)),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 18),

              // Form content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Community Name (Category removed as requested)
                      AppTextFormField1(
                        controller: controller.nameController,
                        label: 'Community Name',
                        hintText: 'e.g. Curtin Community',
                        prefixIcon: const Icon(Icons.groups_rounded,
                            color: Color(0xFF94A3B8)),
                        validator: (val) {
                          if (val == null || val.toString().trim().isEmpty) {
                            return 'Community name is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // 2. Google Places Route Corridor Section & Fixed Location Settings
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
                              children: [
                                const Icon(Icons.alt_route_rounded,
                                    size: 18, color: Color(0xFF2563EB)),
                                const SizedBox(width: 8),
                                Text(
                                  'Route Corridor & Fixed Location Settings',
                                  style: AppTextStyle.text14Medium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Specify if pick-up or drop-off is fixed (e.g. Stadium/Metro as fixed drop-off, Airport as fixed pickup).',
                              style: AppTextStyle.text12MediumOrSmall.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Fixed Location Selector Chips
                            Obx(() {
                              final current = controller.selectedFixedLocationType.value;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.push_pin_rounded,
                                              size: 14, color: Color(0xFF2563EB)),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Fixed Location Mode',
                                            style: AppTextStyle.text12MediumOrSmall.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF1E293B),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Text(
                                        'Choose which stop is fixed',
                                        style: TextStyle(
                                            fontSize: 11, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildFixedOptionChip(
                                        title: 'Fixed Drop-off',
                                        subtitle: 'e.g. Stadium, Metro, Event',
                                        icon: Icons.flag_rounded,
                                        isSelected: current == 'dropoff',
                                        accentColor: const Color(0xFFDC2626),
                                        onTap: () => controller.selectedFixedLocationType.value = 'dropoff',
                                      ),
                                      _buildFixedOptionChip(
                                        title: 'Fixed Pick-up',
                                        subtitle: 'e.g. Airport, Main Terminal',
                                        icon: Icons.flight_takeoff_rounded,
                                        isSelected: current == 'pickup',
                                        accentColor: const Color(0xFF16A34A),
                                        onTap: () => controller.selectedFixedLocationType.value = 'pickup',
                                      ),
                                      _buildFixedOptionChip(
                                        title: 'Both Fixed',
                                        subtitle: 'Fixed Corridor (A → B)',
                                        icon: Icons.sync_alt_rounded,
                                        isSelected: current == 'both',
                                        accentColor: const Color(0xFF2563EB),
                                        onTap: () => controller.selectedFixedLocationType.value = 'both',
                                      ),
                                      _buildFixedOptionChip(
                                        title: 'Flexible Corridor',
                                        subtitle: 'Open Pick & Drop',
                                        icon: Icons.all_inclusive_rounded,
                                        isSelected: current == 'none',
                                        accentColor: const Color(0xFF64748B),
                                        onTap: () => controller.selectedFixedLocationType.value = 'none',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _buildFixedLocationExplanation(current),
                                ],
                              );
                            }),

                            const SizedBox(height: 16),

                            // Pickup & Dropoff Google Places Fields with Dynamic Badges
                            Obx(() {
                              final mode = controller.selectedFixedLocationType.value;
                              final isPickupFixed = mode == 'pickup' || mode == 'both';
                              final isDropFixed = mode == 'dropoff' || mode == 'both';

                              return Column(
                                children: [
                                  _buildPlaceAutocompleteField(
                                    title: 'Pick-up / Origin Location',
                                    icon: Icons.trip_origin_rounded,
                                    iconColor: const Color(0xFF16A34A),
                                    controller: controller.pickupLocationController,
                                    hintText: isPickupFixed
                                        ? 'Search FIXED pickup location (e.g. Perth Airport)...'
                                        : 'Search origin area / pickup suburb...',
                                    predictions: controller.pickupPredictions,
                                    isSearching: controller.isSearchingPickup,
                                    badge: _buildFixedStatusBadge(
                                      isFixed: isPickupFixed,
                                      fixedText: '📌 FIXED ORIGIN',
                                      flexibleText: '📍 FLEXIBLE AREA',
                                      color: const Color(0xFF16A34A),
                                    ),
                                    onChanged: (val) => controller.onPickupSearchChanged(val),
                                    onSelect: (place) => controller.selectPickupPrediction(place),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPlaceAutocompleteField(
                                    title: 'Drop-off / Destination Location',
                                    icon: Icons.pin_drop_rounded,
                                    iconColor: const Color(0xFFDC2626),
                                    controller: controller.dropOffLocationController,
                                    hintText: isDropFixed
                                        ? 'Search FIXED drop-off location (e.g. Optus Stadium, Metro)...'
                                        : 'Search destination area / drop suburb...',
                                    predictions: controller.dropPredictions,
                                    isSearching: controller.isSearchingDrop,
                                    badge: _buildFixedStatusBadge(
                                      isFixed: isDropFixed,
                                      fixedText: '📌 FIXED DESTINATION',
                                      flexibleText: '📍 FLEXIBLE AREA',
                                      color: const Color(0xFFDC2626),
                                    ),
                                    onChanged: (val) => controller.onDropSearchChanged(val),
                                    onSelect: (place) => controller.selectDropPrediction(place),
                                  ),
                                ],
                              );
                            }),

                            const SizedBox(height: 14),

                            // Visible Route Corridor Preview Card
                            Obx(() {
                              final p = controller.selectedPickupPreview.value.trim();
                              final d = controller.selectedDropPreview.value.trim();
                              final mode = controller.selectedFixedLocationType.value;

                              final hasOrigin = p.isNotEmpty;
                              final hasDest = d.isNotEmpty;

                              if (!hasOrigin && !hasDest) {
                                return const SizedBox.shrink();
                              }

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.route_rounded,
                                                size: 15, color: Color(0xFF2563EB)),
                                            SizedBox(width: 6),
                                            Text(
                                              'SELECTED ROUTE CORRIDOR',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2563EB),
                                                letterSpacing: 0.6,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                                color: const Color(0xFFBFDBFE)),
                                          ),
                                          child: Text(
                                            mode == 'dropoff'
                                                ? '🎯 FIXED DROP-OFF'
                                                : (mode == 'pickup'
                                                    ? '🛫 FIXED PICK-UP'
                                                    : (mode == 'both'
                                                        ? '⇄ BOTH FIXED'
                                                        : '🔄 FLEXIBLE')),
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1D4ED8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDCFCE7),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: const Color(0xFF16A34A),
                                                width: 2),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            hasOrigin ? p : 'Origin not set',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: hasOrigin
                                                  ? const Color(0xFF0F172A)
                                                  : const Color(0xFF94A3B8),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Icon(Icons.arrow_forward_rounded,
                                              size: 14,
                                              color: Color(0xFF64748B)),
                                        ),
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEE2E2),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: const Color(0xFFDC2626),
                                                width: 2),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            hasDest ? d : 'Destination not set',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: hasDest
                                                  ? const Color(0xFF0F172A)
                                                  : const Color(0xFF94A3B8),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),

                            const SizedBox(height: 12),

                            // Manual / Display Route Summary
                            AppTextFormField1(
                              controller: controller.routeSummaryController,
                              label: 'Route Summary / Display Name',
                              hintText: 'e.g. Landsdale → Curtin University',
                              prefixIcon: const Icon(Icons.alt_route_rounded,
                                  color: Color(0xFF94A3B8)),
                              validator: (val) {
                                if (val == null || val.toString().trim().isEmpty) {
                                  return 'Route summary is required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // 3. Commute Clock & Date-Time Schedule
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
                              children: [
                                const Icon(Icons.schedule_rounded,
                                    size: 18, color: Color(0xFF2563EB)),
                                const SizedBox(width: 8),
                                Text(
                                  'Schedule, Clock Time & Recurring Options',
                                  style: AppTextStyle.text14Medium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Common Peak Time with Clock Picker & Next Ride Date-Time
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Clock: Common / Peak Time
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Common / Peak Time',
                                            style: AppTextStyle.text14Medium
                                                .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF1E293B),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => controller
                                                .pickCommonTime(context),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4, vertical: 2),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .access_time_filled_rounded,
                                                      size: 14,
                                                      color: Color(0xFF2563EB)),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Pick Clock',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF2563EB),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      AppTextFormField1(
                                        controller:
                                            controller.commonTimeController,
                                        label: '',
                                        hintText: 'e.g. 7:30 AM - 9:00 AM',
                                        prefixIcon: const Icon(
                                            Icons.access_time_rounded,
                                            color: Color(0xFF94A3B8)),
                                        validator: (val) {
                                          if (val == null ||
                                              val.toString().trim().isEmpty) {
                                            return 'Common time is required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Date & Time: Next Scheduled Commute
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Next Commute Date & Time',
                                            style: AppTextStyle.text14Medium
                                                .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF1E293B),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => controller
                                                .pickNextRideDateTime(context),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4, vertical: 2),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .calendar_month_rounded,
                                                      size: 14,
                                                      color: Color(0xFF2563EB)),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Pick Date/Time',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF2563EB),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      AppTextFormField1(
                                        controller:
                                            controller.nextRideTimeController,
                                        label: '',
                                        hintText: 'e.g. 21/10/2026 8:00 AM',
                                        prefixIcon: const Icon(
                                            Icons.calendar_today_rounded,
                                            color: Color(0xFF94A3B8)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Recurring Options Dropdown & Day Chips
                            Text(
                              'Recurring Schedule Frequency',
                              style: AppTextStyle.text14Medium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Obx(() => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFCBD5E1)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: controller
                                          .selectedRecurringOption.value,
                                      isExpanded: true,
                                      items: CommunityController
                                          .availableRecurringOptions
                                          .map((opt) => DropdownMenuItem(
                                                value: opt,
                                                child: Text(
                                                  opt,
                                                  style: const TextStyle(
                                                      fontSize: 13),
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          controller.setRecurringOption(val);
                                        }
                                      },
                                    ),
                                  ),
                                )),

                            const SizedBox(height: 10),

                            // Active Recurring Days Chips
                            Obx(() {
                              final opt =
                                  controller.selectedRecurringOption.value;
                              if (opt == 'One-time') {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Active Commuting Days',
                                    style: AppTextStyle.text12MediumOrSmall
                                        .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: CommunityController.allDaysOfWeek
                                        .map((day) {
                                      final isSelected = controller
                                          .selectedRecurringDays
                                          .contains(day);
                                      return FilterChip(
                                        label: Text(day),
                                        selected: isSelected,
                                        onSelected: (_) => controller
                                            .toggleRecurringDay(day),
                                        selectedColor:
                                            const Color(0xFFDBEAFE),
                                        checkmarkColor:
                                            const Color(0xFF1D4ED8),
                                        labelStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? const Color(0xFF1D4ED8)
                                              : const Color(0xFF64748B),
                                        ),
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: BorderSide(
                                            color: isSelected
                                                ? const Color(0xFF3B82F6)
                                                : const Color(0xFFCBD5E1),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // 4. Icon Type Dropdown (home, stadium, school, business, hospital - car removed)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Icon Type',
                            style: AppTextStyle.text14Medium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFCBD5E1)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: controller.selectedIcon.value,
                                    isExpanded: true,
                                    items: CommunityController.availableIcons
                                        .map((iconKey) => DropdownMenuItem(
                                              value: iconKey,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    CommunityController
                                                        .getIconData(iconKey),
                                                    size: 20,
                                                    color: AppColors
                                                        .primaryColor,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    CommunityController
                                                        .getIconLabel(iconKey),
                                                    style: const TextStyle(
                                                        fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        controller.selectedIcon.value = val;
                                      }
                                    },
                                  ),
                                ),
                              )),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 5. Description
                      AppTextFormField1(
                        controller: controller.descriptionController,
                        label: 'Description',
                        hintText:
                            'Daily shared rides for students & staff commuting between corridors...',
                        maxLines: 3,
                        prefixIcon: const Icon(Icons.notes_rounded,
                            color: Color(0xFF94A3B8)),
                        validator: (val) {
                          if (val == null || val.toString().trim().isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // 6. Active Status Switch
                      Obx(() => Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  controller.isActive.value
                                      ? Icons.check_circle_rounded
                                      : Icons.pause_circle_rounded,
                                  color: controller.isActive.value
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Active Community Status',
                                        style:
                                            AppTextStyle.text14Medium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        controller.isActive.value
                                            ? 'Community is visible on mobile apps for joining and ride creation.'
                                            : 'Community is hidden/paused from mobile apps.',
                                        style: AppTextStyle
                                            .text12MediumOrSmall
                                            .copyWith(
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: controller.isActive.value,
                                  activeTrackColor: const Color(0xFF2563EB),
                                  onChanged: (val) =>
                                      controller.isActive.value = val,
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 18),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      if (Navigator.of(context, rootNavigator: true).canPop()) {
                        Navigator.of(context, rootNavigator: true).pop();
                      } else {
                        Get.back();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.text14Medium.copyWith(
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Obx(() => SizedBox(
                        width: 180,
                        child: AppButton(
                          label: controller.isSaving.value
                              ? 'Saving...'
                              : (isEditing
                                  ? 'Save Changes'
                                  : 'Create Community'),
                          onPressed: controller.isSaving.value
                              ? () {}
                              : () async {
                                  final success =
                                      await controller.saveCommunity();
                                  if (success && context.mounted) {
                                    if (Navigator.of(context, rootNavigator: true).canPop()) {
                                      Navigator.of(context, rootNavigator: true).pop();
                                    } else {
                                      Get.back();
                                    }
                                  }
                                },
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceAutocompleteField({
    required String title,
    required IconData icon,
    required Color iconColor,
    required TextEditingController controller,
    required String hintText,
    required RxList<String> predictions,
    required RxBool isSearching,
    Widget? badge,
    required void Function(String) onChanged,
    required void Function(String) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppTextStyle.text12MediumOrSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              badge,
            ],
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            prefixIcon: Icon(icon, color: iconColor, size: 18),
            suffixIcon: Obx(() {
              if (isSearching.value) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              if (controller.text.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () {
                    controller.clear();
                    predictions.clear();
                  },
                );
              }
              return const SizedBox.shrink();
            }),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
          ),
        ),
        Obx(() {
          if (predictions.isEmpty) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 160),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: predictions.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final place = predictions[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on_outlined,
                      size: 16, color: Color(0xFF2563EB)),
                  title: Text(
                    place,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => onSelect(place),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFixedStatusBadge({
    required bool isFixed,
    required String fixedText,
    required String flexibleText,
    required Color color,
  }) {
    if (isFixed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(
          fixedText,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 0.3,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Text(
        flexibleText,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildFixedOptionChip({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? accentColor : const Color(0xFFCBD5E1),
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? accentColor : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? accentColor : const Color(0xFF1E293B),
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.check_circle_rounded, size: 13, color: accentColor),
                    ],
                  ],
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected
                        ? accentColor.withValues(alpha: 0.85)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedLocationExplanation(String mode) {
    String text;
    IconData icon;
    Color color;

    switch (mode) {
      case 'dropoff':
        text =
            'Fixed Drop-off: The destination is locked (e.g. Stadium for a concert, Metro, University). Passengers can request pick-up from flexible locations or suburbs.';
        icon = Icons.flag_rounded;
        color = const Color(0xFFDC2626);
        break;
      case 'pickup':
        text =
            'Fixed Pick-up: The origin is locked (e.g. Airport, Central Hub). Passengers are picked up from here and can drop off at flexible locations or suburbs.';
        icon = Icons.flight_takeoff_rounded;
        color = const Color(0xFF16A34A);
        break;
      case 'both':
        text =
            'Both Fixed: Fixed point-to-point corridor between Origin and Destination.';
        icon = Icons.sync_alt_rounded;
        color = const Color(0xFF2563EB);
        break;
      case 'none':
      default:
        text =
            'Flexible: Both pick-up and drop-off can be customized freely by commuters within this community.';
        icon = Icons.all_inclusive_rounded;
        color = const Color(0xFF64748B);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
