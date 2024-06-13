import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/widgets/banner_running_workout.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../objectbox.g.dart';
import '../../../objects/workout.dart';
import '../../../util/objectbox/ob_workout.dart';
import '../../../widgets/spotify_bar.dart';
import '../../../widgets/workout_expansion_tile.dart';
import '../../other_screens/screen_running_workout/screen_running_workout.dart';

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
  late CnConfig cnConfig = Provider.of<CnConfig>(context);
  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context);

  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      top: false,
      bottom: false,
      child: SizedBox(
        height: size.height,
        child: Stack(
          children: [
            ListView.builder(
                padding: EdgeInsets.zero,
                addAutomaticKeepAlives: true,
                physics: const BouncingScrollPhysics(),
                key: cnWorkouts.keyListViewAllTemplates,
                controller: cnWorkouts.scrollController,
                itemCount: cnWorkouts.workouts.length+1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == cnWorkouts.workouts.length){
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
                  if(index == 0){
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: cnRunningWorkout.isRunning? 250 : 0),
                          height: cnRunningWorkout.isRunning? 110 : 60,
                        ),
                        WorkoutExpansionTile(
                          workout: cnWorkouts.workouts[index],
                          padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 0),
                          onExpansionChange: (bool isOpen) => cnWorkouts.opened[index] = isOpen,
                          initiallyExpanded: cnWorkouts.opened[index],
                        )
                      ],
                    );
                  }
                  return WorkoutExpansionTile(
                      workout: cnWorkouts.workouts[index],
                      padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 0),
                      onExpansionChange: (bool isOpen) => cnWorkouts.opened[index] = isOpen,
                      initiallyExpanded: cnWorkouts.opened[index],
                  );
                }
            ),
            /// do not make const, should be updated by rebuild
            const Hero(
                transitionOnUserGestures: true,
                tag: "Banner",
                child: BannerRunningWorkout()
            ),
            SafeArea(
              bottom: true,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                transform: Matrix4.translationValues(
                    /// x
                    -5,
                    /// y
                    -(cnConfig.useSpotify? cnSpotifyBar.height + 4 : 0) - (cnNewWorkout.minPanelHeight>0? (cnNewWorkout.minPanelHeight-cnBottomMenu.height) : 0),
                    /// z
                    0),
                curve: Curves.easeInOut,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                      width: 54,
                      height: 54,
                      child: IconButton(
                          key: cnWorkouts.keyAddWorkout,
                          iconSize: 25,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.transparent),
                          ),
                          onPressed: () {
                            cnNewWorkout.openPanelAsTemplate();
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
          ],
        ),
      ),
    );
  }
}

class CnWorkouts extends ChangeNotifier {
  List<Workout> workouts = [];
  final GlobalKey keyListViewAllTemplates = GlobalKey();
  final GlobalKey keyAddWorkout = GlobalKey();
  List<bool> opened = [];
  ScrollController scrollController = ScrollController();
  late final AnimationController animationControllerWorkoutPanel;

  void refreshAllWorkouts() async{
    List<ObWorkout> obWorkouts = await objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(true)).order(ObWorkout_.name).build().findAsync();
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