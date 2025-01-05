import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

List<TargetFocus> targets = [];

initTutorialAddExercise(BuildContext context){
  CnNewExercisePanel cnNewExercise = Provider.of<CnNewExercisePanel>(context, listen: false);
  CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  targets = [];
  targets.addAll([
    /// Panel workout add Exercise
    TargetFocus(
        shape: ShapeLightFocus.RRect,
        identify: "Add Exercise",
        keyTarget: cnNewWorkout.keyAddExercise,
        enableOverlayTab: false,
        enableTargetTab: true,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(AppLocalizations.of(context)!.t2AddExercise,
                    // child: cnNewWorkout.workout.name.isEmpty
                    //     ? Text(AppLocalizations.of(context)!.t2AddExercise)
                    //     : Text("${AppLocalizations.of(context)!.t2AddExercise} ${cnNewWorkout.workout.name}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20.0
                      ),
                    ),
                  )
                ],
              )
          )
        ]
    ),
    /// Panel Exercise explanation
    TargetFocus(
        shape: ShapeLightFocus.RRect,
        identify: "Header Exercise Panel",
        keyTarget: cnNewExercise.keyHeader,
        enableOverlayTab: false,
        enableTargetTab: true,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      AppLocalizations.of(context)!.t2SetExerciseOptions,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19.0
                      ),
                    ),
                  )
                ],
              )
          )
        ]
    ),
    /// Panel Exercise explanation
    TargetFocus(
        shape: ShapeLightFocus.RRect,
        identify: "Enter Exercise Name",
        keyTarget: cnNewExercise.keyExerciseName,
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
                    AppLocalizations.of(context)!.t2EnterExName,
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
    )
  ]);
}

void showTutorialAddExercise(BuildContext context) {
  CnNewWorkOutPanel cnNewWorkOutPanel = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  CnNewExercisePanel cnNewExercisePanel = Provider.of<CnNewExercisePanel>(context, listen: false);
  CnConfig cnConfig = Provider.of<CnConfig>(context, listen: false);
  tutorialIsRunning = true;
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  TutorialCoachMark(
    targets: targets,
    alignSkip: Alignment.topRight,
    pulseEnable: true,
    focusAnimationDuration: const Duration(milliseconds: 400),
    unFocusAnimationDuration: const Duration(milliseconds: 400),
    // showSkipInLastTarget: false,
    onClickTargetWithTapPosition: (target, tapDetails) {
      if(target.identify == "Add Exercise"){
        cnNewExercisePanel.openPanel(
            workout: cnNewWorkOutPanel.workout,
            onConfirm: cnNewWorkOutPanel.confirmAddExercise
        );
      }
      else if(target.identify == "Enter Exercise Name"){
        FocusScope.of(context).requestFocus(cnNewExercisePanel.focusNodeTextFieldExerciseName);
      }
    },
    onClickOverlay: (target){},
    onSkip: (){
      currentTutorialStep = maxTutorialStep;
      cnConfig.setCurrentTutorialStep(currentTutorialStep);
      return true;
    },
    onFinish: (){
      currentTutorialStep = 3;
      cnConfig.setCurrentTutorialStep(currentTutorialStep);
      SystemChrome.setPreferredOrientations([]);
    },
  ).show(context:context);
}