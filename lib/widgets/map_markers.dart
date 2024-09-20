import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parking_app/domain/park.dart';
import 'package:parking_app/main.dart';

Future<BitmapDescriptor> getCustomIcon(GlobalKey iconKey) async {
  Future<Uint8List> capturePng(GlobalKey iconKey) async {
    try {
      RenderRepaintBoundary boundary =
          iconKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();
      return pngBytes;
    } catch (e) {
      print(e);
      return Uint8List(0);
    }
  }

  Uint8List imageData = await capturePng(iconKey);
  return BitmapDescriptor.fromBytes(imageData);
}

class ParkingLotMapMarker extends StatelessWidget {
  ParkingLotMapMarker({required this.parkingLot});

  ParkingLot parkingLot;
  Color fgColor = const Color(0xFF49c14b);

  @override
  Widget build(BuildContext context) {
    int? availablePlaces = parkingLot.getAvailablePlaces();
    bool parkingLotIsFull = availablePlaces == null || availablePlaces == 0;
    Color fgColor = parkingLotIsFull
        ? Theme.of(context).colorScheme.onBackground
        : Theme.of(context).aquaPrimary;

    return CustomPaint(
      painter: BorderPainter(color: fgColor),
      child: ClipPath(
        clipper: RectPinClipper(),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).listItemBackground2,
          ),
          child: Icon(
            Icons.local_parking,
            size: 24,
            color: fgColor,
          ),
        ),
      ),
    );
  }
}

class RectPinClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addRRect(RRect.fromRectAndCorners(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.1,
        size.width * 0.8,
        size.height * 0.75,
      ),
      topLeft: const Radius.circular(5),
      topRight: const Radius.circular(5),
      bottomLeft: const Radius.circular(5),
      bottomRight: const Radius.circular(5),
    ));
    path.moveTo(size.width * 0.35,
        size.height * 0.85); // Starting point for the salience
    path.lineTo(size.width / 2, size.height * 0.98); // Point of the salience
    path.lineTo(size.width * 0.65,
        size.height * 0.85); // Back to the base of the salience
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BorderPainter extends CustomPainter {
  BorderPainter({required this.color});

  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    path.addRRect(RRect.fromRectAndCorners(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.1,
        size.width * 0.8,
        size.height * 0.75,
      ),
      topLeft: const Radius.circular(5),
      topRight: const Radius.circular(5),
      bottomLeft: const Radius.circular(5),
      bottomRight: const Radius.circular(5),
    ));
    path.moveTo(size.width * 0.35, size.height * 0.85);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width * 0.65, size.height * 0.85);
    path.close();

    canvas.drawPath(path, paint); // Draw the border on the path
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
