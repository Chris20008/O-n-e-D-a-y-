import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/screen_workouts/screen_running_workout.dart';

class BannerRunningWorkout extends StatefulWidget {
  const BannerRunningWorkout({super.key});

  @override
  State<BannerRunningWorkout> createState() => _BannerRunningWorkoutState();
}

class _BannerRunningWorkoutState extends State<BannerRunningWorkout> {

  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    if(!cnRunningWorkout.isRunning){
      return const SizedBox();
    }
    return Container(
      width: double.maxFinite,
      height: 110,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [
              Color(0xff55300a),
              Color(0xff44260b),
            ]
        ),
        // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))
      ),
      child: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: SizedBox(),
          ),
          GestureDetector(
            onTap: () => cnRunningWorkout.reopenRunningWorkout(context),
            child: Container(
              height: 50,
              width: double.maxFinite,
              // color: Color(0xff44260b),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Color(0xff55300a),
                      Color(0xff44260b),
                    ]
                ),
                // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cnRunningWorkout.workout.name,
                    textScaleFactor: 1.6,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
