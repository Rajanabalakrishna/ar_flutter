import 'package:flutter/material.dart';

import '../../models/car_model.dart';


class CarSelectScreen extends StatefulWidget {
  const CarSelectScreen({super.key});
  @override
  State<CarSelectScreen> createState() => _CarSelectScreenState();
}

class _CarSelectScreenState extends State<CarSelectScreen> {
  String _selectedId = 'red_racer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Choose Your Car 🏎️',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 1.1, crossAxisSpacing: 12, mainAxisSpacing: 12),
                itemCount: availableCars.length,
                itemBuilder: (_, i) {
                  final car = availableCars[i];
                  final isSelected = car.id == _selectedId;
                  return GestureDetector(
                    onTap: car.isUnlocked
                        ? () => setState(() => _selectedId = car.id)
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? car.color.withOpacity(0.2)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isSelected ? car.color : Colors.white.withOpacity(0.1),
                            width: isSelected ? 2.5 : 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(car.emoji, style: const TextStyle(fontSize: 48)),
                          const SizedBox(height: 8),
                          Text(car.name,
                              style: TextStyle(
                                  color: car.isUnlocked ? Colors.white : Colors.white38,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          if (!car.isUnlocked)
                            const Text('🔒 Locked',
                                style: TextStyle(color: Colors.white38, fontSize: 12))
                          else
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const Text('⚡ Speed: ',
                                  style: TextStyle(color: Colors.white54, fontSize: 12)),
                              Text('${(car.speed * 100).toInt()}',
                                  style: TextStyle(
                                      color: car.color,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ]),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/game',
                      arguments: {'carId': _selectedId});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                child: const Text('START GAME 🚀',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}