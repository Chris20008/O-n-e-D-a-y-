import 'dart:ui';
import 'package:flutter/material.dart';

class SlidableSingleSetProxyDecorator extends StatelessWidget {

  final int index;
  final Animation<double> animation;
  final Widget child;

  const SlidableSingleSetProxyDecorator({
    super.key,
    required this.index,
    required this.animation,
    required this.child
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double scale = lerpDouble(1, 1.06, animValue)!;
        return Transform.scale(
          scale: scale,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Material(
                child: Container(
                    padding: const EdgeInsets.only(left: 2),
                    color: Colors.grey.withValues(alpha: 0.1),
                    child: child
                )
            ),
          ),
        );
      },
      child: child,
    );
  }
}
