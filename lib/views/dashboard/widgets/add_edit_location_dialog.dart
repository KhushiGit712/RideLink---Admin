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
        width: 580,
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
                            isEditing ? 'Edit Location' : 'Add New Location',
                            style: AppTextStyle.text20Medium.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            isEditing
                                ? 'Update location metadata and coordinates'
                                : 'Create a new service hub or pickup/dropoff zone',
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
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 24),

              // Form Content
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location Name
                    AppTextFormField1(
                      controller: locCtrl.nameController,
                      label: 'Location / Hub Name',
                      hintText: 'e.g. Downtown Central Terminal',
                      prefixIcon: const Icon(Icons.business_rounded, color: Color(0xFF94A3B8)),
                    ),

                    const SizedBox(height: 16),

                    // Street Address
                    AppTextFormField1(
                      controller: locCtrl.addressController,
                      label: 'Street Address',
                      hintText: 'e.g. 500 Market Street, Suite 400',
                      prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF94A3B8)),
                    ),

                    const SizedBox(height: 16),

                    // City & State Row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppTextFormField1(
                            controller: locCtrl.cityController,
                            label: 'City',
                            hintText: 'e.g. San Francisco',
                            prefixIcon: const Icon(Icons.location_city_rounded, color: Color(0xFF94A3B8)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: AppTextFormField1(
                            controller: locCtrl.stateController,
                            label: 'State / Region',
                            hintText: 'e.g. CA',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Lat & Lng Row
                    Row(
                      children: [
                        Expanded(
                          child: AppTextFormField1(
                            controller: locCtrl.latController,
                            label: 'Latitude',
                            hintText: 'e.g. 37.7897',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            prefixIcon: const Icon(Icons.my_location_rounded, color: Color(0xFF94A3B8)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextFormField1(
                            controller: locCtrl.lngController,
                            label: 'Longitude',
                            hintText: 'e.g. -122.4005',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            prefixIcon: const Icon(Icons.my_location_rounded, color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Type & Capacity Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location Type',
                                style: AppTextStyle.text14Medium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Obx(() => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.stroke),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: locCtrl.selectedType.value,
                                        isExpanded: true,
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'Hub',
                                            child: Text('Hub'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Pickup Point',
                                            child: Text('Pickup Point'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Dropoff Zone',
                                            child: Text('Dropoff Zone'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Terminal',
                                            child: Text('Terminal'),
                                          ),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) {
                                            locCtrl.selectedType.value = val;
                                          }
                                        },
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextFormField1(
                            controller: locCtrl.capacityController,
                            label: 'Vehicle Capacity',
                            hintText: 'e.g. 25',
                            keyboardType: TextInputType.number,
                            prefixIcon: const Icon(Icons.directions_car_outlined, color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Active Status Switch Toggle
                    Obx(() => Container(
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
                                      'Active Service Status',
                                      style: AppTextStyle.text14Medium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      locCtrl.isActive.value
                                          ? 'Location will be visible & available for dispatch.'
                                          : 'Location will be temporarily disabled.',
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
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Dialog Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                  SizedBox(
                    width: 160,
                    child: AppButton(
                      label: isEditing ? 'Save Changes' : 'Create Location',
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
