import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import '../objects/exercise.dart';

class ExerciseRow extends StatelessWidget {
  final Exercise exercise;
  // final double textScaleFactor;
  final EdgeInsetsGeometry? padding;
  final Widget? child;
  final int flexLeft;
  final int flexRight;
  final TextStyle? style;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  const ExerciseRow({
    super.key,
    required this.exercise,
    // this.textScaleFactor = 1.5,
    this.padding,
    this.child,
    this.flexLeft = 3,
    this.flexRight = 7,
    this.style,
    this.margin,
    this.borderRadius
  });

  final double _widthOfField = 44;
  final double _height = 40;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: double.maxFinite,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        // color: Color(0x921c1001),
        borderRadius: borderRadius?? BorderRadius.circular(8)
      ),
      margin: margin,
      padding: padding?? const EdgeInsets.all(0),
      duration: const Duration(milliseconds: 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child?? OverflowSafeText(
            exercise.name,
            textAlign: TextAlign.center,
            // fontSize: 12,
            style: style,
            minFontSize: 12,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: _height,
            child: ListView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: [
                  for (var set in exercise.sets)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 3, right: 3),
                        child: SizedBox(
                          width: _widthOfField,
                          height: _height,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [

                              /// Background of single set
                              backgroundSingleSet,

                              /// One Column for each set (weight / amount)
                              dataSingleSet(set, exercise)
                            ],
                          ),
                        ),
                      ),
                    ),
                ]
            ),
          ),
        ],
      ),
    );
  }
}