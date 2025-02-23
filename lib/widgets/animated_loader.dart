import 'package:flutter/material.dart';

class AnimatedLoader extends StatefulWidget {
  final double width;
  final bool isDark;

  const AnimatedLoader({super.key, required this.width, this.isDark = false});

  @override
  State<AnimatedLoader> createState() => _AnimatedLoaderState();
}

class _AnimatedLoaderState extends State<AnimatedLoader> 
with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();
  late final Animation<double> _animation = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: Image.asset(
        "assets/images/loader.png",
        width: widget.width,
        colorBlendMode: null,
        color: widget.isDark ? Colors.black : Colors.white),
    );
  }
}