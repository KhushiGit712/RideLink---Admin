import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/constants/app_colors.dart';
import 'package:ridelink_admin/theme/app_text_style.dart';
import 'package:ridelink_admin/views/dashboard/controllers/location_controller.dart';
import 'package:ridelink_admin/widgets/app_button.dart';
import 'package:ridelink_admin/widgets/app_text_field.dart';

class AddEditLocationDialog extends StatelessWidget {
  const AddEditLocationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final locCtrl = Get.find<LocationController>();
    final isEditing = locCtrl.editingLocationId.value != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: 560,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: locCtrl.locationFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isEditing
                              ? Icons.edit_location_alt_rounded
                              : Icons.add_location_alt_rounded,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Edit Service Area' : 'Add New Service Area',
                            style: AppTextStyle.text20Medium.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            isEditing
                                ? 'Update center coordinates & operating radius'
                                : 'Define an allowed operating city and operating radius in KM',
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
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 20),

              // Form Content (Section 5.1 & 7.4)
              // City / Region Name
              AppTextFormField1(
                controller: locCtrl.cityNameController,
                label: 'City / Region Name',
                hintText: 'e.g. Austin Metro Area',
                prefixIcon: const Icon(
                  Icons.location_city_rounded,
                  color: Color(0xFF94A3B8),
                ),
              ),

              const SizedBox(height: 16),

              // State / Region & Operating Radius in KM
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: AppTextFormField1(
                      controller: locCtrl.stateController,
                      label: 'State / Region',
                      hintText: 'e.g. Texas',
                      prefixIcon: const Icon(
                        Icons.map_outlined,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: AppTextFormField1(
                      controller: locCtrl.radiusKmController,
                      label: 'Operating Radius (KM)',
                      hintText: 'e.g. 40.0',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: const Icon(
                        Icons.radar_rounded,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Center Latitude & Longitude
              Row(
                children: [
                  Expanded(
                    child: AppTextFormField1(
                      controller: locCtrl.latController,
                      label: 'Center Latitude',
                      hintText: 'e.g. 30.2672',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: const Icon(
                        Icons.my_location_rounded,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextFormField1(
                      controller: locCtrl.lngController,
                      label: 'Center Longitude',
                      hintText: 'e.g. -97.7431',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: const Icon(
                        Icons.my_location_rounded,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Active / Inactive Switch Toggle (Section 5.1)
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        locCtrl.isActive.value
                            ? Icons.check_circle_rounded
                            : Icons.pause_circle_rounded,
                        color: locCtrl.isActive.value
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Service Status (${locCtrl.isActive.value ? 'Active' : 'Inactive'})',
                              style: AppTextStyle.text14Medium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              locCtrl.isActive.value
                                  ? 'Rides can be scheduled & requested within this zone.'
                                  : 'Disabled. Users will see: "RideLink is not available in this area yet."',
                              style: AppTextStyle.text12MediumOrSmall.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: locCtrl.isActive.value,
                        activeColor: const Color(0xFF2563EB),
                        onChanged: (val) => locCtrl.isActive.value = val,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Dialog Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  SizedBox(
                    width: 170,
                    child: AppButton(
                      label: isEditing ? 'Save Changes' : 'Add Location',
                      onPressed: () {
                        if (locCtrl.saveLocation()) {
                          Get.back();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
