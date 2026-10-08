import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ridelink_admin/views/dashboard/controllers/community_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/driver_document_controller.dart';
import 'package:ridelink_admin/views/dashboard/controllers/support_ticket_controller.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _usersSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ridesSub;

  final RxInt selectedIndex = 0.obs;
  final RxBool isSidebarCollapsed = false.obs;
  final RxBool isLoadingStats = false.obs;

  // 1. User & Driver Metrics (Live numbers from Firestore)
  final RxInt totalUsers = 0.obs;
  final RxInt totalRiders = 0.obs;
  final RxInt totalDrivers = 0.obs;
  final RxInt verifiedDrivers = 0.obs;
  final RxInt newUsersToday = 0.obs;

  // Legacy bindings support
  final RxInt totalPassengers = 0.obs;
  final RxInt activeRidesToday = 0.obs;

  // 2. Rides & Trips Metrics (Live numbers from Firestore)
  final RxInt totalRides = 0.obs;
  final RxInt activeRides = 0.obs;
  final RxInt completedRides = 0.obs;
  final RxInt scheduledRides = 0.obs;
  final RxInt cancelledRides = 0.obs;
  final RxInt ridesToday = 0.obs;

  // 3. Last Updated Timestamp
  final Rx<DateTime> lastUpdated = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    _initDashboardListeners();
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  void toggleSidebar() {
    isSidebarCollapsed.value = !isSidebarCollapsed.value;
  }

  int get unreadNotifications {
    if (Get.isRegistered<SupportTicketController>()) {
      return Get.find<SupportTicketController>().unresolvedCount;
    }
    return 0;
  }

  void refreshMetrics() {
    _initDashboardListeners();
  }

  void _initDashboardListeners() {
    isLoadingStats(true);

    _usersSub?.cancel();
    _ridesSub?.cancel();

    // 1. Real-time stream for 'users' collection in Firestore
    try {
      _usersSub = _firestore
          .collection('users')
          .snapshots()
          .listen(
            (snapshot) {
              int usersCount = snapshot.docs.length;
              int drivers = 0;
              int riders = 0;
              int verified = 0;
              int todayUsers = 0;

              final now = DateTime.now();
              final startOfToday = DateTime(now.year, now.month, now.day);
              final Set<String> foundDriverIds = {};

              for (final doc in snapshot.docs) {
                final data = doc.data();
                final activeRole = (data['activeRole'] ?? data['role'] ?? data['userType'] ?? '')
                    .toString()
                    .toLowerCase();
                final rawRoles = data['roles'];
                final roles = rawRoles is List
                    ? rawRoles.map((e) => e.toString().toLowerCase()).toList()
                    : <String>[];
                final driverStats = data['driverStats'] is Map ? data['driverStats'] as Map : {};
                final isVerifiedDriver = data['is_verified_driver'] == true ||
                    driverStats['isVerifiedDriver'] == true ||
                    data['isDriverVerified'] == true;

                final isDriver = roles.contains('driver') ||
                    activeRole == 'driver' ||
                    data['isDriver'] == true ||
                    isVerifiedDriver ||
                    data['vehicle'] != null;

                if (isDriver) {
                  drivers++;
                  foundDriverIds.add(doc.id);
                  if (isVerifiedDriver) verified++;
                } else {
                  riders++;
                }

                // Check if user was registered today
                DateTime? created;
                final rawCreated = data['createdAt'];
                if (rawCreated is Timestamp) {
                  created = rawCreated.toDate();
                } else if (rawCreated is String) {
                  created = DateTime.tryParse(rawCreated);
                }
                if (created != null && created.isAfter(startOfToday)) {
                  todayUsers++;
                }
              }

              // Check if driver KYC applications are in driver_verifications
              if (Get.isRegistered<DriverDocumentController>()) {
                final driverCtrl = Get.find<DriverDocumentController>();
                for (final req in driverCtrl.requests) {
                  if (!foundDriverIds.contains(req.driverId) &&
                      !foundDriverIds.contains(req.id)) {
                    foundDriverIds.add(req.driverId);
                    drivers++;
                    if (req.isApproved) verified++;
                  }
                }
              }

              if (usersCount > 0) {
                totalUsers.value = usersCount;
                totalRiders.value = riders;
                totalPassengers.value = riders;
                totalDrivers.value = drivers;
                verifiedDrivers.value = verified;
                newUsersToday.value = todayUsers;
              } else {
                _fallbackFromOtherControllers();
              }

              lastUpdated.value = DateTime.now();
              isLoadingStats(false);
            },
            onError: (err) {
              debugPrint('Dashboard users collection stream error: $err');
              _fallbackFromOtherControllers();
              isLoadingStats(false);
            },
          );
    } catch (e) {
      debugPrint('Failed to initialize users collection listener: $e');
      _fallbackFromOtherControllers();
      isLoadingStats(false);
    }

    // 2. Real-time stream for 'rides' collection in Firestore
    try {
      _ridesSub = _firestore
          .collection('rides')
          .snapshots()
          .listen(
            (snapshot) {
              int total = snapshot.docs.length;
              int active = 0;
              int completed = 0;
              int scheduled = 0;
              int cancelled = 0;
              int todayRides = 0;

              final now = DateTime.now();
              final startOfToday = DateTime(now.year, now.month, now.day);

              for (final doc in snapshot.docs) {
                final data = doc.data();
                final status = (data['status'] ?? '').toString().toLowerCase();

                if (status == 'active' ||
                    status == 'ongoing' ||
                    status == 'in_progress' ||
                    status == 'started') {
                  active++;
                } else if (status == 'completed' || status == 'finished') {
                  completed++;
                } else if (status == 'scheduled' ||
                    status == 'pending' ||
                    status == 'booked' ||
                    status == 'open') {
                  scheduled++;
                } else if (status == 'cancelled' || status == 'canceled') {
                  cancelled++;
                } else {
                  active++;
                }

                DateTime? created;
                if (data['createdAt'] is Timestamp) {
                  created = (data['createdAt'] as Timestamp).toDate();
                } else if (data['date'] is Timestamp) {
                  created = (data['date'] as Timestamp).toDate();
                } else if (data['createdAt'] is String) {
                  created = DateTime.tryParse(data['createdAt'] as String);
                }
                if (created != null && created.isAfter(startOfToday)) {
                  todayRides++;
                }
              }

              totalRides.value = total;
              activeRides.value = active;
              activeRidesToday.value = active;
              completedRides.value = completed;
              scheduledRides.value = scheduled;
              cancelledRides.value = cancelled;
              ridesToday.value = todayRides;

              lastUpdated.value = DateTime.now();
            },
            onError: (err) {
              debugPrint('Dashboard rides collection stream error: $err');
            },
          );
    } catch (e) {
      debugPrint('Failed to initialize rides collection listener: $e');
    }
  }

  void _fallbackFromOtherControllers() {
    int drivers = 0;
    int verified = 0;
    if (Get.isRegistered<DriverDocumentController>()) {
      final driverCtrl = Get.find<DriverDocumentController>();
      drivers = driverCtrl.requests.length;
      verified = driverCtrl.approvedCount;
    }

    int riders = 0;
    if (Get.isRegistered<CommunityController>()) {
      final commCtrl = Get.find<CommunityController>();
      riders = commCtrl.totalPassengers;
      if (drivers == 0) drivers = commCtrl.totalDrivers;
    }

    totalDrivers.value = drivers;
    verifiedDrivers.value = verified;
    totalRiders.value = riders;
    totalPassengers.value = riders;
    totalUsers.value = riders + drivers;
  }

  @override
  void onClose() {
    _usersSub?.cancel();
    _ridesSub?.cancel();
    super.onClose();
  }
}
