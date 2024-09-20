import 'package:geolocator/geolocator.dart';
import 'package:parking_app/api/api_parking_lot.dart';
import 'package:parking_app/data/global_state.dart';

import 'incident.dart';

class ParkingLot {
  // General Info
  final String _id;
  final String _name;
  final String? _address;
  final String _coordinates;
  final String? _schedule_working_days;
  final String? _schedule_weekends;
  final String _typology;
  int _parkingPlaces;
  final int? _chargingPlaces;
  final int? _disabledPlaces;
  bool _active = true;
  bool _markedFavorite = false;
  // Fees Info
  final Map<String, double?>? _fees;
  // Live Data
  late int? _occupiedPlaces;
  // Incidents Info
  List<Incident> _incidents = [];

  ParkingLot(
    this._id,
    this._name,
    this._address,
    this._coordinates,
    this._schedule_working_days,
    this._schedule_weekends,
    this._typology,
    this._parkingPlaces,
    this._chargingPlaces,
    this._disabledPlaces,
    this._fees,
  ) {
    _occupiedPlaces = null;
  }

  int? get disabledPlaces => _disabledPlaces;

  int? get chargingPlaces => _chargingPlaces;

  int get parkingPlaces => _parkingPlaces;

  String get typology => _typology;

  String? get scheduleWorkingDays => _schedule_working_days;

  String? get scheduleWeekends => _schedule_weekends;

  String get coordinates => _coordinates;

  String? get address => _address;

  String get name => _name;

  String get id => _id;

  bool get active => _active;

  bool get favorite => _markedFavorite;

  set setFavorite(bool value) {
    _markedFavorite = value;
  }

  set parkingPlaces(int value) {
    _parkingPlaces = value;
  }

  set occupiedPlaces(int? value) {
    _occupiedPlaces = value;
  }

  set active(bool value) {
    _active = value;
  }

  Map<String, double?>? get fees => _fees;

  int? get occupiedPlaces => _occupiedPlaces;

  List<Incident> get incidents => _incidents;

  set incidents(List<Incident> value) {
    _incidents = value;
  }

  void addIncident(Incident incident) {
    _incidents.add(incident);
  }

  @override
  String toString() {
    return '$_name | $_address | $_parkingPlaces';
  }

  // !!!WARNING!!!
  // This function has a lot of workaround due to all the 'messed' in the api
  void updateLiveData(ApiParkingLotData apiData) {
    // make sure the capacity is a valid value, otherwise it will brake basic
    // functionality
    if (apiData.maxCapacity > 0) {
      _parkingPlaces = apiData.maxCapacity;
    }

    // make sure the current occupation fits the max capacity and uses absolute
    // values since the api might return negative values (WTF?!)
    if (apiData.occupation.abs() > _parkingPlaces) {
      _occupiedPlaces = _parkingPlaces;
    } else {
      _occupiedPlaces = apiData.occupation.abs();
    }

    _active = apiData.active;
  }

  void invalidateLiveData() {
    _occupiedPlaces = null;
  }

  int? getAvailablePlaces() {
    if (_occupiedPlaces == null) return null;
    return _parkingPlaces - _occupiedPlaces!;
  }

  /// Returns the parking lot occupation rounded (from 0 to 100).
  int? getOccupationPercentage() {
    if (_occupiedPlaces == null) return null;
    return (100 * _occupiedPlaces! / _parkingPlaces).floor();
  }

  /// Returns the parking lot occupation in a string.
  ///
  /// Free            ->  (0-69)%
  /// Places left     ->  (70-99)% || available_places <= 10
  /// Full            ->  100%
  String getOccupationInText() {
    int? availablePlaces = getAvailablePlaces();

    if (availablePlaces == null) return 'No Data';
    if (availablePlaces == 0) return 'Full';
    int? occupationPercentage = getOccupationPercentage()!;
    if (availablePlaces <= 10 ||
        (occupationPercentage >= 70 && occupationPercentage <= 99)) {
      return '$availablePlaces left';
    }
    return 'Free';
  }

  String getWeekdaysSchedule() {
    if (_schedule_working_days == null || _schedule_working_days.isEmpty) {
      return 'Not Applicable';
    }
    return _schedule_working_days.replaceAll(':', 'h');
  }

  String getWeekendsSchedule() {
    if (_schedule_weekends == null || _schedule_weekends.isEmpty) {
      return 'Not Applicable';
    }

    // Check if the schedule is the same for Saturday and Sunday
    String sched = _schedule_weekends.replaceAll(':', 'h');
    if (!sched.contains('|')) {
      return _schedule_weekends.replaceAll(':', 'h');
    }

    List<String> scheds = _schedule_weekends.split('|');
    String sat = scheds[0].replaceAll(':', 'h');
    String sun =
        scheds[1] != 'null' ? scheds[1].replaceAll(':', 'h') : 'Not Applicable';

    if (sat == sun) return sat;
    return 'Sat: $sat | Sun: $sun';
  }

