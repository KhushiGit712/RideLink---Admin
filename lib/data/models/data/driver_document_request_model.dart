import 'package:intl/intl.dart';

class DriverDocumentItem {
  final String id;
  final String docType; // "Driving License", "Vehicle RC", "Insurance Policy", "National ID"
  final String documentNumber;
  final String expiryDate;
  final String fileUrl;
  final String status; // "Pending", "Approved", "Rejected"
  final String? rejectionNote;

  DriverDocumentItem({
    required this.id,
    required this.docType,
    required this.documentNumber,
    required this.expiryDate,
    required this.fileUrl,
    this.status = 'Pending',
    this.rejectionNote,
  });

  DriverDocumentItem copyWith({
    String? id,
    String? docType,
    String? documentNumber,
    String? expiryDate,
    String? fileUrl,
    String? status,
    String? rejectionNote,
  }) {
    return DriverDocumentItem(
      id: id ?? this.id,
      docType: docType ?? this.docType,
      documentNumber: documentNumber ?? this.documentNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      fileUrl: fileUrl ?? this.fileUrl,
      status: status ?? this.status,
      rejectionNote: rejectionNote ?? this.rejectionNote,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'docType': docType,
      'documentNumber': documentNumber,
      'expiryDate': expiryDate,
      'fileUrl': fileUrl,
      'status': status,
      'rejectionNote': rejectionNote,
    };
  }

  factory DriverDocumentItem.fromJson(Map<String, dynamic> json) {
    return DriverDocumentItem(
      id: json['id'] ?? '',
      docType: json['docType'] ?? '',
      documentNumber: json['documentNumber'] ?? '',
      expiryDate: json['expiryDate'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      status: json['status'] ?? 'Pending',
      rejectionNote: json['rejectionNote'],
    );
  }
}

class DriverDocumentRequestModel {
  final String id;
  final String driverId;
  final String driverName;
  final String driverEmail;
  final String driverPhone;
  final String profileImageUrl;
  final String vehicleType; // "Sedan", "SUV", "Electric", "Bike", "Van"
  final String vehicleModel;
  final String vehiclePlateNumber;
  final DateTime submittedAt;
  final String status; // "Pending", "Approved", "Rejected"
  final String? rejectionReason;
  final List<DriverDocumentItem> documents;

  DriverDocumentRequestModel({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.driverEmail,
    required this.driverPhone,
    required this.profileImageUrl,
    required this.vehicleType,
    required this.vehicleModel,
    required this.vehiclePlateNumber,
    DateTime? submittedAt,
    this.status = 'Pending',
    this.rejectionReason,
    required this.documents,
  }) : submittedAt = submittedAt ?? DateTime.now();

  DriverDocumentRequestModel copyWith({
    String? id,
    String? driverId,
    String? driverName,
    String? driverEmail,
    String? driverPhone,
    String? profileImageUrl,
    String? vehicleType,
    String? vehicleModel,
    String? vehiclePlateNumber,
    DateTime? submittedAt,
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
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehiclePlateNumber: vehiclePlateNumber ?? this.vehiclePlateNumber,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      documents: documents ?? this.documents,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'driverName': driverName,
      'driverEmail': driverEmail,
      'driverPhone': driverPhone,
      'profileImageUrl': profileImageUrl,
      'vehicleType': vehicleType,
      'vehicleModel': vehicleModel,
      'vehiclePlateNumber': vehiclePlateNumber,
      'submittedAt': submittedAt.toIso8601String(),
      'status': status,
      'rejectionReason': rejectionReason,
      'documents': documents.map((e) => e.toJson()).toList(),
    };
  }

  factory DriverDocumentRequestModel.fromJson(Map<String, dynamic> json) {
    return DriverDocumentRequestModel(
      id: json['id'] ?? '',
      driverId: json['driverId'] ?? '',
      driverName: json['driverName'] ?? '',
      driverEmail: json['driverEmail'] ?? '',
      driverPhone: json['driverPhone'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      vehicleType: json['vehicleType'] ?? 'Sedan',
      vehicleModel: json['vehicleModel'] ?? '',
      vehiclePlateNumber: json['vehiclePlateNumber'] ?? '',
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : DateTime.now(),
      status: json['status'] ?? 'Pending',
      rejectionReason: json['rejectionReason'],
      documents: json['documents'] != null
          ? (json['documents'] as List)
              .map((e) => DriverDocumentItem.fromJson(e))
              .toList()
          : [],
    );
  }

  String get formattedSubmittedDate {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(submittedAt);
  }

  int get approvedDocsCount {
    return documents.where((doc) => doc.status == 'Approved').length;
  }
}
