import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/screen_workouts/panels/new_workout_panel.dart';
import '../screens/screen_workouts/screen_running_workout.dart';
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
  final double _height = 50;

  @override
  Widget build(BuildContext context) {
    print("REBUILD BANNER");

    print("--- REBUILD BANNER RUNNING WORKOUTS WITH ROUTE: ${ModalRoute.of(context)?.settings.name == "/"}");

    if(!cnRunningWorkout.isRunning){
      return const SizedBox(width: double.maxFinite);
    }
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: 10.0,
            sigmaY: 10.0,
            tileMode: TileMode.mirror
        ),
        child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
          ),
          child: SafeArea(
            bottom: false,
            child: GestureDetector(
              onTap: () {
                if(!cnRunningWorkout.isVisible){
                  cnRunningWorkout.isVisible = true;
                  // cnBottomMenu.refresh();
                  // setState(() {});
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
                    Text(
                      cnRunningWorkout.workout.name,
                      textScaler: const TextScaler.linear(1.6),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
