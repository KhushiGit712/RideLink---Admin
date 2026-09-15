import 'package:intl/intl.dart';

class LocationModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final String type; // Hub, Pickup Point, Dropoff Zone, Terminal
  final bool isActive;
  final int capacity;
  final DateTime createdAt;

  LocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.isActive = true,
    this.capacity = 10,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  LocationModel copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? state,
    double? latitude,
    double? longitude,
    String? type,
    bool? isActive,
    int? capacity,
    DateTime? createdAt,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      capacity: capacity ?? this.capacity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'isActive': isActive,
      'capacity': capacity,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] ?? 'Hub',
      isActive: json['isActive'] ?? true,
      capacity: json['capacity'] ?? 10,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(createdAt);
  }

  String get coordinatesFormatted {
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }
}
