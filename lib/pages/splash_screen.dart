import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:parking_app/data/database.dart';
import 'package:parking_app/data/global_state.dart';
import 'package:parking_app/main.dart';
import 'package:parking_app/pages/main_layout.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _globalAppStateInitialized = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(const Duration(seconds: 2), () {
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (ctx) => const MainScaffoldLayout()),
          );
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_globalAppStateInitialized) {
      _initializeGlobalAppState(context);
      _globalAppStateInitialized = true;
    }
  }

  Future<void> _initializeGlobalAppState(BuildContext context) async {
    final db = context.read<LocalDatabase>();
    await db.init();
    context.read<GlobalAppState>().loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: Theme.of(context).menuBackground,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints:
                      const BoxConstraints(maxWidth: 225, maxHeight: 225),
                  child: Image.asset('assets/logo/splash-logo.png'),
                ),
                const SizedBox(
                  height: 120,
                ),
                SpinKitFadingFour(color: Theme.of(context).colorScheme.primary)
              ],
            )));
  }
}
