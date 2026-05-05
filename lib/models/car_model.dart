import 'package:flutter/material.dart';

class CarModel {
  final String id;
  final String name;
  final String emoji;
  final String glbAssetPath;
  final Color color;
  final double speed;
  final bool isUnlocked;

  const CarModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.glbAssetPath,
    required this.color,
    required this.speed,
    this.isUnlocked = false,
  });
}

const List<CarModel> availableCars = [
  CarModel(
    id: 'red_racer',
    name: 'Red Racer',
    emoji: '🏎️',
    glbAssetPath: 'assets/models/red_car.glb',
    color: Color(0xFFE53935),
    speed: 1.0,
    isUnlocked: true,
  ),
  CarModel(
    id: 'blue_rocket',
    name: 'Blue Rocket',
    emoji: '🚀',
    glbAssetPath: 'assets/models/blue_car.glb',
    color: Color(0xFF1E88E5),
    speed: 1.3,
  ),
  CarModel(
    id: 'green_monster',
    name: 'Green Monster',
    emoji: '🚙',
    glbAssetPath: 'assets/models/green_car.glb',
    color: Color(0xFF43A047),
    speed: 0.8,
  ),
  CarModel(
    id: 'gold_king',
    name: 'Gold King',
    emoji: '👑',
    glbAssetPath: 'assets/models/gold_car.glb',
    color: Color(0xFFFFB300),
    speed: 1.5,
  ),
];