import 'dart:math';

import 'package:flutter/material.dart';
import 'package:parking_app/domain/park.dart';
import 'package:parking_app/main.dart';
import 'package:parking_app/widgets/semicircle_progress_indicator.dart';

class ParkingLotListItem extends StatelessWidget {
  const ParkingLotListItem({
    required this.parkingLot,
    required this.navigateToDetails,
  });

  final ParkingLot parkingLot;
  final void Function(ParkingLot parkingLot) navigateToDetails;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        navigateToDetails(parkingLot);
      },
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 600,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.35, 1.0],
            colors: [
              Theme.of(context).listItemBackground1,
              Theme.of(context).listItemBackground2,
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parkingLot.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).listItemPrimary,
                    ),
                    softWrap: true,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        parkingLot.currentlyInServiceStatus(DateTime.now())
                            ? Icons.check_circle_outline_rounded
                            : Icons.cancel_outlined,
                        size: 22,
                        color: Theme.of(context).listItemSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        parkingLot.currentlyInServiceStatus(DateTime.now())
                            ? 'In service'
                            : 'Out of service',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).listItemSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 22,
                        color: Theme.of(context).listItemSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        parkingLot.getDistanceToParkingLotInString() ??
                            'Not available',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).listItemSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Column(
                    children: [
                      SemicircleProgressIndicator(
                        progress: parkingLot.getOccupationPercentage() != null
                            ? parkingLot.getOccupationPercentage()! / 100
                            : null,
                        size: 62,
                        primaryColor:
                            parkingLot.getOccupationPercentage() == 100 ||
                                    parkingLot.getOccupationPercentage() == null
                                ? Theme.of(context).listItemSecondary
                                : Theme.of(context).aquaPrimary,
                        backgroundColor:
                            Theme.of(context).colorScheme.background,
                        textColor:
                            parkingLot.getOccupationPercentage() == 100 ||
                                    parkingLot.getOccupationPercentage() == null
                                ? Theme.of(context).listItemSecondary
                                : Theme.of(context).listItemPrimary,
                        strokeWidth: 6,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        parkingLot.getOccupationInText(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: parkingLot.getOccupationInText() == 'Full' ||
                                  parkingLot.getAvailablePlaces() == null
                              ? Theme.of(context).listItemSecondary
                              : Theme.of(context).aquaPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 22),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 36,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class ParkingFavoriteItem extends StatelessWidget {
  const ParkingFavoriteItem({
    super.key,
    required this.parkingLot,
    required this.navigateToDetails,
  });

  final ParkingLot parkingLot;
  final void Function(ParkingLot parkingLot) navigateToDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints(
          maxWidth: 600,
        ),
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.35, 1.0],
              colors: [
                Theme.of(context).listItemBackground1,
                Theme.of(context).listItemBackground2,
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                spreadRadius: 1,
                blurRadius: 6,
                offset: Offset(0, 5),
              ),
            ]),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parkingLot.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).listItemPrimary,
                    ),
                    softWrap: true,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        parkingLot.currentlyInServiceStatus(DateTime.now())
                            ? Icons.check_circle_outline_rounded
                            : Icons.cancel_outlined,
                        size: 22,
                        color: Theme.of(context).listItemSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        parkingLot.currentlyInServiceStatus(DateTime.now())
                            ? 'In service'
                            : 'Out of service',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).listItemSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 22,
                        color: Theme.of(context).listItemSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        parkingLot.getDistanceToParkingLotInString() ??
                            'Not available',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).listItemSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                print('TODO');
              },
              child: Container(
                margin: const EdgeInsets.only(right: 14),
                child: Column(
                  children: [
                    Icon(
                      Icons.remove_circle_rounded,
                      size: 38,
                      //color: Theme.of(context).colorScheme.error,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Remove',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        //color: Theme.of(context).colorScheme.error,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

class ParkingDashboardContainer extends StatelessWidget {
  const ParkingDashboardContainer({
    super.key,
    required this.parkingLot,
    required this.navigateToDetails,
  });

  final ParkingLot parkingLot;
  final void Function(ParkingLot parkingLot) navigateToDetails;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: InkWell(
        onTap: () {
          navigateToDetails(parkingLot);
        },
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 160,
          ),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.35, 1.0],
                colors: [
                  Theme.of(context).listItemBackground1,
                  Theme.of(context).listItemBackground2,
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: Offset(0, 5),
                ),
              ]),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          margin: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                parkingLot.name,
                style: TextStyle(
                  fontSize: parkingLot.name.length < 20 ? 17 : 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).listItemPrimary,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  SemicircleProgressIndicator(
                    progress: parkingLot.getOccupationPercentage() != null
                        ? parkingLot.getOccupationPercentage()! / 100
                        : null,
                    size: 54,
                    primaryColor: parkingLot.getOccupationPercentage() == 100 ||
                            parkingLot.getOccupationPercentage() == null
                        ? Theme.of(context).listItemSecondary
                        : Theme.of(context).aquaPrimary,
                    backgroundColor: Theme.of(context).colorScheme.background,
                    textColor: parkingLot.getOccupationPercentage() == 100 ||
                            parkingLot.getOccupationPercentage() == null
                        ? Theme.of(context).listItemSecondary
                        : Theme.of(context).listItemPrimary,
                    strokeWidth: 6,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    parkingLot.getOccupationInText(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: parkingLot.getOccupationInText() == 'Full' ||
                                parkingLot.getAvailablePlaces() == null
                            ? Theme.of(context).listItemSecondary
                            : Theme.of(context).aquaPrimary),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        parkingLot.currentlyInServiceStatus(DateTime.now())
                            ? Icons.check_circle_outline_rounded
                            : Icons.cancel_outlined,
                        size: 14,
                        color: Theme.of(context).listItemSecondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        parkingLot.currentlyInServiceStatus(DateTime.now())
                            ? 'In service'
                            : 'Out of serv.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).listItemSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: Theme.of(context).listItemSecondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        parkingLot.getDistanceToParkingLotInString() ?? 'N/A',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).listItemSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ParkingLotSearchItem extends StatelessWidget {
  const ParkingLotSearchItem({
    super.key,
    required this.parkingLot,
    required this.navigateToDetails,
  });

  final ParkingLot parkingLot;
  final void Function(ParkingLot parkingLot) navigateToDetails;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        navigateToDetails(parkingLot);
        Navigator.of(context).pop();
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 400,
          minWidth: min(300, MediaQuery.of(context).size.width - 60),
        ),
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.35, 1.0],
              colors: [
                Theme.of(context).listItemBackground1,
                Theme.of(context).listItemBackground2,
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                spreadRadius: 0,
                blurRadius: 3,
                offset: Offset(0, 3),
              ),
            ]),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          parkingLot.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).listItemPrimary,
                          ),
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        parkingLot.getOccupationInText(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: parkingLot.getOccupationInText() != 'Full'
                              ? Theme.of(context).aquaPrimary
                              : Theme.of(context).listItemSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            parkingLot.currentlyInServiceStatus(DateTime.now())
                                ? Icons.check_circle_outline_rounded
                                : Icons.cancel_outlined,
                            size: 16,
                            color: Theme.of(context).listItemSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            parkingLot.currentlyInServiceStatus(DateTime.now())
                                ? 'In service'
                                : 'Out of service',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).listItemSecondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: Theme.of(context).listItemSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            parkingLot.getDistanceToParkingLotInString() ??
                                'Not available',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).listItemSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(width: 20),
            Flexible(
              flex: 0,
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
