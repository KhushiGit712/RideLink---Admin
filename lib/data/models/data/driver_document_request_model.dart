import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DriverDocumentItem {
  final String id;
  final String docType; // "Driver's License (Front)", "Driver's License (Back)", "Registration Certificate (RC)", "Vehicle Insurance Policy"
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
  final String vehicleMake;
  final String vehicleModel;
  final String vehicleYear;
  final String vehiclePlate;
  final int passengerSeats;
  final String vehicleType; // "Sedan", "SUV", "Electric", "Van"
  final String licenseNumber;
  final String licenseFrontUrl;
  final String licenseBackUrl;
  final String rcDocumentUrl;
  final String insuranceDocUrl;
  final String insuranceExpiryDate;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
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
    required this.vehicleMake,
    required this.vehicleModel,
    this.vehicleYear = '2023',
    required this.vehiclePlate,
    this.passengerSeats = 4,
    this.vehicleType = 'Sedan',
    required this.licenseNumber,
    required this.licenseFrontUrl,
    required this.licenseBackUrl,
    required this.rcDocumentUrl,
    required this.insuranceDocUrl,
    this.insuranceExpiryDate = '2027-02-14',
    DateTime? submittedAt,
    this.reviewedAt,
    this.status = 'Pending',
    this.rejectionReason,
    List<DriverDocumentItem>? documents,
  })  : submittedAt = submittedAt ?? DateTime.now(),
        documents = documents ??
            [
              DriverDocumentItem(
                id: '${id}_dl_f',
                docType: "Driver's License (Front)",
                documentNumber: licenseNumber,
                expiryDate: '2028-11-15',
                fileUrl: licenseFrontUrl,
                status: status,
              ),
              DriverDocumentItem(
                id: '${id}_dl_b',
                docType: "Driver's License (Back)",
                documentNumber: licenseNumber,
                expiryDate: '2028-11-15',
                fileUrl: licenseBackUrl,
                status: status,
              ),
              DriverDocumentItem(
                id: '${id}_rc',
                docType: 'Registration Certificate (RC)',
                documentNumber: vehiclePlate,
                expiryDate: '2027-08-30',
                fileUrl: rcDocumentUrl,
                status: status,
              ),
              DriverDocumentItem(
                id: '${id}_ins',
                docType: 'Vehicle Insurance Policy',
                documentNumber: 'POL-INS-8821',
                expiryDate: insuranceExpiryDate,
                fileUrl: insuranceDocUrl,
                status: status,
              ),
            ];

  // Backward-compatibility getter for vehiclePlateNumber
  String get vehiclePlateNumber => vehiclePlate;
  String get fullVehicleDetails =>
      '$vehicleMake $vehicleModel ($vehicleYear) • $vehiclePlate';

  DriverDocumentRequestModel copyWith({
    String? id,
    String? driverId,
    String? driverName,
    String? driverEmail,
    String? driverPhone,
    String? profileImageUrl,
    String? vehicleMake,
    String? vehicleModel,
    String? vehicleYear,
    String? vehiclePlate,
    int? passengerSeats,
    String? vehicleType,
    String? licenseNumber,
    String? licenseFrontUrl,
    String? licenseBackUrl,
    String? rcDocumentUrl,
    String? insuranceDocUrl,
    String? insuranceExpiryDate,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? status,
    String? rejectionReason,
    List<DriverDocumentItem>? documents,
    String? vehiclePlateNumber,
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
      vehicleYear: vehicleYear ?? this.vehicleYear,
      vehiclePlate: vehiclePlate ?? vehiclePlateNumber ?? this.vehiclePlate,
      passengerSeats: passengerSeats ?? this.passengerSeats,
      vehicleType: vehicleType ?? this.vehicleType,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseFrontUrl: licenseFrontUrl ?? this.licenseFrontUrl,
      licenseBackUrl: licenseBackUrl ?? this.licenseBackUrl,
      rcDocumentUrl: rcDocumentUrl ?? this.rcDocumentUrl,
      insuranceDocUrl: insuranceDocUrl ?? this.insuranceDocUrl,
      insuranceExpiryDate: insuranceExpiryDate ?? this.insuranceExpiryDate,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      documents: documents ?? this.documents,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'driverId': driverId,
      'driverName': driverName,
      'driverEmail': driverEmail,
      'driverPhone': driverPhone,
      'profileImageUrl': profileImageUrl,
      'vehicleMake': vehicleMake,
      'vehicleModel': vehicleModel,
      'vehicleYear': vehicleYear,
      'vehiclePlate': vehiclePlate,
      'passengerSeats': passengerSeats,
      'vehicleType': vehicleType,
      'licenseNumber': licenseNumber,
      'licenseFrontUrl': licenseFrontUrl,
      'licenseBackUrl': licenseBackUrl,
      'rcDocumentUrl': rcDocumentUrl,
      'insuranceDocUrl': insuranceDocUrl,
      'insuranceExpiryDate': insuranceExpiryDate,
      'status': status,
      'rejectionReason': rejectionReason,
      'documents': documents.map((e) => e.toJson()).toList(),
      'submittedAt': Timestamp.fromDate(submittedAt),
      'reviewedAt':
          reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'driverName': driverName,
      'driverEmail': driverEmail,
      'driverPhone': driverPhone,
      'profileImageUrl': profileImageUrl,
      'vehicleMake': vehicleMake,
      'vehicleModel': vehicleModel,
      'vehicleYear': vehicleYear,
      'vehiclePlate': vehiclePlate,
      'passengerSeats': passengerSeats,
      'vehicleType': vehicleType,
      'licenseNumber': licenseNumber,
      'licenseFrontUrl': licenseFrontUrl,
      'licenseBackUrl': licenseBackUrl,
      'rcDocumentUrl': rcDocumentUrl,
      'insuranceDocUrl': insuranceDocUrl,
      'insuranceExpiryDate': insuranceExpiryDate,
      'submittedAt': submittedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'status': status,
      'rejectionReason': rejectionReason,
      'documents': documents.map((e) => e.toJson()).toList(),
    };
  }

  factory DriverDocumentRequestModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    DateTime parsedSubmittedAt = DateTime.now();
    if (data['submittedAt'] is Timestamp) {
      parsedSubmittedAt = (data['submittedAt'] as Timestamp).toDate();
    } else if (data['submittedAt'] is String) {
      parsedSubmittedAt =
          DateTime.tryParse(data['submittedAt'] as String) ?? DateTime.now();
    }

    DateTime? parsedReviewedAt;
    if (data['reviewedAt'] is Timestamp) {
      parsedReviewedAt = (data['reviewedAt'] as Timestamp).toDate();
    } else if (data['reviewedAt'] is String) {
      parsedReviewedAt = DateTime.tryParse(data['reviewedAt'] as String);
    }

    final id = doc.id;
    final licenseNumber = data['licenseNumber'] ?? '';
    final licenseFrontUrl = data['licenseFrontUrl'] ?? '';
    final licenseBackUrl = data['licenseBackUrl'] ?? '';
    final rcDocumentUrl = data['rcDocumentUrl'] ?? '';
    final insuranceDocUrl = data['insuranceDocUrl'] ?? '';
    final insuranceExpiry = data['insuranceExpiryDate'] ?? '2027-02-14';
    final vehiclePlate =
        data['vehiclePlate'] ?? data['vehiclePlateNumber'] ?? '';
    final status = data['status'] ?? 'Pending';

    List<DriverDocumentItem> docList = [];
    if (data['documents'] != null && data['documents'] is List) {
      docList = (data['documents'] as List)
          .map((e) => DriverDocumentItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (docList.isEmpty) {
      docList = [
        DriverDocumentItem(
          id: '${id}_dl_f',
          docType: "Driver's License (Front)",
          documentNumber: licenseNumber,
          expiryDate: '2028-11-15',
          fileUrl: licenseFrontUrl,
          status: status,
        ),
        DriverDocumentItem(
          id: '${id}_dl_b',
          docType: "Driver's License (Back)",
          documentNumber: licenseNumber,
          expiryDate: '2028-11-15',
          fileUrl: licenseBackUrl,
          status: status,
        ),
        DriverDocumentItem(
          id: '${id}_rc',
          docType: 'Registration Certificate (RC)',
          documentNumber: vehiclePlate,
          expiryDate: '2027-08-30',
          fileUrl: rcDocumentUrl,
          status: status,
        ),
        DriverDocumentItem(
          id: '${id}_ins',
          docType: 'Vehicle Insurance Policy',
          documentNumber: 'POL-INS-8821',
          expiryDate: insuranceExpiry,
          fileUrl: insuranceDocUrl,
          status: status,
        ),
      ];
    }

    return DriverDocumentRequestModel(
      id: id,
      driverId: data['driverId'] ?? id,
      driverName: data['driverName'] ?? '',
      driverEmail: data['driverEmail'] ?? '',
      driverPhone: data['driverPhone'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      vehicleMake: data['vehicleMake'] ?? 'Toyota',
      vehicleModel: data['vehicleModel'] ?? '',
      vehicleYear: data['vehicleYear'] ?? '2023',
      vehiclePlate: vehiclePlate,
      passengerSeats: (data['passengerSeats'] as num?)?.toInt() ?? 4,
      vehicleType: data['vehicleType'] ?? 'Sedan',
      licenseNumber: licenseNumber,
      licenseFrontUrl: licenseFrontUrl,
      licenseBackUrl: licenseBackUrl,
      rcDocumentUrl: rcDocumentUrl,
      insuranceDocUrl: insuranceDocUrl,
      insuranceExpiryDate: insuranceExpiry,
      submittedAt: parsedSubmittedAt,
      reviewedAt: parsedReviewedAt,
      status: status,
      rejectionReason: data['rejectionReason'],
      documents: docList,
    );
  }

  factory DriverDocumentRequestModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedSubmittedAt = DateTime.now();
    if (json['submittedAt'] is Timestamp) {
      parsedSubmittedAt = (json['submittedAt'] as Timestamp).toDate();
    } else if (json['submittedAt'] != null) {
      parsedSubmittedAt =
          DateTime.tryParse(json['submittedAt'].toString()) ?? DateTime.now();
    }

    DateTime? parsedReviewedAt;
    if (json['reviewedAt'] is Timestamp) {
      parsedReviewedAt = (json['reviewedAt'] as Timestamp).toDate();
    } else if (json['reviewedAt'] != null) {
      parsedReviewedAt = DateTime.tryParse(json['reviewedAt'].toString());
    }

    return DriverDocumentRequestModel(
      id: json['id'] ?? '',
      driverId: json['driverId'] ?? '',
      driverName: json['driverName'] ?? '',
      driverEmail: json['driverEmail'] ?? '',
      driverPhone: json['driverPhone'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      vehicleMake: json['vehicleMake'] ?? 'Toyota',
      vehicleModel: json['vehicleModel'] ?? '',
      vehicleYear: json['vehicleYear'] ?? '2023',
      vehiclePlate: json['vehiclePlate'] ?? json['vehiclePlateNumber'] ?? '',
      passengerSeats: json['passengerSeats'] ?? 4,
      vehicleType: json['vehicleType'] ?? 'Sedan',
      licenseNumber: json['licenseNumber'] ?? '',
      licenseFrontUrl: json['licenseFrontUrl'] ?? '',
      licenseBackUrl: json['licenseBackUrl'] ?? '',
      rcDocumentUrl: json['rcDocumentUrl'] ?? '',
      insuranceDocUrl: json['insuranceDocUrl'] ?? '',
      insuranceExpiryDate: json['insuranceExpiryDate'] ?? '2027-02-14',
      submittedAt: parsedSubmittedAt,
      reviewedAt: parsedReviewedAt,
      status: json['status'] ?? 'Pending',
      rejectionReason: json['rejectionReason'],
      documents: json['documents'] != null
          ? (json['documents'] as List)
              .map((e) => DriverDocumentItem.fromJson(e))
              .toList()
          : null,
    );
  }

  String get formattedSubmittedDate {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(submittedAt);
  }

  int get approvedDocsCount {
    return documents.where((doc) => doc.status == 'Approved').length;
  }
}
