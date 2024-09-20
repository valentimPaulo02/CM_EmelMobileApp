import 'package:flutter/material.dart';
import 'package:parking_app/data/database.dart';
import 'package:parking_app/data/global_state.dart';
import 'package:parking_app/domain/sorting.dart';

import '../domain/incident.dart';
import '../domain/park.dart';

class IncidentReportViewModel extends ChangeNotifier {
  final GlobalAppState _globalAppState;
  List<String> _parkingLotNames = [];
  ParkingLot? _temp;
  Incident? _incident;

  String? _parkName;
  DateTime? _date;
  TimeOfDay? _time;
  String? _description;
  IncidentSeverity? _severity;
  String? _picture;

  bool _filledPark = true;
  bool _filledDate = true;
  bool _filledTime = true;
  bool _filledSeverity = true;

  IncidentReportViewModel(this._globalAppState) {
    _temp = null;
    getParkingLotNames();
  }

  void getParkingLotNames() {
    List<String> parkingNames = [];
    List<ParkingLot> parkingLots = [..._globalAppState.parkingLots];
    parkingLots = Sorting.getParkingLotsSorted(
      parkingLots,
      SortingMethod.alphabeticalAscendant,
    );

    for (var parking in parkingLots) {
      parkingNames.add(parking.name);
    }
    _parkingLotNames = parkingNames;
    notifyListeners();
  }

  Future<bool> createIncident(LocalDatabase db) async {
    if (_parkName == null) return false;
    if (_date == null) return false;
    if (_time == null) return false;
    if (_severity == null) return false;

    _temp = _globalAppState.getParkingLotByName(_parkName!)!;
    _incident = Incident(
      DateTime(
        _date!.year,
        _date!.month,
        _date!.day,
        _time!.hour,
        _time!.minute,
      ),
      _description ?? '',
      _severity!,
      _picture,
    );

    bool successfullySavedInDb = await db.insertIncident(_temp!.id, _incident!);
    if (successfullySavedInDb) {
      _temp?.addIncident(_incident!);
    }
    return successfullySavedInDb;
  }

  void checkFormCamps() {
    if (_parkName == null) _filledPark = false;
    if (_date == null) _filledDate = false;
    if (_time == null) _filledTime = false;
    if (_severity == null) _filledSeverity = false;
    notifyListeners();
  }

  List<String> get parkingLotNames => _parkingLotNames;

  String? get parkName => _parkName;

  DateTime? get date => _date;

  TimeOfDay? get time => _time;

  String? get description => _description;

  IncidentSeverity? get severity => _severity;

  String? get picture => _picture;

  bool get filledPark => _filledPark;

  bool get filledDate => _filledDate;

  bool get filledTime => _filledTime;

  bool get filledSeverity => _filledSeverity;

  set setFilledSeverity(bool value) {
    _filledSeverity = value;
    notifyListeners();
  }

  set setFilledTime(bool value) {
    _filledTime = value;
    notifyListeners();
  }

  set setFilledDate(bool value) {
    _filledDate = value;
    notifyListeners();
  }

  set setFilledPark(bool value) {
    _filledPark = value;
    notifyListeners();
  }

  set setPicture(String value) {
    _picture = value;
    notifyListeners();
  }

  set setSeverity(IncidentSeverity value) {
    _severity = value;
    notifyListeners();
  }

  set setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  set setTime(TimeOfDay value) {
    _time = value;
    notifyListeners();
  }

  set setDate(DateTime value) {
    _date = value;
    notifyListeners();
  }

  set setParkName(String value) {
    _parkName = value;
    notifyListeners();
  }

  set setParkingLotNames(List<String> value) {
    _parkingLotNames = value;
    notifyListeners();
  }
}
