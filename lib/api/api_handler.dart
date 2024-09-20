import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:parking_app/api/api_parking_lot.dart';

class NetworkNotAvailableException implements Exception {
  String cause;
  NetworkNotAvailableException(this.cause);
}

class RequestFailedException implements Exception {
  String cause;
  RequestFailedException(this.cause);
}

class EmelApiHandler {
  static const String _baseUrl = 'https://emel.city-platform.com/opendata';
  static const String _parkingLotsUrlPath = '/parking/lots';
  static const String _apiKey = '93600bb4e7fee17750ae478c22182dda';

  static Future<List<ApiParkingLotData>?> fetchParkingLotsData() async {
    late http.Response res;
    try {
      res = await http.get(
        Uri.parse('$_baseUrl$_parkingLotsUrlPath'),
        headers: {
          'api_key': _apiKey,
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

      if (res.statusCode != 200) {
        throw RequestFailedException('status code != 200');
      }
    } catch (_) {
      throw NetworkNotAvailableException('no connection');
    }

    try {
      return ApiParkingLotData.listFromJson(json.decode(res.body));
    } catch (_) {
      throw RequestFailedException('invalid body format');
    }
  }
}
