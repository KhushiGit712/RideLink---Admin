import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CommunityMemberModel {
  final String userId;
  final String name;
  final String role; // 'passenger' or 'driver'
  final String? email;
  final String? phone;
  final DateTime joinedAt;

  CommunityMemberModel({
    required this.userId,
    required this.name,
    required this.role,
    this.email,
    this.phone,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  bool get isDriver => role.toLowerCase() == 'driver';
  bool get isPassenger => role.toLowerCase() == 'passenger';

  String get formattedJoinedDate =>
      DateFormat('MMM dd, yyyy • hh:mm a').format(joinedAt);

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'role': role,
      'email': email ?? '',
      'phone': phone ?? '',
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'role': role,
      'email': email,
      'phone': phone,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory CommunityMemberModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    DateTime parsedJoined = DateTime.now();
    if (data['joinedAt'] is Timestamp) {
      parsedJoined = (data['joinedAt'] as Timestamp).toDate();
    } else if (data['joinedAt'] is String) {
      parsedJoined =
          DateTime.tryParse(data['joinedAt'] as String) ?? DateTime.now();
    }

    return CommunityMemberModel(
      userId: data['userId'] ?? doc.id,
      name: data['name'] ?? 'Unnamed Member',
      role: data['role'] ?? 'passenger',
      email: data['email']?.toString(),
      phone: data['phone']?.toString(),
      joinedAt: parsedJoined,
    );
  }

  factory CommunityMemberModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedJoined = DateTime.now();
    if (json['joinedAt'] is Timestamp) {
      parsedJoined = (json['joinedAt'] as Timestamp).toDate();
    } else if (json['joinedAt'] != null) {
      parsedJoined =
          DateTime.tryParse(json['joinedAt'].toString()) ?? DateTime.now();
    }

    return CommunityMemberModel(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'passenger',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      joinedAt: parsedJoined,
    );
  }
}

