import 'package:fitness_app/main.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/screens/screen_workouts/panels/new_workout_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../objects/workout.dart';
import '../../util/objectbox/ob_workout.dart';
import '../../widgets/workout_expansion_tile.dart';

class ScreenWorkoutHistory extends StatefulWidget {
  const ScreenWorkoutHistory({super.key});

  @override
  State<ScreenWorkoutHistory> createState() => _ScreenWorkoutHistoryState();
}

class _ScreenWorkoutHistoryState extends State<ScreenWorkoutHistory> {

  late CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  late CnWorkoutHistory cnWorkoutHistory;

  @override
  Widget build(BuildContext context) {
    cnWorkoutHistory = Provider.of<CnWorkoutHistory>(context);
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height,
      child: Stack(
        children: [
          ListView.builder(
              addAutomaticKeepAlives: true,
              physics: const BouncingScrollPhysics(),
              key: cnWorkoutHistory.key,
              controller: cnWorkoutHistory.scrollController,
              itemCount: cnWorkoutHistory.workouts.length+1,
              itemBuilder: (BuildContext context, int index) {
                if (index == cnWorkoutHistory.workouts.length){
                  return const SizedBox(height: 100);
                }
                return WorkoutExpansionTile(
                    workout: cnWorkoutHistory.workouts[index],
                    padding: EdgeInsets.only(top: index == 0? 30 : 10, left: 20, right: 20, bottom: 10),
                    onExpansionChange: (bool isOpen) => cnWorkoutHistory.opened[index] = isOpen,
                    initiallyExpanded: cnWorkoutHistory.opened[index]
                );
                // return Padding(
                //   padding: EdgeInsets.only(top: index == 0? 30 : 10, left: 20, right: 20, bottom: 10),
                //   child: ClipRRect(
                //     borderRadius: BorderRadius.circular(15),
                //     child: Container(
                //       color: Colors.black.withOpacity(0.3),
                //       child: Theme(
                //         data: Theme.of(context).copyWith(
                //           splashColor: Colors.transparent,
                //           highlightColor: Colors.transparent,
                //           dividerColor: Colors.transparent,
                //         ),
                //         child: ExpansionTile(
                //           tilePadding: const EdgeInsets.only(left: 10, right: 20),
                //           onExpansionChanged: (bool isOpen){
                //             cnWorkoutHistory.opened[index] = isOpen;
                //           },
                //           initiallyExpanded: cnWorkoutHistory.opened[index],
                //           title: Row(
                //             children: [
                //               Text(
                //                 cnWorkoutHistory.workouts[index].name,
                //                 textScaleFactor: 1.7,
                //                 style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                //               ),
                //               const Expanded(child: SizedBox()),
                //               IconButton(
                //                   onPressed: (){
                //                     editWorkout(Workout.clone(cnWorkoutHistory.workouts[index]));
                //                   },
                //                   icon: Icon(Icons.edit,
                //                   color: Colors.grey.withOpacity(0.4),
                //                   )
                //               )
                //             ],
                //           ),
                //           children: [
                //             Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 LimitedBox(
                //                   maxHeight: 1000,
                //                   child: MultipleExerciseRow(
                //                       exercises: cnWorkoutHistory.workouts[index].exercises,
                //                       textScaleFactor: 1.3,
                //                       padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                //                   )
                //                 )
                //               ],
                //             ),
                //           ]
                //         ),
                //       ),
                //     ),
                //   ),
                // );
              }
          ),
        ],
      ),
    );
  }

  // void editWorkout(Workout workout){
  //   Workout w = Workout.clone(workout);
  //   print("WORKOUT ID in history: ${workout.id}");
  //   if(cnNewWorkout.isUpdating && cnNewWorkout.workout.id == w.id){
  //     cnNewWorkout.openPanel();
  //   }
  //   else{
  //     cnNewWorkout.clear(doRefresh: false);
  //     cnNewWorkout.isUpdating = true;
  //     cnNewWorkout.setWorkout(w);
  //     cnNewWorkout.updateExercisesAndLinksList();
  //     cnNewWorkout.initializeCorrectOrder();
  //     cnNewWorkout.openPanel();
  //   }
  // }
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