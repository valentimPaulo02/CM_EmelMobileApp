import 'package:flutter/material.dart';
import 'package:parking_app/data/global_state.dart';
import 'package:parking_app/domain/park.dart';
import 'package:parking_app/main.dart';
import 'package:parking_app/view_models/favorites_view_model.dart';
import 'package:parking_app/widgets/parking_containers.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key, required this.setPage});

  final void Function(AppPage page) setPage;

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late GlobalAppState _globalAppState;
  bool _appStateInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_appStateInitialized) {
      _globalAppState = Provider.of<GlobalAppState>(context, listen: true);
      _appStateInitialized = false;
    }
  }

  void navigateToDetails(ParkingLot parkingLot) {
    _globalAppState.focusedParkingLot = parkingLot;
    widget.setPage(AppPage.details);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FavoritesViewModel(_globalAppState),
      child: Consumer<FavoritesViewModel>(
        builder: (ctx, model, child) => Container(
          color: Theme.of(context).colorScheme.background,
          alignment: Alignment.topCenter,
          padding: EdgeInsets.symmetric(
              horizontal: model.favorites.isEmpty ? 30 : 0),
          child: model.favorites.isEmpty
              ? _noFavoritesTextWidget(context)
              : Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  alignment: Alignment.topCenter,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    // this item count accounts for top and bottom sized boxes
                    itemCount: model.favorites.length + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const SizedBox(height: 20);
                      }

                      if (index == model.favorites.length + 1) {
                        return const SizedBox(height: 80);
                      }

                      return ParkingLotListItem(
                        parkingLot: model.favorites[index - 1],
                        navigateToDetails: navigateToDetails,
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}

Column _noFavoritesTextWidget(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          children: [
            const TextSpan(
              text: 'Parking lots marked as ',
            ),
            TextSpan(
              text: 'Favorite',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const TextSpan(text: ' will be displayed here'),
          ],
        ),
        softWrap: true,
        textAlign: TextAlign.center,
      ),
      RichText(
        textAlign: TextAlign.center,
        softWrap: true,
        text: TextSpan(
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          children: const [
            TextSpan(
              text: 'To mark a parking lot as ',
            ),
            TextSpan(
              text: 'Favorite',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
              ),
            ),
            TextSpan(
              text:
                  ', go to its details page and toggle the star icon on the top-right corner.',
            ),
          ],
        ),
      )
    ],
  );
}
