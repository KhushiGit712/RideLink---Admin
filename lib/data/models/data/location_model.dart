import 'package:intl/intl.dart';

class LocationModel {
  final String id;
  final String cityName; // e.g. "Austin Metro Area"
  final String state; // e.g. "Texas"
  final double centerLat;
  final double centerLng;
  final double radiusKm; // Operating radius in KM
  final bool isActive;
  final String? address;
  final String? type; // Hub, Pickup Point, Dropoff Zone, Terminal
  final int capacity;
  final DateTime createdAt;

  LocationModel({
    required this.id,
    required this.cityName,
    required this.state,
    required this.centerLat,
    required this.centerLng,
    this.radiusKm = 35.0,
    this.isActive = true,
    this.address,
    this.type = 'Hub',
    this.capacity = 10,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Backward-compatible getters
  String get name => cityName;
  String get city => cityName;
  double get latitude => centerLat;
  double get longitude => centerLng;

  LocationModel copyWith({
    String? id,
    String? cityName,
    String? state,
    double? centerLat,
    double? centerLng,
    double? radiusKm,
    bool? isActive,
    String? address,
    String? type,
    int? capacity,
    DateTime? createdAt,
    // Support legacy copyWith args
    String? name,
    String? city,
    double? latitude,
    double? longitude,
  }) {
    return LocationModel(
      id: id ?? this.id,
      cityName: cityName ?? name ?? city ?? this.cityName,
      state: state ?? this.state,
      centerLat: centerLat ?? latitude ?? this.centerLat,
      centerLng: centerLng ?? longitude ?? this.centerLng,
      radiusKm: radiusKm ?? this.radiusKm,
      isActive: isActive ?? this.isActive,
      address: address ?? this.address,
      type: type ?? this.type,
      capacity: capacity ?? this.capacity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cityName': cityName,
      'name': cityName,
      'city': cityName,
      'state': state,
      'centerLat': centerLat,
      'centerLng': centerLng,
      'latitude': centerLat,
      'longitude': centerLng,
      'radiusKm': radiusKm,
      'isActive': isActive,
      'address': address ?? '',
      'type': type ?? 'Hub',
      'capacity': capacity,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? '',
      cityName: json['cityName'] ?? json['name'] ?? json['city'] ?? '',
      state: json['state'] ?? '',
      centerLat: (json['centerLat'] as num?)?.toDouble() ??
          (json['latitude'] as num?)?.toDouble() ??
          0.0,
      centerLng: (json['centerLng'] as num?)?.toDouble() ??
          (json['longitude'] as num?)?.toDouble() ??
          0.0,
      radiusKm: (json['radiusKm'] as num?)?.toDouble() ?? 35.0,
      isActive: json['isActive'] ?? true,
      address: json['address'],
      type: json['type'] ?? 'Hub',
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
    return '${centerLat.toStringAsFixed(4)}, ${centerLng.toStringAsFixed(4)}';
  }

  String get radiusFormatted {
    return '${radiusKm.toStringAsFixed(1)} km';
  }
}
