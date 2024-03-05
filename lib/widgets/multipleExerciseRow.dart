import 'package:flutter/material.dart';
import '../objects/exercise.dart';

class MultipleExerciseRow extends StatelessWidget {
  final List<Exercise> exercises;
  final double textScaleFactor;
  final EdgeInsetsGeometry? padding;

  const MultipleExerciseRow({
    super.key,
    required this.exercises,
    this.textScaleFactor = 1,
    this.padding
  });

  final double _height = 60;
  final double _width = 30;
  final double _topBottomPadding = 5;
  final double _iconSize = 13;

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
                                          Text("-", textScaleFactor: 0.9,)
                                        else if (ex.restInSeconds < 60)
                                          Text("${ex.restInSeconds}s", textScaleFactor: 0.9,)
                                        else if (ex.restInSeconds % 60 != 0)
                                          Text("${(ex.restInSeconds/60).floor()}:${ex.restInSeconds%60}m", textScaleFactor: 0.9,)
                                        else
                                          Text("${(ex.restInSeconds/60).round()}m", textScaleFactor: 0.9,),
                                        SizedBox(width: 10,)
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
                                          Text("-", textScaleFactor: 0.9,)
                                        else
                                          Text(ex.seatLevel.toString(), textScaleFactor: 0.9,)
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 5,),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      ex.name,
                                      textScaleFactor: ex.name.length > 20 ? 0.8
                                          : ex.name.length > 14 ? 1.1
                                          : ex.name.length > 9 ? 1.3
                                          : ex.name.length > 5 ? 1.4
                                          : 1.5
                                  )
                              ),
                            ],
                          ),
                        )
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10,),

            // /// If in any exercise the seat level or rest time is defined, add an extra column
            // if(exercises.any((exercise) => exercise.seatLevel != null) || exercises.any((exercise) => exercise.restInSeconds > 0))
            //   Row(
            //     children: [
            //       Column(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           for (Exercise ex in exercises)
            //             Container(
            //               height: height + (2*topBottomPadding),
            //               width: 65,
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 mainAxisSize: MainAxisSize.min,
            //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //                 children: [
            //
            //                   if(ex.restInSeconds > 0)
            //                   Row(
            //                     children: [
            //                       const Icon(Icons.timer, size: 20,),
            //                       const SizedBox(width: 2,),
            //                       if (ex.restInSeconds >= 10)
            //                         Text("${(ex.restInSeconds/60).round()}:${ex.restInSeconds%60}m")
            //                       else
            //                         Text("${ex.restInSeconds}s")
            //                     ],
            //                   ),
            //
            //                   if(ex.seatLevel != null)
            //                     Row(
            //                       children: [
            //                         const Icon(Icons.airline_seat_recline_normal, size: 20,),
            //                         const SizedBox(width: 2,),
            //                         Text(ex.seatLevel.toString())
            //                       ],
            //                     )
            //                 ],
            //               ),
            //             ),
            //         ],
            //       ),
            //       const SizedBox(width: 10,),
            //     ],
            //   ),

            Expanded(
              flex: 7,
              child: SingleChildScrollView(

                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),

                /// Column for all Exercises
                child: Row(
                  children: [
                    /// If in any exercise the seat level or rest time is defined, add an extra column
                    // if(exercises.any((exercise) => exercise.seatLevel != null) || exercises.any((exercise) => exercise.restInSeconds > 0))
                    //   Row(
                    //     children: [
                    //       Column(
                    //         mainAxisSize: MainAxisSize.min,
                    //         children: [
                    //           for (Exercise ex in exercises)
                    //             Container(
                    //               height: height + (2*topBottomPadding),
                    //               width: 65,
                    //               child: Column(
                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                 mainAxisSize: MainAxisSize.min,
                    //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //                 children: [
                    //
                    //                   if(ex.restInSeconds > 0)
                    //                     Row(
                    //                       children: [
                    //                         const Icon(Icons.timer, size: 20,),
                    //                         const SizedBox(width: 2,),
                    //                         if (ex.restInSeconds >= 10)
                    //                           Text("${(ex.restInSeconds/60).round()}:${ex.restInSeconds%60}m")
                    //                         else
                    //                           Text("${ex.restInSeconds}s")
                    //                       ],
                    //                     ),
                    //
                    //                   if(ex.seatLevel != null)
                    //                     Row(
                    //                       children: [
                    //                         const Icon(Icons.airline_seat_recline_normal, size: 20,),
                    //                         const SizedBox(width: 2,),
                    //                         Text(ex.seatLevel.toString())
                    //                       ],
                    //                     )
                    //                 ],
                    //               ),
                    //             ),
                    //         ],
                    //       ),
                    //       const SizedBox(width: 10,),
                    //     ],
                    //   ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (Exercise ex in exercises)

                          /// One Row for each exercise
                          Row(
                            children: [
                            for (var set in ex.sets)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 3, right: 3, top: _topBottomPadding, bottom: _topBottomPadding),
                                  child: Container(
                                    height: _height,
                                    width: _width,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [

                                        /// Backgroud of single set
                                        Container(
                                          // height: height,
                                          // width: width,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[500]!.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(5),
                                            // border: Border.all(color: Colors.black, width: 1)
                                            // border: BoxBorder
                                          ),
                                        ),

                                        /// One Column for each set
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text("${set.weight}"),
                                            Container(
                                              color: Colors.grey[900],
                                              height: 1,
                                              width: _width/2,
                                            ),
                                            Text("${set.amount}")
                                          ],
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
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );

    // return Padding(
    //   padding: padding?? const EdgeInsets.all(0),
    //   child: Row(
    //     children: [
    //       Expanded(
    //           flex:3,
    //           child: Text(exercises.name, textScaleFactor: textScaleFactor,)
    //       ),
    //       Expanded(
    //         flex: 7,
    //         child: SizedBox(
    //           height: 60,
    //           child: ListView(
    //               physics: const BouncingScrollPhysics(),
    //               scrollDirection: Axis.horizontal,
    //               children: [
    //                 for (var set in exercises.sets)
    //                   ClipRRect(
    //                     borderRadius: BorderRadius.circular(5),
    //                     child: Padding(
    //                       padding: const EdgeInsets.only(left: 3, right: 3),
    //                       child: Stack(
    //                         alignment: Alignment.center,
    //                         children: [
    //                           Container(
    //                             width: 30,
    //                             decoration: BoxDecoration(
    //                               color: Colors.grey[500]!.withOpacity(0.2),
    //                               borderRadius: BorderRadius.circular(5),
    //                               // border: Border.all(color: Colors.black, width: 1)
    //                               // border: BoxBorder
    //                             ),
    //                           ),
    //                           Column(
    //                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                             children: [
    //                               Text("${set.weight}"),
    //                               Container(
    //                                 color: Colors.grey[900],
    //                                 height: 1,
    //                                 width: 15,
    //                               ),
    //                               Text("${set.amount}")
    //                             ],
    //                           )
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //               ]
    //           ),
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }
}
