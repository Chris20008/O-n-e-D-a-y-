import 'dart:ui';

import 'package:fitness_app/screens/screen_workouts/screen_workouts.dart';
import 'package:fitness_app/widgets/animated_column.dart';
import 'package:fitness_app/widgets/stopwatch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../objects/exercise.dart';
import '../../objects/workout.dart';
import '../../util/constants.dart';
import '../../widgets/bottom_menu.dart';
import '../../widgets/spotify_bar.dart';
import '../../widgets/standard_popup.dart';

class ScreenRunningWorkout extends StatefulWidget {
  const ScreenRunningWorkout({
    super.key,
  });

  @override
  State<ScreenRunningWorkout> createState() => _ScreenRunningWorkoutState();
}

class _ScreenRunningWorkoutState extends State<ScreenRunningWorkout> {
  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  late CnStopwatchWidget cnStopwatchWidget = Provider.of<CnStopwatchWidget>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout;
  final double _iconSize = 13;
  final double _heightOfSetRow = 50;
  final double _setPadding = 5;

  @override
  Widget build(BuildContext context) {
    cnRunningWorkout = Provider.of<CnRunningWorkout>(context);

    return PopScope(
      onPopInvoked: (doPop){
        if(cnRunningWorkout.isVisible){
          cnRunningWorkout.isVisible = false;
          // cnHomepage.refresh(refreshSpotifyBar: true);
          cnWorkouts.refresh();
          cnBottomMenu.refresh();

          Future.delayed(const Duration(milliseconds: 300), (){
            cnSpotifyBar.refresh();
            // cnWorkouts.refresh();
            // cnBottomMenu.refresh();
          });
        }
        // cnSpotifyBar.refresh();
        // cnWorkouts.refresh();
        // cnBottomMenu.refresh();
      },
      // onWillPop: () async{
      //   cnRunningWorkout.isVisible = false;
      //   // cnHomepage.refresh(refreshSpotifyBar: true);
      //   cnSpotifyBar.refresh();
      //   cnWorkouts.refresh();
      //   cnBottomMenu.refresh();
      //   return true;
      // },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Scaffold(
              extendBody: true,
              // resizeToAvoidBottomInset: false,
              bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom < 50? ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 10.0,
                      sigmaY: 10.0,
                      tileMode: TileMode.mirror
                  ),
                  child: GestureDetector(
                    onTap: openPopUpFinishWorkout,
                    child: Container(
                      height: 70,
                      color: Colors.black.withOpacity(0.5),
                      // decoration: BoxDecoration(
                      //     gradient: LinearGradient(
                      //         begin: Alignment.topCenter,
                      //         end: Alignment.bottomCenter,
                      //         colors: [
                      //           Colors.black.withOpacity(0.3),
                      //           Colors.black.withOpacity(0.6),
                      //           Colors.black.withOpacity(1),
                      //         ]
                      //     )
                      // ),
                      child: Center(child: Text("Finish", style: TextStyle(color: Colors.amber[800]), textScaleFactor: 1.4,)),
                    ),
                  ),
                ),
              ): const SizedBox(),
              body: GestureDetector(
                onTap: (){
                  FocusScope.of(context).unfocus();
                },
                child: Stack(
                  children: [
                    // const BackgroundImage(),
                    // ImageFiltered(
                    //     imageFilter: ImageFilter.blur(
                    //       sigmaX: 50.0,
                    //       sigmaY: 50.0,
                    //     ),
                    //     child: cnSpotifyBar.lastImage
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(top:0,bottom: 0,left: 20, right: 20),
                      child: Column(
                        children: [

                          Expanded(

                            /// Each EXERCISE
                            child: ListView.separated(
                              // key: listViewKey,
                              controller: cnRunningWorkout.scrollController,
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              separatorBuilder: (BuildContext context, int index) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 20,),
                                    Container(
                                      height: 1,
                                      width: double.maxFinite - 50,
                                      color: Colors.amber[900]!.withOpacity(0.6),
                                    ),
                                    const SizedBox(height: 20,),
                                  ],
                                );
                              },
                              itemCount: cnRunningWorkout.groupedExercises.length,
                              itemBuilder: (BuildContext context, int indexExercise) {
                                Widget? child;
                                dynamic newEx = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value;
                                if(newEx is! Exercise){
                                  newEx = newEx[cnRunningWorkout.selectedIndexes[cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].key]];
                                }
                                Exercise lastEx = cnRunningWorkout.lastWorkout.exercises.where((element) => element.name == newEx.name).first;
                                child = Column(
                                  children: [
                                    Align(
                                        alignment: Alignment.centerLeft,
                                        child: cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value is Exercise?
                                        // Text(newEx.name, textScaleFactor: 1.2,):
                                        ExerciseNameText(newEx.name):
                                        DropdownMenu<String>(
                                          initialSelection: newEx.name,
                                          onSelected: (String? value) {
                                            setState(() {
                                              final lists = cnRunningWorkout.groupedExercises.entries.toList().where((element) => element.value is List<Exercise>); ///.whereType<List>();
                                              final t = lists.map((element) => element.value.indexWhere((ex) {
                                                return ex.name == value;
                                              })).toList().firstWhere((element) => element >=0);
                                              cnRunningWorkout.selectedIndexes[cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].key] = t;
                                            });
                                          },
                                          dropdownMenuEntries: cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value.map<DropdownMenuEntry<String>>((Exercise value) {
                                            return DropdownMenuEntry<String>(value: value.name, label: value.name);
                                          }).toList(),
                                        )
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(Icons.airline_seat_recline_normal, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
                                        const SizedBox(width: 2,),
                                        if (newEx.seatLevel == null)
                                          const Text("-", textScaleFactor: 0.9,)
                                        else
                                          Text(newEx.seatLevel.toString(), textScaleFactor: 0.9,)
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.timer, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
                                        const SizedBox(width: 2,),
                                        if (newEx.restInSeconds == 0)
                                          const Text("-", textScaleFactor: 0.9,)
                                        else if (newEx.restInSeconds < 60)
                                          Text("${newEx.restInSeconds}s", textScaleFactor: 0.9,)
                                        else if (newEx.restInSeconds % 60 != 0)
                                            Text("${(newEx.restInSeconds/60).floor()}:${newEx.restInSeconds%60}m", textScaleFactor: 0.9,)
                                          else
                                            Text("${(newEx.restInSeconds/60).round()}m", textScaleFactor: 0.9,),
                                        const SizedBox(width: 10,)
                                      ],
                                    ),

                                    /// Each Set
                                    ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: newEx.sets.length+1,
                                        itemBuilder: (BuildContext context, int indexSet) {
                                          if(indexSet == newEx.sets.length){
                                            return Row(
                                              children: [
                                                Expanded(
                                                  child: IconButton(
                                                      alignment: Alignment.center,
                                                      color: Colors.amber[800],
                                                      style: ButtonStyle(
                                                          backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
                                                          shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(20)))
                                                      ),
                                                      onPressed: () {
                                                        addSet(newEx, lastEx);
                                                      },
                                                      icon: const Icon(
                                                        Icons.add,
                                                        size: 20,
                                                      )
                                                  ),
                                                ),
                                              ],
                                            );
                                          }

                                          SingleSet set = lastEx.sets[indexSet];
                                          Widget? child;
                                          child = Padding(
                                            padding: EdgeInsets.only(bottom: _setPadding, top: _setPadding),
                                            child: SizedBox(
                                              width: double.maxFinite,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  SizedBox(width: 80,child: Text("${indexSet + 1}", textScaleFactor: 1.2,)),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        Expanded(
                                                          child: GestureDetector(
                                                            onTap: (){
                                                              cnRunningWorkout.textControllers[newEx.name]?[indexSet][0].text = set.weight?.toString()?? "";
                                                              newEx.sets[indexSet].weight = set.weight;
                                                              cnRunningWorkout.refresh();
                                                            },
                                                            child: Container(
                                                              height: _heightOfSetRow,
                                                              color: Colors.transparent,
                                                              child: Center(child: Text("${set.weight?? ""}", textScaleFactor: 1.2,)),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 50,
                                                          height: _heightOfSetRow,
                                                          /// Input weight
                                                          child: Center(
                                                            child: TextField(
                                                              maxLength: 3,
                                                              textAlignVertical: TextAlignVertical.center,
                                                              keyboardType: TextInputType.number,
                                                              controller: cnRunningWorkout.textControllers[newEx.name]?[indexSet][0],
                                                              decoration: InputDecoration(
                                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                                isDense: true,
                                                                counterText: "",
                                                              ),
                                                              onChanged: (value){
                                                                value = value.trim();
                                                                if(value.isNotEmpty){
                                                                  newEx.sets[indexSet].weight = int.parse(value);
                                                                }
                                                                else{
                                                                  newEx.sets[indexSet].weight = null;
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const Spacer(flex: 1),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        Expanded(
                                                          child: GestureDetector(
                                                            onTap: (){
                                                              cnRunningWorkout.textControllers[newEx.name]?[indexSet][1].text = set.amount?.toString()?? "";
                                                              newEx.sets[indexSet].amount = set.amount;
                                                              cnRunningWorkout.refresh();
                                                            },
                                                            child: Container(
                                                              height: _heightOfSetRow,
                                                              color: Colors.transparent,
                                                              child: Center(child: Text("${set.amount?? ""}", textScaleFactor: 1.2,)),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 50,
                                                          height: _heightOfSetRow,

                                                          /// Input amount
                                                          child: Center(
                                                            child: TextField(
                                                              maxLength: 3,
                                                              textAlignVertical: TextAlignVertical.center,
                                                              keyboardType: TextInputType.number,
                                                              controller: cnRunningWorkout.textControllers[newEx.name]?[indexSet][1],
                                                              decoration: InputDecoration(
                                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                                isDense: true,
                                                                counterText: "",
                                                              ),
                                                              onChanged: (value){
                                                                value = value.trim();
                                                                if(value.isNotEmpty){
                                                                  newEx.sets[indexSet].amount = int.parse(value);
                                                                }
                                                                else{
                                                                  newEx.sets[indexSet].amount = null;
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 25,)
                                                ],
                                              ),
                                            ),
                                          );

                                          return Slidable(
                                            key: cnRunningWorkout.slideableKeys[newEx.name]![indexSet],
                                            // key: UniqueKey(),
                                            startActionPane: ActionPane(
                                              motion: const ScrollMotion(),
                                              dismissible: DismissiblePane(
                                                  onDismissed: () {
                                                    dismiss(newEx, lastEx, indexSet);
                                                  }),
                                              children: [
                                                SlidableAction(
                                                  flex:10,
                                                  onPressed: (BuildContext context){
                                                    dismiss(newEx, lastEx, indexSet);
                                                  },
                                                  borderRadius: BorderRadius.circular(15),
                                                  backgroundColor: Color(0xFFA12D2C),
                                                  foregroundColor: Colors.white,
                                                  icon: Icons.delete,
                                                ),
                                                SlidableAction(
                                                  flex: 1,
                                                  onPressed: (BuildContext context){},
                                                  backgroundColor: Colors.transparent,
                                                  foregroundColor: Colors.transparent,
                                                  label: '',
                                                ),
                                              ],
                                            ),
                                            child: child,
                                          );
                                        }
                                    ),
                                  ],
                                );

                                /// Top Spacer
                                if (indexExercise == 0){
                                  child = Column(
                                    children: [
                                      const SizedBox(height: 90,),
                                      child
                                    ],
                                  );
                                }

                                /// Bottom Spacer
                                if (indexExercise == cnRunningWorkout.groupedExercises.length-1){
                                  child = Column(
                                    children: [
                                      child,
                                      const SizedBox(height: 70,)
                                    ],
                                  );
                                }

                                return child;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      // borderRadius: BorderRadius.circular(15),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10, tileMode: TileMode.mirror),
                        child: Container(
                          // margin: const EdgeInsets.only(bottom: 30),
                          height: 130,
                          width: double.maxFinite,
                          color: Colors.black.withOpacity(0.5),
                          // decoration: BoxDecoration(
                          //   // color: Colors.black.withOpacity(0.5),
                          //   // borderRadius: BorderRadius.circular(10),
                          //     gradient: LinearGradient(
                          //         begin: Alignment.topCenter,
                          //         end: Alignment.bottomCenter,
                          //         colors: [
                          //           // Colors.black.withOpacity(0.4),
                          //           Colors.black.withOpacity(1),
                          //           Colors.black.withOpacity(0.3),
                          //         ]
                          //     )
                          // ),
                          child: Column(
                            children: [
                              const SafeArea(
                                bottom: false,
                                child: SizedBox(),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                child: Column(
                                  children: [
                                    Text(cnRunningWorkout.workout.name, textScaleFactor: 1.4, style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 10,),
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Set", textScaleFactor: 1),
                                        SizedBox(width: 20,),
                                        Text("Weight", textScaleFactor: 1),
                                        SizedBox(width: 1,),
                                        Text("Amount", textScaleFactor: 1),
                                        SizedBox(width: 1,)
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if(MediaQuery.of(context).viewInsets.bottom < 50)
                    // Stack(
                    //   children: [
                    //     AnimatedContainer(
                    //       duration: Duration(milliseconds: cnSpotifyBar.animationTimeSpotifyBar),
                    //       transform: Matrix4.translationValues(0, 0, 0),
                    //       child: const Hero(
                    //           transitionOnUserGestures: true,
                    //           tag: "SpotifyBar",
                    //           child: SpotifyBar()
                    //       ),
                    //     ),
                    //     AnimatedContainer(
                    //         duration: Duration(milliseconds: cnSpotifyBar.animationTimeSpotifyBar),
                    //         transform: Matrix4.translationValues(0, -cnSpotifyBar.height, 0),
                    //         child: const StopwatchWidget()
                    //     ),
                    //   ],
                    // ),
                      const AnimatedColumn(),
                    // SafeArea(
                    //   child: Stack(
                    //     alignment: Alignment.bottomRight,
                    //     children: [
                    //       Padding(
                    //         padding: EdgeInsets.only(bottom: cnSpotifyBar.height*2),
                    //         child: AnimatedContainer(
                    //           duration: Duration(milliseconds: cnStopwatchWidget.animationTimeStopwatch),
                    //           transform: Matrix4.translationValues(0, cnStopwatchWidget.isOpened? -cnStopwatchWidget.heightOfTimer+cnSpotifyBar.height : 0, 0),
                    //           width: cnSpotifyBar.height,
                    //           height: cnSpotifyBar.height,
                    //           padding: const EdgeInsets.only(right: 10),
                    //           child: IconButton(
                    //               iconSize: 28,
                    //               style: ButtonStyle(
                    //                 backgroundColor: MaterialStateProperty.all(Colors.transparent),
                    //               ),
                    //               onPressed: () {
                    //                 Navigator.of(context).pop();
                    //                 cnHomepage.refresh(refreshSpotifyBar: true);
                    //               },
                    //               icon: Icon(
                    //                 Icons.fullscreen_exit,
                    //                 color: Colors.amber[800],
                    //               )
                    //           ),
                    //         ),
                    //       ),
                    //       AnimatedContainer(
                    //           duration: Duration(milliseconds: cnStopwatchWidget.animationTimeStopwatch),
                    //           transform: Matrix4.translationValues(
                    //             ///x
                    //               0,
                    //               ///y
                    //               cnStopwatchWidget.isOpened && !cnSpotifyBar.isConnected?
                    //               0 :
                    //               cnStopwatchWidget.isOpened && cnSpotifyBar.isConnected?
                    //               -cnSpotifyBar.height - 5:
                    //               -cnSpotifyBar.height,
                    //               ///z
                    //               0),
                    //           child: const StopwatchWidget()
                    //       ),
                    //       AnimatedContainer(
                    //         duration: Duration(milliseconds: cnStopwatchWidget.animationTimeStopwatch),
                    //         transform: Matrix4.translationValues(0, cnStopwatchWidget.isOpened && !cnSpotifyBar.isConnected? -cnStopwatchWidget.heightOfTimer: 0, 0),
                    //         child: const Hero(
                    //             transitionOnUserGestures: true,
                    //             tag: "SpotifyBar",
                    //             child: SpotifyBar()
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // SafeArea(
                    //   child: Stack(
                    //     alignment: Alignment.bottomRight,
                    //     children: [
                    //       Padding(
                    //         padding: EdgeInsets.only(bottom: cnSpotifyBar.height*2),
                    //         child: AnimatedContainer(
                    //           duration: Duration(milliseconds: cnSpotifyBar.animationTimeSpotifyBar),
                    //           transform: Matrix4.translationValues(0, cnStopwatchWidget.isOpened? -cnStopwatchWidget.heightOfTimer+cnSpotifyBar.height : 0, 0),
                    //           width: cnSpotifyBar.height,
                    //           height: cnSpotifyBar.height,
                    //           padding: const EdgeInsets.only(right: 10),
                    //           child: IconButton(
                    //               iconSize: 28,
                    //               style: ButtonStyle(
                    //                 backgroundColor: MaterialStateProperty.all(Colors.transparent),
                    //               ),
                    //               onPressed: () {
                    //                 Navigator.of(context).pop();
                    //                 cnHomepage.refresh(refreshSpotifyBar: true);
                    //               },
                    //               icon: Icon(
                    //                 Icons.fullscreen_exit,
                    //                 color: Colors.amber[800],
                    //               )
                    //           ),
                    //         ),
                    //       ),
                    //       AnimatedContainer(
                    //           duration: Duration(milliseconds: cnSpotifyBar.animationTimeSpotifyBar),
                    //           transform: Matrix4.translationValues(
                    //               ///x
                    //               0,
                    //               ///y
                    //               cnStopwatchWidget.isOpened && !cnSpotifyBar.isConnected?
                    //               0 :
                    //               cnStopwatchWidget.isOpened && cnSpotifyBar.isConnected?
                    //               -cnSpotifyBar.height - 5:
                    //               -cnSpotifyBar.height,
                    //               ///z
                    //               0),
                    //           child: const StopwatchWidget()
                    //       ),
                    //       AnimatedContainer(
                    //         duration: Duration(milliseconds: cnSpotifyBar.animationTimeSpotifyBar),
                    //         transform: Matrix4.translationValues(0, cnStopwatchWidget.isOpened && !cnSpotifyBar.isConnected? -cnStopwatchWidget.heightOfTimer: 0, 0),
                    //         child: const Hero(
                    //             transitionOnUserGestures: true,
                    //             tag: "SpotifyBar",
                    //             child: SpotifyBar()
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // )
                  ],
                ),
              ),
            ),
            const StandardPopUp(),
          ],
        ),
      ),
      // onPopInvoked: (doPop) async{
      //   if(doPop){
      //     cnRunningWorkout.isVisible = false;
      //     // cnHomepage.refresh(refreshSpotifyBar: true);
      //     cnSpotifyBar.refresh();
      //     cnWorkouts.refresh();
      //     cnBottomMenu.refresh();
      //   }
      //   // return true;
      // },
      // child: MaterialApp(
      //   themeMode: ThemeMode.dark,
      //   title: 'Flutter Demo',
      //   darkTheme: ThemeData.dark().copyWith(
      //       colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber[800] ?? Colors.amber),
      //       useMaterial3: true,
      //       splashFactory: InkSparkle.splashFactory
      //   ),
        // home: Scaffold(
        //   body: Stack(
        //     alignment: Alignment.center,
        //     children: [
        //       Scaffold(
        //         extendBody: true,
        //         // resizeToAvoidBottomInset: false,
        //         bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom < 50? ClipRRect(
        //           child: BackdropFilter(
        //             filter: ImageFilter.blur(
        //               sigmaX: 10.0,
        //               sigmaY: 10.0,
        //               tileMode: TileMode.mirror
        //             ),
        //             child: GestureDetector(
        //               onTap: openPopUpFinishWorkout,
        //               child: Container(
        //                 height: 70,
        //                 color: Colors.black.withOpacity(0.5),
        //                 // decoration: BoxDecoration(
        //                 //     gradient: LinearGradient(
        //                 //         begin: Alignment.topCenter,
        //                 //         end: Alignment.bottomCenter,
        //                 //         colors: [
        //                 //           Colors.black.withOpacity(0.3),
        //                 //           Colors.black.withOpacity(0.6),
        //                 //           Colors.black.withOpacity(1),
        //                 //         ]
        //                 //     )
        //                 // ),
        //                 child: Center(child: Text("Finish", style: TextStyle(color: Colors.amber[800]), textScaleFactor: 1.4,)),
        //               ),
        //             ),
        //           ),
        //         ): const SizedBox(),
        //         body: GestureDetector(
        //           onTap: (){
        //             FocusScope.of(context).unfocus();
        //           },
        //           child: Stack(
        //             children: [
        //               // const BackgroundImage(),
        //               // ImageFiltered(
        //               //     imageFilter: ImageFilter.blur(
        //               //       sigmaX: 50.0,
        //               //       sigmaY: 50.0,
        //               //     ),
        //               //     child: cnSpotifyBar.lastImage
        //               // ),
        //               Padding(
        //                 padding: const EdgeInsets.only(top:0,bottom: 0,left: 20, right: 20),
        //                 child: Column(
        //                   children: [
        //
        //                     Expanded(
        //
        //                       /// Each EXERCISE
        //                       child: ListView.separated(
        //                         // key: listViewKey,
        //                         controller: cnRunningWorkout.scrollController,
        //                         physics: const BouncingScrollPhysics(),
        //                         shrinkWrap: true,
        //                         separatorBuilder: (BuildContext context, int index) {
        //                           return Column(
        //                             children: [
        //                               const SizedBox(height: 20,),
        //                               Container(
        //                                 height: 1,
        //                                 width: double.maxFinite - 50,
        //                                 color: Colors.amber[900]!.withOpacity(0.6),
        //                               ),
        //                               const SizedBox(height: 20,),
        //                             ],
        //                           );
        //                         },
        //                         itemCount: cnRunningWorkout.groupedExercises.length,
        //                         itemBuilder: (BuildContext context, int indexExercise) {
        //                           Widget? child;
        //                           dynamic newEx = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value;
        //                           if(newEx is! Exercise){
        //                             newEx = newEx[cnRunningWorkout.selectedIndexes[cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].key]];
        //                           }
        //                           Exercise lastEx = cnRunningWorkout.lastWorkout.exercises.where((element) => element.name == newEx.name).first;
        //                           child = Column(
        //                             children: [
        //                               Align(
        //                                   alignment: Alignment.centerLeft,
        //                                   child: cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value is Exercise?
        //                                     // Text(newEx.name, textScaleFactor: 1.2,):
        //                                     ExerciseNameText(newEx.name):
        //                                     DropdownMenu<String>(
        //                                       initialSelection: newEx.name,
        //                                       onSelected: (String? value) {
        //                                         setState(() {
        //                                           final lists = cnRunningWorkout.groupedExercises.entries.toList().where((element) => element.value is List<Exercise>); ///.whereType<List>();
        //                                           final t = lists.map((element) => element.value.indexWhere((ex) {
        //                                             return ex.name == value;
        //                                           })).toList().firstWhere((element) => element >=0);
        //                                           cnRunningWorkout.selectedIndexes[cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].key] = t;
        //                                         });
        //                                       },
        //                                       dropdownMenuEntries: cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value.map<DropdownMenuEntry<String>>((Exercise value) {
        //                                         return DropdownMenuEntry<String>(value: value.name, label: value.name);
        //                                       }).toList(),
        //                                     )
        //                               ),
        //                               const SizedBox(height: 5),
        //                               Row(
        //                                 children: [
        //                                   Icon(Icons.airline_seat_recline_normal, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
        //                                   const SizedBox(width: 2,),
        //                                   if (newEx.seatLevel == null)
        //                                     const Text("-", textScaleFactor: 0.9,)
        //                                   else
        //                                     Text(newEx.seatLevel.toString(), textScaleFactor: 0.9,)
        //                                 ],
        //                               ),
        //                               Row(
        //                                 children: [
        //                                   Icon(Icons.timer, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
        //                                   const SizedBox(width: 2,),
        //                                   if (newEx.restInSeconds == 0)
        //                                     const Text("-", textScaleFactor: 0.9,)
        //                                   else if (newEx.restInSeconds < 60)
        //                                     Text("${newEx.restInSeconds}s", textScaleFactor: 0.9,)
        //                                   else if (newEx.restInSeconds % 60 != 0)
        //                                       Text("${(newEx.restInSeconds/60).floor()}:${newEx.restInSeconds%60}m", textScaleFactor: 0.9,)
        //                                     else
        //                                       Text("${(newEx.restInSeconds/60).round()}m", textScaleFactor: 0.9,),
        //                                   const SizedBox(width: 10,)
        //                                 ],
        //                               ),
        //
        //                               /// Each Set
        //                               ListView.builder(
        //                                   physics: const BouncingScrollPhysics(),
        //                                   shrinkWrap: true,
        //                                   itemCount: newEx.sets.length+1,
        //                                   itemBuilder: (BuildContext context, int indexSet) {
        //                                     if(indexSet == newEx.sets.length){
        //                                       return Row(
        //                                         children: [
        //                                           Expanded(
        //                                             child: IconButton(
        //                                                 alignment: Alignment.center,
        //                                                 color: Colors.amber[800],
        //                                                 style: ButtonStyle(
        //                                                     backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
        //                                                     shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(20)))
        //                                                 ),
        //                                                 onPressed: () {
        //                                                   addSet(newEx, lastEx);
        //                                                 },
        //                                                 icon: const Icon(
        //                                                   Icons.add,
        //                                                   size: 20,
        //                                                 )
        //                                             ),
        //                                           ),
        //                                         ],
        //                                       );
        //                                     }
        //
        //                                     SingleSet set = lastEx.sets[indexSet];
        //                                     Widget? child;
        //                                     child = Padding(
        //                                       padding: EdgeInsets.only(bottom: _setPadding, top: _setPadding),
        //                                       child: SizedBox(
        //                                         width: double.maxFinite,
        //                                         child: Row(
        //                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                                           children: [
        //                                             SizedBox(width: 80,child: Text("${indexSet + 1}", textScaleFactor: 1.2,)),
        //                                             Expanded(
        //                                               flex: 3,
        //                                               child: Row(
        //                                                 mainAxisAlignment: MainAxisAlignment.end,
        //                                                 children: [
        //                                                   Expanded(
        //                                                     child: GestureDetector(
        //                                                       onTap: (){
        //                                                         cnRunningWorkout.textControllers[newEx.name]?[indexSet][0].text = set.weight?.toString()?? "";
        //                                                         newEx.sets[indexSet].weight = set.weight;
        //                                                         cnRunningWorkout.refresh();
        //                                                       },
        //                                                       child: Container(
        //                                                         height: _heightOfSetRow,
        //                                                         color: Colors.transparent,
        //                                                         child: Center(child: Text("${set.weight?? ""}", textScaleFactor: 1.2,)),
        //                                                       ),
        //                                                     ),
        //                                                   ),
        //                                                   SizedBox(
        //                                                     width: 50,
        //                                                     height: _heightOfSetRow,
        //                                                     /// Input weight
        //                                                     child: Center(
        //                                                       child: TextField(
        //                                                         maxLength: 3,
        //                                                         textAlignVertical: TextAlignVertical.center,
        //                                                         keyboardType: TextInputType.number,
        //                                                         controller: cnRunningWorkout.textControllers[newEx.name]?[indexSet][0],
        //                                                         decoration: InputDecoration(
        //                                                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        //                                                           isDense: true,
        //                                                           counterText: "",
        //                                                         ),
        //                                                         onChanged: (value){
        //                                                           value = value.trim();
        //                                                           if(value.isNotEmpty){
        //                                                             newEx.sets[indexSet].weight = int.parse(value);
        //                                                           }
        //                                                           else{
        //                                                             newEx.sets[indexSet].weight = null;
        //                                                           }
        //                                                         },
        //                                                       ),
        //                                                     ),
        //                                                   ),
        //                                                 ],
        //                                               ),
        //                                             ),
        //                                             const Spacer(flex: 1),
        //                                             Expanded(
        //                                               flex: 3,
        //                                               child: Row(
        //                                                 mainAxisAlignment: MainAxisAlignment.end,
        //                                                 children: [
        //                                                   Expanded(
        //                                                     child: GestureDetector(
        //                                                       onTap: (){
        //                                                         cnRunningWorkout.textControllers[newEx.name]?[indexSet][1].text = set.amount?.toString()?? "";
        //                                                         newEx.sets[indexSet].amount = set.amount;
        //                                                         cnRunningWorkout.refresh();
        //                                                       },
        //                                                       child: Container(
        //                                                         height: _heightOfSetRow,
        //                                                         color: Colors.transparent,
        //                                                         child: Center(child: Text("${set.amount?? ""}", textScaleFactor: 1.2,)),
        //                                                       ),
        //                                                     ),
        //                                                   ),
        //                                                   SizedBox(
        //                                                     width: 50,
        //                                                     height: _heightOfSetRow,
        //
        //                                                     /// Input amount
        //                                                     child: Center(
        //                                                       child: TextField(
        //                                                         maxLength: 3,
        //                                                         textAlignVertical: TextAlignVertical.center,
        //                                                         keyboardType: TextInputType.number,
        //                                                         controller: cnRunningWorkout.textControllers[newEx.name]?[indexSet][1],
        //                                                         decoration: InputDecoration(
        //                                                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        //                                                           isDense: true,
        //                                                           counterText: "",
        //                                                         ),
        //                                                         onChanged: (value){
        //                                                           value = value.trim();
        //                                                           if(value.isNotEmpty){
        //                                                             newEx.sets[indexSet].amount = int.parse(value);
        //                                                           }
        //                                                           else{
        //                                                             newEx.sets[indexSet].amount = null;
        //                                                           }
        //                                                         },
        //                                                       ),
        //                                                     ),
        //                                                   ),
        //                                                 ],
        //                                               ),
        //                                             ),
        //                                             const SizedBox(width: 25,)
        //                                           ],
        //                                         ),
        //                                       ),
        //                                     );
        //
        //                                     return Slidable(
        //                                       key: cnRunningWorkout.slideableKeys[newEx.name]![indexSet],
        //                                       // key: UniqueKey(),
        //                                       startActionPane: ActionPane(
        //                                         motion: const ScrollMotion(),
        //                                         dismissible: DismissiblePane(
        //                                             onDismissed: () {
        //                                               dismiss(newEx, lastEx, indexSet);
        //                                             }),
        //                                         children: [
        //                                           SlidableAction(
        //                                           flex:10,
        //                                             onPressed: (BuildContext context){
        //                                               dismiss(newEx, lastEx, indexSet);
        //                                             },
        //                                             borderRadius: BorderRadius.circular(15),
        //                                             backgroundColor: Color(0xFFA12D2C),
        //                                             foregroundColor: Colors.white,
        //                                             icon: Icons.delete,
        //                                           ),
        //                                           SlidableAction(
        //                                             flex: 1,
        //                                             onPressed: (BuildContext context){},
        //                                             backgroundColor: Colors.transparent,
        //                                             foregroundColor: Colors.transparent,
        //                                             label: '',
        //                                           ),
        //                                         ],
        //                                       ),
        //                                       child: child,
        //                                     );
        //                                   }
        //                               ),
        //                             ],
        //                           );
        //
        //                           /// Top Spacer
        //                           if (indexExercise == 0){
        //                             child = Column(
        //                               children: [
        //                                 const SizedBox(height: 90,),
        //                                 child
        //                               ],
        //                             );
        //                           }
        //
        //                           /// Bottom Spacer
        //                           if (indexExercise == cnRunningWorkout.groupedExercises.length-1){
        //                             child = Column(
        //                               children: [
        //                                 child,
        //                                 const SizedBox(height: 70,)
        //                               ],
        //                             );
        //                           }
        //
        //                           return child;
        //                         },
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //               ClipRRect(
        //                 // borderRadius: BorderRadius.circular(15),
        //                 child: BackdropFilter(
        //                     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10, tileMode: TileMode.mirror),
        //                     child: Container(
        //                       // margin: const EdgeInsets.only(bottom: 30),
        //                       height: 130,
        //                       width: double.maxFinite,
        //                       color: Colors.black.withOpacity(0.5),
        //                       // decoration: BoxDecoration(
        //                       //   // color: Colors.black.withOpacity(0.5),
        //                       //   // borderRadius: BorderRadius.circular(10),
        //                       //     gradient: LinearGradient(
        //                       //         begin: Alignment.topCenter,
        //                       //         end: Alignment.bottomCenter,
        //                       //         colors: [
        //                       //           // Colors.black.withOpacity(0.4),
        //                       //           Colors.black.withOpacity(1),
        //                       //           Colors.black.withOpacity(0.3),
        //                       //         ]
        //                       //     )
        //                       // ),
        //                       child: Column(
        //                         children: [
        //                           const SafeArea(
        //                             bottom: false,
        //                             child: SizedBox(),
        //                           ),
        //                           Padding(
        //                             padding: const EdgeInsets.only(left: 20, right: 20),
        //                             child: Column(
        //                               children: [
        //                                 Text(cnRunningWorkout.workout.name, textScaleFactor: 1.4, style: TextStyle(fontWeight: FontWeight.bold)),
        //                                 const SizedBox(height: 10,),
        //                                 const Row(
        //                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                                   children: [
        //                                     Text("Set", textScaleFactor: 1),
        //                                     SizedBox(width: 20,),
        //                                     Text("Weight", textScaleFactor: 1),
        //                                     SizedBox(width: 1,),
        //                                     Text("Amount", textScaleFactor: 1),
        //                                     SizedBox(width: 1,)
        //                                   ],
        //                                 ),
        //                               ],
        //                             ),
        //                           ),
        //                         ],
        //                       ),
        //                     ),
        //                 ),
        //               ),
        //               if(MediaQuery.of(context).viewInsets.bottom < 50)
        //                 // Stack(
        //                 //   children: [
        //                 //     AnimatedContainer(
        //                 //       duration: Duration(milliseconds: cnSpotifyBar.animationTimeSpotifyBar),
        //                 //       transform: Matrix4.translationValues(0, 0, 0),
        //                 //       child: const Hero(
        //                 //           transitionOnUserGestures: true,
        //                 //           tag: "SpotifyBar",
        //                 //           child: SpotifyBar()
        //                 //       ),
        //                 //     ),
        //                 //     AnimatedContainer(
        //                 //         duration: Duration(milliseconds: cnSpotifyBar.animationTimeSpotifyBar),
        //                 //         transform: Matrix4.translationValues(0, -cnSpotifyBar.height, 0),
        //                 //         child: const StopwatchWidget()
        //                 //     ),
        //                 //   ],
        //                 // ),
        //                 AnimatedColumn(),
        //                 // SafeArea(
        //                 //   child: Stack(
        //                 //     alignment: Alignment.bottomRight,
        //                 //     children: [
        //                 //       Padding(
        //                 //         padding: EdgeInsets.only(bottom: cnSpotifyBar.height*2),
        //                 //         child: AnimatedContainer(
        //                 //           duration: Duration(milliseconds: cnStopwatchWidget.animationTimeStopwatch),
        //                 //           transform: Matrix4.translationValues(0, cnStopwatchWidget.isOpened? -cnStopwatchWidget.heightOfTimer+cnSpotifyBar.height : 0, 0),
        //                 //           width: cnSpotifyBar.height,
        //                 //           height: cnSpotifyBar.height,
        //                 //           padding: const EdgeInsets.only(right: 10),
        //                 //           child: IconButton(
        //                 //               iconSize: 28,
        //                 //               style: ButtonStyle(
        //                 //                 backgroundColor: MaterialStateProperty.all(Colors.transparent),
        //                 //               ),
        //                 //               onPressed: () {
        //                 //                 Navigator.of(context).pop();
        //                 //                 cnHomepage.refresh(refreshSpotifyBar: true);
        //                 //               },
        //                 //               icon: Icon(
        //                 //                 Icons.fullscreen_exit,
        //                 //                 color: Colors.amber[800],
        //                 //               )
        //                 //           ),
        //                 //         ),
        //                 //       ),
        //                 //       AnimatedContainer(
        //                 //           duration: Duration(milliseconds: cnStopwatchWidget.animationTimeStopwatch),
        //                 //           transform: Matrix4.translationValues(
        //                 //             ///x
        //                 //               0,
        //                 //               ///y
        //                 //               cnStopwatchWidget.isOpened && !cnSpotifyBar.isConnected?
        //                 //               0 :
        //                 //               cnStopwatchWidget.isOpened && cnSpotifyBar.isConnected?
        //                 //               -cnSpotifyBar.height - 5:
        //                 //               -cnSpotifyBar.height,
        //                 //               ///z
        //                 //               0),
        //                 //           child: const StopwatchWidget()
        //                 //       ),
        //                 //       AnimatedContainer(
        //                 //         duration: Duration(milliseconds: cnStopwatchWidget.animationTimeStopwatch),
        //                 //         transform: Matrix4.translationValues(0, cnStopwatchWidget.isOpened && !cnSpotifyBar.isConnected? -cnStopwatchWidget.heightOfTimer: 0, 0),
        //                 //         child: const Hero(
        //                 //             transitionOnUserGestures: true,
        //                 //             tag: "SpotifyBar",
        //                 //             child: SpotifyBar()
        //                 //         ),
        //                 //       ),
        //                 //     ],
        //                 //   ),
        //                 // ),
        //                 // SafeArea(
        //                 //   child: Stack(
        //                 //     alignment: Alignment.bottomRight,
        //                 //     children: [
        //                 //       Padding(
        //                 //         padding: EdgeInsets.only(bottom: cnSpotifyBar.height*2),
        //                 //         child: AnimatedContainer(
        //                 //           duration: Duration(milliseconds: cnSpotifyBar.animationTimeSpotifyBar),
        //                 //           transform: Matrix4.translationValues(0, cnStopwatchWidget.isOpened? -cnStopwatchWidget.heightOfTimer+cnSpotifyBar.height : 0, 0),
        //                 //           width: cnSpotifyBar.height,
        //                 //           height: cnSpotifyBar.height,
        //                 //           padding: const EdgeInsets.only(right: 10),
        //                 //           child: IconButton(
        //                 //               iconSize: 28,
        //                 //               style: ButtonStyle(
        //                 //                 backgroundColor: MaterialStateProperty.all(Colors.transparent),
        //                 //               ),
        //                 //               onPressed: () {
        //                 //                 Navigator.of(context).pop();
        //                 //                 cnHomepage.refresh(refreshSpotifyBar: true);
        //                 //               },
        //                 //               icon: Icon(
        //                 //                 Icons.fullscreen_exit,
        //                 //                 color: Colors.amber[800],
        //                 //               )
        //                 //           ),
        //                 //         ),
        //                 //       ),
        //                 //       AnimatedContainer(
        //                 //           duration: Duration(milliseconds: cnSpotifyBar.animationTimeSpotifyBar),
        //                 //           transform: Matrix4.translationValues(
        //                 //               ///x
        //                 //               0,
        //                 //               ///y
        //                 //               cnStopwatchWidget.isOpened && !cnSpotifyBar.isConnected?
        //                 //               0 :
        //                 //               cnStopwatchWidget.isOpened && cnSpotifyBar.isConnected?
        //                 //               -cnSpotifyBar.height - 5:
        //                 //               -cnSpotifyBar.height,
        //                 //               ///z
        //                 //               0),
        //                 //           child: const StopwatchWidget()
        //                 //       ),
        //                 //       AnimatedContainer(
        //                 //         duration: Duration(milliseconds: cnSpotifyBar.animationTimeSpotifyBar),
        //                 //         transform: Matrix4.translationValues(0, cnStopwatchWidget.isOpened && !cnSpotifyBar.isConnected? -cnStopwatchWidget.heightOfTimer: 0, 0),
        //                 //         child: const Hero(
        //                 //             transitionOnUserGestures: true,
        //                 //             tag: "SpotifyBar",
        //                 //             child: SpotifyBar()
        //                 //         ),
        //                 //       ),
        //                 //     ],
        //                 //   ),
        //                 // )
        //             ],
        //           ),
        //         ),
        //       ),
        //       const StandardPopUp(),
        //     ],
        //   ),
        // ),
      // ),
    );
  }

  void addSet(Exercise ex, Exercise lastEx){
    setState(() {
      ex.addSet();
      lastEx.addSet();
      cnRunningWorkout.textControllers[ex.name]?.add([TextEditingController(), TextEditingController()]);
      cnRunningWorkout.slideableKeys[ex.name]?.add(UniqueKey());
      cnRunningWorkout.scrollController.jumpTo(cnRunningWorkout.scrollController.position.pixels+_heightOfSetRow + _setPadding*2);
    });
  }

  void dismiss(Exercise ex, Exercise lastEx, int index){
    setState(() {
      ex.sets.removeAt(index);
      lastEx.sets.removeAt(index);
      cnRunningWorkout.textControllers[ex.name]?.removeAt(index);
      cnRunningWorkout.slideableKeys[ex.name]?.removeAt(index);
    });
  }

  void openPopUpFinishWorkout(){
    cnStandardPopUp.open(
        child: Column(
          children: [
            const Text(
                "Finish Workout?",
              textAlign: TextAlign.center,
              textScaleFactor: 1.2,
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20,),
            Container(
              height: 0.5,
              width: double.maxFinite,
              color: Colors.grey[700]!.withOpacity(0.5),
            ),
            SizedBox(
              height: 40,
              width: double.maxFinite,
              child: ElevatedButton(
                  onPressed: () => finishWorkout(doUpdate: true),
                  style: ButtonStyle(
                      shadowColor: MaterialStateProperty.all(Colors.transparent),
                      surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
                  ),
                  child: const Text(
                    "Finish And Update Template"
                  ),
              ),
            ),
          ],
      ),
      confirmText: "Finish",
      onConfirm: finishWorkout,
      padding: const EdgeInsets.only(top: 20)
    );
  }

  void finishWorkout({bool doUpdate = false}){
    cnStandardPopUp.clear();
    Future.delayed(const Duration(milliseconds: 500), (){
      cnRunningWorkout.workout.refreshDate();
      cnRunningWorkout.removeNotSelectedExercises();
      cnRunningWorkout.workout.removeEmptyExercises();
      if(cnRunningWorkout.workout.exercises.isNotEmpty){
        cnRunningWorkout.workout.saveToDatabase();
        if(doUpdate){
          cnRunningWorkout.workout.updateTemplate();
        }
        cnWorkouts.refreshAllWorkouts();
      }
      cnRunningWorkout.clear();
      cnRunningWorkout.isVisible = false;
      // cnHomepage.refresh(refreshSpotifyBar: true);
      cnWorkouts.refresh();
      cnBottomMenu.refresh();
      Future.delayed(const Duration(milliseconds: 100), (){
        Navigator.of(context).pop();
        cnHomepage.refresh();
        cnSpotifyBar.refresh();
      });
    });
  }
}

class CnRunningWorkout extends ChangeNotifier {
  Workout workout = Workout();
  Workout lastWorkout = Workout();
  bool isRunning = false;
  bool isVisible = false;
  ScrollController scrollController = ScrollController();
  late Map<String, List<Key>> slideableKeys = {
    for (var e in workout.exercises)
      e.name :
      e.generateKeyForEachSet()
  };
  late Map<String, List<List<TextEditingController>>> textControllers = {
    for (var e in workout.exercises)
      e.name :
      e.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList()
  };
  /// Contains all Excercises - linked and non linked ones - as a Map
  /// linked exercises are saved as another Map with key = linkName
  /// non linked Excercises are saved as the exercise itself with the ex.name as the key
  Map groupedExercises = {};
  /// Contains for each linked exercise the currently selected index for getting the right one
  /// from the groupedExercises Map
  Map<String, int> selectedIndexes = {};

  void openRunningWorkout(BuildContext context, Workout w){
    setLastWorkout(w);
    isRunning = true;
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => const ScreenRunningWorkout()
        ));
    isVisible = true;
  }

  void reopenRunningWorkout(BuildContext context){
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => const ScreenRunningWorkout()
        ));
    isVisible = true;
  }
  
  void removeNotSelectedExercises(){
    for (MapEntry entry in List.from(groupedExercises.entries)){
      if(entry.value is Exercise) continue;
      groupedExercises[entry.key] = groupedExercises[entry.key][selectedIndexes[entry.key]];
    }
    workout.exercises = List.from(groupedExercises.entries.map((entry) => entry.value));
  }

  // void closeRunningWorkout(BuildContext context){
  //   Navigator.pop(context);
  // }

  void setLastWorkout(Workout w){
    lastWorkout = w;

    workout = Workout.copy(lastWorkout);
    workout.resetAllExercisesSets();
    print("workout ${workout.linkedExercises}");
    print("lastWorkout ${workout.linkedExercises}");

    slideableKeys = {
      for (var e in workout.exercises)
        e.name :
        e.generateKeyForEachSet()
    };

    selectedIndexes = {
      for (String link in workout.linkedExercises)
        link:
        0
    };

    groupedExercises.clear();
    for (Exercise ex in workout.exercises){
      if (ex.linkName == null){
        groupedExercises[ex.name] = ex;
      }
      else if(!groupedExercises.containsKey(ex.linkName)){
        groupedExercises[ex.linkName] = [ex];
      }
      else{
        groupedExercises[ex.linkName] = groupedExercises[ex.linkName] + [ex];
      }
    }

    textControllers = {
      for (var e in workout.exercises)
        e.name :
        e.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList()
    };
  }

  void clear(){
    print("clear");
    workout = Workout();
    textControllers.clear();
    slideableKeys.clear();
    selectedIndexes.clear();
    groupedExercises.clear();
    scrollController = ScrollController();
    isRunning = false;
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}