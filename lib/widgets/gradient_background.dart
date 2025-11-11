import 'dart:ui';
import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final double top;
  final double bottom;

  const GradientBackground({
    Key? key,
    required this.child,
    this.top = -50,
    this.bottom = -50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0))),
        Positioned(top: top, left: -30, child: BlurredCircle()),
        Positioned(top: bottom, left: -60, child: BlurredCircle()),
        child,
      ],
    );
  }
}

class BlurredCircle extends StatelessWidget {
  const BlurredCircle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 882,
      height: 651,
      decoration: BoxDecoration(shape: BoxShape.circle),
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(73, 173, 213, 1),
                Color.fromRGBO(152, 203, 147, 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
