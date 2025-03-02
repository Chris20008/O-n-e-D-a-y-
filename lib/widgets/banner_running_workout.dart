import 'dart:ui';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/main_screens/screen_workouts/screen_workouts.dart';
import '../screens/other_screens/screen_running_workout/screen_running_workout.dart';
import '../screens/main_screens/screen_workouts/panels/new_workout_panel.dart';
import 'bottom_menu.dart';

class BannerRunningWorkout extends StatefulWidget {
  const BannerRunningWorkout({super.key});

  @override
  State<BannerRunningWorkout> createState() => _BannerRunningWorkoutState();
}

class _BannerRunningWorkoutState extends State<BannerRunningWorkout> {

  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  late CnWorkouts cnWorkouts;
  final double _height = 50;

  @override
  Widget build(BuildContext context) {
    cnWorkouts = Provider.of<CnWorkouts>(context);
    // print("REBUILD BANNER RUNNING WORKOUT");

    return AnimatedCrossFade(
        firstChild: const SizedBox(width: double.maxFinite),
        secondChild: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: 10.0,
                sigmaY: 10.0,
                tileMode: TileMode.mirror
            ),
            child: Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
              ),
              child: SafeArea(
                bottom: false,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if(!cnRunningWorkout.isVisible){
                      cnRunningWorkout.reopenRunningWorkout(context);
                    }
                  },
                  child: Container(
                    height: _height,
                    width: double.maxFinite,
                    color: Colors.black.withOpacity(0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Expanded(
                          flex: 4,
                          child: Center(
                            child: OverflowSafeText(
                                cnRunningWorkout.workout.name,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 1,
                                minFontSize: 27
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        crossFadeState: !cnRunningWorkout.isRunning
          ?CrossFadeState.showFirst
          :CrossFadeState.showSecond,
        duration: const Duration(
          milliseconds: 250
        )
    );

    // if(!cnRunningWorkout.isRunning){
    //   return const SizedBox(width: double.maxFinite);
    // }
    // print("IS RUNNING");
    // return ClipRRect(
    //   child: BackdropFilter(
    //     filter: ImageFilter.blur(
    //         sigmaX: 10.0,
    //         sigmaY: 10.0,
    //         tileMode: TileMode.mirror
    //     ),
    //     child: Container(
    //       width: double.maxFinite,
    //       decoration: BoxDecoration(
    //           color: Colors.black.withOpacity(0.5),
    //       ),
    //       child: SafeArea(
    //         bottom: false,
    //         child: GestureDetector(
    //           onTap: () {
    //             if(!cnRunningWorkout.isVisible){
    //               cnRunningWorkout.reopenRunningWorkout(context);
    //             }
    //           },
    //           child: Container(
    //             height: _height,
    //             width: double.maxFinite,
    //             color: Colors.black.withOpacity(0.0),
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 Spacer(),
    //                 Expanded(
    //                   flex: 4,
    //                   child: Center(
    //                     child: OverflowSafeText(
    //                       cnRunningWorkout.workout.name,
    //                       style: Theme.of(context).textTheme.titleMedium,
    //                       maxLines: 1,
    //                       minFontSize: 27
    //                     ),
    //                   ),
    //                 ),
    //                 const Spacer(),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
