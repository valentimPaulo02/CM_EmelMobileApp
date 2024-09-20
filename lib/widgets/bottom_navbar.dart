import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:parking_app/main.dart';

class AppNavbar extends StatefulWidget {
  AppNavbar({
    super.key,
    required this.currentPage,
    required this.setPage,
  });

  AppPage currentPage;
  void Function(AppPage page) setPage;

  @override
  State<AppNavbar> createState() => _AppNavbarState();
}

class _AppNavbarState extends State<AppNavbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: BottomAppBar(
        color: Theme.of(context).menuBackground,
        elevation: 0,
        height: 58,
        padding: EdgeInsets.zero,
        shape: CustomCircularNotchedRectangle(borderRadius: 10.0),
        notchMargin: 8,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.warning_rounded),
                iconSize: 36,
                padding: EdgeInsets.zero,
                color: widget.currentPage == AppPage.incidentReport
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).menuForeground,
                onPressed: () {
                  widget.setPage(AppPage.incidentReport);
                },
              ),
              IconButton(
                icon: const Icon(Icons.map_rounded),
                iconSize: 36,
                padding: EdgeInsets.zero,
                color: widget.currentPage == AppPage.parksMap
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).menuForeground,
                onPressed: () {
                  widget.setPage(AppPage.parksMap);
                },
              ),
              const SizedBox(
                width: 80,
              ),
              IconButton(
                icon: const Icon(Icons.format_list_bulleted_rounded),
                iconSize: 36,
                padding: EdgeInsets.zero,
                color: widget.currentPage == AppPage.parksList
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).menuForeground,
                onPressed: () {
                  widget.setPage(AppPage.parksList);
                },
              ),
              IconButton(
                icon: const Icon(Icons.star_rounded),
                iconSize: 36,
                padding: EdgeInsets.zero,
                color: widget.currentPage == AppPage.favorites
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).menuForeground,
                onPressed: () {
                  widget.setPage(AppPage.favorites);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomCircularNotchedRectangle extends NotchedShape {
  double borderRadius = 10.0;

  CustomCircularNotchedRectangle({this.borderRadius = 10.0});

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) {
      return Path()..addRect(host);
    }

    // The guest's shape is a circle bounded by the guest rectangle.
    // So the guest's radius is half the guest width.
    final double notchRadius = guest.width / 2.0;

    // We build a path for the notch from 3 segments:
    // Segment A - a Bezier curve from the host's top edge to segment B.
    // Segment B - an arc with radius notchRadius.
    // Segment C - a Bezier curve from segment B back to the host's top edge.
    //
    // A detailed explanation and the derivation of the formulas below is
    // available at: https://goo.gl/Ufzrqn

    const double s1 = 20.0;
    const double s2 = 10.0;

    final double r = notchRadius;
    final double a = -1.0 * r - s2;
    final double b = host.top - guest.center.dy;

    final double n2 = math.sqrt(b * b * r * r * (a * a + b * b - r * r));
    final double p2xA = ((a * r * r) - n2) / (a * a + b * b);
    final double p2xB = ((a * r * r) + n2) / (a * a + b * b);
    final double p2yA = math.sqrt(r * r - p2xA * p2xA);
    final double p2yB = math.sqrt(r * r - p2xB * p2xB);

    final List<Offset?> p = List<Offset?>.filled(6, null);

    // p0, p1, and p2 are the control points for segment A.
    p[0] = Offset(a - s1, b);
    p[1] = Offset(a, b);
    final double cmp = b < 0 ? -1.0 : 1.0;
    p[2] = cmp * p2yA > cmp * p2yB ? Offset(p2xA, p2yA) : Offset(p2xB, p2yB);

    // p3, p4, and p5 are the control points for segment B, which is a mirror
    // of segment A around the y axis.
    p[3] = Offset(-1.0 * p[2]!.dx, p[2]!.dy);
    p[4] = Offset(-1.0 * p[1]!.dx, p[1]!.dy);
    p[5] = Offset(-1.0 * p[0]!.dx, p[0]!.dy);

    // translate all points back to the absolute coordinate system.
    for (int i = 0; i < p.length; i += 1) {
      p[i] = p[i]! + guest.center;
    }

    return Path()
      // top-left corner start
      ..moveTo(host.left, host.bottom)
      ..lineTo(host.left, host.top + borderRadius)
      ..arcToPoint(
        Offset(host.left + borderRadius, host.top),
        radius: Radius.circular(borderRadius),
        clockwise: true,
      )
      // top-left corner end
      ..moveTo(host.left + borderRadius, host.top)
      ..lineTo(p[0]!.dx, p[0]!.dy)
      ..quadraticBezierTo(p[1]!.dx, p[1]!.dy, p[2]!.dx, p[2]!.dy)
      ..arcToPoint(
        p[3]!,
        radius: Radius.circular(notchRadius),
        clockwise: false,
      )
      ..quadraticBezierTo(p[4]!.dx, p[4]!.dy, p[5]!.dx, p[5]!.dy)
      // top-right corner start
      ..lineTo(host.right - borderRadius, host.top)
      ..arcToPoint(
        Offset(host.right, host.top + borderRadius),
        radius: Radius.circular(borderRadius),
        clockwise: true,
      )
      // top-right corner end
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();
  }
}
