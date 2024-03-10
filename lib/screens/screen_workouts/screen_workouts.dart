import 'dart:ui';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/screen_workouts/panels/new_workout_panel.dart';
import 'package:fitness_app/screens/screen_workouts/screen_running_workout.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../objectbox.g.dart';
import '../../objects/workout.dart';
import '../../util/objectbox/ob_workout.dart';
import '../../widgets/workout_expansion_tile.dart';

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

  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    cnWorkouts = Provider.of<CnWorkouts>(context);
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height,
      child: Stack(
        children: [
          ListView.builder(
              addAutomaticKeepAlives: true,
              physics: const BouncingScrollPhysics(),
              key: cnWorkouts.key,
              controller: cnWorkouts.scrollController,
              itemCount: cnWorkouts.workouts.length+1,
              itemBuilder: (BuildContext context, int index) {
                if (index == cnWorkouts.workouts.length){
                  return const SizedBox(height: 100);
                }
                return WorkoutExpansionTile(
                    workout: cnWorkouts.workouts[index],
                    padding: EdgeInsets.only(top: index == 0? 30 : 10, left: 20, right: 20, bottom: 10),
                    onExpansionChange: (bool isOpen) => cnWorkouts.opened[index] = isOpen,
                    initiallyExpanded: cnWorkouts.opened[index],
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
                              backgroundColor: MaterialStateProperty.all(Colors.transparent),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                          ),
                          onPressed: () {
                            if(cnNewWorkout.isUpdating){
                              cnNewWorkout.clear();
                            }
                            cnNewWorkout.workout.isTemplate = true;
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
              const SizedBox(height: 75),
            ],
          ),
        ],
      ),
    );
  }
}

class CnWorkouts extends ChangeNotifier {
  List<Workout> workouts = [];
  Key key = UniqueKey();
  List<bool> opened = [];
  ScrollController scrollController = ScrollController();

  void refreshAllWorkouts(){
    List<ObWorkout> obWorkouts = objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(true)).build().find();
    workouts.clear();

    for (var w in obWorkouts) {
      workouts.add(Workout.fromObWorkout(w));
    }
    opened = workouts.map((e) => false).toList();
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}