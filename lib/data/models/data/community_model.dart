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
  final String commonTime; // e.g. "7:30 AM - 9:00 AM"
  final String description;
  final String icon; // 'school', 'business', 'hospital', 'car'
  final String category; // 'university', 'corporate', 'healthcare', 'metro', 'corridor'
  final int passengersCount;
  final int driversCount;
  final String nextRideTime;
  final int nextRideSeatsOpen;
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
    this.commonTime = '7:30 AM - 9:00 AM',
    this.description = '',
    this.icon = 'school',
    this.category = 'university',
    this.passengersCount = 0,
    this.driversCount = 0,
    this.nextRideTime = 'Tomorrow 8:00 AM',
    this.nextRideSeatsOpen = 3,
    List<String>? memberIds,
    List<String>? passengerMemberIds,
    List<String>? driverMemberIds,
    this.coverImageUrl = '',
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
  })  : memberIds = memberIds ?? [],
        passengerMemberIds = passengerMemberIds ?? [],
        driverMemberIds = driverMemberIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  CommunityModel copyWith({
    String? id,
    String? name,
    String? routeSummary,
    String? commonTime,
    String? description,
    String? icon,
    String? category,
    int? passengersCount,
    int? driversCount,
    String? nextRideTime,
    int? nextRideSeatsOpen,
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
      commonTime: commonTime ?? this.commonTime,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      passengersCount: passengersCount ?? this.passengersCount,
      driversCount: driversCount ?? this.driversCount,
      nextRideTime: nextRideTime ?? this.nextRideTime,
      nextRideSeatsOpen: nextRideSeatsOpen ?? this.nextRideSeatsOpen,
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
      'commonTime': commonTime,
      'description': description,
      'icon': icon,
      'category': category,
      'passengersCount': passengersCount,
      'driversCount': driversCount,
      'nextRideTime': nextRideTime,
      'nextRideSeatsOpen': nextRideSeatsOpen,
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
      'commonTime': commonTime,
      'description': description,
      'icon': icon,
      'category': category,
      'passengersCount': passengersCount,
      'driversCount': driversCount,
      'nextRideTime': nextRideTime,
      'nextRideSeatsOpen': nextRideSeatsOpen,
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

    return CommunityModel(
      id: doc.id,
      name: data['name'] ?? '',
      routeSummary: parsedRoute,
      commonTime: data['commonTime'] ?? '7:30 AM - 9:00 AM',
      description: data['description'] ?? '',
      icon: data['icon'] ?? 'school',
      category: data['category'] ?? 'university',
      passengersCount:
          (data['passengersCount'] as num?)?.toInt() ?? pMemberIds.length,
      driversCount:
          (data['driversCount'] as num?)?.toInt() ?? dMemberIds.length,
      nextRideTime: data['nextRideTime'] ?? 'Tomorrow 8:00 AM',
      nextRideSeatsOpen:
          (data['nextRideSeatsOpen'] as num?)?.toInt() ?? 3,
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

    return CommunityModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      routeSummary: parsedRoute,
      commonTime: json['commonTime'] ?? '7:30 AM - 9:00 AM',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'school',
      category: json['category'] ?? 'university',
      passengersCount:
          (json['passengersCount'] as num?)?.toInt() ?? pMemberIds.length,
      driversCount:
          (json['driversCount'] as num?)?.toInt() ?? dMemberIds.length,
      nextRideTime: json['nextRideTime'] ?? 'Tomorrow 8:00 AM',
      nextRideSeatsOpen:
          (json['nextRideSeatsOpen'] as num?)?.toInt() ?? 3,
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

  int get totalMembersCount =>
      memberIds.isNotEmpty ? memberIds.length : (passengersCount + driversCount);

  String get formattedDate => DateFormat('MMM dd, yyyy').format(createdAt);
}
