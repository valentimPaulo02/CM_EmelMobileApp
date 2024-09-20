import 'package:flutter/material.dart';
import 'package:parking_app/data/global_state.dart';
import 'package:parking_app/main.dart';
import 'package:provider/provider.dart';

class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.appPage,
  });

  final AppPage appPage;

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class _AppHeaderState extends State<AppHeader> {
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

  String formatDatetime(DateTime dateTime) {
    String formattedHour = dateTime.hour.toString().padLeft(2, '0');
    String formattedMinute = dateTime.minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute';
  }

  @override
  Widget build(BuildContext context) {
    String pageTitle;

    switch (widget.appPage) {
      case AppPage.dashboard:
        pageTitle = 'Dashboard';
      case AppPage.parksList:
        pageTitle = 'Parking Lots | List';
      case AppPage.parksMap:
        pageTitle = 'Parking Lots | Map';
      case AppPage.favorites:
        pageTitle = 'Favorites';
      case AppPage.incidentReport:
        pageTitle = 'Incident Report';
      case AppPage.details:
        pageTitle = 'Details';
    }
    return AppBar(
      shadowColor: Colors.black,
      elevation: 8,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),
      backgroundColor: Theme.of(context).menuBackground,
      surfaceTintColor: Theme.of(context).menuBackground,
      title: Row(
        children: [
          Image.asset(
            'assets/logo/main-logo.png',
            width: 30,
            height: 30,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(
            width: 20,
          ),
          Text(
            pageTitle,
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Last updated',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFCFD0D4),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatDatetime(_globalAppState.lastUpdatedParkingInfo),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFCFD0D4),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
