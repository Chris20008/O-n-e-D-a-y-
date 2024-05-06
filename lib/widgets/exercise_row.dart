import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import '../objects/exercise.dart';

class ExerciseRow extends StatelessWidget {
  final Exercise exercise;
  final double textScaleFactor;
  final EdgeInsetsGeometry? padding;
  final Widget? child;
  final int flexLeft;
  final int flexRight;

  const ExerciseRow({
    super.key,
    required this.exercise,
    this.textScaleFactor = 1.5,
    this.padding,
    this.child,
    this.flexLeft = 3,
    this.flexRight = 7
  });

  final double _widthOfField = 36;
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
                                Container(
                                  width: _widthOfField,
                                  decoration: BoxDecoration(
                                      color: Colors.grey[500]!.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(5),
                                      // border: Border.all(color: Colors.black, width: 1)
                                    // border: BoxBorder
                                  ),
                                ),

                                /// One Column for each set (weight / amount)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      OverflowSafeText(
                                          "${set.weight.toString().endsWith(".0")? set.weight?.toInt() : set.weight}",
                                          maxLines: 1,
                                          fontSize: 14,
                                          minFontSize: 9
                                      ),
                                      Container(
                                        color: Colors.grey[900],
                                        height: 1,
                                        width: 15,
                                      ),
                                      Text("${set.amount}")
                                    ],
                                  ),
                                )
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
