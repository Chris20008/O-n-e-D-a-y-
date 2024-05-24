import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/screen_workouts.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

List<TargetFocus> targets = [];

initTutorial({
  required CnBottomMenu cnBottomMenu,
  required CnWorkouts cnWorkouts,
  required CnNewWorkOutPanel cnNewWorkout
}){
  targets.addAll([
    TargetFocus(
        shape: ShapeLightFocus.Circle,
        identify: "Add Workout",
        keyTarget: cnWorkouts.keyAddWorkout,
        contents: [
          TargetContent(
              align: ContentAlign.left,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Let's create your first workout Template",
                    style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.only(top: 10.0),
                  //   child: Text("Let's create your first workout Template",
                  //     style: TextStyle(
                  //         color: Colors.white
                  //     ),),
                  // )
                ],
              )
          )
        ]
    ),
    TargetFocus(
          shape: ShapeLightFocus.Circle,
          identify: "Add Link",
          keyTarget: cnNewWorkout.keyAddLink,
          enableOverlayTab: true,
          // enableTargetTab: false,
          contents: [
            TargetContent(
                align: ContentAlign.bottom,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Create Groups",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text("You can group exercises. This can be helpful when you have alternating exercises in a workout or just want to have an alternative when you primary exercise is not available.",
                        style: TextStyle(
                            color: Colors.white
                        ),),
                    )
                  ],
                )
            )
          ]
      )
  ]);
}

void showTutorial(BuildContext context, {required CnNewWorkOutPanel cnNewWorkOutPanel}) {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  TutorialCoachMark(
    targets: targets, // List<TargetFocus>
    // colorShadow: Colors.black, // DEFAULT Colors.black
    // opacityShadow: 0.6,
    alignSkip: Alignment.topRight,
    pulseEnable: true,
    // textSkip: "SKIP",
    // paddingFocus: 10,
    // opacityShadow: 0.8,
    focusAnimationDuration: const Duration(milliseconds: 400),
    unFocusAnimationDuration: const Duration(milliseconds: 400),
    showSkipInLastTarget: false,
    onClickTarget: (target){
      print(target);
    },
    onClickTargetWithTapPosition: (target, tapDetails) {
      print("target: ${target.identify}");
      print("clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      if(target.identify == "Add Workout"){
        /// should not be delayed, otherwise the new focus can be at the wrong place since the panel could still be animating
        // Future.delayed(const Duration(milliseconds: 0), (){
          cnNewWorkOutPanel.openPanelAsTemplate();
        // });
      }
    },
    onClickOverlay: (target){
      print(target);
    },
    onSkip: (){
      print("skip");
      return true;
    },
    onFinish: (){
      SystemChrome.setPreferredOrientations([]);
      print("finish");
    },
  ).show(context:context);
}