import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:parking_app/data/global_state.dart';
import 'package:parking_app/domain/incident.dart';
import 'package:parking_app/domain/park.dart';
import 'package:parking_app/main.dart';
import 'package:parking_app/widgets/button.dart';
import 'package:parking_app/widgets/toast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    GlobalAppState globalAppState = Provider.of<GlobalAppState>(context);
    ParkingLot parking = globalAppState.focusedParkingLot;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          _NameRow(parking: parking),
          const SizedBox(height: 20),
          _TextInfo(title: 'Location', text: parking.address ?? 'N/A'),
          const SizedBox(height: 20),
          _CoordinatesRow(parking: parking),
          const SizedBox(height: 20),
          _TypologyContainer(parkingLot: parking),
          const SizedBox(height: 20),
          _IncidentsContainer(parking: parking),
          const SizedBox(height: 20),
          _OperationRow(parking: parking),
          const SizedBox(height: 20),
          _OccupationRow(parking: parking),
          const SizedBox(height: 30),
          _FeesRow(
            fees: parking.fees,
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _TextInfo extends StatelessWidget {
  const _TextInfo({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary),
        ),
        Text(
          text,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onBackground),
        ),
      ],
    );
  }
}

class _NameRow extends StatefulWidget {
  _NameRow({required this.parking});

  ParkingLot parking;

  @override
  _NameRowState createState() => _NameRowState();
}

