import 'dart:math' as math;

import 'package:flutter/material.dart';

class RotatingFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final void Function() onFavoritePressed;
  final double iconSize;

  const RotatingFavoriteButton({
    required this.isFavorite,
    required this.onFavoritePressed,
    super.key,
    this.iconSize = 24.0,
  });

  @override
  RotatingFavoriteButtonState createState() => RotatingFavoriteButtonState();
}

class RotatingFavoriteButtonState extends State<RotatingFavoriteButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onPressed() async {
    await _controller.forward();
    await _controller.forward();
    await _controller.reverse();
    await _controller.reverse();
    await _controller.forward();
    await _controller.reverse();
    widget.onFavoritePressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(angle: _rotationAnimation.value, child: child);
      },
      child: IconButton(
        onPressed: _onPressed,
        icon: Icon(Icons.star, color: widget.isFavorite ? Colors.yellow : Colors.grey),
        iconSize: widget.iconSize,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: widget.iconSize + 8, minHeight: widget.iconSize + 8),
      ),
    );
  }
}
