import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
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
  late CnConfig cnConfig;
  late CnWorkouts cnWorkouts;

  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    cnConfig = Provider.of<CnConfig>(context);
    cnWorkouts = Provider.of<CnWorkouts>(context);
    final size = MediaQuery.of(context).size;

    print("Screen Workouts");

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

                  /// Bottom Spacer
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

                  /// First Child with Top Space
                  if(index == 0){
                    return SafeArea(
                      bottom: false,
                      left: false,
                      right: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Selector<CnBannerRunningWorkout, bool>(
                              selector: (_, cn) => cn.showBanner,
                              builder: (_, showBanner, __){
                                return AnimatedContainer(
                                  duration: Duration(milliseconds: showBanner? 250 : 0),
                                  height: showBanner? 75 : 25,
                                );
                              }
                          ),
                          WorkoutExpansionTile(
                            workout: cnWorkouts.workouts[index],
                            padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 0),
                            onExpansionChange: (bool isOpen) => cnWorkouts.opened[index] = isOpen,
                            initiallyExpanded: cnWorkouts.opened[index],
                          )
                        ],
                      ),
                    );
                  }

                  /// Other 2 - n Templates
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
                            backgroundColor: WidgetStateProperty.all(Colors.transparent),
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

            // Center(
            //   child: ElevatedButton(
            //     child: Text("Test"),
            //     onPressed: ()async{
            //       pushRoute();
            //       // HapticFeedback.selectionClick();
            //       // Future.delayed(const Duration(milliseconds: 1000), () async{
            //       //   // final localFiles = await getLocalBackupFiles();
            //       //   Navigator.push(
            //       //       context,
            //       //       CupertinoPageRoute(
            //       //           builder: (context) => const LocalFilePicker()
            //       //       ));
            //       // });
            //     },
            //   ),
            // )
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
  // late final AnimationController animationControllerWorkoutsScreen;

  Future refreshAllWorkouts() async{
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