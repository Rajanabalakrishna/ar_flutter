import 'package:flutter/foundation.dart';

enum GamePhase { scanning, placing, playing, paused, finished }

class GameState extends ChangeNotifier {
  GamePhase _phase = GamePhase.scanning;
  int _score = 0;
  int _coinsCollected = 0;
  int _timeLeft = 60;
  bool _isPlaneDetected = false;
  bool _isCarPlaced = false;
  double _carSpeed = 1.0;
  String _selectedCarId = 'red_racer';

  GamePhase get phase => _phase;
  int get score => _score;
  int get coinsCollected => _coinsCollected;
  int get timeLeft => _timeLeft;
  bool get isPlaneDetected => _isPlaneDetected;
  bool get isCarPlaced => _isCarPlaced;
  double get carSpeed => _carSpeed;
  String get selectedCarId => _selectedCarId;

  void setPhase(GamePhase phase) {
    _phase = phase;
    notifyListeners();
  }

  void setPlaneDetected(bool detected) {
    if (_isPlaneDetected != detected) {
      _isPlaneDetected = detected;
      if (detected && _phase == GamePhase.scanning) {
        _phase = GamePhase.placing;
      }
      notifyListeners();
    }
  }

  void setCarPlaced() {
    _isCarPlaced = true;
    _phase = GamePhase.playing;
    notifyListeners();
  }

  void addCoin() {
    _coinsCollected++;
    _score += 10;
    notifyListeners();
  }

  void decrementTime() {
    if (_timeLeft > 0) {
      _timeLeft--;
      if (_timeLeft == 0) _phase = GamePhase.finished;
      notifyListeners();
    }
  }

  void selectCar(String carId) {
    _selectedCarId = carId;
    notifyListeners();
  }

  void reset() {
    _phase = GamePhase.scanning;
    _score = 0;
    _coinsCollected = 0;
    _timeLeft = 60;
    _isPlaneDetected = false;
    _isCarPlaced = false;
    notifyListeners();
  }
}