import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:parking_app/domain/park.dart';

class LocalParkingData {
  static Future<List<ParkingLot>> parse() async {
    String dataString =
        await rootBundle.loadString('assets/local_data/emel_parking_data.json');
    List<dynamic> data = jsonDecode(dataString);

    List<ParkingLot> parkingLots = [];

    for (var park in data) {
      // General Info
      String id = park['id'];
      Map<String, dynamic> generalInfo = park['general_info'];
      String name = generalInfo['name'];
      String address = generalInfo['address'];
      String coordinates = generalInfo['coordinates'];
      List<String?>? schedule;
      if (generalInfo['schedule'] != null) {
        schedule = [
          generalInfo['schedule']['working_days'],
          generalInfo['schedule']['weekends'],
        ];
      } else {
        schedule = null;
      }
      String typology = generalInfo['typology'];
      int parkingPlaces = generalInfo['parkingPlaces'];
      int? chargingPlaces = generalInfo['chargingPlaces'];
      int? disabledPlaces = generalInfo['disabledPlaces'];

      // Fees Info
      List<dynamic> parkFees = park['fees'];
      Map<String, double> fees = {};

      if (parkFees.isNotEmpty) {
        for (var item in parkFees) {
          for (var fee in item.entries) {
            String valueWithoutEuroSign =
                fee.value.substring(0, fee.value.length - 2);
            fees[fee.key] = double.parse(valueWithoutEuroSign.toString());
          }
        }
      }

      ParkingLot parking = ParkingLot(
          id,
          name,
          address,
          coordinates,
          schedule?[0],
          schedule?[1],
          typology,
          parkingPlaces,
          chargingPlaces,
          disabledPlaces,
          fees);
      parkingLots.add(parking);
    }
    return parkingLots;
  }
}
