import 'package:parking_app/domain/incident.dart';
import 'package:parking_app/domain/park.dart';
import 'package:test/test.dart';

void main() {
  ParkingLot parking = ParkingLot(
    'what',
    'OK',
    'caresbruh',
    'oui,oui',
    'someday sometime',
    null,
    'yes',
    3,
    0,
    null,
    Map.of({'': 0}),
  );

  group('getIncidentsLast24Hours', () {
    test('valid incidents', () {
      List<Incident> incidents = [
        Incident(
          DateTime.now(),
          'yesok',
          IncidentSeverity.high,
          null,
        ),
        Incident(
          DateTime.now().subtract(const Duration(hours: 23)),
          'yesok',
          IncidentSeverity.high,
          null,
        ),
      ];
      parking.incidents = incidents;
      expect(parking.getIncidentsLast24Hours().length, 2);

      incidents.add(
        Incident(
          DateTime.now().subtract(const Duration(hours: 3)),
          'yesok',
          IncidentSeverity.high,
          null,
        ),
      );
      incidents.add(
        Incident(
          DateTime.now().subtract(const Duration(seconds: 1)),
          'yesok',
          IncidentSeverity.high,
          null,
        ),
      );
      expect(parking.getIncidentsLast24Hours().length, 4);
    });

    test('invalid incidents', () {
      List<Incident> incidents = [
        Incident(
          DateTime.now().subtract(const Duration(days: 2)),
          'suuuuupp',
          IncidentSeverity.veryHigh,
          null,
        ),
        Incident(
          DateTime.now().subtract(const Duration(hours: 24)),
          'suuuuupp',
          IncidentSeverity.veryHigh,
          null,
        ),
        Incident(
          DateTime.now().subtract(const Duration(days: 7)),
          'suuuuupp',
          IncidentSeverity.veryHigh,
          null,
        ),
      ];
      parking.incidents = incidents;

      expect(parking.getIncidentsLast24Hours().length, 0);
    });
  });

  group('getIncidentsLastWeek', () {
    test('valid incidents', () {
      List<Incident> incidents = [
        Incident(
          DateTime.now().subtract(const Duration(days: 3)),
          'itiswhatitis',
          IncidentSeverity.low,
          null,
        ),
        Incident(
          DateTime.now().subtract(const Duration(minutes: 32)),
          'itiswhatitis',
          IncidentSeverity.low,
          null,
        ),
        Incident(
          DateTime.now().subtract(const Duration(hours: 167)),
          'itiswhatitis',
          IncidentSeverity.low,
          null,
        ),
      ];
      parking.incidents = incidents;

      expect(parking.getIncidentsLastWeek().length, 3);

      incidents.add(
        Incident(
          DateTime.now().subtract(const Duration(days: 6)),
          'itiswhatitis',
          IncidentSeverity.low,
          null,
        ),
      );
      expect(parking.getIncidentsLastWeek().length, 4);
    });

    test('invalid incidents', () {
      List<Incident> incidents = [
        Incident(
          DateTime.now().subtract(const Duration(days: 7, minutes: 1)),
          'okbruh',
          IncidentSeverity.veryHigh,
          null,
        ),
        Incident(
          DateTime.now().subtract(const Duration(days: 8)),
          'okbruh',
          IncidentSeverity.veryHigh,
          null,
        ),
        Incident(
          DateTime.now().subtract(const Duration(hours: 169)),
          'okbruh',
          IncidentSeverity.veryHigh,
          null,
        ),
      ];
      parking.incidents = incidents;
      expect(parking.getIncidentsLastWeek().length, 0);
    });
  });

  group('getIncidentsLastWeekExceptLast24Hours', () {
    test('valid incidents', () {
      List<Incident> incidents = [
        Incident(
          DateTime.now().subtract(const Duration(hours: 25)),
          'okbruh',
          IncidentSeverity.veryHigh,
          null,
        ),
        Incident(
          DateTime.now().subtract(const Duration(minutes: 1441)),
          'okbruh',
          IncidentSeverity.veryHigh,
          null,
        ),
      ];
      parking.incidents = incidents;
      expect(parking.getIncidentsLastWeekExceptLast24Hours().length, 2);
    });

    test('invalid incidents', () {
      List<Incident> incidents = [
        Incident(
          DateTime.now().subtract(const Duration(hours: 24)),
          'okbruh',
          IncidentSeverity.veryHigh,
          null,
        ),
        Incident(
          DateTime.now().subtract(const Duration(minutes: 5)),
          'okbruh',
          IncidentSeverity.veryHigh,
          null,
        ),
        Incident(
          DateTime.now().subtract(const Duration(minutes: 1440)),
          'okbruh',
          IncidentSeverity.veryHigh,
          null,
        ),
        Incident(
          DateTime.now().subtract(const Duration(seconds: 1)),
          'okbruh',
          IncidentSeverity.veryHigh,
          null,
        ),
        Incident(
          DateTime.now().subtract(const Duration(hours: 25)),
          'okbruh',
          IncidentSeverity.veryHigh,
          null,
        ),
      ];
      parking.incidents = incidents;
      expect(parking.getIncidentsLastWeekExceptLast24Hours().length, 3);
    });
  });

  group('getWeekdaysSchedule', () {
    test('valid schedules', () {
      ParkingLot parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        '00h00-24h00',
        null,
        'cares',
        3424,
        232,
        24,
        {},
      );

      String realResult = parkingLot.getWeekdaysSchedule();
      String expectedResult = '00h00-24h00';
      expect(realResult, expectedResult);
    });

    test('invalid schedules', () {
      ParkingLot parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        null,
        null,
        'cares',
        3424,
        232,
        24,
        {},
      );

      String realResult = parkingLot.getWeekdaysSchedule();
      String expectedResult = 'Not Applicable';
      expect(realResult, expectedResult);
    });
  });

  group('getWeekendsSchedule', () {
    test('valid schedules', () {
      ParkingLot parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        null,
        '00h00-24h00',
        'cares',
        3424,
        232,
        24,
        {},
      );
      String realResult = parkingLot.getWeekendsSchedule();
      String expectedResult = '00h00-24h00';
      expect(realResult, expectedResult);

      parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        null,
        '08h00-02h00',
        'cares',
        3424,
        232,
        24,
        {},
      );
      realResult = parkingLot.getWeekendsSchedule();
      expectedResult = '08h00-02h00';
      expect(realResult, expectedResult);

      parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        null,
        '06h00-22h00|06h00-22h00',
        'cares',
        3424,
        232,
        24,
        {},
      );
      realResult = parkingLot.getWeekendsSchedule();
      expectedResult = '06h00-22h00';
      expect(realResult, expectedResult);
    });

    test('missing values', () {
      ParkingLot parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        null,
        null,
        'cares',
        3424,
        232,
        24,
        {},
      );
      String realResult = parkingLot.getWeekendsSchedule();
      String expectedResult = 'Not Applicable';
      expect(realResult, expectedResult);

      parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        null,
        '07h00-02h00|08h00-15h00',
        'cares',
        3424,
        232,
        24,
        {},
      );
      realResult = parkingLot.getWeekendsSchedule();
      expectedResult = 'Sat: 07h00-02h00 | Sun: 08h00-15h00';
      expect(realResult, expectedResult);

      parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        null,
        '07h30-23h00|null',
        'cares',
        3424,
        232,
        24,
        {},
      );
      realResult = parkingLot.getWeekendsSchedule();
      expectedResult = 'Sat: 07h30-23h00 | Sun: Not Applicable';
      expect(realResult, expectedResult);
    });
  });

  group('currentlyInServiceStatus', () {
    test('in-service', () {
      ParkingLot parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        '00h00-24h00',
        null,
        'cares',
        3424,
        232,
        24,
        {},
      );
      bool status = parkingLot.currentlyInServiceStatus(
        DateTime(2024, 04, 05, 12, 34),
      );
      expect(status, true);

      parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        null,
        '08h00-16h00',
        'cares',
        3424,
        232,
        24,
        {},
      );
      status = parkingLot.currentlyInServiceStatus(
        DateTime(2024, 04, 06, 8, 0),
      );
      expect(status, true);

      parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        null,
        '08h00-20h00|07h00-18h00',
        'cares',
        3424,
        232,
        24,
        {},
      );
      status = parkingLot.currentlyInServiceStatus(
        DateTime(2024, 04, 07, 17, 59),
      );
      expect(status, true);

      parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        '07h30-21h00',
        null,
        'cares',
        3424,
        232,
        24,
        {},
      );
      status = parkingLot.currentlyInServiceStatus(
        DateTime(2024, 04, 05, 20, 59),
      );
      expect(status, true);

      parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        '09h30-02h00',
        null,
        'cares',
        3424,
        232,
        24,
        {},
      );
      status = parkingLot.currentlyInServiceStatus(
        DateTime(2024, 04, 05, 1, 19),
      );
      expect(status, true);

      parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        '09h30-02h00',
        null,
        'cares',
        3424,
        232,
        24,
        {},
      );
      status = parkingLot.currentlyInServiceStatus(
        DateTime(2024, 04, 05, 1, 59),
      );
      expect(status, true);
    });

    test('out-of-service', () {
      ParkingLot parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        '08h00-24h00',
        null,
        'cares',
        3424,
        232,
        24,
        {},
      );
      bool status = parkingLot.currentlyInServiceStatus(
        DateTime(2024, 04, 05, 7, 23),
      );
      expect(status, false);

      parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        null,
        '07h00-23h00',
        'cares',
        3424,
        232,
        24,
        {},
      );
      status = parkingLot.currentlyInServiceStatus(
        DateTime(2024, 04, 06, 6, 59),
      );
      expect(status, false);

      parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        '08h30-15h00',
        null,
        'cares',
        3424,
        232,
        24,
        {},
      );
      status = parkingLot.currentlyInServiceStatus(
        DateTime(2024, 04, 05, 15, 1),
      );
      expect(status, false);

      parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        null,
        '08h30-15h00|null',
        'cares',
        3424,
        232,
        24,
        {},
      );
      status = parkingLot.currentlyInServiceStatus(
        DateTime(2024, 04, 07, 12, 0),
      );
      expect(status, false);
    });

    test('missing schedules', () {
      ParkingLot parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        null,
        null,
        'cares',
        3424,
        232,
        24,
        {},
      );
      bool status = parkingLot.currentlyInServiceStatus(
        DateTime(2024, 04, 05, 9, 10),
      );
      expect(status, false);

      parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        null,
        null,
        'cares',
        3424,
        232,
        24,
        {},
      );
      status = parkingLot.currentlyInServiceStatus(
        DateTime(2024, 04, 05, 9, 10),
      );
      expect(status, false);

      parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        '08h00-24h00',
        null,
        'cares',
        3424,
        232,
        24,
        {},
      );
      status = parkingLot.currentlyInServiceStatus(
        DateTime(2024, 04, 06, 8, 0),
      );
      expect(status, false);

      parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        '08h00-24h00',
        '08h00-24h00|null',
        'cares',
        3424,
        232,
        24,
        {},
      );
      status = parkingLot.currentlyInServiceStatus(
        DateTime(2024, 04, 07, 12, 0),
      );
      expect(status, false);

      parkingLot = ParkingLot(
        'niceid',
        'Gucci Parking',
        'somewhere',
        'ok',
        null,
        '08h00-24h00|null',
        'cares',
        3424,
        232,
        24,
        {},
      );
      status = parkingLot.currentlyInServiceStatus(
        DateTime(2024, 04, 04, 14, 46),
      );
      expect(status, false);
    });
  });
}
