import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Document Verification Status Enum strictly matching Section 3.2:
/// "pending" | "verified" | "rejected"
enum DocumentVerificationStatus {
  pending,
  verified,
  rejected;

  String get value => name;

  static DocumentVerificationStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'verified':
        return DocumentVerificationStatus.verified;
      case 'rejected':
        return DocumentVerificationStatus.rejected;
      case 'pending':
      default:
        return DocumentVerificationStatus.pending;
    }
  }
}

/// Standard Document IDs and Titles strictly matching Section 3.2:
/// 1. driving_licence: Valid Driver's Licence ("Driving Licence")
/// 2. vehicle_registration: Vehicle Registration Certificate ("Vehicle Registration")
/// 3. vehicle_insurance: Third-party / Comprehensive Vehicle Insurance ("Vehicle Insurance")
/// 4. police_check: National Police Certificate (Optional) ("Police Check")
class DriverDocumentType {
  static const String drivingLicence = 'driving_licence';
  static const String vehicleRegistration = 'vehicle_registration';
  static const String vehicleInsurance = 'vehicle_insurance';
  static const String policeCheck = 'police_check';

  static const List<String> requiredDocIds = [
    drivingLicence,
    vehicleRegistration,
    vehicleInsurance,
  ];

  static const List<String> allDocIds = [
    drivingLicence,
    vehicleRegistration,
    vehicleInsurance,
    policeCheck,
  ];

  static String getTitle(String id) {
    switch (id) {
      case drivingLicence:
        return 'Driving Licence';
      case vehicleRegistration:
        return 'Vehicle Registration';
      case vehicleInsurance:
        return 'Vehicle Insurance';
      case policeCheck:
        return 'Police Check';
      default:
        return id;
    }
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}

/// Represents an individual document in subcollection `users/{user_id}/docs/{doc_id}`
/// Schema strictly conforms to Section 3.2 of the Database Architecture specification.
class DriverDocumentItem {
  final String id;
  final String title;
  final String userId;
  final String? fileName;
  final String fileUrl;
  final String status; // "pending" | "verified" | "rejected"
  final String? rejectionReason;
  final DateTime? uploadedAt;
  final DateTime? updatedAt;
  final DateTime? verifiedAt;
  final String? verifiedBy;

  DriverDocumentItem({
    required this.id,
    required this.title,
    this.userId = '',
    this.fileName,
    required this.fileUrl,
    this.status = 'pending',
    this.rejectionReason,
    this.uploadedAt,
    this.updatedAt,
    this.verifiedAt,
    this.verifiedBy,
  });

  String get docType => id;
  String get displayTitle => title.isNotEmpty ? title : DriverDocumentType.getTitle(id);

  bool get isVerified => status.toLowerCase() == 'verified';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isRejected => status.toLowerCase() == 'rejected';
  String? get rejectionNote => rejectionReason;

  // Compatibility getters for UI
  String get documentNumber => '';
  String get expiryDate => '';

  DriverDocumentItem copyWith({
    String? id,
    String? title,
    String? userId,
    String? fileName,
    String? fileUrl,
    String? status,
    String? rejectionReason,
    DateTime? uploadedAt,
    DateTime? updatedAt,
    DateTime? verifiedAt,
    String? verifiedBy,
  }) {
    return DriverDocumentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
    );
  }

