import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parking_app/domain/park.dart';
import 'package:parking_app/main.dart';
import 'package:parking_app/view_models/parks_map_view_model.dart';
import 'package:parking_app/widgets/map_markers.dart';
import 'package:provider/provider.dart';

import '../data/global_state.dart';

class ParksMapPage extends StatefulWidget {
  const ParksMapPage({super.key, required this.setPage});

  final void Function(AppPage page) setPage;

  @override
  State<ParksMapPage> createState() => _ParksMapPageState();
}

class _ParksMapPageState extends State<ParksMapPage> {
  late final GlobalAppState _globalAppState;
  bool _appStateInitialized = false;
  late List<ParkingLot> _parkingLots;
  final List<GlobalKey> _markerKeys = [];
  final Set<Marker> _markers = {};
  String _mapThemeString = '';
  bool _showParkingLotInfoPopup = false;
  GoogleMapController? mapController;

  @override
  void initState() {
    rootBundle.loadString('assets/themes/map_theme.json').then((data) {
      _mapThemeString = data;
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_appStateInitialized) {
      _globalAppState = Provider.of<GlobalAppState>(context, listen: true);
      _parkingLots = _globalAppState.parkingLots;
      _appStateInitialized = true;
    }
  }

  void setFocusedParkingLot(ParkingLot parkingLot) {
    _globalAppState.focusedParkingLot = parkingLot;
  }

  Widget parkingLotMarkerWidgets(List<ParkingLot> parkingLots) {
    return Stack(
        children: parkingLots.map((parkingLot) {
      GlobalKey markerKey = GlobalKey();
      _markerKeys.add(markerKey);
      return RepaintBoundary(
        key: markerKey,
        child: ParkingLotMapMarker(
          parkingLot: parkingLot,
        ),
      );
    }).toList());
  }

  void transformMarkerWidgetsInMapMarkers(List<GlobalKey> keys) {
    for (var i = 0; i < _parkingLots.length; i++) {
      ParkingLot parkingLot = _parkingLots[i];

      getCustomIcon(keys[i]).then((testIcon) {
        setState(() {
          _markers.add(Marker(
            markerId: MarkerId(_parkingLots[i].id),
            icon: testIcon,
            position:
                LatLng(parkingLot.getLatitude(), parkingLot.getLongitude()),
            onTap: () {
              setFocusedParkingLot(parkingLot);
              setState(() {
                _showParkingLotInfoPopup = true;
              });
              mapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(
                      parkingLot.getLatitude(),
                      parkingLot.getLongitude(),
                    ),
                    zoom: 15,
                  ),
                ),
              );
              // setCoordinates(lat, long)
            },
          ));
        });
      });
    }
  }

  Widget mapButtons() {
    return Column(
      children: [
        if (_globalAppState.locationIsEnabled())
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).menuBackground,
                borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              onPressed: () {
                mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(
                        GlobalAppState.currentLocationLat!,
                        GlobalAppState.currentLocationLon!,
                      ),
                      zoom: 15,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.my_location, size: 30),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).menuBackground,
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              IconButton(
                onPressed: () {
                  mapController?.animateCamera(CameraUpdate.zoomIn());
                },
                icon: const Icon(Icons.add_rounded, size: 32),
                color: Theme.of(context).colorScheme.primary,
              ),
              IconButton(
                onPressed: () {
                  mapController?.animateCamera(CameraUpdate.zoomOut());
                },
                icon: const Icon(Icons.remove_rounded, size: 32),
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Transform.translate(
          offset: const Offset(-200, -200),
          child: parkingLotMarkerWidgets(_parkingLots),
        ),
        GoogleMap(
          style: _mapThemeString,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          tiltGesturesEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            setState(() {
              mapController = controller;
            });
            transformMarkerWidgetsInMapMarkers(_markerKeys);
          },
          onTap: (_) {
            setState(() {
              _showParkingLotInfoPopup = false;
            });
          },
          initialCameraPosition: const CameraPosition(
            target: LatLng(38.722249611290955, -9.139338928981338),
            zoom: 13,
          ),
          markers: _markers,
        ),
        if (_showParkingLotInfoPopup)
          InfoContainer(
            parking: _globalAppState.focusedParkingLot,
            setPage: widget.setPage,
          ),
        Positioned(
          bottom: 80,
          right: 14,
          child: mapButtons(),
        ),
      ],
    );
  }
}

class InfoContainer extends StatefulWidget {
  final ParkingLot? parking;
  final void Function(AppPage page) setPage;

  const InfoContainer({
    super.key,
    required this.parking,
    required this.setPage,
  });

  @override
  State<InfoContainer> createState() => _InfoContainerState();
}

class _InfoContainerState extends State<InfoContainer> {
  late final GlobalAppState _globalAppState;
  bool _appStateInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_appStateInitialized) {
      _globalAppState = Provider.of<GlobalAppState>(context, listen: true);
      _appStateInitialized = true;
    }
  }

  void navigateToDetailsPage(ParkingLot parkingLot) {
    _globalAppState.focusedParkingLot = parkingLot;
    widget.setPage(AppPage.details);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ParkMapViewModel(),
      child: Consumer<ParkMapViewModel>(
        builder: (context, model, child) => Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 350,
            ),
            margin: const EdgeInsets.only(top: 30),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 10,
                  blurRadius: 18,
                  offset: const Offset(0, 5), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: _TextWidget(
                        widget.parking!.name,
                        20,
                        Theme.of(context).listItemPrimary,
                        FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_sharp,
                          size: 24,
                          color: Theme.of(context).listItemSecondary,
                        ),
                        const SizedBox(width: 2),
                        _TextWidget(
                          widget.parking!.getDistanceToParkingLotInString() ??
                              'N/A',
                          20,
                          Theme.of(context).listItemSecondary,
                          FontWeight.w500,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.parking!
                                  .currentlyInServiceStatus(DateTime.now())
                              ? Icons.check_circle_outline_rounded
                              : Icons.cancel_outlined,
                          size: 22,
                          color: Theme.of(context).aquaPrimary,
                        ),
                        const SizedBox(width: 5),
                        _TextWidget(
                          widget.parking!
                                  .currentlyInServiceStatus(DateTime.now())
                              ? 'In service'
                              : 'Out of service',
                          18,
                          Theme.of(context).aquaPrimary,
                          FontWeight.w500,
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car_rounded,
                          size: 22,
                          color: Theme.of(context).aquaPrimary,
                        ),
                        const SizedBox(width: 4),
                        _TextWidget(
                          widget.parking!.getOccupationInText(),
                          18,
                          Theme.of(context).aquaPrimary,
                          FontWeight.w500,
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        model.openGeoNavigationOnCoordinates(
                          model.getGeoNavigationUrl(widget.parking!),
                          context,
                        );
                      },
                      label: _TextWidget(
                        'GPS',
                        20,
                        Theme.of(context).colorScheme.primary,
                        FontWeight.w500,
                      ),
                      icon: Icon(
                        Icons.navigation_rounded,
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 16,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        navigateToDetailsPage(widget.parking!);
                      },
                      label: _TextWidget(
                        'Info',
                        20,
                        Theme.of(context).colorScheme.primary,
                        FontWeight.w500,
                      ),
                      icon: Icon(
                        Icons.info_rounded,
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TextWidget extends StatelessWidget {
  const _TextWidget(
    this.text,
    this.size,
    this.color,
    this.fontWeight,
  );

  final String text;
  final double size;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: fontWeight,
      ),
      softWrap: true,
    );
  }
}
