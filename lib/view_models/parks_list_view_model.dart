import 'package:flutter/foundation.dart';
import 'package:parking_app/data/global_state.dart';
import 'package:parking_app/domain/park.dart';
import 'package:parking_app/domain/sorting.dart';

class ParkListViewModel extends ChangeNotifier {
  final GlobalAppState _globalAppState;
  List<ParkingLot> _parkingLots = [];

  List<ParkingLot> get parkingLots => _parkingLots;

  ParkListViewModel(this._globalAppState) {
    _parkingLots = [..._globalAppState.parkingLots];
    updateSortingMethodAndSortParkingLots(
        _globalAppState.currentListSortingMethod);
    notifyListeners();
  }

  void updateSortingMethodAndSortParkingLots(SortingMethod sort) {
    _globalAppState.currentListSortingMethod = sort;
    _parkingLots = Sorting.getParkingLotsSorted(
      _parkingLots,
      _globalAppState.currentListSortingMethod,
    );
    notifyListeners();
  }
}