  /// Firestore JSON matching Section 3.2 schema
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title.isNotEmpty ? title : displayTitle,
      'user_id': userId,
      'file_name': fileName,
      'file_url': fileUrl,
      'status': status.toLowerCase(),
      'rejection_reason': rejectionReason,
      'uploaded_at': uploadedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
      'verified_by': verifiedBy,
    };
  }

  Map<String, dynamic> toJson() => toFirestore();

  factory DriverDocumentItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return DriverDocumentItem.fromJson(data, snapshot.id);
  }

  factory DriverDocumentItem.fromJson(
    Map<String, dynamic> json, [
    String? docId,
  ]) {
    final id = (json['id'] ?? docId ?? '').toString();
    final title = (json['title'] ?? '').toString();
    return DriverDocumentItem(
      id: id,
      title: title.isNotEmpty ? title : DriverDocumentType.getTitle(id),
      userId: (json['user_id'] ?? '').toString(),
      fileName: json['file_name']?.toString(),
      fileUrl: (json['file_url'] ?? '').toString().trim(),
      status: (json['status'] ?? 'pending').toString().toLowerCase(),
      rejectionReason: json['rejection_reason']?.toString(),
      uploadedAt: _parseDateTime(json['uploaded_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      verifiedAt: _parseDateTime(json['verified_at']),
      verifiedBy: json['verified_by']?.toString(),
    );
  }
}

/// Aggregated view of a Driver profile and verification documents
/// Profile is read from `users/{userId}` using keys from Section 3.1
/// Documents are read strictly from `users/{userId}/docs/{doc_id}` subcollection (Section 3.2)
class DriverDocumentRequestModel {
  final String id;
  final String driverId;
  final String driverName;
  final String driverEmail;
  final String driverPhone;
  final String profileImageUrl;
  final String vehicleMake;
  final String vehicleModel;
  final String vehicleColor;
  final String vehiclePlate;
  final String vehicleType;
  final double driverRating;
  final int driverTripsCompleted;
  final bool isOnline;
  final bool isVerifiedDriver; // Section 3.1 singular verification flag on users
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String status; // "Pending" | "Verified" | "Rejected" | "Unsubmitted"
  final String? rejectionReason;
  final List<DriverDocumentItem> documents;

  DriverDocumentRequestModel({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.driverEmail,
    required this.driverPhone,
    required this.profileImageUrl,
    required this.vehicleMake,
    required this.vehicleModel,
    this.vehicleColor = '',
    required this.vehiclePlate,
    this.vehicleType = 'Sedan',
    this.driverRating = 5.0,
    this.driverTripsCompleted = 0,
    this.isOnline = false,
    this.isVerifiedDriver = false,
    DateTime? submittedAt,
    this.reviewedAt,
    this.status = 'Pending',
    this.rejectionReason,
    List<DriverDocumentItem>? documents,
  })  : submittedAt = submittedAt ?? DateTime.now(),
        documents = documents ?? [];

  // Convenience getters
  String get vehiclePlateNumber => vehiclePlate;
  int get passengerSeats => 4;
  String get formattedSubmittedDate =>
      DateFormat('MMM dd, yyyy • hh:mm a').format(submittedAt);

  int get approvedDocsCount => documents.where((doc) => doc.isVerified).length;
  int get verifiedDocsCount => approvedDocsCount;

  bool get isVerified => isVerifiedDriver || status.toLowerCase() == 'verified';
  bool get isApproved => isVerified; // alias for callers
  bool get isPending => !isVerified && status.toLowerCase() == 'pending';
  bool get isRejected => !isVerified && status.toLowerCase() == 'rejected';
  bool get isUnsubmitted => !isVerified && status.toLowerCase() == 'unsubmitted';

  bool get hasDocuments => documents.any((d) => d.fileUrl.isNotEmpty);

  // Document shortcut URL helpers
  String get licenseFrontUrl => _docUrl(DriverDocumentType.drivingLicence);
  String get licenseBackUrl => '';
  String get rcDocumentUrl => _docUrl(DriverDocumentType.vehicleRegistration);
  String get insuranceDocUrl => _docUrl(DriverDocumentType.vehicleInsurance);
  String get policeCheckUrl => _docUrl(DriverDocumentType.policeCheck);
  String get licenseNumber => vehiclePlate;

  String _docUrl(String docId) {
    for (final doc in documents) {
      if (doc.id == docId) return doc.fileUrl;
    }
    return '';
  }

  DriverDocumentRequestModel copyWith({
    String? id,
    String? driverId,
    String? driverName,
    String? driverEmail,
    String? driverPhone,
    String? profileImageUrl,
    String? vehicleMake,
    String? vehicleModel,
    String? vehicleColor,
    String? vehiclePlate,
    String? vehicleType,
    double? driverRating,
    int? driverTripsCompleted,
    bool? isOnline,
    bool? isVerifiedDriver,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? status,
    String? rejectionReason,
    List<DriverDocumentItem>? documents,
  }) {
    return DriverDocumentRequestModel(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverEmail: driverEmail ?? this.driverEmail,
      driverPhone: driverPhone ?? this.driverPhone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleType: vehicleType ?? this.vehicleType,
      driverRating: driverRating ?? this.driverRating,
      driverTripsCompleted: driverTripsCompleted ?? this.driverTripsCompleted,
      isOnline: isOnline ?? this.isOnline,
      isVerifiedDriver: isVerifiedDriver ?? this.isVerifiedDriver,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      documents: documents ?? this.documents,
    );
  }

  /// Parses profile fields from `users/{userId}` (Section 3.1)
  /// and pairs them with subcollection documents from `users/{userId}/docs/{doc_id}` (Section 3.2).
  factory DriverDocumentRequestModel.fromUserSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc, [
    List<DriverDocumentItem>? subcollectionDocs,
  ]) {
    final data = doc.data() ?? {};
    final id = doc.id;

    final fullName = (data['fullName'] ?? '').toString();
    final email = (data['email'] ?? '').toString();
    final phoneNumber = (data['phoneNumber'] ?? '').toString();
    final isOnline = data['isOnline'] == true;
    final isVerifiedDriver = data['is_verified_driver'] == true;

    // Driver stats (Section 3.1)
    final Map<String, dynamic> driverStats = data['driverStats'] is Map
        ? Map<String, dynamic>.from(data['driverStats'] as Map)
        : {};
    final rating = (driverStats['rating'] as num?)?.toDouble() ?? 5.0;
    final tripsCompleted =
        (driverStats['tripsCompleted'] as num?)?.toInt() ?? 0;

    // Vehicle details (Section 3.1: make, model, color, licensePlate, type)
    final Map<String, dynamic> vehicle = data['vehicle'] is Map
        ? Map<String, dynamic>.from(data['vehicle'] as Map)
        : {};
    final vMake = (vehicle['make'] ?? '').toString();
    final vModel = (vehicle['model'] ?? '').toString();
    final vColor = (vehicle['color'] ?? '').toString();
    final vPlate = (vehicle['licensePlate'] ?? '').toString();
    final vType = (vehicle['type'] ?? 'Sedan').toString();

    // Map subcollection documents strictly by standard doc IDs
    final List<DriverDocumentItem> docList = [];
    final Map<String, DriverDocumentItem> subDocsById = {};

    if (subcollectionDocs != null) {
      for (final sDoc in subcollectionDocs) {
        subDocsById[sDoc.id] = sDoc;
      }
    }

    // Build list for the 4 standard document IDs
    for (final docId in DriverDocumentType.allDocIds) {
      if (subDocsById.containsKey(docId)) {
        docList.add(subDocsById[docId]!);
      } else {
        docList.add(
          DriverDocumentItem(
            id: docId,
            title: DriverDocumentType.getTitle(docId),
            userId: id,
            fileUrl: '',
            status: isVerifiedDriver ? 'verified' : 'pending',
          ),
        );
      }
    }

    // Status logic strictly based on is_verified_driver and subcollection documents
    String status = 'Pending';
    String? rejectionReason;

    final hasAnyUploaded = docList.any((d) => d.fileUrl.isNotEmpty);
    final anyRejected = docList.any((d) => d.isRejected);
    final anyPending = docList
        .where((d) => DriverDocumentType.requiredDocIds.contains(d.id))
        .any((d) => d.isPending);

    final userRejection = data['rejection_reason']?.toString();

    if (isVerifiedDriver) {
      status = 'Verified';
    } else if (anyRejected) {
      status = 'Rejected';
      final rejDoc = docList.firstWhere((d) => d.isRejected);
      rejectionReason = (rejDoc.rejectionReason != null &&
              rejDoc.rejectionReason!.trim().isNotEmpty)
          ? rejDoc.rejectionReason
          : userRejection;
    } else if (userRejection != null && userRejection.trim().isNotEmpty) {
      status = 'Rejected';
      rejectionReason = userRejection;
    } else if (hasAnyUploaded && anyPending) {
      status = 'Pending';
    } else if (!hasAnyUploaded) {
      status = 'Unsubmitted';
    } else {
      status = 'Pending';
    }

    final createdAt = _parseDateTime(data['createdAt']) ?? DateTime.now();
    final updatedAt = _parseDateTime(data['updatedAt']);

    return DriverDocumentRequestModel(
      id: id,
      driverId: id,
      driverName: fullName,
      driverEmail: email,
      driverPhone: phoneNumber,
      profileImageUrl: '',
      vehicleMake: vMake,
      vehicleModel: vModel,
      vehicleColor: vColor,
      vehiclePlate: vPlate,
      vehicleType: vType,
      driverRating: rating,
      driverTripsCompleted: tripsCompleted,
      isOnline: isOnline,
      isVerifiedDriver: isVerifiedDriver,
      submittedAt: createdAt,
      reviewedAt: updatedAt,
      status: status,
      rejectionReason: rejectionReason,
      documents: docList,
    );
  }

  factory DriverDocumentRequestModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc, [
    List<DriverDocumentItem>? subcollectionDocs,
  ]) {
    return DriverDocumentRequestModel.fromUserSnapshot(doc, subcollectionDocs);
  }

  factory DriverDocumentRequestModel.fromJson(Map<String, dynamic> json) {
    final vehicle = json['vehicle'] is Map
        ? Map<String, dynamic>.from(json['vehicle'] as Map)
        : {};

    return DriverDocumentRequestModel(
      id: (json['id'] ?? '').toString(),
      driverId: (json['id'] ?? '').toString(),
      driverName: (json['fullName'] ?? '').toString(),
      driverEmail: (json['email'] ?? '').toString(),
      driverPhone: (json['phoneNumber'] ?? '').toString(),
      profileImageUrl: '',
      vehicleMake: (vehicle['make'] ?? '').toString(),
      vehicleModel: (vehicle['model'] ?? '').toString(),
      vehicleColor: (vehicle['color'] ?? '').toString(),
      vehiclePlate: (vehicle['licensePlate'] ?? '').toString(),
      vehicleType: (vehicle['type'] ?? 'Sedan').toString(),
      driverRating: (json['driverStats']?['rating'] as num?)?.toDouble() ?? 5.0,
      driverTripsCompleted:
          (json['driverStats']?['tripsCompleted'] as num?)?.toInt() ?? 0,
      isOnline: json['isOnline'] == true,
      isVerifiedDriver: json['is_verified_driver'] == true,
      submittedAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      reviewedAt: _parseDateTime(json['updatedAt']),
      status: (json['status'] ?? 'Pending').toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      documents: json['documents'] != null
          ? (json['documents'] as List)
              .map((e) => DriverDocumentItem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': driverName,
      'email': driverEmail,
      'phoneNumber': driverPhone,
      'is_verified_driver': isVerifiedDriver,
      'isOnline': isOnline,
      'vehicle': {
        'make': vehicleMake,
        'model': vehicleModel,
        'color': vehicleColor,
        'licensePlate': vehiclePlate,
        'type': vehicleType,
      },
      'createdAt': submittedAt.toIso8601String(),
      'updatedAt': reviewedAt?.toIso8601String(),
      'status': status,
      'rejection_reason': rejectionReason,
      'documents': documents.map((e) => e.toFirestore()).toList(),
    };
  }
}
