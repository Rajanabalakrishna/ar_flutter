import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo area
              const Text('🏎️', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              const Text('AR CAR RACE',
                  style: TextStyle(
                      color: Color(0xFF00BCD4),
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4)),
              const SizedBox(height: 8),
              Text('Drive your car on the real store floor!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6), fontSize: 15)),
              const SizedBox(height: 60),

              // PLAY button
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/car_select'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('🎮  PLAY NOW',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),

              // Instructions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('How to Play 👇',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _step('1', 'Point camera at the store floor'),
                    _step('2', 'Wait for blue dots to appear (floor detected!)'),
                    _step('3', 'Tap on floor to place your car'),
                    _step('4', 'Use joystick to drive & collect coins! 🪙'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step(String num, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
              color: const Color(0xFF00BCD4),
              borderRadius: BorderRadius.circular(12)),
          child: Center(
              child: Text(num,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 14))),
      ]),
    );
  }
}