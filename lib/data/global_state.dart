import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parking_app/api/api_handler.dart';
import 'package:parking_app/api/api_parking_lot.dart';
import 'package:parking_app/data/database.dart';
import 'package:parking_app/domain/park.dart';
import 'package:parking_app/domain/sorting.dart';
import 'package:parking_app/services/connectivity_service.dart';
import 'package:parking_app/services/location_service.dart';

class GlobalAppState extends ChangeNotifier {
  List<ParkingLot> _parkingLots = [];
  static double? _currentLocationLat;
  static double? _currentLocationLon;
  SortingMethod _currentListSortingMethod = SortingMethod.alphabeticalAscendant;
  late ParkingLot _focusedParkingLot;
  DateTime _lastUpdatedParkingInfo = DateTime.now();
  Timer? _parkingDataFetchTimer;
  Timer? _deviceLocationFetchTimer;

  GlobalAppState() {
    _updateParkingDataPeriodically(const Duration(minutes: 1));
    _getCurrentDeviceLocationPeriodically(const Duration(seconds: 5));
  }

  List<ParkingLot> get parkingLots => _parkingLots;

  static double? get currentLocationLat => _currentLocationLat;

  static double? get currentLocationLon => _currentLocationLon;

  SortingMethod get currentListSortingMethod => _currentListSortingMethod;

  ParkingLot get focusedParkingLot => _focusedParkingLot;

  DateTime get lastUpdatedParkingInfo => _lastUpdatedParkingInfo;

  set currentListSortingMethod(SortingMethod sort) {
    _currentListSortingMethod = sort;
  }

  set focusedParkingLot(ParkingLot parkingLot) {
    _focusedParkingLot = parkingLot;
  }

  Future<bool> loadInitialData() async {
    // get parking lots from db
    _parkingLots = await LocalDatabase.getParkingLots() ?? [];

    // fetch current device location
    _updateLocationData();

    // update parking data with realtime info
    await updateParkingData();
    notifyListeners();
    return true;
  }

  void _updateParkingDataPeriodically(Duration interval) {
    _parkingDataFetchTimer = Timer.periodic(interval, (_) async {
      if (await ConnectivityService.hasConnection()) {
        await updateParkingData();
      } else {
        bool currentDataIsStale = _lastUpdatedParkingInfo
            .isBefore(DateTime.now().subtract(const Duration(minutes: 30)));

        if (currentDataIsStale) {
          invalidateParkingData();
        }
      }
      notifyListeners();
    });
  }

  void _getCurrentDeviceLocationPeriodically(Duration interval) {
    _deviceLocationFetchTimer = Timer.periodic(interval, (_) async {
      await _updateLocationData();
      notifyListeners();
    });
  }

  Future<void> updateParkingData() async {
    List<ApiParkingLotData>? apiParkingData;

    try {
      apiParkingData = await EmelApiHandler.fetchParkingLotsData();
    } catch (_) {
      // we can handle api data fetching exceptions here
    }

    if (apiParkingData == null) return;

    List<ParkingLot> updatedParkingLots = [];

    for (var parkingLotData in apiParkingData) {
      // search parking by coordinates and name
      ParkingLot? existingParkingLot = getParkingLotById(parkingLotData.id);

      if (existingParkingLot == null) {
        // create new parking lots that don't exist in local data
        ParkingLot newParkingLot = ParkingLot(
          parkingLotData.id,
          parkingLotData.name,
          null,
          '${parkingLotData.lat},${parkingLotData.lon}',
          null,
          null,
          parkingLotData.type.toLowerCase() == 'estrutura'
              ? 'Structure'
              : 'Surface',
          parkingLotData.maxCapacity.abs(),
          null,
          null,
          null,
        );
        newParkingLot.updateLiveData(parkingLotData);
        updatedParkingLots.add(newParkingLot);

        continue;
      }

      // update parking info
      existingParkingLot.updateLiveData(parkingLotData);
      updatedParkingLots.add(existingParkingLot);

      // update 'last updated' timestamp
      _lastUpdatedParkingInfo = DateTime.parse(parkingLotData.occupationDate);
    }
    _parkingLots = updatedParkingLots;
    notifyListeners();
  }

  void invalidateParkingData() {
    for (var parkingLot in _parkingLots) {
      parkingLot.invalidateLiveData();
    }
  }

  Future<void> _updateLocationData() async {
    Position? loc = await LocationService.getDeviceLocation();
    if (loc == null) {
      _currentLocationLat = null;
      _currentLocationLon = null;
    } else {
      _currentLocationLat = loc.latitude;
      _currentLocationLon = loc.longitude;
    }
  }

  ParkingLot? getParkingLotById(String id) {
    for (var parkingLot in _parkingLots) {
      if (parkingLot.id == id) return parkingLot;
    }
    return null;
  }

  ParkingLot? getParkingLotByName(String parkName) {
    for (var parkingLot in _parkingLots) {
      if (parkingLot.name == parkName) return parkingLot;
    }
    return null;
  }

  ParkingLot? getParkingLotByCoordinates(String lat, String lon) {
    for (var parkingLot in _parkingLots) {
      List<String> pCoordinates = parkingLot.coordinates.split(',');
      double pLat = double.parse(pCoordinates[0]);
      double pLon = double.parse(pCoordinates[1]);
      double dLat = double.parse(lat);
      double dLon = double.parse(lon);

      if (compareDouble(pLat, dLat, 3) && compareDouble(pLon, dLon, 3)) {
        return parkingLot;
      }
    }
    return null;
  }

  bool compareDouble(double value1, double value2, int places) {
    num fac = pow(10, places);
    return (value1 * fac).round() == (value2 * fac).round();
  }

  bool validParkingLotId(String id) {
    for (var parkingLot in _parkingLots) {
      if (parkingLot.id == id) return true;
    }
    return false;
  }

  List<ParkingLot> getFavoriteParkingLots() {
    return [
      ..._parkingLots.where((parking) => parking.favorite),
    ];
  }

  bool locationIsEnabled() {
    return _currentLocationLat != null || _currentLocationLon != null;
  }

  @override
  void dispose() {
    _parkingDataFetchTimer?.cancel();
    _deviceLocationFetchTimer?.cancel();
    super.dispose();
  }
}
