import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/screen_workouts/panels/new_workout_panel.dart';
import 'package:fitness_app/screens/screen_workouts/screen_running_workout.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/widgets/banner_running_workout.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../objectbox.g.dart';
import '../../objects/workout.dart';
import '../../util/objectbox/ob_workout.dart';
import '../../widgets/spotify_bar.dart';
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
  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
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
              padding: EdgeInsets.zero,
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
                    padding: EdgeInsets.only(top: index == 0? cnRunningWorkout.isRunning? 20+110:70 : 10, left: 20, right: 20, bottom: 0),
                    onExpansionChange: (bool isOpen) => cnWorkouts.opened[index] = isOpen,
                    initiallyExpanded: cnWorkouts.opened[index],
                );
              }
          ),
          BannerRunningWorkout(),
          Container(
            height: double.maxFinite,
            width: double.maxFinite,
            padding: EdgeInsets.only(right: 5, bottom: 64),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SafeArea(
                  bottom: false,
                  child: SizedBox(
                    width: 54,
                    height: 54,
                    child: IconButton(
                        iconSize: 25,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.transparent),
                        ),
                        onPressed: () {
                          saveBackup();
                          // loadBackup();
                        },
                        icon: Icon(
                          Icons.backup,
                          color: Colors.amber[800],
                        )
                    ),
                  ),
                ),
                SizedBox(
                  width: 54,
                  height: 54,
                  child: IconButton(
                      iconSize: 25,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () {
                        // saveBackup();
                        loadBackup();
                      },
                      icon: Icon(
                        Icons.cloud_download,
                        color: Colors.amber[800],
                      )
                  ),
                ),
                Spacer(),
                // SizedBox(
                //   height: cnNewWorkout.minPanelHeight > 0? 64 : 0,
                // ),
                SizedBox(
                  width: 54,
                  height: 54,
                  child: IconButton(
                      iconSize: 25,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () {
                        if(cnNewWorkout.isUpdating){
                          cnNewWorkout.clear();
                        }
                        cnNewWorkout.workout.isTemplate = true;
                        cnNewWorkout.openPanel();
                        cnHomepage.refresh();
                      },
                      icon: Icon(
                          Icons.add,
                        color: Colors.amber[800],
                      )
                  ),
                ),

                /// Space to be over bottom navigation bar
                const SafeArea(
                    top: false,
                    left: false,
                    right: false,
                    child: SizedBox()
                ),
              ],
            ),
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
  late CnSpotifyBar cnSpotifyBar;

  CnWorkouts(BuildContext context){
    cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  }

  void refreshSpotifyBarDelayed(){
    Future.delayed(const Duration(milliseconds:500), (){
      cnSpotifyBar.seekToRelative(1);
      // cnSpotifyBar.refresh();
    });
  }

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