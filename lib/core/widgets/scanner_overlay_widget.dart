import 'package:flutter/material.dart';

class ScannerOverlayWidget extends StatefulWidget {
  final double width;
  final double height;
  final Color scanColor;

  const ScannerOverlayWidget({
    super.key,
    this.width = 280,
    this.height = 280,
    this.scanColor = const Color(0xFFFFD700),
  });

  @override
  State<ScannerOverlayWidget> createState() => _ScannerOverlayWidgetState();
}

class _ScannerOverlayWidgetState extends State<ScannerOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Background Dim dengan Lubang (Cara yang benar-benar stabil)
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: const Alignment(0, -0.2), // Biar lubang agak ke atas
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 2. Garis Animasi & Border Kotak
        Align(
          alignment: const Alignment(0, -0.2), // Harus sama dengan alignment di atas agar sinkron
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              children: [
                // Top Left
                _cornerBorder(top: 0, left: 0, isTop: true, isLeft: true),
                // Top Right
                _cornerBorder(top: 0, right: 0, isTop: true, isLeft: false),
                // Bottom Left
                _cornerBorder(bottom: 0, left: 0, isTop: false, isLeft: true),
                // Bottom Right
                _cornerBorder(bottom: 0, right: 0, isTop: false, isLeft: false),
                
                // Laser Line
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Stack(
                        children: [
                          Positioned(
                            top: _animation.value * widget.height,
                            left: 10,
                            right: 10,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.scanColor.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                                color: widget.scanColor,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _cornerBorder({double? top, double? bottom, double? left, double? right, required bool isTop, required bool isLeft}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? BorderSide(color: widget.scanColor, width: 4) : BorderSide.none,
            bottom: !isTop ? BorderSide(color: widget.scanColor, width: 4) : BorderSide.none,
            left: isLeft ? BorderSide(color: widget.scanColor, width: 4) : BorderSide.none,
            right: !isLeft ? BorderSide(color: widget.scanColor, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
