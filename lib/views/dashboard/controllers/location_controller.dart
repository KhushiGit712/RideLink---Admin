import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/utils/app_snack_bar.dart';
import 'package:ridelink_admin/data/models/data/location_model.dart';

class LocationController extends GetxController {
  final RxList<LocationModel> locations = <LocationModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatusFilter = 'All'.obs; // All, Active, Inactive

  // Form Field Controllers for Add/Edit Dialog (Section 5.1 & 7.4)
  final TextEditingController cityNameController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();
  final TextEditingController radiusKmController = TextEditingController();

  final RxBool isActive = true.obs;
  final RxnString editingLocationId = RxnString();

  final GlobalKey<FormState> locationFormKey = GlobalKey<FormState>();


  List<LocationModel> get filteredLocations {
    return locations.where((loc) {
      final query = searchQuery.value.toLowerCase();
      final matchesSearch = query.isEmpty ||
          loc.cityName.toLowerCase().contains(query) ||
          loc.state.toLowerCase().contains(query) ||
          loc.id.toLowerCase().contains(query);

      final matchesStatus = selectedStatusFilter.value == 'All' ||
          (selectedStatusFilter.value == 'Active' && loc.isActive) ||
          (selectedStatusFilter.value == 'Inactive' && !loc.isActive);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  int get totalCount => locations.length;
  int get activeCount => locations.where((l) => l.isActive).length;
  int get inactiveCount => locations.where((l) => !l.isActive).length;

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
  }

  void prepareAddLocation() {
    editingLocationId.value = null;
    cityNameController.clear();
    stateController.text = 'Texas';
    latController.text = '30.2672';
    lngController.text = '-97.7431';
    radiusKmController.text = '35.0';
    isActive.value = true;
  }

  void prepareEditLocation(LocationModel location) {
    editingLocationId.value = location.id;
    cityNameController.text = location.cityName;
    stateController.text = location.state;
    latController.text = location.centerLat.toString();
    lngController.text = location.centerLng.toString();
    radiusKmController.text = location.radiusKm.toString();
    isActive.value = location.isActive;
  }

  bool saveLocation() {
    if (locationFormKey.currentState != null &&
        !locationFormKey.currentState!.validate()) {
      return false;
    }

    final String cityName = cityNameController.text.trim();
    final String state = stateController.text.trim();
    final double lat = double.tryParse(latController.text.trim()) ?? 0.0;
    final double lng = double.tryParse(lngController.text.trim()) ?? 0.0;
    final double radius = double.tryParse(radiusKmController.text.trim()) ?? 35.0;

    if (editingLocationId.value == null) {
      // Create New Location
      final newLocation = LocationModel(
        id: 'loc_${10 + locations.length + 1}',
        cityName: cityName,
        state: state,
        centerLat: lat,
        centerLng: lng,
        radiusKm: radius,
        isActive: isActive.value,
        createdAt: DateTime.now(),
      );

      locations.insert(0, newLocation);
      AppSnackBar.success(message: 'Service location "$cityName" added successfully!');
    } else {
      // Update Existing Location
      final index = locations.indexWhere((l) => l.id == editingLocationId.value);
      if (index != -1) {
        final existing = locations[index];
        final updated = existing.copyWith(
          cityName: cityName,
          state: state,
          centerLat: lat,
          centerLng: lng,
          radiusKm: radius,
          isActive: isActive.value,
        );
        locations[index] = updated;
        AppSnackBar.success(message: 'Service location "$cityName" updated successfully!');
      }
    }
    return true;
  }

  void toggleLocationStatus(String id) {
    final index = locations.indexWhere((l) => l.id == id);
    if (index != -1) {
      final loc = locations[index];
      final newStatus = !loc.isActive;
      locations[index] = loc.copyWith(isActive: newStatus);
      AppSnackBar.success(
        message: 'Location "${loc.cityName}" is now ${newStatus ? 'Active' : 'Inactive'}',
      );
    }
  }

  void deleteLocation(String id) {
    final index = locations.indexWhere((l) => l.id == id);
    if (index != -1) {
      final name = locations[index].cityName;
      locations.removeAt(index);
      AppSnackBar.success(message: 'Service location "$name" deleted successfully');
    }
  }

  @override
  void onClose() {
    cityNameController.dispose();
    stateController.dispose();
    latController.dispose();
    lngController.dispose();
    radiusKmController.dispose();
    super.onClose();
  }
}
