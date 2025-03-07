import 'package:collection/collection.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../objects/exercise.dart';

class MultipleExerciseRow extends StatelessWidget {
  final List<Exercise> exercises;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final double? minFontSize;
  final Color? colorFade;
  final bool comparePreviousExercise;

  const MultipleExerciseRow({
    super.key,
    required this.exercises,
    this.padding,
    this.fontSize,
    this.minFontSize,
    this.colorFade,
    this.comparePreviousExercise = false
  });

  final double _height = 60;
  final double _width = 44;
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
              width: 110,
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
                                        Icon(
                                          CupertinoIcons.timer,
                                          size: _iconSize,
                                          color: Colors.white,
                                        ),
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
                                        Icon(
                                          Icons.airline_seat_recline_normal,
                                          size: _iconSize,
                                          color: Colors.white,
                                        ),
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
                                        minFontSize: 13,
                                        maxLines: 2
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
                      children: getExerciseRows(),
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

  List<Widget> getExerciseRows(){
    List<Widget> children = [];
    Exercise? previousExercise;
    for(Exercise ex in exercises){
      List<Widget> sets = [];
      /// Remove empty sets in case the previous exercise had one
      /// Because from no on, we assume that all weights and amounts
      /// in previous workout are not null
      previousExercise?.removeEmptySets();
      ex.sets.forEachIndexed((index, set){

        /// Has weight or amount improved?
        bool? weightImproved;
        bool? amountImproved;
        if(comparePreviousExercise
            && previousExercise != null
            && previousExercise.sets.length > index
            && set.weight != null
            && set.amount != null
            && set.setType != null
        ){
          if(previousExercise.sets[index].weight! < set.weight!){
            weightImproved = true;
          }
          else if(previousExercise.sets[index].weight! > set.weight!){
            weightImproved = false;
          }
          if(previousExercise.sets[index].amount! < set.amount!){
            amountImproved = true;
          }
          else if(previousExercise.sets[index].amount! > set.amount!){
            amountImproved = false;
          }
        }
        /// null means no comparison with previous possible
        else{
          weightImproved = null;
          amountImproved = null;
        }

        if(set.weight == null || set.amount == null){
          /// Create empty box as placeholder
          sets.add(
              SizedBox(
                  height: _height+ _topBottomPadding*2,
                  width: _width + _leftRightPadding*2
              )
          );
        }
        else{
          /// Each Set
          sets.add(
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
                        backgroundSingleSet,

                        /// One Column for each set (weight / amount)
                        dataSingleSet(set, ex),

                        if(weightImproved != null)
                          getArrow(weightImproved, true),
                        if(amountImproved != null)
                          getArrow(amountImproved, false),
                        // if(setTypeChanged)
                        //   getSetType(set.setType!)
                        // getSetType(1)
                      ],
                    ),
                  ),
                ),
              )
          );
        }
      });
      /// One Row for each exercise
      children.add(
          Row(
            children: sets,
          )
      );
      previousExercise = ex;
    }
    return children;
  }

  Widget getSetType(int setType){
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.5),
        color: setType == 1? Colors.blue : setType == 2? Colors.green : Colors.transparent
      ),
    );
  }

  Widget getArrow(bool improved, bool top){
    return Positioned(
      top: top? 0 - 4 : null,
      right: 0 - 4,
      bottom: top? null : _height/2-_topBottomPadding*2 - 4,
      child: Icon(
        improved? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
        color: improved? Colors.green : Colors.red,
        size: 20,
      ),
    );
  }
}