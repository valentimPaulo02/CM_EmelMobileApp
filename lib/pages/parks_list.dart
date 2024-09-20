import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:parking_app/data/global_state.dart';
import 'package:parking_app/domain/park.dart';
import 'package:parking_app/domain/sorting.dart';
import 'package:parking_app/main.dart';
import 'package:parking_app/view_models/parks_list_view_model.dart';
import 'package:parking_app/widgets/parking_containers.dart';
import 'package:provider/provider.dart';

class ParksListPage extends StatefulWidget {
  const ParksListPage({super.key, required this.setPage});

  final void Function(AppPage page) setPage;

  @override
  State<ParksListPage> createState() => _ParksListPageState();
}

class _ParksListPageState extends State<ParksListPage> {
  late final GlobalAppState _globalAppState;
  bool _appStateInitialized = false;

  @override
  void didChangeDependencies() {
    if (!_appStateInitialized) {
      _globalAppState = Provider.of<GlobalAppState>(context, listen: true);
      _appStateInitialized = true;
    }
    super.didChangeDependencies();
  }

  void navigateToDetailsPage(ParkingLot parkingLot) {
    _globalAppState.focusedParkingLot = parkingLot;
    widget.setPage(AppPage.details);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ParkListViewModel(_globalAppState),
      child: Consumer<ParkListViewModel>(
        builder: (context, model, child) => Container(
          alignment: Alignment.center,
          color: Theme.of(context).colorScheme.background,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        // we add 2 to itemCount to account for the sized boxes
                        itemCount: model.parkingLots.length + 2,
                        itemBuilder: (context, index) {
                          // top padding
                          if (index == 0) {
                            return const SizedBox(height: 20);
                          }

                          // bottom padding
                          if (index == model.parkingLots.length + 1) {
                            return const SizedBox(height: 80);
                          }

                          return ParkingLotListItem(
                              parkingLot: model.parkingLots[index - 1],
                              navigateToDetails: navigateToDetailsPage);
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).menuBackground,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black45,
                                spreadRadius: 0,
                                blurRadius: 5,
                                offset: Offset(0, 5),
                              ),
                            ]),
                        margin: const EdgeInsets.symmetric(
                          vertical: 80,
                          horizontal: 0,
                        ),
                        padding: const EdgeInsets.all(0),
                        child: IconButton(
                          icon: Icon(
                            Icons.filter_list_rounded,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return _ParkingFilterDialog(
                                selectedOption:
                                    _globalAppState.currentListSortingMethod,
                                onChanged:
                                    model.updateSortingMethodAndSortParkingLots,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParkingFilterDialog extends StatefulWidget {
  const _ParkingFilterDialog({
    required this.selectedOption,
    required this.onChanged,
  });

  final SortingMethod selectedOption;
  final void Function(SortingMethod) onChanged;

  @override
  State<_ParkingFilterDialog> createState() => _ParkingFilterDialogState();
}

class _ParkingFilterDialogState extends State<_ParkingFilterDialog> {
  late SortingMethod currentSelection;

  final Map<SortingMethod, String> filterItems = {
    SortingMethod.alphabeticalAscendant: 'Alphabetical (Ascending)',
    SortingMethod.alphabeticalDescendant: 'Alphabetical (Descending)',
    SortingMethod.distanceAscendant: 'Distance (Ascending)',
    SortingMethod.distanceDescendant: 'Distance (Descending)',
    SortingMethod.occupationAscending: 'Occupation (Ascending)'
  };

  @override
  void initState() {
    currentSelection = widget.selectedOption;
    super.initState();
  }

  void updateLocalSelection(SortingMethod sort) {
    setState(() {
      currentSelection = sort;
    });
  }

  @override
  Widget build(BuildContext context) {
    double spaceBetweenItems = 20;

    return SimpleDialog(
      contentPadding: const EdgeInsets.all(14),
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).menuBackground.withOpacity(0.95),
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
            child: Column(children: [
              Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              ...filterItems.keys.map((SortingMethod key) {
                return Container(
                  margin: EdgeInsets.only(
                    top: spaceBetweenItems,
                  ),
                  child: TextButton(
                    onPressed: () {
                      updateLocalSelection(key);
                      widget.onChanged(key);
                      Navigator.of(context).pop(); // closes dialog
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: currentSelection == key
                          ? Theme.of(context).colorScheme.primary
                          : const Color(0xFF3b3f45),
                      padding: const EdgeInsets.all(10),
                      shadowColor: Colors.black38,
                    ),
                    child: Row(
                      children: [
                        const Spacer(),
                        Text(
                          filterItems[key]!,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: currentSelection == key
                                ? FontWeight.w500
                                : FontWeight.w400,
                            color: currentSelection == key
                                ? Theme.of(context).menuBackground
                                : Theme.of(context).colorScheme.onBackground,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                );
              }),
            ]),
          ),
        ),
      ],
    );
  }
}
