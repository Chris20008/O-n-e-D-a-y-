import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

List<TargetFocus> targets = [];

initTutorialExplainExerciseDragOptions(BuildContext context){
  CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  targets = [];
  targets.addAll([
    /// Panel workout add Exercise
    TargetFocus(
        shape: ShapeLightFocus.RRect,
        identify: "Explain Drag and Swipe Options",
        keyTarget: cnNewWorkout.keyFirstExercise,
        enableOverlayTab: false,
        enableTargetTab: true,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context)!.t3ExOptions,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20.0
                        ),
                      ),

                      const SizedBox(height: 15,),

                      RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "${AppLocalizations.of(context)!.t3SwipeLeft1} ",
                                style: const TextStyle(
                                  color: Colors.white,
                                  // fontSize: 15.0
                                ),
                              ),
                              WidgetSpan(
                                child: RotatedBox(
                                  quarterTurns: 2,
                                  child: Icon(
                                    size: 18,
                                    Icons.arrow_right_alt_outlined,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                              TextSpan(
                                text: " ${AppLocalizations.of(context)!.t3SwipeLeft2}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  // fontSize: 15.0
                                ),
                              ),
                            ],
                          )
                      ),
                      const SizedBox(height: 10,),
                      SizedBox(
                          width: 200,
                          child: Image.asset(
                              scale: 0.8,
                              "${pictureAssetPath}Swipe Left.jpg"
                          )
                      ),

                      const SizedBox(height: 40,),

                      RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "${AppLocalizations.of(context)!.t3SwipeRight1} ",
                                style: const TextStyle(
                                  color: Colors.white,
                                  // fontSize: 15.0
                                ),
                              ),
                              WidgetSpan(
                                child: Icon(
                                  size: 18,
                                  Icons.arrow_right_alt_outlined,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              TextSpan(
                                text: " ${AppLocalizations.of(context)!.t3SwipeRight2}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  // fontSize: 15.0
                                ),
                              ),
                            ],
                          )
                      ),

                      const SizedBox(height: 10,),
                      SizedBox(
                          width: 200,
                          child: Image.asset(
                              scale: 0.6,
                              "${pictureAssetPath}Swipe Right.jpg"
                          )
                      ),

                      const SizedBox(height: 40,),

                      Text(AppLocalizations.of(context)!.t3LongPress,
                        style: const TextStyle(
                            color: Colors.white,
                            // fontSize: 15.0
                        ),
                      ),
                      const SizedBox(height: 10,),
                      SizedBox(
                          width: 200,
                          child: Image.asset(
                              scale: 0.6,
                              "${pictureAssetPath}Drag.jpg"
                          )
                      ),
                    ],
                  ),
                ),
              )
          )
        ]
    ),
    /// Panel workout add Link
    TargetFocus(
        shape: ShapeLightFocus.Circle,
        identify: "Add Link",
        keyTarget: cnNewWorkout.keyAddLink,
        enableOverlayTab: false,
        enableTargetTab: true,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: getExplainExerciseGroups(context)
          )
        ]
    ),
  ]);
}

void showTutorialExplainExerciseDragOptions(BuildContext context) {
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
    onClickTargetWithTapPosition: (target, tapDetails) {},
    onClickOverlay: (target){},
    onSkip: (){
      currentTutorialStep = maxTutorialStep;
      cnConfig.setCurrentTutorialStep(currentTutorialStep);
      return true;
    },
    onFinish: (){
      currentTutorialStep = 10;
      cnConfig.setCurrentTutorialStep(currentTutorialStep);
      tutorialIsRunning = false;
      SystemChrome.setPreferredOrientations([]);
    },
  ).show(context:context);
}