  bool currentlyInServiceStatus(DateTime targetTime) {
    bool weekday = targetTime.weekday != DateTime.saturday &&
        targetTime.weekday != DateTime.sunday;

    List<String> scheduleData = [];

    if (weekday) {
      if (_schedule_working_days == null) return false;
      scheduleData = _schedule_working_days.split('-');
    } else {
      if (_schedule_weekends == null) return false;

      if (_schedule_weekends.contains('|')) {
        List<String> weekendData = _schedule_weekends.split('|');
        if (weekendData[0] == 'null' || weekendData[1] == 'null') return false;

        scheduleData = targetTime.weekday == DateTime.saturday
            ? weekendData[0].split('-')
            : weekendData[1].split('-');
      } else {
        scheduleData = _schedule_weekends.split('-');
      }
    }

    // fix time format
    scheduleData =
        scheduleData.map((data) => data.replaceAll(':', 'h')).toList();

    // Start time
    List<String> startTime = scheduleData[0].split('h');
    int startHour = int.parse(startTime[0]);
    int startMin = int.parse(startTime[1]);
    DateTime startDateTime;

    // End time
    List<String> endTime = scheduleData[1].split('h');
    int endHour = int.parse(endTime[0]);
    int endMin = int.parse(endTime[1]);
    DateTime endDateTime;

    bool endsNextDay = endHour < startHour;
    // in case it ends the next day, check if the current time
    // is already next day
    if (endsNextDay) {
      bool alreadyNextDay = targetTime.hour < endHour;
      startDateTime = DateTime(
        targetTime.year,
        targetTime.month,
        targetTime.day,
        startHour,
        startMin,
      );
      if (alreadyNextDay) {
        startDateTime = startDateTime.subtract(const Duration(days: 1));
      }

      endDateTime = DateTime(
        targetTime.year,
        targetTime.month,
        targetTime.day,
        endHour,
        endMin,
      );
    } else {
      startDateTime = DateTime(
        targetTime.year,
        targetTime.month,
        targetTime.day,
        startHour,
        startMin,
      );
      endDateTime = DateTime(
        targetTime.year,
        targetTime.month,
        targetTime.day,
        endHour,
        endMin,
      );
    }

    return (targetTime.isAtSameMomentAs(startDateTime) ||
            targetTime.isAfter(startDateTime)) &&
        targetTime.isBefore(endDateTime);
  }

  List<Incident> getIncidentsLast24Hours() {
    List<Incident> incidents = [];
    for (var incident in _incidents) {
      if (incident.timestamp
          .isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
        incidents.add(incident);
      }
    }
    return incidents;
  }

  List<Incident> getIncidentsLastWeek() {
    List<Incident> incidents = [];
    for (var incident in _incidents) {
      if (incident.timestamp
          .isAfter(DateTime.now().subtract(const Duration(days: 7)))) {
        incidents.add(incident);
      }
    }
    return incidents;
  }

  List<Incident> getIncidentsLastWeekExceptLast24Hours() {
    List<Incident> incidents = [];
    for (var incident in _incidents) {
      bool inLastWeek = incident.timestamp
          .isAfter(DateTime.now().subtract(const Duration(days: 7)));
      bool inLast24 = incident.timestamp
          .isAfter(DateTime.now().subtract(const Duration(days: 1)));
      if (inLastWeek && !inLast24) {
        incidents.add(incident);
      }
    }
    return incidents;
  }

  double? getDistanceToParkingLotInMeters() {
    double? currentLat = GlobalAppState.currentLocationLat;
    double? currentLon = GlobalAppState.currentLocationLon;

    if (currentLat == null || currentLon == null) return null;

    List<String> parkingCoordinates = coordinates.split(',');
    double parkingLat = double.parse(parkingCoordinates[0].replaceAll(' ', ''));
    double parkingLon = double.parse(parkingCoordinates[1].replaceAll(' ', ''));
    return Geolocator.distanceBetween(
      currentLat,
      currentLon,
      parkingLat,
      parkingLon,
    );
  }

  String? getDistanceToParkingLotInString() {
    double? distanceInMeters = getDistanceToParkingLotInMeters();

    if (distanceInMeters == null) {
      return null;
    }

    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    }

    String kmString = (distanceInMeters / 1000.0).toStringAsFixed(1);
    if (distanceInMeters < 100000) {
      return '${kmString.replaceAll('.', ',')}km';
    }

    if (distanceInMeters >= 1000000) {
      return '>999km';
    }

    return '${kmString.split('.')[0]}km';
  }

  double getLatitude() {
    return double.parse(coordinates.split(',')[0]);
  }

  double getLongitude() {
    return double.parse(coordinates.split(',')[1]);
  }
}
