import 'package:fitness_app/main.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import '../../../objects/workout.dart';
import '../../../util/objectbox/ob_workout.dart';
import '../../../widgets/spotify_bar.dart';
import '../../../widgets/workout_expansion_tile.dart';
import '../screen_workouts/panels/new_workout_panel.dart';
import '../../screen_running_workout/screen_running_workout.dart';

class ScreenWorkoutHistory extends StatefulWidget {
  const ScreenWorkoutHistory({super.key});

  @override
  State<ScreenWorkoutHistory> createState() => _ScreenWorkoutHistoryState();
}

class _ScreenWorkoutHistoryState extends State<ScreenWorkoutHistory> {

  late CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  late CnWorkoutHistory cnWorkoutHistory;
  // List<Widget> children = [];

  @override
  Widget build(BuildContext context) {
    cnWorkoutHistory = Provider.of<CnWorkoutHistory>(context);
    final size = MediaQuery.of(context).size;
    // createListViewChildren();

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
                  return SafeArea(
                      top: false,
                      left: false,
                      right: false,
                      child: AnimatedContainer(
                        height: cnSpotifyBar.height + 20 + (cnNewWorkout.minPanelHeight > 0? cnNewWorkout.minPanelHeight-MediaQuery.paddingOf(context).bottom : 0),
                        duration: const Duration(milliseconds: 300),
                      )
                  );
                }
                final dateOfWorkout = cnWorkoutHistory.workouts[index].date;
                final DateTime? dateOfNewerWorkout = index > 0 ? cnWorkoutHistory.workouts[index-1].date : null;
                Widget child = WorkoutExpansionTile(
                    workout: cnWorkoutHistory.workouts[index],
                    // padding: EdgeInsets.only(top: index == 0? cnRunningWorkout.isRunning? 20:70 : 10, left: 20, right: 20, bottom: 0),
                    padding: EdgeInsets.zero,
                    onExpansionChange: (bool isOpen) => cnWorkoutHistory.opened[index] = isOpen,
                    initiallyExpanded: cnWorkoutHistory.opened[index]
                );

                /// check if date is not null
                if (dateOfWorkout != null) {

                  if(dateOfWorkout.isToday()){
                    if(dateOfNewerWorkout == null){
                      child = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              "Today",
                              textScaler: TextScaler.linear(1.8),
                            ),
                          ),
                          const SizedBox(height: 5),
                          child
                        ],
                      );
                    }
                    return child;
                  }

                  else if(dateOfWorkout.isInLastSevenDays() &&
                      (dateOfNewerWorkout == null || dateOfNewerWorkout.isToday())
                  ){
                    child = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(dateOfNewerWorkout != null)
                          SizedBox(height: 40,),
                        const Center(
                          child: Text(
                            "Last 7 Days",
                            textScaler: TextScaler.linear(1.7),
                          ),
                        ),
                        const SizedBox(height: 5),
                        child
                      ],
                    );
                  }

                  else if(!dateOfWorkout.isInLastSevenDays() &&
                      (dateOfNewerWorkout == null || dateOfNewerWorkout.isInLastSevenDays() || !dateOfWorkout.isSameMonth(dateOfNewerWorkout))
                  ){
                    child = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(dateOfNewerWorkout != null)
                          SizedBox(height: 40,),
                        Center(
                          child: Text(
                            DateFormat('MMMM y', Localizations.localeOf(context).languageCode).format(dateOfWorkout),
                            textScaler: const TextScaler.linear(1.7),
                          ),
                        ),
                        if(dateOfNewerWorkout == null || !dateOfWorkout.isSameWeek(dateOfNewerWorkout))
                          getWeekDecoration(Jiffy.parseFromDateTime(dateOfWorkout).weekOfYear.toString()),
                        const SizedBox(height: 5),
                        child
                      ],
                    );
                  }
                  else if(dateOfNewerWorkout == null || !dateOfWorkout.isSameWeek(dateOfNewerWorkout)){
                    child = Column(
                      children: [
                        SizedBox(height: 15,),
                        getWeekDecoration(Jiffy.parseFromDateTime(dateOfWorkout).weekOfYear.toString()),
                        const SizedBox(height: 5),
                        child
                      ],
                    );
                  }
                }

                return child;
                // return children[index];
              },
          ),
        ],
      ),
    );
  }

  Widget getWeekDecoration(String weekOfYear){
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black.withOpacity(0.6),
        ),
        child: Text(
          "week $weekOfYear",
          textScaler: const TextScaler.linear(1),
        ),
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