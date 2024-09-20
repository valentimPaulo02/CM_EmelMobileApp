import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:parking_app/data/global_state.dart';
import 'package:parking_app/domain/park.dart';
import 'package:parking_app/main.dart';
import 'package:parking_app/view_models/dashboard_view_model.dart';
import 'package:parking_app/widgets/button.dart';
import 'package:parking_app/widgets/parking_containers.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.setPage,
  });

  final void Function(AppPage page) setPage;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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

  void navigateToDetails(ParkingLot parkingLot) {
    _globalAppState.focusedParkingLot = parkingLot;
    widget.setPage(AppPage.details);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(_globalAppState),
      child: Consumer<DashboardViewModel>(
        builder: (context, model, child) => Container(
          color: Theme.of(context).colorScheme.background,
          alignment: Alignment.center,
          child: model.nearestFreeParkingLots.length == 4
              ? Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            Icon(
                              Icons.my_location_rounded,
                              size: 22,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Near Me',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ParkingDashboardContainer(
                              parkingLot: model.nearestFreeParkingLots[0],
                              navigateToDetails: navigateToDetails,
                            ),
                            ParkingDashboardContainer(
                              parkingLot: model.nearestFreeParkingLots[1],
                              navigateToDetails: navigateToDetails,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ParkingDashboardContainer(
                              parkingLot: model.nearestFreeParkingLots[2],
                              navigateToDetails: navigateToDetails,
                            ),
                            ParkingDashboardContainer(
                              parkingLot: model.nearestFreeParkingLots[3],
                              navigateToDetails: navigateToDetails,
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            Icon(
                              Icons.star_rounded,
                              size: 28,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Favorites',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (model.nearestFavoriteParkingLots.isEmpty)
                              Flexible(
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      top: 40, bottom: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'Parking lots marked as ',
                                        ),
                                        TextSpan(
                                          text: 'Favorite',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.italic,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                        const TextSpan(
                                            text: ' will be displayed here'),
                                      ],
                                    ),
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            if (model.nearestFavoriteParkingLots.isNotEmpty)
                              ParkingDashboardContainer(
                                parkingLot: model.nearestFavoriteParkingLots[0],
                                navigateToDetails: navigateToDetails,
                              ),
                            if (model.nearestFavoriteParkingLots.length == 1)
                              Flexible(child: Container()),
                            if (model.nearestFavoriteParkingLots.length > 1)
                              ParkingDashboardContainer(
                                parkingLot: model.nearestFavoriteParkingLots[1],
                                navigateToDetails: navigateToDetails,
                              ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppButton(
                              text: 'Search',
                              icon: Icons.search_rounded,
                              color: Theme.of(context).colorScheme.secondary,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 40,
                              ),
                              onPressed: () => showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return _ParkingLotSearchDialog(
                                      parkingLots: [
                                        ..._globalAppState.parkingLots
                                      ],
                                      navigateToDetails: navigateToDetails,
                                    );
                                  }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                )
              : SpinKitRipple(
                  size: 75,
                  color: Theme.of(context).colorScheme.primary,
                ),
        ),
      ),
    );
  }
}

class _ParkingLotSearchDialog extends StatefulWidget {
  const _ParkingLotSearchDialog({
    required this.parkingLots,
    required this.navigateToDetails,
  });

  final List<ParkingLot> parkingLots;
  final void Function(ParkingLot parkingLot) navigateToDetails;

  @override
  State<_ParkingLotSearchDialog> createState() =>
      _ParkingLotSearchDialogState();
}

class _ParkingLotSearchDialogState extends State<_ParkingLotSearchDialog> {
  String _searchQuery = '';
  List<Widget> _results = [];

  @override
  void initState() {
    _updateResults(widget.parkingLots);
    super.initState();
  }

  void _updateResults(List<ParkingLot> parkingLots) {
    _results = [];
    if (_searchQuery.isEmpty) {
      for (var parking in parkingLots) {
        _results.add(ParkingLotSearchItem(
          parkingLot: parking,
          navigateToDetails: widget.navigateToDetails,
        ));
        _results.add(const SizedBox(height: 12));
      }
    } else {
      for (var parking in parkingLots) {
        if (parking.name.toLowerCase().contains(_searchQuery)) {
          _results.add(ParkingLotSearchItem(
            parkingLot: parking,
            navigateToDetails: widget.navigateToDetails,
          ));
          _results.add(const SizedBox(height: 12));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 450),
                padding: const EdgeInsets.symmetric(horizontal: 25),
                margin: const EdgeInsets.only(top: 20),
                child: TextField(
                  autofocus: true,
                  showCursor: true,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  maxLength: 50,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .background
                        .withOpacity(0.2),
                    labelText: 'Search by name',
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    hintText: 'Campo Grande',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    border: const UnderlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _updateResults(widget.parkingLots);
                    });
                  },
                ),
              ),
              const SizedBox(height: 25),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: _results,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton(
                    text: 'close',
                    textSize: 18,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
