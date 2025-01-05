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

  const ExerciseRow({
    super.key,
    required this.exercise,
    // this.textScaleFactor = 1.5,
    this.padding,
    this.child,
    this.flexLeft = 3,
    this.flexRight = 7
  });

  final double _widthOfField = 44;
  final double _height = 60;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding?? const EdgeInsets.all(0),
      child: Row(
        children: [
          Expanded(
              flex:flexLeft,
              child: child?? OverflowSafeText(exercise.name)
          ),
          Expanded(
            flex: flexRight,
            child: SizedBox(
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
          )
        ],
      ),
    );
  }
}
