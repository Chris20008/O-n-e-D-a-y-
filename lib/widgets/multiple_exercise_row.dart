import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import '../objects/exercise.dart';

class MultipleExerciseRow extends StatelessWidget {
  final List<Exercise> exercises;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final double? minFontSize;
  final Color? colorFade;

  const MultipleExerciseRow({
    super.key,
    required this.exercises,
    this.padding,
    this.fontSize,
    this.minFontSize,
    this.colorFade,
  });

  final double _height = 60;
  final double _width = 36;
  final double _topBottomPadding = 5;
  final double _iconSize = 13;
  final double _leftRightPadding = 3;

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: padding?? const EdgeInsets.all(0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Column(

                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (Exercise ex in exercises)
                    SizedBox(
                        height: _height + (2*_topBottomPadding),
                        child: Padding(
                          padding: EdgeInsets.only(top: _topBottomPadding, bottom: _topBottomPadding),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [

                                  // if(ex.restInSeconds > 0)
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: [
                                        Icon(Icons.timer, size: _iconSize,),
                                        const SizedBox(width: 2,),
                                        if (ex.restInSeconds == 0)
                                          const Text("-", textScaler: TextScaler.linear(0.9),)
                                        else if (ex.restInSeconds < 60)
                                          Text("${ex.restInSeconds}s", textScaler: const TextScaler.linear(0.9),)
                                        else if (ex.restInSeconds % 60 != 0)
                                          Expanded(
                                              child: OverflowSafeText(
                                                "${(ex.restInSeconds/60).floor()}:${ex.restInSeconds%60}m",
                                                maxLines: 1,
                                                fontSize: 12
                                              ),
                                          )
                                        else
                                          Text("${(ex.restInSeconds/60).round()}m", textScaler: const TextScaler.linear(0.9),),
                                        const SizedBox(width: 10,)
                                      ],
                                    ),
                                  ),

                                  // if(ex.seatLevel != null)
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Icon(Icons.airline_seat_recline_normal, size: _iconSize,),
                                        const SizedBox(width: 2,),
                                        if (ex.seatLevel == null)
                                          const Text("-", textScaler: TextScaler.linear(0.9),)
                                        else
                                          Text(ex.seatLevel.toString(), textScaler: const TextScaler.linear(0.9),)
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Expanded(
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: OverflowSafeText(
                                        ex.name,
                                        fontSize: fontSize,
                                        minFontSize: 14,
                                        maxLines: 1
                                    )
                                ),
                              ),
                              const SizedBox(height: 5,),
                            ],
                          ),
                        )
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10,),

            Expanded(
              flex: 7,
              child: Stack(
                children: [
                  SingleChildScrollView(

                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),

                    /// Column for all Exercises
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (Exercise ex in exercises)

                          /// One Row for each exercise
                          Row(
                            children: [
                            for (var set in ex.sets)
                              set.weight == null || set.amount == null?
                              /// Create empty box as placeholder
                              SizedBox(
                                height: _height+ _topBottomPadding*2,
                                width: _width + _leftRightPadding*2
                              ) :
                              /// Each Set
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: set == ex.sets.first && colorFade != null? 15 : 3,
                                      right: set == ex.sets.last && colorFade != null? 30 : 3,
                                      top: _topBottomPadding,
                                      bottom: _topBottomPadding),
                                  child: SizedBox(
                                    height: _height,
                                    width: _width,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [

                                        /// Background of single set
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[500]!.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(5),
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
                                                width: _width/2,
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
                            ],
                          )
                      ],
                    ),
                  ),
                  if(colorFade != null)
                    Positioned(
                      right: 0,
                      top:0,
                      bottom: 0,
                      child: Container(
                        width: 20,
                          // color:Colors.red
                        decoration: BoxDecoration(
                          gradient:  LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                colorFade!.withOpacity(0.0),
                                colorFade!,
                              ]
                          ),
                        ),
                        // height: 40,
                      ),
                    ),
                  if(colorFade != null)
                    Positioned(
                      left: 0,
                      top:0,
                      bottom: 0,
                      child: Container(
                        width: 20,
                        // color:Colors.red
                        decoration: BoxDecoration(
                          gradient:  LinearGradient(
                              end: Alignment.centerLeft,
                              begin: Alignment.centerRight,
                              colors: [
                                colorFade!.withOpacity(0.0),
                                colorFade!,
                              ]
                          ),
                        ),
                        // height: 40,
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
