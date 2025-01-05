import 'package:fitness_app/main.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:provider/provider.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/screen_workouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

List<TargetFocus> targets = [];

initTutorialAddWorkout(BuildContext context){
  CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  targets = [];
  targets.addAll([
    /// Button add Workout
    TargetFocus(
        enableOverlayTab: false,
        enableTargetTab: true,
        shape: ShapeLightFocus.Circle,
        identify: "Add Workout",
        keyTarget: cnWorkouts.keyAddWorkout,
        contents: [
          TargetContent(
              align: ContentAlign.left,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.t1CreateTemplate,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0
                    ),
                  ),
                ],
              )
          )
        ]
    ),
    /// Panel workout create workout name
    TargetFocus(
        shape: ShapeLightFocus.RRect,
        identify: "Create Workout Name",
        keyTarget: cnNewWorkout.keyTextFieldWorkoutName,
        enableOverlayTab: false,
        enableTargetTab: true,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.t1EnterWoName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0
                    ),
                  ),
                ],
              )
          )
        ]
    ),
  ]);
}

void showTutorialAddWorkout(BuildContext context){
  CnNewWorkOutPanel cnNewWorkOutPanel = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  CnConfig cnConfig = Provider.of<CnConfig>(context, listen: false);
  tutorialIsRunning = true;
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
    // showSkipInLastTarget: false,
    onClickTargetWithTapPosition: (target, tapDetails) {
      if(target.identify == "Add Workout"){
        cnNewWorkOutPanel.openPanelAsTemplate();
      }
      else if(target.identify == "Create Workout Name"){
        FocusScope.of(context).requestFocus(cnNewWorkOutPanel.focusNodeTextFieldWorkoutName);
      }
    },
    onClickOverlay: (target){},
    onSkip: (){
      currentTutorialStep = maxTutorialStep;
      cnConfig.setCurrentTutorialStep(currentTutorialStep);
      return true;
    },
    onFinish: (){
      currentTutorialStep = 1;
      cnConfig.setCurrentTutorialStep(currentTutorialStep);
      SystemChrome.setPreferredOrientations([]);
      // print("finish");
    },
  ).show(context:context);
}