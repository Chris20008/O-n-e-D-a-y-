import 'dart:ui';

import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/screen_workouts/panels/new_exercise_panel.dart';
import 'package:fitness_app/screens/screen_workouts/panels/new_workout_panel.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:fitness_app/widgets/exerciseRow.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../objects/workout.dart';
import '../../util/objectbox/ob_workout.dart';

class ScreenWorkout extends StatefulWidget {
  const ScreenWorkout({super.key});

  @override
  State<ScreenWorkout> createState() => _ScreenWorkoutState();
}

class _ScreenWorkoutState extends State<ScreenWorkout> {

  late CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  late CnWorkouts cnWorkouts;

  @override
  Widget build(BuildContext context) {
    cnWorkouts = Provider.of<CnWorkouts>(context);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: ListView.builder(
              addAutomaticKeepAlives: true,
              physics: const BouncingScrollPhysics(),
              key: cnWorkouts.key,
              itemCount: cnWorkouts.workouts.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      // color: Colors.transparent,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.transparent,
                          // focusColor: Colors.transparent,
                          // hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          dividerColor: Colors.transparent,
                        ),
                        // child: Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Padding(
                        //         padding: const EdgeInsets.only(left: 10, top: 10),
                        //         child: Text(
                        //           cnWorkouts.workouts[index].name?? "Unknown Workout",
                        //           textScaleFactor: 1.5,
                        //           style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        //         )
                        //       // child: Text(
                        //       //   cnWorkouts.workouts[index].name?? "Unknown Workout",
                        //       //   textScaleFactor: 1.5,
                        //       //   style: const TextStyle(fontWeight: FontWeight.bold),
                        //       // )
                        //     ),
                        //     // LimitedBox(
                        //     //   maxHeight: 500,
                        //     //   child: ListView.builder(
                        //     //       physics: const BouncingScrollPhysics(),
                        //     //       shrinkWrap: true,
                        //     //       itemCount: cnWorkouts.workouts[index].exercises.length,
                        //     //       itemBuilder: (BuildContext context, int index) {
                        //     //         return exerciseRow(
                        //     //           exercise: cnWorkouts.workouts[index].exercises[index],
                        //     //           textScaleFactor: 1.3,
                        //     //           padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        //     //         );
                        //     //       }
                        //     //   ),
                        //     // )
                        //   ],
                        // ),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          title: Padding(
                              padding: const EdgeInsets.only(left: 10, top: 10),
                              child: Text(
                                cnWorkouts.workouts[index].name?? "Unknown Workout",
                                textScaleFactor: 1.5,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              )
                              // child: Text(
                              //   cnWorkouts.workouts[index].name?? "Unknown Workout",
                              //   textScaleFactor: 1.5,
                              //   style: const TextStyle(fontWeight: FontWeight.bold),
                              // )
                          ),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LimitedBox(
                                  maxHeight: 500,
                                  child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: cnWorkouts.workouts[index].exercises.length,
                                      itemBuilder: (BuildContext context, int index_exercide) {
                                        return exerciseRow(
                                          exercise: cnWorkouts.workouts[index].exercises[index_exercide],
                                          textScaleFactor: 1.3,
                                          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                        );
                                      }
                                  ),
                                )
                              ],
                            ),
                          ]
                        ),
                      ),
                    ),
                  ),
                );
              }
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5.0,
                  sigmaY: 5.0,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: IconButton(
                      iconSize: 30,
                      style: ButtonStyle(
                          // backgroundColor: MaterialStateProperty.all(Colors.grey[400]),
                          // backgroundColor: MaterialStateProperty.all(Colors.amber[200]),
                          backgroundColor: MaterialStateProperty.all(Colors.transparent),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                      ),
                      onPressed: () {
                        // objectbox.workoutBox.query(ObWorkout_.name.equals("Test2")).build().remove();
                        // objectbox.workoutBox.remove(id);
                        // cnWorkouts.refreshAllWorkouts();
                        cnNewWorkout.openPanel();
                      },
                      icon: Icon(
                          Icons.add,
                        color: Colors.amber[800],
                      )
                  ),
                ),
              ),
            ),
            Container(height: 65)
          ],
        ),
        const NewWorkOutPanel(),
        const NewExercisePanel(),
      ],
    );
  }
}

class CnWorkouts extends ChangeNotifier {
  List<Workout> workouts = [];
  Key key = UniqueKey();

  void refreshAllWorkouts(){
    List<ObWorkout> obWorkouts = objectbox.workoutBox.getAll();
    workouts.clear();
    for(ObWorkout obWorkout in obWorkouts){
      workouts.add(Workout.fromObWorkout(obWorkout));
    }
    key = UniqueKey();
    refresh();
  }

  void clear(){
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}