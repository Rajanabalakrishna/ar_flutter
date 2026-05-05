import 'package:flutter/material.dart';

class ScanOverlay extends StatefulWidget {
  final bool isPlaneDetected;
  const ScanOverlay({super.key, required this.isPlaneDetected});
  @override
  State<ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<ScanOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 60,
      left: 0, right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, child) => Transform.scale(
            scale: _pulseAnim.value,
            child: child,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: widget.isPlaneDetected
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF00BCD4),
                width: 2,
              ),
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