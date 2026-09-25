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
        width: 760,
        constraints: const BoxConstraints(maxHeight: 840),
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
                                ? 'Update corridor route, commuting times, icon, and details'
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
                    onPressed: () => Get.back(),
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
                      // 1. Community Name & Category
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: AppTextFormField1(
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
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Category',
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
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                            color: const Color(0xFFCBD5E1)),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: controller
                                              .selectedCategory.value,
                                          isExpanded: true,
                                          items: CommunityController
                                              .availableCategories
                                              .map((cat) => DropdownMenuItem(
                                                    value: cat,
                                                    child: Text(
                                                      cat[0].toUpperCase() +
                                                          cat.substring(1),
                                                      style: const TextStyle(
                                                          fontSize: 13),
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              controller
                                                  .selectedCategory.value = val;
                                            }
                                          },
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 2. Route Summary & Common Peak Time
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: AppTextFormField1(
                              controller: controller.routeSummaryController,
                              label: 'Route Summary / Corridor',
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
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: AppTextFormField1(
                              controller: controller.commonTimeController,
                              label: 'Common / Peak Time',
                              hintText: 'e.g. 7:30 AM - 9:00 AM',
                              prefixIcon: const Icon(
                                  Icons.access_time_filled_rounded,
                                  color: Color(0xFF94A3B8)),
                              validator: (val) {
                                if (val == null || val.toString().trim().isEmpty) {
                                  return 'Common time is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Google Places Route Corridor Builder
                      Obx(() => Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => controller.showPlacesSearch.toggle(),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      controller.showPlacesSearch.value
                                          ? Icons.expand_less_rounded
                                          : Icons.add_location_alt_rounded,
                                      size: 16,
                                      color: const Color(0xFF2563EB),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      controller.showPlacesSearch.value
                                          ? 'Hide Google Places Route Builder'
                                          : 'Build Corridor with Google Places (Search Origin & Destination)',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (controller.showPlacesSearch.value) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Column(
                                  children: [
                                    _buildPlaceAutocompleteField(
                                      title: 'Pick-up / Origin Location',
                                      icon: Icons.trip_origin_rounded,
                                      iconColor: const Color(0xFF16A34A),
                                      controller: controller.pickupLocationController,
                                      hintText: 'Search pickup location via Google Places...',
                                      predictions: controller.pickupPredictions,
                                      isSearching: controller.isSearchingPickup,
                                      onChanged: (val) => controller.onPickupSearchChanged(val),
                                      onSelect: (place) => controller.selectPickupPrediction(place),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildPlaceAutocompleteField(
                                      title: 'Drop-off / Destination Location',
                                      icon: Icons.pin_drop_rounded,
                                      iconColor: const Color(0xFFDC2626),
                                      controller: controller.dropOffLocationController,
                                      hintText: 'Search drop-off location via Google Places...',
                                      predictions: controller.dropPredictions,
                                      isSearching: controller.isSearchingDrop,
                                      onChanged: (val) => controller.onDropSearchChanged(val),
                                      onSelect: (place) => controller.selectDropPrediction(place),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      )),

                      const SizedBox(height: 16),

                      // 3. Icon Type Dropdown
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

                      // 4. Description
                      AppTextFormField1(
                        controller: controller.descriptionController,
                        label: 'Description',
                        hintText:
                            'Daily shared rides for Curtin University students & staff commuting from northern suburbs...',
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

                      const SizedBox(height: 16),

                      // 5. Next Ride Default Time & Next Ride Open Seats
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: AppTextFormField1(
                              controller: controller.nextRideTimeController,
                              label: 'Next Ride Display Time (Optional)',
                              hintText: 'e.g. Tomorrow 8:00 AM',
                              prefixIcon: const Icon(
                                  Icons.calendar_today_rounded,
                                  color: Color(0xFF94A3B8)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: AppTextFormField1(
                              controller:
                                  controller.nextRideSeatsOpenController,
                              label: 'Open Seats (Optional)',
                              hintText: '3',
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(
                                  Icons.airline_seat_recline_normal_rounded,
                                  color: Color(0xFF94A3B8)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 6. Cover Image URL
                      AppTextFormField1(
                        controller: controller.coverImageUrlController,
                        label: 'Cover Image URL (Optional)',
                        hintText: 'https://images.unsplash.com/...',
                        prefixIcon: const Icon(Icons.image_outlined,
                            color: Color(0xFF94A3B8)),
                      ),

                      const SizedBox(height: 20),

                      // 7. Active Status Switch
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
                    onPressed: () => Get.back(),
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
                                  if (success) {
                                    Get.back();
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
              separatorBuilder: (_, __) =>
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
}
