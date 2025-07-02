import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PanelHeaderRow extends StatelessWidget {
  final Widget childLeft;
  final Widget childMiddle;
  final Widget childRight;
  final int flexLeft;
  final int flexMiddle;
  final int flexRight;

  const PanelHeaderRow({
    super.key,
    required this.childLeft,
    required this.childMiddle,
    required this.childRight,
    this.flexLeft = 11,
    this.flexMiddle = 10,
    this.flexRight = 11
  });

  static const double height = 50;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              flex: flexLeft,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: childLeft
              )
          ),
          Expanded(
              flex: flexMiddle,
              child: Center(
                child: childMiddle,
              )
          ),
          Expanded(
              flex: flexRight,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: childRight
              )
          ),
        ],
      ),
    );
  }
}
