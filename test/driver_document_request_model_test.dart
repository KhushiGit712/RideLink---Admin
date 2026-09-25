import 'package:flutter_test/flutter_test.dart';
import 'package:ridelink_admin/data/models/data/driver_document_request_model.dart';

void main() {
  group('DriverDocumentRequestModel Tests', () {
    test('instantiates with defaults and documents list', () {
      final req = DriverDocumentRequestModel(
        id: 'req_123',
        driverId: 'drv_456',
        driverName: 'John Doe',
        driverEmail: 'john@example.com',
        driverPhone: '+61 400 000 000',
        profileImageUrl: 'https://example.com/avatar.jpg',
        vehicleMake: 'Toyota',
        vehicleModel: 'Camry',
        vehicleYear: '2023',
        vehiclePlate: '1ABC234',
        licenseNumber: 'DL-998877',
        licenseFrontUrl: 'https://firebasestorage.app/license_front.jpg',
        licenseBackUrl: 'https://firebasestorage.app/license_back.jpg',
        rcDocumentUrl: 'https://firebasestorage.app/rc.jpg',
        insuranceDocUrl: 'https://firebasestorage.app/insurance.jpg',
      );

      expect(req.id, equals('req_123'));
      expect(req.driverId, equals('drv_456'));
      expect(req.status, equals('Pending'));
      expect(req.documents.length, equals(4));
      expect(req.documents.first.docType, equals("Driver's License (Front)"));
      expect(
        req.documents.first.fileUrl,
        equals('https://firebasestorage.app/license_front.jpg'),
      );
    });

    test('toJson and fromJson work reciprocally', () {
      final original = DriverDocumentRequestModel(
        id: 'req_789',
        driverId: 'drv_999',
        driverName: 'Alice Walker',
        driverEmail: 'alice@example.com',
        driverPhone: '+61 411 222 333',
        profileImageUrl: 'https://example.com/alice.jpg',
        vehicleMake: 'Tesla',
        vehicleModel: 'Model 3',
        vehicleYear: '2024',
        vehiclePlate: 'EV-888',
        licenseNumber: 'DL-554433',
        licenseFrontUrl: 'https://storage/f.jpg',
        licenseBackUrl: 'https://storage/b.jpg',
        rcDocumentUrl: 'https://storage/rc.jpg',
        insuranceDocUrl: 'https://storage/ins.jpg',
        status: 'Approved',
        submittedAt: DateTime(2026, 4, 1, 10, 0),
        reviewedAt: DateTime(2026, 4, 1, 11, 0),
      );

      final json = original.toJson();
      final restored = DriverDocumentRequestModel.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.driverName, equals(original.driverName));
      expect(restored.status, equals('Approved'));
      expect(restored.licenseNumber, equals(original.licenseNumber));
      expect(restored.documents.length, equals(4));
    });

    test('toFirestore includes required Firestore fields', () {
      final req = DriverDocumentRequestModel(
        id: 'req_001',
        driverId: 'drv_001',
        driverName: 'Bob Builder',
        driverEmail: 'bob@example.com',
        driverPhone: '+61 499 888 777',
        profileImageUrl: 'https://storage/bob.jpg',
        vehicleMake: 'Ford',
        vehicleModel: 'Ranger',
        vehiclePlate: '4WD-999',
        licenseNumber: 'DL-112233',
        licenseFrontUrl: 'https://storage/dlf.jpg',
        licenseBackUrl: 'https://storage/dlb.jpg',
        rcDocumentUrl: 'https://storage/rc.jpg',
        insuranceDocUrl: 'https://storage/ins.jpg',
      );

      final map = req.toFirestore();
      expect(map['driverId'], equals('drv_001'));
      expect(map['driverName'], equals('Bob Builder'));
      expect(map['licenseFrontUrl'], equals('https://storage/dlf.jpg'));
      expect(map['submittedAt'], isNotNull);
      expect(map['status'], equals('Pending'));
    });
  });
}
