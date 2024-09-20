import 'package:parking_app/data/global_state.dart';
import 'package:parking_app/domain/park.dart';

enum SortingMethod {
  alphabeticalAscendant,
  alphabeticalDescendant,
  distanceAscendant,
  distanceDescendant,
  occupationAscending,
}

class Sorting {
  static List<ParkingLot> getParkingLotsSorted(
    List<ParkingLot> parkingLots,
    SortingMethod sortingMethod,
  ) {
    switch (sortingMethod) {
      case SortingMethod.alphabeticalAscendant:
        return _sortByAlphabeticalAscendant(parkingLots);
      case SortingMethod.alphabeticalDescendant:
        return _sortByAlphabeticalDescendant(parkingLots);
      case SortingMethod.distanceAscendant:
        return _sortByDistanceAscendant(parkingLots);
      case SortingMethod.distanceDescendant:
        return _sortByDistanceDescendant(parkingLots);
      case SortingMethod.occupationAscending:
        return _sortByOccupationAscendant(parkingLots);
    }
  }

  static List<ParkingLot> _sortByAlphabeticalAscendant(
    List<ParkingLot> parkingLots,
  ) {
    parkingLots.sort((p1, p2) => p1.name.compareTo(p2.name));
    return parkingLots;
  }

  static List<ParkingLot> _sortByAlphabeticalDescendant(
    List<ParkingLot> parkingLots,
  ) {
    parkingLots.sort((p1, p2) => p2.name.compareTo(p1.name));
    return parkingLots;
  }

  static List<ParkingLot> _sortByDistanceAscendant(
    List<ParkingLot> parkingLots,
  ) {
    if (GlobalAppState.currentLocationLat == null ||
        GlobalAppState.currentLocationLon == null) {
      return parkingLots;
    }

    parkingLots.sort((p1, p2) => p1
        .getDistanceToParkingLotInMeters()!
        .compareTo(p2.getDistanceToParkingLotInMeters()!));
    return parkingLots;
  }

  static List<ParkingLot> _sortByDistanceDescendant(
    List<ParkingLot> parkingLots,
  ) {
    if (GlobalAppState.currentLocationLat == null ||
        GlobalAppState.currentLocationLon == null) {
      return parkingLots;
    }

    parkingLots.sort((p1, p2) => p2
        .getDistanceToParkingLotInMeters()!
        .compareTo(p1.getDistanceToParkingLotInMeters()!));
    return parkingLots;
  }

  static List<ParkingLot> _sortByOccupationAscendant(
    List<ParkingLot> parkingLots,
  ) {
    parkingLots.sort((p1, p2) {
      int c1 = p1.getOccupationPercentage() == null
          ? 0
          : p1.getOccupationPercentage()!;
      int c2 = p2.getOccupationPercentage() == null
          ? 0
          : p2.getOccupationPercentage()!;
      return c1.compareTo(c2);
    });
    return parkingLots;
  }
}
