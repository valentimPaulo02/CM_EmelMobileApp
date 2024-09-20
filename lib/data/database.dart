import 'dart:io';

import 'package:flutter/services.dart';
import 'package:parking_app/domain/park.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/incident.dart';

class LocalDatabase {
  static Database? db;

  Future<void> init() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'parking_data.db');
    var dbExists = await databaseExists(path);

    if (!dbExists) {
      ByteData data = await rootBundle.load(url.join(
        'assets',
        'local_data',
        'parking_data.db',
      ));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    }

    db = await openDatabase(path, version: 1);
  }

  static Future<List<ParkingLot>?> getParkingLots() async {
    if (db == null) {
      return null;
    }

    const String query = '''
      SELECT p.parking_id, p.name, p.address, p.coordinates, p.typology, 
      p.schedule_working_days, p.schedule_weekends, p.max_capacity, 
      p.charging_places, p.disabled_places, f.minimum, f.hour1, f.hour2, 
      f.hour3, f.hour4, f.maximum
      FROM parking_lot AS p
      INNER JOIN parking_fee as f
      WHERE p.parking_id == f.parking_id
    ''';

    final List<Map<String, dynamic>> parkingLotsData =
        await db!.rawQuery(query);

    List<ParkingLot> parkingLots = [];
    for (var parkingLot in parkingLotsData) {
      String id = parkingLot['parking_id'];
      String name = parkingLot['name'];
      String address = parkingLot['address'];
      String coordinates = parkingLot['coordinates'];
      String typology = parkingLot['typology'];
      String? scheduleWorkingDays = parkingLot['schedule_working_days'];
      String? scheduleWeekends = parkingLot['schedule_weekends'];
      int parkingPlaces = parkingLot['max_capacity'] ?? -1;
      int? chargingPlaces = parkingLot['charging_places'];
      int? disabledPlaces = parkingLot['disabled_places'];

      // fees
      double? min = parkingLot['minimum'];
      double? hour1 = parkingLot['hour1'];
      double? hour2 = parkingLot['hour2'];
      double? hour3 = parkingLot['hour3'];
      double? hour4 = parkingLot['hour4'];
      double? max = parkingLot['maximum'];

      Map<String, double?>? fees;
      if (min != null ||
          hour1 != null ||
          hour2 != null ||
          hour3 != null ||
          hour4 != null ||
          max != null) {
        fees = {
          'minimum': min,
          '1 hour': hour1,
          '2 hours': hour2,
          '3 hours': hour3,
          '4 hours': hour4,
          'daily maximum': max
        };
      }

      ParkingLot parking = ParkingLot(
        id,
        name,
        address,
        coordinates,
        scheduleWorkingDays,
        scheduleWeekends,
        typology,
        parkingPlaces,
        chargingPlaces,
        disabledPlaces,
        fees,
      );
      parkingLots.add(parking);
    }

    // add fees to parking lots
    Map<String, List<Incident>>? incidents =
        await getLastWeekIncidentsByParkingId();
    if (incidents == null) return parkingLots;

    for (var parkingId in incidents.keys) {
      for (var parkingLot in parkingLots) {
        if (parkingLot.id == parkingId) {
          parkingLot.incidents = incidents[parkingId]!;
        }
      }
    }
    return parkingLots;
  }

  Future<bool> insertIncident(String parkingId, Incident incident) async {
    if (db == null) {
      return false;
    }

    return await db!.insert(
          'incident',
          {
            'parking_id': parkingId,
            'description': incident.description,
            'severity': incident.severity.index,
            'image': incident.image,
            'timestamp': incident.timestamp.toIso8601String(),
          },
        ) ==
        1;
  }

  Future<List<Map>?> getIncidents() async {
    if (db == null) {
      return null;
    }

    List<Map> maps = await db!.rawQuery('SELECT * FROM incident');
    return maps;
  }

  static Future<Map<String, List<Incident>>?>
      getLastWeekIncidentsByParkingId() async {
    if (db == null) {
      return null;
    }

    final List<Map<String, dynamic>> queryResults = await db!.query(
      'incident',
      where: 'timestamp >= ?',
      whereArgs: [
        DateTime.now().subtract(const Duration(days: 7)).toIso8601String()
      ],
    );

    final Map<String, List<Incident>> incidentsByParking = {};
    for (var result in queryResults) {
      String parkingId = result['parking_id'];

      if (!incidentsByParking.containsKey(parkingId)) {
        incidentsByParking[parkingId] = [
          Incident(
            DateTime.parse(result['timestamp']),
            result['description'],
            _dbSeverityToIncidentSeverity(result['severity']),
            result['image'],
          )
        ];
      } else {
        incidentsByParking.update(
            parkingId,
            (value) => [
                  ...value,
                  Incident(
                    DateTime.parse(result['timestamp']),
                    result['description'],
                    _dbSeverityToIncidentSeverity(result['severity']),
                    result['image'],
                  )
                ]);
      }
    }
    return incidentsByParking;
  }

  static IncidentSeverity _dbSeverityToIncidentSeverity(int dbValue) {
    switch (dbValue) {
      case 0:
        return IncidentSeverity.veryLow;
      case 1:
        return IncidentSeverity.low;
      case 2:
        return IncidentSeverity.medium;
      case 3:
        return IncidentSeverity.high;
      default:
        return IncidentSeverity.veryHigh;
    }
  }
}
