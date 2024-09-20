import 'package:geolocator/geolocator.dart';
import 'package:parking_app/domain/location.dart';

class LocationService {
  static Future<Position?> getDeviceLocation() async {
    return await GeoLocation.getDeviceLocation();
  }
}
