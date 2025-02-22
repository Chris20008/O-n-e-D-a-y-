import 'dart:io';
import 'package:fitness_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InitialAnimatedScreen extends StatefulWidget {

  final String animationControllerName;
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
  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);

  @override
  void initState() {
    super.initState();
    cnHomepage.animationControllers[widget.animationControllerName] = animationController;
  }

  @override
  void dispose() {
    super.dispose();
    cnHomepage.animationControllers.remove(widget.animationControllerName);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {

        // Scale
        const iOSValue = 0.245;
        const androidValue = 0.15;
        final platformValue = animationController.value * (Platform.isAndroid? androidValue : iOSValue);
        double scale = 1.0 - (platformValue);

        /// BorderRadius
        const double minBorderRadius = 15;
        final double maxBorderRadius = Platform.isAndroid? 30 : 50;
        final double multiplier = (maxBorderRadius - minBorderRadius) / 0.5;
        double borderRadius = (maxBorderRadius - multiplier * animationController.value).clamp(minBorderRadius, maxBorderRadius);

        /// Opacity
        double opacity = (animationController.value * 1.1).clamp(0, 1);
        if(!widget.backDropEnabled){
          opacity = 0;
        }
        return Transform.scale(
          scale: scale,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                decoration: widget.decoration,
                child: Stack(
                  children: [
                    child?? const SizedBox(),
                    IgnorePointer(
                        ignoring: opacity > 0 ? false : true,
                        child: Container(
                          color: Colors.black.withOpacity(opacity),
                          // color: Color.alphaBlend(Colors.black.withOpacity(0.2), Theme.of(context).primaryColor).withOpacity(opacity),
                        )
                    )
                  ],
                ),
                // child: Container(
                //     color: Colors.blue.withOpacity((animationController.value * 1.1).clamp(0, 1)),
                //     child: child
                // ),
              )
          ),
        );
      },
      child: widget.child
    );
  }
}
