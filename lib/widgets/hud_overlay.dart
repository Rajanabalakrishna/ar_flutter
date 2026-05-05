import 'package:flutter/material.dart';

class HudOverlay extends StatelessWidget {
  final int score;
  final int timeLeft;
  final int coins;

  const HudOverlay({
    super.key,
    required this.score,
    required this.timeLeft,
    required this.coins,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Score
              _hudChip('🏆 $score', const Color(0xFF00BCD4)),
              // Timer
              _hudChip(
                '⏱ $timeLeft',
                timeLeft > 15 ? Colors.white : const Color(0xFFEF5350),
              ),
              // Coins
              _hudChip('🪙 $coins', const Color(0xFFFFB300)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hudChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.7)),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}