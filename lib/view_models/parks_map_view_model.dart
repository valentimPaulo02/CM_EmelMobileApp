import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:parking_app/domain/park.dart';
import 'package:parking_app/widgets/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class ParkMapViewModel extends ChangeNotifier {
  String getGeoNavigationUrl(ParkingLot parking) {
    // Select scheme by platform (IOS/Android)
    String scheme = Platform.isIOS ? 'maps' : 'geo';
    return '$scheme:${parking.coordinates}?q=${parking.coordinates}';
  }

  void openGeoNavigationOnCoordinates(
    String navUrl,
    BuildContext context,
  ) async {
    Uri geoUrl = Uri.parse(navUrl);

    try {
      await launchUrl(geoUrl);
    } catch (err) {
      Toast.triggerToast(
        context,
        'An error occurred',
        false,
        ToastAlignment.top,
        null,
        null,
      );
      //log(e);
    }
  }
}
