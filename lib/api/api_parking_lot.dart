import 'package:flutter/cupertino.dart';

class ApiParkingLotData {
  String id;
  String name;
  bool active;
  int entityId;
  int maxCapacity;
  int occupation;
  String occupationDate;
  String lat;
  String lon;
  String type;

  ApiParkingLotData(
    this.id,
    this.name,
    this.active,
    this.entityId,
    this.maxCapacity,
    this.occupation,
    this.occupationDate,
    this.lat,
    this.lon,
    this.type,
  );

  static ApiParkingLotData fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id_parque': String id,
        'nome': String name,
        'activo': int active,
        'id_entidade': int entityId,
        'capacidade_max': int maxCapacity,
        'ocupacao': int occupation,
        'data_ocupacao': String occupationDate,
        'latitude': String lat,
        'longitude': String lon,
        'tipo': String type,
      } =>
        ApiParkingLotData(
          id,
          name,
          active == 0 ? false : true,
          entityId,
          maxCapacity,
          occupation,
          occupationDate,
          lat,
          lon,
          type,
        ),
      _ => throw const FormatException('Failed to load json'),
    };
  }

  static List<ApiParkingLotData> listFromJson(List<dynamic> json) {
    return json.map((data) => fromJson(data as Map<String, dynamic>)).toList();
  }

  static String nameToNameId(String name) {
    String nameId = name.toLowerCase();
    nameId = _removeAccents(nameId);
    nameId = nameId.replaceAll('.', '');
    nameId = nameId.split('-')[0].trim();
    nameId = nameId.replaceAll(' ', '-');
    return nameId;
  }

  static String _removeAccents(String input) {
    const accents = 'áàãâäéèêëíìîïóòõôöúùûüç';
    const withoutAccents = 'aaaaaeeeeiiiiooooouuuuc';

    return input.characters
        .map((char) => accents.contains(char)
            ? withoutAccents[accents.indexOf(char)]
            : char)
        .join();
  }
}
