import 'package:flutter_test/flutter_test.dart';
import 'package:ridelink_admin/data/models/data/community_model.dart';

void main() {
  group('CommunityModel Specification Tests', () {
    test('instantiates with specified schema fields and defaults', () {
      final model = CommunityModel(
        id: 'comm_curtin',
        name: 'Curtin Community',
        routeSummary: 'Landsdale → Curtin University',
        commonTime: '7:30 AM - 9:00 AM',
        description: 'Daily shared rides for Curtin University students & staff.',
        icon: 'school',
        category: 'university',
        passengersCount: 12,
        driversCount: 4,
        nextRideTime: 'Tomorrow 8:00 AM',
        nextRideSeatsOpen: 3,
        memberIds: ['usr_123', 'usr_456'],
        passengerMemberIds: ['usr_123'],
        driverMemberIds: ['usr_456'],
        isActive: true,
      );

      expect(model.id, equals('comm_curtin'));
      expect(model.name, equals('Curtin Community'));
      expect(model.routeSummary, equals('Landsdale → Curtin University'));
      expect(model.commonTime, equals('7:30 AM - 9:00 AM'));
      expect(model.icon, equals('school'));
      expect(model.category, equals('university'));
      expect(model.passengersCount, equals(12));
      expect(model.driversCount, equals(4));
      expect(model.nextRideTime, equals('Tomorrow 8:00 AM'));
      expect(model.nextRideSeatsOpen, equals(3));
      expect(model.memberIds, equals(['usr_123', 'usr_456']));
      expect(model.passengerMemberIds, equals(['usr_123']));
      expect(model.driverMemberIds, equals(['usr_456']));
      expect(model.isActive, isTrue);
    });

    test('toJson and fromJson work symmetrically', () {
      final original = CommunityModel(
        id: 'comm_cbd',
        name: 'City CBD Commuters',
        routeSummary: 'Suburbs ⇄ Perth CBD',
        commonTime: '8:00 AM - 9:30 AM',
        description: 'Corporate commute network',
        icon: 'business',
        category: 'corporate',
        passengersCount: 5,
        driversCount: 2,
        memberIds: ['usr_1'],
        passengerMemberIds: ['usr_1'],
        driverMemberIds: [],
        isActive: true,
      );

      final json = original.toJson();
      final restored = CommunityModel.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.routeSummary, equals(original.routeSummary));
      expect(restored.icon, equals('business'));
      expect(restored.category, equals('corporate'));
      expect(restored.passengersCount, equals(5));
      expect(restored.driversCount, equals(2));
      expect(restored.memberIds, equals(['usr_1']));
    });

    test('route corridor backwards compatibility from pickup/dropoff fields', () {
      final legacyJson = {
        'id': 'comm_legacy',
        'name': 'Curtin Express',
        'pickupLocation': 'Perth Station',
        'dropOffLocation': 'Curtin Bentley Campus',
        'commonTime': '7:30 AM - 9:00 AM',
        'passengersCount': 3,
        'driversCount': 1,
      };

      final model = CommunityModel.fromJson(legacyJson);
      expect(model.routeSummary, equals('Perth Station → Curtin Bentley Campus'));
      expect(model.pickupLocation, equals('Perth Station'));
      expect(model.dropOffLocation, equals('Curtin Bentley Campus'));
    });

    test('route corridor getters parse origin and destination correctly', () {
      final model = CommunityModel(
        id: 'comm_1',
        name: 'Uni Corridor',
        routeSummary: 'Landsdale → Curtin University',
      );
      expect(model.pickupLocation, equals('Landsdale'));
      expect(model.dropOffLocation, equals('Curtin University'));

      final model2 = CommunityModel(
        id: 'comm_2',
        name: 'Metro Line',
        routeSummary: 'Joondalup ⇄ Perth CBD',
      );
      expect(model2.pickupLocation, equals('Joondalup'));
      expect(model2.dropOffLocation, equals('Perth CBD'));
    });
  });
}
