import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parking_app/pages/dashboard.dart';
import 'package:parking_app/pages/details.dart';
import 'package:parking_app/pages/favorites.dart';
import 'package:parking_app/pages/incident_report.dart';
import 'package:parking_app/pages/parks_list.dart';
import 'package:parking_app/pages/parks_map.dart';
import 'package:parking_app/widgets/app_header.dart';
import 'package:parking_app/widgets/bottom_navbar.dart';
import 'package:parking_app/widgets/navbar_floating_button.dart';

import '../main.dart';

class MainScaffoldLayout extends StatefulWidget {
  const MainScaffoldLayout({super.key});

  @override
  _MainScaffoldLayoutState createState() => _MainScaffoldLayoutState();
}

class _MainScaffoldLayoutState extends State<MainScaffoldLayout> {
  AppPage _currentPage = AppPage.dashboard;
  AppPage _previousPage = AppPage.dashboard;
  late double _layoutHPadding;

  @override
  void initState() {
    _layoutHPadding = getGlobalPageHorizontalPaddingByPage(_currentPage);
    super.initState();
  }

  Widget _loadPageWidget(AppPage page) {
    switch (page) {
      case AppPage.dashboard:
        return DashboardPage(setPage: changePage);
      case AppPage.parksList:
        return ParksListPage(setPage: changePage);
      case AppPage.parksMap:
        return ParksMapPage(setPage: changePage);
      case AppPage.favorites:
        return FavoritesPage(setPage: changePage);
      case AppPage.incidentReport:
        return IncidentReportPage(setPage: changePage);
      case AppPage.details:
        return const DetailsPage();
    }
  }

  void changePage(AppPage page) {
    setState(() {
      _previousPage = _currentPage;
      _currentPage = page;
      // Set default page horizontal padding
      _layoutHPadding = getGlobalPageHorizontalPaddingByPage(page);
    });
  }

  void handleGoBackButton() {
    switch (_currentPage) {
      case AppPage.dashboard:
        SystemNavigator.pop();
        break;
      case AppPage.details:
        changePage(_previousPage);
        break;
      default:
        changePage(AppPage.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool value) {
        handleGoBackButton();
      },
      child: Scaffold(
        appBar: AppHeader(appPage: _currentPage),
        body: Container(
          padding: EdgeInsets.symmetric(
            vertical: 0,
            horizontal: _layoutHPadding,
          ),
          child: _loadPageWidget(_currentPage),
        ),
        extendBody: true,
        floatingActionButton: AnimatedContainer(
          width: _currentPage == AppPage.dashboard ? 68 : 58,
          height: _currentPage == AppPage.dashboard ? 68 : 58,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCirc,
          child: NavbarFloatingButton(
            currentPage: _currentPage,
            setPage: changePage,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AppNavbar(
          currentPage: _currentPage,
          setPage: changePage,
        ),
      ),
    );
  }
}

double getGlobalPageHorizontalPaddingByPage(AppPage page) {
  switch (page) {
    case AppPage.parksMap:
      return 0;
    case AppPage.parksList || AppPage.favorites || AppPage.dashboard:
      return 20;
    default:
      return 30;
  }
}
