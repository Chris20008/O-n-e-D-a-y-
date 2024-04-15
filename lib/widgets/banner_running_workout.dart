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
  final double _height = 60;

  @override
  Widget build(BuildContext context) {
    if(!cnRunningWorkout.isRunning){
      return const SizedBox(width: double.maxFinite);
    }
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
            // sigmaX: cnRunningWorkout.isVisible? 0 : 10.0,
            // sigmaY: cnRunningWorkout.isVisible? 0 : 10.0,
            sigmaX: 10.0,
            sigmaY: 10.0,
            tileMode: TileMode.mirror
        ),
        child: Container(
          width: double.maxFinite,
          // height: Platform.isAndroid? 20 : 110,
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              // gradient: cnRunningWorkout.isVisible? const LinearGradient(
              //     begin: Alignment.centerRight,
              //     end: Alignment.centerLeft,
              //     colors: [
              //       Color(0xff160d05),
              //       Color(0xff0a0604),
              //     ]
              // ) : null
          ),
          child: SafeArea(
            bottom: false,
            child: GestureDetector(
              onTap: () {
                cnRunningWorkout.isVisible = true;
                cnBottomMenu.refresh();
                setState(() {});
                cnRunningWorkout.reopenRunningWorkout(context);
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
