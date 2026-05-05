import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _carController;
  late AnimationController _fadeController;
  late Animation<double> _carAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _carController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _carAnim = Tween<double>(begin: -300, end: 0).animate(
        CurvedAnimation(parent: _carController, curve: Curves.elasticOut));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _carController.forward();
    Future.delayed(const Duration(milliseconds: 500), _fadeController.forward);
    Timer(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _carController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _carAnim,
              builder: (_, __) => Transform.translate(
                offset: Offset(_carAnim.value, 0),
                child: const Text('🏎️', style: TextStyle(fontSize: 90)),
              ),
            ),
            const SizedBox(height: 28),
            FadeTransition(
              opacity: _fadeAnim,
              child: Column(children: [
                const Text('AR CAR RACE',
                    style: TextStyle(
                        color: Color(0xFF00BCD4),
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 5)),
                const SizedBox(height: 10),
                Text('Drive on real store floors!',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 16)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}