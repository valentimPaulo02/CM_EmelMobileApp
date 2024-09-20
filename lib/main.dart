import 'package:flutter/material.dart';
import 'package:parking_app/data/database.dart';
import 'package:parking_app/data/global_state.dart';
import 'package:parking_app/pages/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<GlobalAppState>(create: (_) => GlobalAppState()),
      Provider<LocalDatabase>(create: (_) => LocalDatabase()),
    ],
    child: const ParkingApp(),
  ));
}

enum AppPage {
  dashboard,
  parksList,
  parksMap,
  favorites,
  incidentReport,
  details
}

class ParkingApp extends StatelessWidget {
  const ParkingApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking App',
      theme: ThemeData(
        fontFamily: 'Ubuntu',
        colorScheme: ColorScheme(
          background: const Color(0xFF393e47),
          primary: const Color(0xFF5F6BBF),
          secondary: const Color(0xFFD0D6E2),
          brightness: Brightness.dark,
          onPrimary: const Color(0xFFD0D6E2),
          onSecondary: const Color(0xFF31363D),
          error: const Color(0xFFBF6262),
          onError: Colors.red.shade800,
          onBackground: const Color(0xFF828498),
          surface: const Color(0xFF31363D),
          onSurface: const Color(0xFFD0D6E2),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// Extends theme colors
extension ExtraThemeData on ThemeData {
  Color get aquaPrimary => const Color(0xFF70EBE6);
  //Color get menuBackground => const Color(0xFF26292D);
  //Color get menuBackground => const Color(0xFF101113);
  //Color get menuBackground => const Color(0xFF171a1c);
  Color get menuBackground => const Color(0xFF1a1f23); // Current
  Color get menuForeground => const Color(0xFF797a86);
  Color get containerBackground => const Color(0xFF2d3239);
  Color get listItemBackground1 => const Color(0xFF252930);
  Color get listItemBackground2 => const Color(0xFF292F39);
  Color get listItemPrimary => const Color(0xFFD3DBE9);
  //Color get listItemSecondary => const Color(0xFF575F6D); (previous)
  Color get listItemSecondary => const Color(0xFF8E96A5);
}
