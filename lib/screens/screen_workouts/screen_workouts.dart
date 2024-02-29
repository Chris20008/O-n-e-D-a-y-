import 'dart:ui';

import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/screen_workouts/panels/new_exercise_panel.dart';
import 'package:fitness_app/screens/screen_workouts/panels/new_workout_panel.dart';
import 'package:fitness_app/screens/screen_workouts/screen_running_workout.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:fitness_app/widgets/multipleExerciseRow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnWorkouts cnWorkouts;

  @override
  Widget build(BuildContext context) {
    cnWorkouts = Provider.of<CnWorkouts>(context);

    return Stack(
      children: [
        ListView.builder(
            addAutomaticKeepAlives: true,
            physics: const BouncingScrollPhysics(),
            key: cnWorkouts.key,
            controller: cnWorkouts.scrollController,
            itemCount: cnWorkouts.workouts.length+1,
            itemBuilder: (BuildContext context, int index) {
              if (index == cnWorkouts.workouts.length){
                return SizedBox(height: 100);
              }
              return Padding(
                padding: EdgeInsets.only(top: index == 0? 30 : 10, left: 20, right: 20, bottom: 10),
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
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.only(left: 10, right: 20),
                        onExpansionChanged: (bool isOpen){
                          cnWorkouts.opened[index] = isOpen;
                        },
                        initiallyExpanded: cnWorkouts.opened[index],
                        title: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cnWorkouts.workouts[index].name,
                              textScaleFactor: 1.7,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              // style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber[800]!.withOpacity(0.45)),
                            ),
                            const Expanded(child: SizedBox()),
                            IconButton(
                                onPressed: (){
                                  cnRunningWorkout.openRunningWorkout(context, Workout.clone(cnWorkouts.workouts[index]));
                                  // editWorkout(Workout.clone(cnWorkouts.workouts[index]));
                                },
                                icon: Icon(Icons.play_arrow,
                                  color: Colors.grey.withOpacity(0.4),
                                )
                            ),
                            IconButton(
                                onPressed: (){
                                  editWorkout(Workout.clone(cnWorkouts.workouts[index]));
                                },
                                icon: Icon(Icons.edit,
                                color: Colors.grey.withOpacity(0.4),
                                )
                            )
                          ],
                        ),
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LimitedBox(
                                maxHeight: 1000,
                                child: MultipleExerciseRow(
                                    // exercises: [cnWorkouts.workouts[index].exercises[0]],
                                    exercises: cnWorkouts.workouts[index].exercises,
                                    textScaleFactor: 1.3,
                                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                )
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
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Center(
              child: ClipRRect(
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
                          if(cnNewWorkout.isUpdating){
                            cnNewWorkout.clear();
                          }
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
            ),

            /// Space to be over bottom navigation bar
            const SizedBox(height: 65)
          ],
        ),
        const NewWorkOutPanel(),
        const NewExercisePanel(),
      ],
    );
  }

  void editWorkout(Workout workout){
    if(cnNewWorkout.isUpdating && cnNewWorkout.workout.id == workout.id){
      cnNewWorkout.openPanel();
    }
    else{
      cnNewWorkout.isUpdating = true;
      cnNewWorkout.setWorkout(workout);
      cnNewWorkout.openPanel();
    }
  }
}

class CnWorkouts extends ChangeNotifier {
  List<Workout> workouts = [];
  Key key = UniqueKey();
  List<bool> opened = [];
  ScrollController scrollController = ScrollController();

  void refreshAllWorkouts(){
    double pos1 = scrollController.position.pixels;
    print("--------------------------- POSITION $pos1");

    List<ObWorkout> obWorkouts = objectbox.workoutBox.getAll();
    workouts.clear();
    List<bool> newOpened = [];
    for(ObWorkout obWorkout in obWorkouts){
      workouts.add(Workout.fromObWorkout(obWorkout));
      newOpened.add(false);
    }

    /// Exercise has been added
    if(opened.length < newOpened.length){
      /// keep opened state of current ExpansionsTiles and add new ones with opened = false
      opened = opened + newOpened.sublist(opened.length);
    }
    /// Exercise could have been removed
    else{
      opened = opened.sublist(0, obWorkouts.length);
    }
    double pos = scrollController.position.pixels;
    print("--------------------------- POSITION $pos");
    // key = UniqueKey();
    refresh();
    scrollController.jumpTo(pos);
  }

  void refresh(){
    notifyListeners();
  }
}