class _NameRowState extends State<_NameRow> {
  void updateParkingData(ParkingLot parking) {
    setState(() {
      widget.parking = parking;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: _TextInfo(title: 'Name', text: widget.parking.name),
        ),
        const Spacer(),
        InkWell(
          onTap: () {
            if (widget.parking.favorite) {
              widget.parking.setFavorite = false;
              updateParkingData(widget.parking);
            } else {
              widget.parking.setFavorite = true;
              updateParkingData(widget.parking);
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.parking.favorite)
                Icon(
                  Icons.star_rounded,
                  size: 46,
                  color: Theme.of(context).colorScheme.primary,
                ),
              Icon(
                Icons.star_border_rounded,
                size: 52,
                color: widget.parking.favorite
                    ? const Color(0xFF323840)
                    : Colors.black26,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoordinatesRow extends StatelessWidget {
  const _CoordinatesRow({required this.parking});

  final ParkingLot parking;

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
      log(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _TextInfo(title: 'GPS Coordinates', text: parking.coordinates),
        AppButton(
          text: 'GPS',
          textSize: 16,
          icon: Icons.navigation_rounded,
          iconSize: 22,
          padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
          onPressed: () {
            openGeoNavigationOnCoordinates(
              getGeoNavigationUrl(parking),
              context,
            );
          },
        )
      ],
    );
  }
}

class _TypologyContainer extends StatelessWidget {
  const _TypologyContainer({
    required this.parkingLot,
  });

  final ParkingLot parkingLot;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TextInfo(title: 'Typology', text: parkingLot.typology),
        const Spacer(),
        Row(
          children: [
            Icon(
              Icons.ev_station_rounded,
              size: 30,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              parkingLot.chargingPlaces != null
                  ? parkingLot.chargingPlaces.toString()
                  : 'N/A',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Row(
          children: [
            Icon(
              Icons.accessible_rounded,
              size: 30,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              parkingLot.disabledPlaces != null
                  ? parkingLot.disabledPlaces.toString()
                  : 'N/A',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _IncidentsContainer extends StatelessWidget {
  const _IncidentsContainer({required this.parking});

  final ParkingLot parking;

  List<Widget> last24IncidentsContainer(
      BuildContext context, List<Incident> incidents) {
    final List<Widget> children = [
      const Text(
        'Last 24 hours',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 14),
    ];

    if (incidents.isEmpty) {
      children.add(Text(
        'No incidents',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ));
    } else {
      for (var incident in incidents) {
        children.add(_IncidentDialogContainer(incident: incident));
      }
    }
    return children;
  }

  List<Widget> lastWeekIncidentsContainer(
      BuildContext context, List<Incident> incidents) {
    final List<Widget> children = [
      const Text(
        'Last week',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 14),
    ];

    if (incidents.isEmpty) {
      children.add(Text(
        'No incidents',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ));
    } else {
      for (var incident in incidents) {
        children.add(_IncidentDialogContainer(incident: incident));
      }
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    final List<Incident> last24HIncidents = parking.getIncidentsLast24Hours();
    final List<Incident> lastWeekIncidents =
        parking.getIncidentsLastWeekExceptLast24Hours();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Incidents (last 24 hours)',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary),
          ),
          parking.incidents.isEmpty
              ? Row(children: [
                  Icon(
                    Icons.warning_rounded,
                    size: 32,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    last24HIncidents.length.toString(),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onBackground),
                  ),
                ])
              : Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      size: 32,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      last24HIncidents.length.toString(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                )
        ]),
        AppButton(
          text: 'Open',
          textSize: 16,
          icon: Icons.warning_rounded,
          iconSize: 20,
          color: last24HIncidents.isNotEmpty
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onBackground,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog.fullscreen(
                backgroundColor: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 64,
                    horizontal: 20,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.background,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Incidents',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Expanded(
                        flex: 100,
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.transparent,
                                Theme.of(context).colorScheme.background,
                                Theme.of(context).colorScheme.background,
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.025, 0.975, 1.0],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                ...last24IncidentsContainer(
                                    context, last24HIncidents),
                                const SizedBox(height: 14),
                                ...lastWeekIncidentsContainer(
                                    context, lastWeekIncidents),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppButton(
                            text: 'close',
                            textSize: 18,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OccupationRow extends StatelessWidget {
  const _OccupationRow({required this.parking});

  final ParkingLot parking;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Occupation',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary),
            ),
            Text(
              parking.getOccupationPercentage() != null
                  ? '${parking.getOccupationPercentage().toString()}%'
                  : 'Not available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: parking.getOccupationPercentage() != null
                    ? Theme.of(context).aquaPrimary
                    : Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            Text(
              parking.getAvailablePlaces() != null
                  ? parking.getAvailablePlaces().toString()
                  : 'N/A',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: parking.getAvailablePlaces() != null
                    ? Theme.of(context).aquaPrimary
                    : Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _OperationRow extends StatelessWidget {
  const _OperationRow({required this.parking});

  final ParkingLot parking;

  @override
  Widget build(BuildContext context) {
    bool inService = parking.currentlyInServiceStatus(DateTime.now());
    String weekdaysText = parking.getWeekdaysSchedule();
    String weekendsText = parking.getWeekendsSchedule();
    bool scheduleIsTheSame = weekdaysText == weekendsText;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Operating Hours',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                scheduleIsTheSame
                    ? Text(
                        weekdaysText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Weekdays: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: weekdaysText,
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      'Weekends${weekendsText == 'Not Applicable' ? ': ' : '\n'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: weekendsText,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ],
            )),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'In Service',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary),
            ),
            const SizedBox(height: 5),
            Icon(
              inService
                  ? Icons.check_circle_outline_rounded
                  : Icons.cancel_outlined,
              size: 36,
              color: inService
                  ? Theme.of(context).aquaPrimary
                  : Theme.of(context).colorScheme.onBackground,
            )
          ],
        )
      ],
    );
  }
}

class _FeesRow extends StatelessWidget {
  const _FeesRow({required this.fees});

  final Map<String, double?>? fees;

  @override
  Widget build(BuildContext context) {
    int aux = 0;
    List<Widget> feesWidgets = [];

    fees?.forEach((key, value) {
      feesWidgets.add(
        Container(
          color: aux % 2 == 0 ? const Color(0xFF31363D) : Colors.transparent,
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                key,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Text(
                value != 0 ? '${value.toString()}0€' : '-',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
      aux++;
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        fees == null || feesWidgets.isEmpty
            ? Text(
                fees != null ? 'No Fees Applicable' : 'Fees Not Available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              )
            : AppButton(
                text: 'Check Fees',
                textSize: 18,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                onPressed: () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AlertDialog(
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            title: Text(
                              'Parking Fees',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            content: SizedBox(
                              width:
                                  min(MediaQuery.of(context).size.width, 340),
                              child: Wrap(
                                children: [
                                  Column(children: feesWidgets),
                                ],
                              ),
                            ),
                            actions: const <Widget>[],
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                            surfaceTintColor:
                                Theme.of(context).colorScheme.background,
                            titlePadding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 20,
                            ),
                            contentPadding: const EdgeInsets.all(0),
                            insetPadding:
                                const EdgeInsets.symmetric(horizontal: 0),
                            buttonPadding: const EdgeInsets.all(0),
                            actionsPadding: const EdgeInsets.all(0),
                            scrollable: false,
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              size: 62,
                              color: Theme.of(context).colorScheme.primary,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: const Offset(0, 5),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}

class _IncidentDialogContainer extends StatelessWidget {
  const _IncidentDialogContainer({required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    String severityText;
    Color severityColor;
    String timestampFormat =
        incident.timestamp.toString().substring(0, 16).split(' ').join(' at ');
    bool hasImage = incident.image != null;

    switch (incident.severity) {
      case IncidentSeverity.veryLow:
        severityText = 'Very low';
        severityColor = Colors.green.shade400;
        break;
      case IncidentSeverity.low:
        severityText = 'Low';
        severityColor = Colors.lightGreen.shade400;
        break;
      case IncidentSeverity.medium:
        severityText = 'Medium';
        severityColor = Colors.yellow.shade400;
        break;
      case IncidentSeverity.high:
        severityText = 'High';
        severityColor = Colors.orange.shade400;
        break;
      case IncidentSeverity.veryHigh:
        severityText = 'Very high';
        severityColor = Colors.red.shade400;
        break;
    }

    return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).containerBackground,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reported At',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      Text(
                        timestampFormat,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Severity',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      Text(
                        severityText,
                        style: TextStyle(
                          fontSize: 15,
                          color: severityColor,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              Text(
                incident.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              if (hasImage) const SizedBox(height: 12),
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset('assets/images/img_placeholder.png'),
                ),
            ],
          ),
        ));
  }
}
