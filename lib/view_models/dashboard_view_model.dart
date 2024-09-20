import 'package:flutter/foundation.dart';
import 'package:parking_app/data/global_state.dart';
import 'package:parking_app/domain/park.dart';
import 'package:parking_app/domain/sorting.dart';

class DashboardViewModel extends ChangeNotifier {
  final GlobalAppState _globalAppState;
  List<ParkingLot> _nearestFreeParkingLots = [];
  List<ParkingLot> _nearestFavoriteParkingLots = [];

  DashboardViewModel(this._globalAppState) {
    _updateParkingLots();
    _globalAppState.addListener(_updateParkingLots);
  }

  List<ParkingLot> get nearestFreeParkingLots => _nearestFreeParkingLots;

  List<ParkingLot> get nearestFavoriteParkingLots =>
      _nearestFavoriteParkingLots;

  void _updateParkingLots() {
    _updateNearestFreeParkingLots();
    _updateNearestFavoriteParkingLots();
    notifyListeners();
  }

  void _updateNearestFreeParkingLots() {
    _nearestFreeParkingLots = Sorting.getParkingLotsSorted(
      [..._globalAppState.parkingLots],
      SortingMethod.distanceAscendant,
    )
        .where((parking) {
          if (parking.getAvailablePlaces() == null) return true;
          return parking.getAvailablePlaces()! > 0;
        })
        .take(4)
        .toList();
  }

  void _updateNearestFavoriteParkingLots() {
    _nearestFavoriteParkingLots = Sorting.getParkingLotsSorted(
      [..._globalAppState.parkingLots],
      SortingMethod.distanceAscendant,
    ).where((parking) => parking.favorite).take(2).toList();
  }

  @override
  void dispose() {
    _globalAppState.removeListener(_updateParkingLots);
    super.dispose();
  }
}
