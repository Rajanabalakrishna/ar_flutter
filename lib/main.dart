import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/screens/ar_game_screen.dart';
import 'game/screens/car_select_screen.dart';
import 'game/screens/home_screen.dart';
import 'game/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const ARCarGameApp());
}

class ARCarGameApp extends StatelessWidget {
  const ARCarGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Car Race',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00BCD4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home':   (context) => const HomeScreen(),
        '/car_select': (context) => const CarSelectScreen(),
        '/game':   (context) => const ARGameScreen(),
      },
    );
  }
}