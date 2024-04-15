import 'package:fitness_app/main.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/screens/screen_workouts/panels/new_workout_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../objects/workout.dart';
import '../../util/objectbox/ob_workout.dart';
import '../../widgets/workout_expansion_tile.dart';
import '../screen_workouts/screen_running_workout.dart';

class ScreenWorkoutHistory extends StatefulWidget {
  const ScreenWorkoutHistory({super.key});

  @override
  State<ScreenWorkoutHistory> createState() => _ScreenWorkoutHistoryState();
}

class _ScreenWorkoutHistoryState extends State<ScreenWorkoutHistory> {

  late CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnWorkoutHistory cnWorkoutHistory;

  @override
  Widget build(BuildContext context) {
    cnWorkoutHistory = Provider.of<CnWorkoutHistory>(context);
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height,
      child: Stack(
        children: [
          ListView.separated(
              padding: const EdgeInsets.only(top: 70, left: 20, right: 20, bottom: 0),
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 10);
              },
              addAutomaticKeepAlives: true,
              physics: const BouncingScrollPhysics(),
              key: cnWorkoutHistory.key,
              controller: cnWorkoutHistory.scrollController,
              itemCount: cnWorkoutHistory.workouts.length+1,
              itemBuilder: (BuildContext context, int index) {
                if (index == cnWorkoutHistory.workouts.length){
                  return const SizedBox(height: 150);
                }
                return WorkoutExpansionTile(
                    workout: cnWorkoutHistory.workouts[index],
                    // padding: EdgeInsets.only(top: index == 0? cnRunningWorkout.isRunning? 20:70 : 10, left: 20, right: 20, bottom: 0),
                    padding: EdgeInsets.zero,
                    onExpansionChange: (bool isOpen) => cnWorkoutHistory.opened[index] = isOpen,
                    initiallyExpanded: cnWorkoutHistory.opened[index]
                );
              },
          ),
        ],
      ),
    );
  }
}

class CnWorkoutHistory extends ChangeNotifier {
  List<Workout> workouts = [];
  Key key = UniqueKey();
  List<bool> opened = [];
  ScrollController scrollController = ScrollController();

  void refreshAllWorkouts(){
    workouts.clear();
    // final builder = objectbox.workoutBox.query().order(ObWorkout_.date, flags: Order.descending).build();
    final builder = objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(false)).order(ObWorkout_.date, flags: Order.descending).build();
    List<ObWorkout> obWorkouts = builder.find();

    for (var w in obWorkouts) {
      workouts.add(Workout.fromObWorkout(w));
    }
    opened = workouts.map((e) => false).toList();

    // double pos = scrollController.position.pixels;
    refresh();
    // scrollController.jumpTo(pos);
  }

  void refresh(){
    notifyListeners();
  }
}