import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_engine/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_engine/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_engine/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin_engine/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_engine/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_engine/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin_engine/models/ar_node.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'dart:async';
import 'dart:math';

import '../game_state.dart';


class ARGameScreen extends StatefulWidget {
  const ARGameScreen({super.key});
  @override
  State<ARGameScreen> createState() => _ARGameScreenState();
}

class _ARGameScreenState extends State<ARGameScreen> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARAnchorManager arAnchorManager;

  ARNode? _carNode;
  ARPlaneAnchor? _carAnchor;
  final List<ARNode> _coinNodes = [];
  final List<ARAnchor> _coinAnchors = [];

  final GameState _gameState = GameState();
  Timer? _gameTimer;
  Timer? _coinSpawnTimer;

  double _joystickX = 0;
  double _joystickY = 0;
  double _carRotation = 0;
  Timer? _moveTimer;
  vm.Vector3 _carPosition = vm.Vector3(0, 0, 0);
  String _selectedCarId = 'red_racer';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null) _selectedCarId = args['carId'] ?? 'red_racer';
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _coinSpawnTimer?.cancel();
    _moveTimer?.cancel();
    arSessionManager.dispose();
    super.dispose();
  }

  void _onARViewCreated(
      ARSessionManager sessionMgr,
      ARObjectManager objectMgr,
      ARAnchorManager anchorMgr,
      ARLocationManager locationMgr,
      ) {
    arSessionManager = sessionMgr;
    arObjectManager = objectMgr;
    arAnchorManager = anchorMgr;

    arSessionManager.onInitialize(
      showFeaturePoints: true,
      showPlanes: true,
      handleTaps: true,
    );
    arObjectManager.onInitialize();
    arSessionManager.onPlaneOrPointTap = _onPlaneTapped;
  }

  Future<void> _onPlaneTapped(List<ARHitTestResult> hits) async {
    if (_gameState.isCarPlaced) return;

    final planeTap = hits.firstWhere(
          (h) => h.type == ARHitTestResultType.plane,
      orElse: () => hits.first,
    );

    final anchor = ARPlaneAnchor(transformation: planeTap.worldTransform);

    // ✅ FIX: addAnchor returns bool? — use != true, NOT if(!x!)
    final bool? anchorAdded = await arAnchorManager.addAnchor(anchor);
    if (anchorAdded != true) return;

    _carAnchor = anchor;
    _carPosition = vm.Vector3(0, 0, 0);

    final carNode = ARNode(
      type: NodeType.fileSystemAppFolderGLB,
      uri: _getCarGlb(_selectedCarId),
      scale: vm.Vector3(0.15, 0.15, 0.15),
      position: vm.Vector3(0, 0, 0),
      rotation: vm.Vector4(0, 1, 0, 0),
    );

    // ✅ FIX: addNode also returns bool?
    final bool? nodeAdded = await arObjectManager.addNode(carNode, planeAnchor: anchor);
    if (nodeAdded == true) {
      _carNode = carNode;
      _gameState.setCarPlaced();
      _startGame();
      setState(() {});
    }
  }

  String _getCarGlb(String carId) {
    switch (carId) {
      case 'blue_rocket':  return 'assets/models/blue_car.glb';
      case 'green_monster': return 'assets/models/green_car.glb';
      case 'gold_king':    return 'assets/models/gold_car.glb';
      default:             return 'assets/models/red_car.glb';
    }
  }

  void _startGame() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _gameState.decrementTime();
      setState(() {});
      if (_gameState.phase == GamePhase.finished) {
        _gameTimer?.cancel();
        _moveTimer?.cancel();
        _coinSpawnTimer?.cancel();
        if (mounted) _showGameOver();
      }
    });

    _coinSpawnTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_gameState.phase == GamePhase.playing) _spawnCoin();
    });

    _moveTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _moveCar();
    });

    Future.delayed(const Duration(milliseconds: 500), _spawnCoin);
  }

  void _moveCar() {
    if (_carNode == null || _gameState.phase != GamePhase.playing) return;
    final speed = 0.005 * _gameState.carSpeed;
    if (_joystickX.abs() < 0.1 && _joystickY.abs() < 0.1) return;

    _carRotation += _joystickX * 2.5;
    final angle = _carRotation * (pi / 180);
    _carPosition.x += sin(angle) * _joystickY * speed;
    _carPosition.z -= cos(angle) * _joystickY * speed;

    _carNode!.position = _carPosition;
    _carNode!.rotation = vm.Vector4(0, 1, 0, _carRotation * (pi / 180)) as vm.Matrix3;
    _checkCoinCollisions();
  }

  Future<void> _spawnCoin() async {
    if (_carAnchor == null) return;
    final rand = Random();
    final offset = vm.Vector3(
      (rand.nextDouble() - 0.5) * 0.6,
      0.05,
      (rand.nextDouble() - 0.5) * 0.6,
    );

    final coinAnchor = ARPlaneAnchor(transformation: _carAnchor!.transformation);

    // ✅ FIX: nullable bool check
    final bool? anchorAdded = await arAnchorManager.addAnchor(coinAnchor);
    if (anchorAdded != true) return;

    // ✅ FIX: NodeType.sphere doesn't exist — use webGLB with hosted model
    final coinNode = ARNode(
      type: NodeType.webGLB,
      uri: 'https://github.com/KhronosGroup/glTF-Sample-Models/raw/main/2.0/BoxAnimated/glTF-Binary/BoxAnimated.glb',
      scale: vm.Vector3(0.04, 0.04, 0.04),
      position: offset,
      rotation: vm.Vector4(0, 1, 0, 0),
    );

    final bool? nodeAdded = await arObjectManager.addNode(coinNode, planeAnchor: coinAnchor);
    if (nodeAdded == true) {
      _coinNodes.add(coinNode);
      _coinAnchors.add(coinAnchor);
    }
  }

  void _checkCoinCollisions() {
    for (int i = _coinNodes.length - 1; i >= 0; i--) {
      final dist = (_carPosition - _coinNodes[i].position).length;
      if (dist < 0.12) {
        arObjectManager.removeNode(_coinNodes[i]);
        arAnchorManager.removeAnchor(_coinAnchors[i]);
        _coinNodes.removeAt(i);
        _coinAnchors.removeAt(i);
        _gameState.addCoin();
        setState(() {});
      }
    }
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      // ✅ FIX: _GameOverDialog defined in same file below
      builder: (_) => _GameOverDialog(
        score: _gameState.score,
        coins: _gameState.coinsCollected,
        onRestart: () {
          Navigator.pop(context);
          for (final n in _coinNodes) arObjectManager.removeNode(n);
          for (final a in _coinAnchors) arAnchorManager.removeAnchor(a);
          _coinNodes.clear();
          _coinAnchors.clear();
          if (_carNode != null) arObjectManager.removeNode(_carNode!);
          if (_carAnchor != null) arAnchorManager.removeAnchor(_carAnchor!);
          _carNode = null;
          _carAnchor = null;
          _carRotation = 0;
          _carPosition = vm.Vector3(0, 0, 0);
          _gameState.reset();
          setState(() {});
        },
        onHome: () =>
            Navigator.popUntil(context, ModalRoute.withName('/home')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ARView(
            onARViewCreated: _onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontal,
          ),

          // ✅ FIX: use _ScanOverlay (defined below in same file)
          if (!_gameState.isCarPlaced)
            _ScanOverlay(isPlaneDetected: _gameState.isPlaneDetected),

          // ✅ FIX: use _HudOverlay (defined below in same file)
          if (_gameState.isCarPlaced)
            _HudOverlay(
              score: _gameState.score,
              timeLeft: _gameState.timeLeft,
              coins: _gameState.coinsCollected,
            ),

          if (_gameState.isCarPlaced)
            Positioned(
              bottom: 40,
              left: 40,
              child: Joystick(
                mode: JoystickMode.all,
                listener: (details) {
                  _joystickX = details.x;
                  _joystickY = details.y;
                },
                onStickDragEnd: () {
                  _joystickX = 0;
                  _joystickY = 0;
                },
              ),
            ),

          if (_gameState.isCarPlaced)
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: IconButton(
                  onPressed: () {
                    if (_gameState.phase == GamePhase.playing) {
                      _gameState.setPhase(GamePhase.paused);
                      _gameTimer?.cancel();
                      _moveTimer?.cancel();
                    } else if (_gameState.phase == GamePhase.paused) {
                      _gameState.setPhase(GamePhase.playing);
                      _startGame();
                    }
                    setState(() {});
                  },
                  icon: Icon(
                    _gameState.phase == GamePhase.paused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// Inline widgets — defined here so NO import errors occur
// ════════════════════════════════════════════════════════════

class _ScanOverlay extends StatefulWidget {
  final bool isPlaneDetected;
  const _ScanOverlay({required this.isPlaneDetected});
  @override
  State<_ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<_ScanOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.92, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, child) =>
              Transform.scale(scale: _anim.value, child: child),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: widget.isPlaneDetected
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF00BCD4),
                  width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isPlaneDetected ? Icons.check_circle : Icons.search,
                  color: widget.isPlaneDetected
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF00BCD4),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.isPlaneDetected
                      ? '✅ Floor found! Tap to place car'
                      : '📸 Point camera at the floor...',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HudOverlay extends StatelessWidget {
  final int score;
  final int timeLeft;
  final int coins;
  const _HudOverlay(
      {required this.score, required this.timeLeft, required this.coins});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _chip('🏆 $score', const Color(0xFF00BCD4)),
              _chip('⏱ $timeLeft',
                  timeLeft > 15 ? Colors.white : const Color(0xFFEF5350)),
              _chip('🪙 $coins', const Color(0xFFFFB300)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) => Container(
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

class _GameOverDialog extends StatelessWidget {
  final int score;
  final int coins;
  final VoidCallback onRestart;
  final VoidCallback onHome;
  const _GameOverDialog(
      {required this.score,
        required this.coins,
        required this.onRestart,
        required this.onHome});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0A0E1A),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏁', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            const Text('RACE OVER!',
                style: TextStyle(
                    color: Color(0xFF00BCD4),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _stat('🏆 Score', '$score', const Color(0xFF00BCD4)),
                _stat('🪙 Coins', '$coins', const Color(0xFFFFB300)),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRestart,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text('🔄 Play Again',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onHome,
              child: const Text('🏠 Home',
                  style: TextStyle(color: Colors.white54, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Column(children: [
      Text(label,
          style:
          TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
      const SizedBox(height: 4),
      Text(value,
          style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold)),
    ]),
  );
}