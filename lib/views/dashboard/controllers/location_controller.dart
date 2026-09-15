import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/utils/app_snack_bar.dart';
import 'package:ridelink_admin/data/models/data/location_model.dart';

class LocationController extends GetxController {
  final RxList<LocationModel> locations = <LocationModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatusFilter = 'All'.obs; // All, Active, Inactive
  final RxString selectedTypeFilter = 'All'.obs; // All, Hub, Pickup Point, Dropoff Zone, Terminal

  // Form Field Controllers for Add/Edit Dialog
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();

  final RxString selectedType = 'Hub'.obs;
  final RxBool isActive = true.obs;
  final RxnString editingLocationId = RxnString();

  final GlobalKey<FormState> locationFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _loadInitialMockLocations();
  }

  void _loadInitialMockLocations() {
    locations.assignAll([
      LocationModel(
        id: 'LOC-101',
        name: 'Downtown Main Hub',
        address: '500 Market Street',
        city: 'San Francisco',
        state: 'CA',
        latitude: 37.7897,
        longitude: -122.4005,
        type: 'Hub',
        isActive: true,
        capacity: 35,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      LocationModel(
        id: 'LOC-102',
        name: 'SFO Airport Terminal Pickup',
        address: 'International Terminal, Door 3',
        city: 'San Francisco',
        state: 'CA',
        latitude: 37.6213,
        longitude: -122.3790,
        type: 'Pickup Point',
        isActive: true,
        capacity: 50,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      LocationModel(
        id: 'LOC-103',
        name: 'Oakland Tech Depot',
        address: '1200 Broadway Ave',
        city: 'Oakland',
        state: 'CA',
        latitude: 37.8044,
        longitude: -122.2712,
        type: 'Hub',
        isActive: true,
        capacity: 20,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      LocationModel(
        id: 'LOC-104',
        name: 'San Jose Caltrain Station',
        address: '65 Cahill St',
        city: 'San Jose',
        state: 'CA',
        latitude: 37.3300,
        longitude: -121.9025,
        type: 'Dropoff Zone',
        isActive: false,
        capacity: 15,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      LocationModel(
        id: 'LOC-105',
        name: 'Berkeley Campus Express Stop',
        address: 'Telegraph & Bancroft Way',
        city: 'Berkeley',
        state: 'CA',
        latitude: 37.8690,
        longitude: -122.2590,
        type: 'Terminal',
        isActive: true,
        capacity: 25,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ]);
  }

  List<LocationModel> get filteredLocations {
    return locations.where((loc) {
      // Search filter
      final query = searchQuery.value.toLowerCase();
      final matchesSearch = query.isEmpty ||
          loc.name.toLowerCase().contains(query) ||
          loc.address.toLowerCase().contains(query) ||
          loc.city.toLowerCase().contains(query) ||
          loc.id.toLowerCase().contains(query);

      // Status filter
      final matchesStatus = selectedStatusFilter.value == 'All' ||
          (selectedStatusFilter.value == 'Active' && loc.isActive) ||
          (selectedStatusFilter.value == 'Inactive' && !loc.isActive);

      // Type filter
      final matchesType = selectedTypeFilter.value == 'All' ||
          loc.type == selectedTypeFilter.value;

      return matchesSearch && matchesStatus && matchesType;
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

  void setTypeFilter(String type) {
    selectedTypeFilter.value = type;
  }

  void prepareAddLocation() {
    editingLocationId.value = null;
    nameController.clear();
    addressController.clear();
    cityController.clear();
    stateController.text = 'CA';
    latController.text = '37.7749';
    lngController.text = '-122.4194';
    capacityController.text = '15';
    selectedType.value = 'Hub';
    isActive.value = true;
  }

  void prepareEditLocation(LocationModel location) {
    editingLocationId.value = location.id;
    nameController.text = location.name;
    addressController.text = location.address;
    cityController.text = location.city;
    stateController.text = location.state;
    latController.text = location.latitude.toString();
    lngController.text = location.longitude.toString();
    capacityController.text = location.capacity.toString();
    selectedType.value = location.type;
    isActive.value = location.isActive;
  }

  bool saveLocation() {
    if (locationFormKey.currentState != null && !locationFormKey.currentState!.validate()) {
      return false;
    }

    final String name = nameController.text.trim();
    final String address = addressController.text.trim();
    final String city = cityController.text.trim();
    final String state = stateController.text.trim();
    final double lat = double.tryParse(latController.text.trim()) ?? 0.0;
    final double lng = double.tryParse(lngController.text.trim()) ?? 0.0;
    final int capacity = int.tryParse(capacityController.text.trim()) ?? 10;

    if (editingLocationId.value == null) {
      // Create New Location
      final newLocation = LocationModel(
        id: 'LOC-${100 + locations.length + 1}',
        name: name,
        address: address,
        city: city,
        state: state,
        latitude: lat,
        longitude: lng,
        type: selectedType.value,
        isActive: isActive.value,
        capacity: capacity,
        createdAt: DateTime.now(),
      );

      locations.insert(0, newLocation);
      AppSnackBar.success(message: 'Location "$name" created successfully!');
    } else {
      // Update Existing Location
      final index = locations.indexWhere((l) => l.id == editingLocationId.value);
      if (index != -1) {
        final existing = locations[index];
        final updated = existing.copyWith(
          name: name,
          address: address,
          city: city,
          state: state,
          latitude: lat,
          longitude: lng,
          type: selectedType.value,
          isActive: isActive.value,
          capacity: capacity,
        );
        locations[index] = updated;
        AppSnackBar.success(message: 'Location "$name" updated successfully!');
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
        message: 'Location "${loc.name}" is now ${newStatus ? 'Active' : 'Inactive'}',
      );
    }
  }

  void deleteLocation(String id) {
    final index = locations.indexWhere((l) => l.id == id);
    if (index != -1) {
      final name = locations[index].name;
      locations.removeAt(index);
      AppSnackBar.success(message: 'Location "$name" deleted successfully');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    latController.dispose();
    lngController.dispose();
    capacityController.dispose();
    super.onClose();
  }
}