class CommunityModel {
  final String id;
  final String name;
  final String routeSummary;
  final String? explicitPickupLocation;
  final String? explicitDropOffLocation;
  final String commonTime; // e.g. "7:30 AM - 9:00 AM"
  final String description;
  final String icon; // 'school', 'business', 'hospital', 'home', 'stadium'
  final String category; // 'university', 'corporate', 'healthcare', 'metro', 'corridor'
  final String fixedLocationType; // 'dropoff', 'pickup', 'both', 'none'
  final bool isFixedPickup;
  final bool isFixedDropOff;
  final String? fixedLocation;
  final int passengersCount;
  final int driversCount;
  final String nextRideTime;
  final int nextRideSeatsOpen;
  final String recurringOption; // 'Daily', 'Weekdays', 'Weekends', 'Weekly', 'Custom', 'One-time'
  final List<String> recurringDays;
  final List<String> memberIds;
  final List<String> passengerMemberIds;
  final List<String> driverMemberIds;
  final String coverImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CommunityModel({
    required this.id,
    required this.name,
    required this.routeSummary,
    this.explicitPickupLocation,
    this.explicitDropOffLocation,
    this.commonTime = '7:30 AM - 9:00 AM',
    this.description = '',
    this.icon = 'school',
    this.category = 'university',
    this.fixedLocationType = 'both',
    bool? isFixedPickup,
    bool? isFixedDropOff,
    this.fixedLocation,
    this.passengersCount = 0,
    this.driversCount = 0,
    this.nextRideTime = 'Tomorrow 8:00 AM',
    this.nextRideSeatsOpen = 0,
    this.recurringOption = 'Weekdays',
    List<String>? recurringDays,
    List<String>? memberIds,
    List<String>? passengerMemberIds,
    List<String>? driverMemberIds,
    this.coverImageUrl = '',
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
  })  : isFixedPickup = isFixedPickup ??
            (fixedLocationType == 'pickup' || fixedLocationType == 'both'),
        isFixedDropOff = isFixedDropOff ??
            (fixedLocationType == 'dropoff' || fixedLocationType == 'both'),
        recurringDays = recurringDays ?? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        memberIds = memberIds ?? [],
        passengerMemberIds = passengerMemberIds ?? [],
        driverMemberIds = driverMemberIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  CommunityModel copyWith({
    String? id,
    String? name,
    String? routeSummary,
    String? explicitPickupLocation,
    String? explicitDropOffLocation,
    String? commonTime,
    String? description,
    String? icon,
    String? category,
    String? fixedLocationType,
    bool? isFixedPickup,
    bool? isFixedDropOff,
    String? fixedLocation,
    int? passengersCount,
    int? driversCount,
    String? nextRideTime,
    int? nextRideSeatsOpen,
    String? recurringOption,
    List<String>? recurringDays,
    List<String>? memberIds,
    List<String>? passengerMemberIds,
    List<String>? driverMemberIds,
    String? coverImageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      routeSummary: routeSummary ?? this.routeSummary,
      explicitPickupLocation:
          explicitPickupLocation ?? this.explicitPickupLocation,
      explicitDropOffLocation:
          explicitDropOffLocation ?? this.explicitDropOffLocation,
      commonTime: commonTime ?? this.commonTime,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      fixedLocationType: fixedLocationType ?? this.fixedLocationType,
      isFixedPickup: isFixedPickup ?? this.isFixedPickup,
      isFixedDropOff: isFixedDropOff ?? this.isFixedDropOff,
      fixedLocation: fixedLocation ?? this.fixedLocation,
      passengersCount: passengersCount ?? this.passengersCount,
      driversCount: driversCount ?? this.driversCount,
      nextRideTime: nextRideTime ?? this.nextRideTime,
      nextRideSeatsOpen: nextRideSeatsOpen ?? this.nextRideSeatsOpen,
      recurringOption: recurringOption ?? this.recurringOption,
      recurringDays: recurringDays ?? this.recurringDays,
      memberIds: memberIds ?? this.memberIds,
      passengerMemberIds: passengerMemberIds ?? this.passengerMemberIds,
      driverMemberIds: driverMemberIds ?? this.driverMemberIds,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get pickupLocation {
    if (explicitPickupLocation != null &&
        explicitPickupLocation!.trim().isNotEmpty) {
      return explicitPickupLocation!.trim();
    }
    final s = routeSummary.trim();
    if (s.contains('→')) return s.split('→').first.trim();
    if (s.contains('->')) return s.split('->').first.trim();
    if (s.contains('⇄')) return s.split('⇄').first.trim();
    if (s.contains('<->')) return s.split('<->').first.trim();
    if (s.contains(' - ')) return s.split(' - ').first.trim();
    if (s.contains(' to ')) return s.split(' to ').first.trim();
    return s.isNotEmpty ? s : 'Corridor Origin';
  }

  String get dropOffLocation {
    if (explicitDropOffLocation != null &&
        explicitDropOffLocation!.trim().isNotEmpty) {
      return explicitDropOffLocation!.trim();
    }
    final s = routeSummary.trim();
    if (s.contains('→')) return s.split('→').last.trim();
    if (s.contains('->')) return s.split('->').last.trim();
    if (s.contains('⇄')) return s.split('⇄').last.trim();
    if (s.contains('<->')) return s.split('<->').last.trim();
    if (s.contains(' - ')) return s.split(' - ').last.trim();
    if (s.contains(' to ')) return s.split(' to ').last.trim();
    return 'Corridor Destination';
  }

  static String extractRouteSummary(Map<String, dynamic> data) {
    final explicit = (data['routeSummary'] ??
            data['corridor'] ??
            data['route'] ??
            data['route_summary'] ??
            '')
        .toString()
        .trim();

    if (explicit.isNotEmpty) {
      return explicit;
    }

    final pickup = (data['pickupLocation'] ??
            data['pickup_location'] ??
            data['pickup'] ??
            data['from'] ??
            data['origin'] ??
            data['startLocation'] ??
            '')
        .toString()
        .trim();

    final drop = (data['dropOffLocation'] ??
            data['dropoffLocation'] ??
            data['drop_off_location'] ??
            data['dropoff'] ??
            data['to'] ??
            data['destination'] ??
            '')
        .toString()
        .trim();

    if (pickup.isNotEmpty && drop.isNotEmpty) {
      return '$pickup → $drop';
    } else if (pickup.isNotEmpty) {
      return pickup;
    } else if (drop.isNotEmpty) {
      return drop;
    } else if (data['pickupPoints'] is List &&
        (data['pickupPoints'] as List).isNotEmpty) {
      final p = (data['pickupPoints'] as List).first.toString().trim();
      final d = (data['dropPoints'] is List &&
              (data['dropPoints'] as List).isNotEmpty)
          ? (data['dropPoints'] as List).first.toString().trim()
          : '';
      return d.isNotEmpty ? '$p → $d' : p;
    } else if (data['name'] != null &&
        data['name'].toString().trim().isNotEmpty) {
      return '${data['name'].toString().trim()} Corridor';
    }
    return 'Transit Corridor';
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'routeSummary': routeSummary,
      'pickupLocation': pickupLocation,
      'dropOffLocation': dropOffLocation,
      'fixedLocationType': fixedLocationType,
      'isFixedPickup': isFixedPickup,
      'isFixedDropOff': isFixedDropOff,
      'fixedLocation': fixedLocation ??
          (fixedLocationType == 'dropoff'
              ? dropOffLocation
              : (fixedLocationType == 'pickup' ? pickupLocation : routeSummary)),
      'commonTime': commonTime,
      'description': description,
      'icon': icon,
      'category': category,
      'passengersCount': passengersCount,
      'driversCount': driversCount,
      'nextRideTime': nextRideTime,
      'nextRideSeatsOpen': nextRideSeatsOpen,
      'recurringOption': recurringOption,
      'recurringDays': recurringDays,
      'memberIds': memberIds,
      'passengerMemberIds': passengerMemberIds,
      'driverMemberIds': driverMemberIds,
      'coverImageUrl': coverImageUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'routeSummary': routeSummary,
      'pickupLocation': pickupLocation,
      'dropOffLocation': dropOffLocation,
      'fixedLocationType': fixedLocationType,
      'isFixedPickup': isFixedPickup,
      'isFixedDropOff': isFixedDropOff,
      'fixedLocation': fixedLocation,
      'commonTime': commonTime,
      'description': description,
      'icon': icon,
      'category': category,
      'passengersCount': passengersCount,
      'driversCount': driversCount,
      'nextRideTime': nextRideTime,
      'nextRideSeatsOpen': nextRideSeatsOpen,
      'recurringOption': recurringOption,
      'recurringDays': recurringDays,
      'memberIds': memberIds,
      'passengerMemberIds': passengerMemberIds,
      'driverMemberIds': driverMemberIds,
      'coverImageUrl': coverImageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory CommunityModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    DateTime parsedCreatedAt = DateTime.now();
    if (data['createdAt'] is Timestamp) {
      parsedCreatedAt = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      parsedCreatedAt =
          DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now();
    }

    DateTime? parsedUpdatedAt;
    if (data['updatedAt'] is Timestamp) {
      parsedUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
    } else if (data['updatedAt'] is String) {
      parsedUpdatedAt = DateTime.tryParse(data['updatedAt'] as String);
    }

    final pMemberIds = List<String>.from(data['passengerMemberIds'] ?? []);
    final dMemberIds = List<String>.from(data['driverMemberIds'] ?? []);
    final allMemberIds = List<String>.from(data['memberIds'] ?? []);
    final parsedRoute = extractRouteSummary(data);

    final explicitP = (data['pickupLocation'] ??
            data['pickup_location'] ??
            data['pickup'] ??
            '')
        .toString()
        .trim();
    final explicitD = (data['dropOffLocation'] ??
            data['dropoffLocation'] ??
            data['drop_off_location'] ??
            data['dropoff'] ??
            '')
        .toString()
        .trim();
    final recOpt = (data['recurringOption'] ??
            data['recurring_option'] ??
            data['recurring'] ??
            'Weekdays')
        .toString();
    final recDays = data['recurringDays'] is List
        ? List<String>.from(data['recurringDays'])
        : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

    final rawFixedType = data['fixedLocationType'] ?? data['fixed_location_type'];
    final String fixedType;
    if (rawFixedType != null && rawFixedType.toString().trim().isNotEmpty) {
      fixedType = rawFixedType.toString().trim();
    } else if (data['isFixedDropOff'] == true && data['isFixedPickup'] == false) {
      fixedType = 'dropoff';
    } else if (data['isFixedPickup'] == true && data['isFixedDropOff'] == false) {
      fixedType = 'pickup';
    } else if (data['isFixedPickup'] == false && data['isFixedDropOff'] == false) {
      fixedType = 'none';
    } else {
      fixedType = 'both';
    }

    final bool isFixedP = data['isFixedPickup'] == true ||
        fixedType == 'pickup' ||
        fixedType == 'both';
    final bool isFixedD = data['isFixedDropOff'] == true ||
        fixedType == 'dropoff' ||
        fixedType == 'both';
    final String? fixedLoc = data['fixedLocation']?.toString() ??
        (fixedType == 'dropoff'
            ? (explicitD.isNotEmpty ? explicitD : null)
            : (fixedType == 'pickup'
                ? (explicitP.isNotEmpty ? explicitP : null)
                : null));

    return CommunityModel(
      id: doc.id,
      name: data['name'] ?? '',
      routeSummary: parsedRoute,
      explicitPickupLocation: explicitP.isNotEmpty ? explicitP : null,
      explicitDropOffLocation: explicitD.isNotEmpty ? explicitD : null,
      fixedLocationType: fixedType,
      isFixedPickup: isFixedP,
      isFixedDropOff: isFixedD,
      fixedLocation: fixedLoc,
      commonTime: data['commonTime'] ?? '7:30 AM - 9:00 AM',
      description: data['description'] ?? '',
      icon: data['icon'] ?? 'school',
      category: data['category'] ?? 'corridor',
      passengersCount:
          (data['passengersCount'] as num?)?.toInt() ?? pMemberIds.length,
      driversCount:
          (data['driversCount'] as num?)?.toInt() ?? dMemberIds.length,
      nextRideTime: data['nextRideTime'] ?? 'Tomorrow 8:00 AM',
      nextRideSeatsOpen:
          (data['nextRideSeatsOpen'] as num?)?.toInt() ?? 0,
      recurringOption: recOpt,
      recurringDays: recDays,
      memberIds: allMemberIds.isNotEmpty
          ? allMemberIds
          : {...pMemberIds, ...dMemberIds}.toList(),
      passengerMemberIds: pMemberIds,
      driverMemberIds: dMemberIds,
      coverImageUrl: data['coverImageUrl'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedCreatedAt = DateTime.now();
    if (json['createdAt'] is Timestamp) {
      parsedCreatedAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] != null) {
      parsedCreatedAt =
          DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now();
    }

    DateTime? parsedUpdatedAt;
    if (json['updatedAt'] is Timestamp) {
      parsedUpdatedAt = (json['updatedAt'] as Timestamp).toDate();
    } else if (json['updatedAt'] != null) {
      parsedUpdatedAt = DateTime.tryParse(json['updatedAt'].toString());
    }

    final pMemberIds = List<String>.from(json['passengerMemberIds'] ?? []);
    final dMemberIds = List<String>.from(json['driverMemberIds'] ?? []);
    final allMemberIds = List<String>.from(json['memberIds'] ?? []);
    final parsedRoute = extractRouteSummary(json);

    final explicitP = (json['pickupLocation'] ??
            json['pickup_location'] ??
            '')
        .toString()
        .trim();
    final explicitD = (json['dropOffLocation'] ??
            json['dropoffLocation'] ??
            '')
        .toString()
        .trim();
    final recOpt = (json['recurringOption'] ?? 'Weekdays').toString();
    final recDays = json['recurringDays'] is List
        ? List<String>.from(json['recurringDays'])
        : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

    final rawFixedType = json['fixedLocationType'] ?? json['fixed_location_type'];
    final String fixedType;
    if (rawFixedType != null && rawFixedType.toString().trim().isNotEmpty) {
      fixedType = rawFixedType.toString().trim();
    } else if (json['isFixedDropOff'] == true && json['isFixedPickup'] == false) {
      fixedType = 'dropoff';
    } else if (json['isFixedPickup'] == true && json['isFixedDropOff'] == false) {
      fixedType = 'pickup';
    } else if (json['isFixedPickup'] == false && json['isFixedDropOff'] == false) {
      fixedType = 'none';
    } else {
      fixedType = 'both';
    }

    final bool isFixedP = json['isFixedPickup'] == true ||
        fixedType == 'pickup' ||
        fixedType == 'both';
    final bool isFixedD = json['isFixedDropOff'] == true ||
        fixedType == 'dropoff' ||
        fixedType == 'both';
    final String? fixedLoc = json['fixedLocation']?.toString() ??
        (fixedType == 'dropoff'
            ? (explicitD.isNotEmpty ? explicitD : null)
            : (fixedType == 'pickup'
                ? (explicitP.isNotEmpty ? explicitP : null)
                : null));

    return CommunityModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      routeSummary: parsedRoute,
      explicitPickupLocation: explicitP.isNotEmpty ? explicitP : null,
      explicitDropOffLocation: explicitD.isNotEmpty ? explicitD : null,
      fixedLocationType: fixedType,
      isFixedPickup: isFixedP,
      isFixedDropOff: isFixedD,
      fixedLocation: fixedLoc,
      commonTime: json['commonTime'] ?? '7:30 AM - 9:00 AM',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'school',
      category: json['category'] ?? 'corridor',
      passengersCount:
          (json['passengersCount'] as num?)?.toInt() ?? pMemberIds.length,
      driversCount:
          (json['driversCount'] as num?)?.toInt() ?? dMemberIds.length,
      nextRideTime: json['nextRideTime'] ?? 'Tomorrow 8:00 AM',
      nextRideSeatsOpen:
          (json['nextRideSeatsOpen'] as num?)?.toInt() ?? 0,
      recurringOption: recOpt,
      recurringDays: recDays,
      memberIds: allMemberIds.isNotEmpty
          ? allMemberIds
          : {...pMemberIds, ...dMemberIds}.toList(),
      passengerMemberIds: pMemberIds,
      driverMemberIds: dMemberIds,
      coverImageUrl: json['coverImageUrl'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  bool get isPickupFixed =>
      fixedLocationType == 'pickup' || fixedLocationType == 'both' || isFixedPickup;

  bool get isDropOffFixed =>
      fixedLocationType == 'dropoff' || fixedLocationType == 'both' || isFixedDropOff;

  String get fixedLocationTitle {
    if (fixedLocationType == 'dropoff') return 'Fixed Drop-off';
    if (fixedLocationType == 'pickup') return 'Fixed Pick-up';
    if (fixedLocationType == 'both') return 'Both Fixed';
    return 'Flexible Corridor';
  }

  int get totalMembersCount =>
      memberIds.isNotEmpty ? memberIds.length : (passengersCount + driversCount);

  String get formattedDate => DateFormat('MMM dd, yyyy').format(createdAt);
}
