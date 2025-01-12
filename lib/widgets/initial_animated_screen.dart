import 'dart:io';
import 'package:fitness_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InitialAnimatedScreen extends StatefulWidget {

  final String animationControllerName;
  final Widget child;

  const InitialAnimatedScreen({
    super.key,
    required this.animationControllerName,
    required this.child
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
        double scale = 1.0 - (animationController.value * (Platform.isAndroid? 0.15 : 0.245));
        double borderRadius = 26 - (scale*10-9)*20;
        borderRadius = borderRadius > 25 ? 25 : borderRadius;
        double opacity = (animationController.value * 1.1).clamp(0, 1);
        return Transform.scale(
          scale: scale,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0xffc26a0e),
                          Color(0xbb110a02)
                        ]
                    )
                ),
                child: Stack(
                  children: [
                    child?? const SizedBox(),
                    IgnorePointer(
                        ignoring: opacity > 0 ? false : true,
                        child: Container(
                          color: Colors.black.withOpacity(opacity),
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
