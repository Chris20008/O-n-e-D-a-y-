import 'package:flutter/material.dart';

class BackgroundSingleSet extends StatelessWidget {
  final Color? color;

  const BackgroundSingleSet({
    super.key,
    this.color
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color?? Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
