import 'package:flutter/cupertino.dart';
import 'package:parking_app/data/global_state.dart';
import 'package:parking_app/domain/park.dart';

class FavoritesViewModel extends ChangeNotifier {
  final GlobalAppState _globalAppState;
  late List<ParkingLot> _favorites = [];

  FavoritesViewModel(this._globalAppState) {
    _favorites = _globalAppState.getFavoriteParkingLots();
  }

  List<ParkingLot> get favorites => _favorites;
}
