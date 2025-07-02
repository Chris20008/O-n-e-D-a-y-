import 'dart:io';
import 'package:fitness_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'animation_controller_name.dart';

class InitialAnimatedScreen extends StatefulWidget {

  final AnimationControllerName animationControllerName;
  final Widget child;
  final bool backDropEnabled;
  final BoxDecoration? decoration;

  const InitialAnimatedScreen({
    super.key,
    required this.animationControllerName,
    required this.child,
    this.backDropEnabled = true,
    this.decoration = const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xffc26a0e),
              Color(0xbb110a02)
            ]
        )
    )
  });

  @override
  State<InitialAnimatedScreen> createState() => _InitialAnimatedScreenState();
}

class _InitialAnimatedScreenState extends State<InitialAnimatedScreen> with TickerProviderStateMixin{

  final double minBorderRadius = 15;
  final double maxBorderRadius = Platform.isAndroid? 30 : 50;
  final double minScale = Platform.isAndroid? 0.85 : 0.755;
  late CnHomepage cnHomepage = context.read<CnHomepage>();

  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  /// Opacity
  late final opacityAnim = Tween<double>(begin: 0.0, end: 1.0)
      .animate(animationController);

  /// BorderRadius
  late final borderRadiusAnim = Tween<double>(begin: maxBorderRadius, end: minBorderRadius).animate(
    CurvedAnimation(
      parent: animationController,
      curve: const Interval(
        0.0, 0.5,
        curve: Curves.linear,
      ),
    ),
  );

  /// Scale
  late final scaleAnim = Tween<double>(begin: 1.0, end: minScale)
      .animate(animationController);

  @override
  void initState() {
    super.initState();
    cnHomepage.animationControllers[widget.animationControllerName.value] = animationController;
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
    cnHomepage.animationControllers.remove(widget.animationControllerName.value);
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {

        /// BorderRadius
        final double borderRadius = borderRadiusAnim.value == maxBorderRadius ? 0 : borderRadiusAnim.value;

        /// Transform y position
        double y = animationController.value * 10;

        final matrix = Matrix4.identity()
          ..translate(0.0, y)
          ..scale(scaleAnim.value);

        return Transform(
          transform: matrix,
          alignment: Alignment.center,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                decoration: widget.decoration,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    child ?? const SizedBox(),
                    if(opacityAnim.value > 0 && widget.backDropEnabled)
                      Container(color: Color.fromRGBO(0, 0, 0, opacityAnim.value)),
                  ],
                ),
              )
          ),
        );
      },
      child: widget.child
    );
  }
}
