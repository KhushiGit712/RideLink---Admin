import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/core/utils/app_snack_bar.dart';
import 'package:ridelink_admin/data/models/data/community_model.dart';
import 'package:ridelink_admin/data/services/google_places_service.dart';

class CommunityController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _communitiesSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _membersSubscription;

  final RxList<CommunityModel> communities = <CommunityModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // Search & Filters
  final RxString searchQuery = ''.obs;
  final RxString selectedCategoryFilter = 'All'.obs;
  final RxString selectedStatusFilter = 'All'.obs; // All, Active, Inactive
  final RxBool isCardView = false.obs;

  // Selected Community & Subcollection Members
  final Rx<CommunityModel?> selectedCommunity = Rx<CommunityModel?>(null);
  final RxList<CommunityMemberModel> communityMembers =
      <CommunityMemberModel>[].obs;
  final RxBool isLoadingMembers = false.obs;

  // Form Fields for Add/Edit Community (Section 6.2)
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController routeSummaryController = TextEditingController();
  final TextEditingController pickupLocationController = TextEditingController();
  final TextEditingController dropOffLocationController = TextEditingController();
  final RxList<String> pickupPredictions = <String>[].obs;
  final RxBool isSearchingPickup = false.obs;
  final RxList<String> dropPredictions = <String>[].obs;
  final RxBool isSearchingDrop = false.obs;
  final RxBool showPlacesSearch = false.obs;
  Timer? _placesDebounceTimer;
  final TextEditingController commonTimeController = TextEditingController();
  final RxString selectedIcon = 'school'.obs; // school, business, hospital, car
  final RxString selectedCategory = 'university'
      .obs; // university, corporate, healthcare, metro, corridor
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController nextRideTimeController = TextEditingController();
  final TextEditingController nextRideSeatsOpenController =
      TextEditingController();
  final TextEditingController coverImageUrlController = TextEditingController();
  final RxBool isActive = true.obs;
  final RxnString editingCommunityId = RxnString();

  static const List<String> availableIcons = [
    'school',
    'business',
    'hospital',
    'car',
  ];

  static const List<String> availableCategories = [
    'university',
    'corporate',
    'healthcare',
    'metro',
    'corridor',
  ];

  static IconData getIconData(String iconKey) {
    switch (iconKey.toLowerCase()) {
      case 'business':
        return Icons.business_center_outlined;
      case 'hospital':
        return Icons.local_hospital_outlined;
      case 'car':
        return Icons.directions_car_outlined;
      case 'school':
      default:
        return Icons.school_outlined;
    }
  }

  static String getIconLabel(String iconKey) {
    switch (iconKey.toLowerCase()) {
      case 'business':
        return 'Corporate / CBD (business)';
      case 'hospital':
        return 'Hospital / Healthcare (hospital)';
      case 'car':
        return 'Commuter Corridor (car)';
      case 'school':
      default:
        return 'University / Campus (school)';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initFirestoreListener();
  }

  void _initFirestoreListener() {
    isLoading(true);
    try {
      _communitiesSubscription = _firestore
          .collection('communities')
          .snapshots()
          .listen(
        (snapshot) {
          final List<CommunityModel> loaded = [];
          for (final doc in snapshot.docs) {
            try {
              loaded.add(CommunityModel.fromSnapshot(doc));
            } catch (e) {
              debugPrint('Error parsing community doc ${doc.id}: $e');
            }
          }
          // Sort by createdAt descending
          loaded.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          communities.assignAll(loaded);
          isLoading(false);

          // Keep selectedCommunity updated if currently open
          if (selectedCommunity.value != null) {
            final updated = communities.firstWhereOrNull(
              (c) => c.id == selectedCommunity.value!.id,
            );
            selectedCommunity.value = updated;
          } else if (loaded.isNotEmpty) {
            openCommunityMembers(loaded.first);
          }
        },
        onError: (err) {
          debugPrint('Firestore communities listener error: $err');
          isLoading(false);
          AppSnackBar.error(message: 'Failed to load communities: $err');
        },
      );
    } catch (e) {
      isLoading(false);
      debugPrint('Failed to initialize community listener: $e');
    }
  }

  List<CommunityModel> get filteredCommunities {
    return communities.where((com) {
      final query = searchQuery.value.toLowerCase().trim();
      final matchesSearch = query.isEmpty ||
          com.name.toLowerCase().contains(query) ||
          com.routeSummary.toLowerCase().contains(query) ||
          com.pickupLocation.toLowerCase().contains(query) ||
          com.dropOffLocation.toLowerCase().contains(query) ||
          com.description.toLowerCase().contains(query) ||
          com.id.toLowerCase().contains(query);

      final matchesCategory = selectedCategoryFilter.value == 'All' ||
          com.category.toLowerCase() ==
              selectedCategoryFilter.value.toLowerCase();

      final matchesStatus = selectedStatusFilter.value == 'All' ||
          (selectedStatusFilter.value == 'Active' && com.isActive) ||
          (selectedStatusFilter.value == 'Inactive' && !com.isActive);

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  int get totalCount => communities.length;
  int get activeCount => communities.where((c) => c.isActive).length;
  int get inactiveCount => communities.where((c) => !c.isActive).length;
  int get totalPassengers =>
      communities.fold(0, (total, c) => total + c.passengersCount);
  int get totalDrivers =>
      communities.fold(0, (total, c) => total + c.driversCount);

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setCategoryFilter(String cat) {
    selectedCategoryFilter.value = cat;
  }

  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
  }

  void onPickupSearchChanged(String query) {
    _placesDebounceTimer?.cancel();
    if (query.trim().length < 2) {
      pickupPredictions.clear();
      isSearchingPickup(false);
      return;
    }
    _placesDebounceTimer = Timer(const Duration(milliseconds: 350), () async {
      isSearchingPickup(true);
      final results = await GooglePlacesService.getPlacePredictions(query);
      pickupPredictions.assignAll(results);
      isSearchingPickup(false);
    });
  }

  void selectPickupPrediction(String place) {
    pickupLocationController.text = place;
    pickupPredictions.clear();
    _syncRouteSummaryFromLocations();
  }

  void onDropSearchChanged(String query) {
    _placesDebounceTimer?.cancel();
    if (query.trim().length < 2) {
      dropPredictions.clear();
      isSearchingDrop(false);
      return;
    }
    _placesDebounceTimer = Timer(const Duration(milliseconds: 350), () async {
      isSearchingDrop(true);
      final results = await GooglePlacesService.getPlacePredictions(query);
      dropPredictions.assignAll(results);
      isSearchingDrop(false);
    });
  }

  void selectDropPrediction(String place) {
    dropOffLocationController.text = place;
    dropPredictions.clear();
    _syncRouteSummaryFromLocations();
  }

  void _syncRouteSummaryFromLocations() {
    final p = pickupLocationController.text.trim();
    final d = dropOffLocationController.text.trim();
    if (p.isNotEmpty && d.isNotEmpty) {
      routeSummaryController.text = '$p → $d';
    } else if (p.isNotEmpty) {
      routeSummaryController.text = p;
    } else if (d.isNotEmpty) {
      routeSummaryController.text = d;
    }
  }

  void prepareAddCommunity() {
    editingCommunityId.value = null;
    nameController.clear();
    routeSummaryController.clear();
    pickupLocationController.clear();
    dropOffLocationController.clear();
    pickupPredictions.clear();
    dropPredictions.clear();
    showPlacesSearch.value = false;
    commonTimeController.text = '7:30 AM - 9:00 AM';
    selectedIcon.value = 'school';
    selectedCategory.value = 'university';
    descriptionController.clear();
    nextRideTimeController.text = 'Tomorrow 8:00 AM';
    nextRideSeatsOpenController.text = '3';
    coverImageUrlController.clear();
    isActive.value = true;
  }

  void prepareEditCommunity(CommunityModel community) {
    editingCommunityId.value = community.id;
    nameController.text = community.name;
    routeSummaryController.text = community.routeSummary;
    pickupLocationController.text = community.pickupLocation;
    dropOffLocationController.text = community.dropOffLocation;
    pickupPredictions.clear();
    dropPredictions.clear();
    showPlacesSearch.value = false;
    commonTimeController.text = community.commonTime;
    selectedIcon.value = availableIcons.contains(community.icon)
        ? community.icon
        : 'school';
    selectedCategory.value = availableCategories.contains(community.category)
        ? community.category
        : 'university';
    descriptionController.text = community.description;
    nextRideTimeController.text = community.nextRideTime;
    nextRideSeatsOpenController.text = community.nextRideSeatsOpen.toString();
    coverImageUrlController.text = community.coverImageUrl;
    isActive.value = community.isActive;
  }

  Future<bool> saveCommunity() async {
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      return false;
    }

    final String name = nameController.text.trim();
    final String routeSummary = routeSummaryController.text.trim();
    final String commonTime = commonTimeController.text.trim();
    final String description = descriptionController.text.trim();
    final String nextRideTime = nextRideTimeController.text.trim().isEmpty
        ? 'Tomorrow 8:00 AM'
        : nextRideTimeController.text.trim();
    final int nextRideSeatsOpen =
        int.tryParse(nextRideSeatsOpenController.text.trim()) ?? 3;
    final String coverImageUrl = coverImageUrlController.text.trim();

    isSaving(true);
    try {
      if (editingCommunityId.value == null) {
        // Create new community in Firestore
        final docRef = _firestore.collection('communities').doc();
        final newCommunity = CommunityModel(
          id: docRef.id,
          name: name,
          routeSummary: routeSummary,
          commonTime: commonTime,
          description: description,
          icon: selectedIcon.value,
          category: selectedCategory.value,
          passengersCount: 0,
          driversCount: 0,
          nextRideTime: nextRideTime,
          nextRideSeatsOpen: nextRideSeatsOpen,
          memberIds: [],
          passengerMemberIds: [],
          driverMemberIds: [],
          coverImageUrl: coverImageUrl,
          isActive: isActive.value,
          createdAt: DateTime.now(),
        );

        await docRef.set(newCommunity.toFirestore());
        AppSnackBar.success(message: 'Community "$name" created successfully!');
      } else {
        // Update existing community in Firestore
        final String id = editingCommunityId.value!;
        final temp = CommunityModel(
          id: id,
          name: name,
          routeSummary: routeSummary,
        );
        await _firestore.collection('communities').doc(id).update({
          'name': name,
          'routeSummary': routeSummary,
          'pickupLocation': temp.pickupLocation,
          'dropOffLocation': temp.dropOffLocation,
          'commonTime': commonTime,
          'description': description,
          'icon': selectedIcon.value,
          'category': selectedCategory.value,
          'nextRideTime': nextRideTime,
          'nextRideSeatsOpen': nextRideSeatsOpen,
          'coverImageUrl': coverImageUrl,
          'isActive': isActive.value,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        AppSnackBar.success(message: 'Community "$name" updated successfully!');
      }
      isSaving(false);
      return true;
    } catch (e) {
      isSaving(false);
      AppSnackBar.error(message: 'Failed to save community: $e');
      return false;
    }
  }

  Future<void> toggleCommunityStatus(String id) async {
    final com = communities.firstWhereOrNull((c) => c.id == id);
    if (com == null) return;

    final newStatus = !com.isActive;
    try {
      await _firestore.collection('communities').doc(id).update({
        'isActive': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppSnackBar.success(
        message:
            'Community "${com.name}" is now ${newStatus ? 'Active' : 'Inactive'}',
      );
    } catch (e) {
      AppSnackBar.error(message: 'Failed to update community status: $e');
    }
  }

  Future<void> deleteCommunity(String id) async {
    final com = communities.firstWhereOrNull((c) => c.id == id);
    final name = com?.name ?? id;
    try {
      // 1. Delete all member subcollection docs if any
      final membersSnap = await _firestore
          .collection('communities')
          .doc(id)
          .collection('members')
          .get();
      for (final doc in membersSnap.docs) {
        await doc.reference.delete();
      }

      // 2. Delete primary community document
      await _firestore.collection('communities').doc(id).delete();
      if (selectedCommunity.value?.id == id) {
        closeCommunityMembers();
      }
      AppSnackBar.success(message: 'Community "$name" deleted successfully.');
    } catch (e) {
      AppSnackBar.error(message: 'Failed to delete community: $e');
    }
  }

  // --- Subcollection Members Management (Section 6.3) ---

  void openCommunityMembers(CommunityModel community) {
    selectedCommunity.value = community;
    _membersSubscription?.cancel();
    isLoadingMembers(true);
    communityMembers.clear();

    _membersSubscription = _firestore
        .collection('communities')
        .doc(community.id)
        .collection('members')
        .snapshots()
        .listen(
      (snapshot) {
        final List<CommunityMemberModel> loaded = [];
        for (final doc in snapshot.docs) {
          try {
            loaded.add(CommunityMemberModel.fromSnapshot(doc));
          } catch (e) {
            debugPrint('Error parsing community member ${doc.id}: $e');
          }
        }
        loaded.sort((a, b) => b.joinedAt.compareTo(a.joinedAt));
        communityMembers.assignAll(loaded);
        isLoadingMembers(false);
      },
      onError: (err) {
        debugPrint('Members subscription error: $err');
        isLoadingMembers(false);
        AppSnackBar.error(message: 'Failed to load community members: $err');
      },
    );
  }

  void closeCommunityMembers() {
    _membersSubscription?.cancel();
    _membersSubscription = null;
    selectedCommunity.value = null;
    communityMembers.clear();
  }

  Future<void> removeMemberFromCommunity(
      String communityId, CommunityMemberModel member) async {
    try {
      final isDriver = member.isDriver;

      // 1. Delete doc from subcollection
      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('members')
          .doc(member.userId)
          .delete();

      // 2. Update arrays & counts in parent document
      final updateData = <String, dynamic>{
        'memberIds': FieldValue.arrayRemove([member.userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isDriver) {
        updateData['driverMemberIds'] =
            FieldValue.arrayRemove([member.userId]);
        updateData['driversCount'] = FieldValue.increment(-1);
      } else {
        updateData['passengerMemberIds'] =
            FieldValue.arrayRemove([member.userId]);
        updateData['passengersCount'] = FieldValue.increment(-1);
      }

      await _firestore.collection('communities').doc(communityId).update(updateData);

      // 3. Remove community from user profile if doc exists
      try {
        await _firestore.collection('users').doc(member.userId).update({
          'joinedCommunities': FieldValue.arrayRemove([communityId]),
        });
      } catch (_) {
        // User doc may not exist or not have permissions
      }

      AppSnackBar.success(message: 'Member "${member.name}" removed from community.');
    } catch (e) {
      AppSnackBar.error(message: 'Failed to remove member: $e');
    }
  }

  @override
  void onClose() {
    _communitiesSubscription?.cancel();
    _membersSubscription?.cancel();
    nameController.dispose();
    routeSummaryController.dispose();
    pickupLocationController.dispose();
    dropOffLocationController.dispose();
    _placesDebounceTimer?.cancel();
    commonTimeController.dispose();
    descriptionController.dispose();
    nextRideTimeController.dispose();
    nextRideSeatsOpenController.dispose();
    coverImageUrlController.dispose();
    super.onClose();
  }
}
