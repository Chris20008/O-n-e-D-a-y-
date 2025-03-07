import 'package:fitness_app/main.dart';
import 'package:fitness_app/objects/exercise.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/widgets/cupertino_button_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/screen_workouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:page_indicator_plus/page_indicator_plus.dart';

List<TargetFocus> targets = [];
TextStyle tStyle = const TextStyle(
    color: Colors.white,
    fontSize: 19.0
);
PageController pageViewControllerExercises = PageController();
PageController pageViewControllerGroups = PageController();
int pageCountExercises = 0;
int pageCountGroups = 0;

initTutorialCreateWorkoutTemplate(BuildContext context){
  CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  CnNewExercisePanel cnNewExercise = Provider.of<CnNewExercisePanel>(context, listen: false);
  CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);

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
        enableTargetTab: false,
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
                    child: Text(AppLocalizations.of(context)!.t1AddExercise,
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
        identify: "Enter Exercise Name",
        keyTarget: cnNewExercise.keyExerciseName,
        enableOverlayTab: false,
        enableTargetTab: false,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.t1EnterExName,
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

    /// Panel Exercise explanation
    TargetFocus(
        shape: ShapeLightFocus.RRect,
        identify: "Header Exercise Panel",
        keyTarget: cnNewExercise.keyHeader,
        enableOverlayTab: false,
        enableTargetTab: false,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: getChildExplainExerciseSetting(context)
          )
        ]
    ),

    /// Panel Exercise Set Row
    TargetFocus(
        shape: ShapeLightFocus.RRect,
        identify: "Set Row",
        keyTarget: cnNewExercise.keySetRow,
        enableOverlayTab: false,
        enableTargetTab: false,
        contents: [
          TargetContent(
              align: ContentAlign.top,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      AppLocalizations.of(context)!.t1WeightAmount,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19.0
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: CupertinoButtonText(
                        text: AppLocalizations.of(context)!.welcomeNext,
                        onPressed: (){
                          if(cnNewExercise.controllers[0][0].text.isEmpty){
                            FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[0][0]);
                          }
                          else if(cnNewExercise.controllers[0][1].text.isEmpty){
                            FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[0][1]);
                          }
                          else{
                            blockUserInput(context, duration: 1200);
                            cnHomepage.tutorial?.next();
                            FocusManager.instance.primaryFocus?.unfocus();
                          }
                        }
                    ),
                  )
                ],
              )
          )
        ]
    ),

    /// Panel Exercise Save Button
    TargetFocus(
        shape: ShapeLightFocus.RRect,
        identify: "Save Exercise",
        keyTarget: cnNewExercise.keySaveButton,
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
                      AppLocalizations.of(context)!.t1SaveExercise,
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

    /// Panel workout add Exercise
    TargetFocus(
        shape: ShapeLightFocus.RRect,
        identify: "Explain Swipe Options",
        keyTarget: cnNewWorkout.keyFirstExercise,
        enableOverlayTab: false,
        enableTargetTab: false,
        focusAnimationDuration: const Duration(milliseconds: 400),
        unFocusAnimationDuration: const Duration(milliseconds: 0),
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context)!.t1SwipeLeft,
                        style: tStyle,
                      ),
                    ],
                  ),
                ),
              )
          ),
        ]
    ),

    /// Panel workout add Exercise
    TargetFocus(
        shape: ShapeLightFocus.RRect,
        identify: "Explain Drag Options",
        keyTarget: cnNewWorkout.keyFirstExercise,
        enableOverlayTab: false,
        enableTargetTab: false,
        focusAnimationDuration: const Duration(milliseconds: 0),
        unFocusAnimationDuration: const Duration(milliseconds: 0),
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
                        AppLocalizations.of(context)!.t1LongPress,
                        style: tStyle,
                      ),
                    ],
                  ),
                ),
              )
          ),
        ]
    ),

    /// Panel workout add Link
    TargetFocus(
        shape: ShapeLightFocus.Circle,
        identify: "Add Link",
        keyTarget: cnNewWorkout.keyAddLink,
        enableOverlayTab: false,
        enableTargetTab: false,
        contents: [
          TargetContent(
              align: ContentAlign.bottom,
              child: getChildExplainGroups(context)
          )
        ]
    ),
  ]);
}

Widget getChildExplainExerciseSetting(BuildContext context){
  TextScaler ts = const TextScaler.linear(1.2);

  List<Widget> pages = [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.t1SetExerciseOptions,
          style: tStyle,
        )
      ],
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.t1CategoryHeader,
          style: tStyle,
        ),
        const SizedBox(height: 15,),
        Row(
          children: [
            Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.t1Category1, textScaler: ts)),
            Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.t1Category2, textScaler: ts))
          ],
        ),
        const SizedBox(height: 5,),
        Row(
          children: [
            Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.t1Category3, textScaler: ts)),
            Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.t1Category4, textScaler: ts))
          ],
        ),
        const SizedBox(height: 5,),
        Row(
          children: [
            Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.t1Category5, textScaler: ts)),
            Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.t1Category6, textScaler: ts))
          ],
        ),
        const SizedBox(height: 15,),
        Row(
          children: [
            Text(
                AppLocalizations.of(context)!.t1CategoryEnd,
                textScaler: ts
            )
          ],
        )
      ],
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            AppLocalizations.of(context)!.t1BodyWeight,
            style: tStyle
        )
      ],
    )
  ];

  pageCountExercises = pages.length;

  return ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: (MediaQuery.of(context).size.height / 4).clamp(300, 1000),
      maxWidth:MediaQuery.of(context).size.width,
    ),
    child: Stack(
      children: [
        PageView(
          controller: pageViewControllerExercises,
          children: pages,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: PageIndicator(
            controller: pageViewControllerExercises,
            count: pageCountExercises,
            size: 8,
            layout: PageIndicatorLayout.WARM,
            activeColor: activeColor,
            scale: 0.65,
            space: 10,
          ),
        )
      ],
    ),
  );
}

Widget getChildExplainGroups(BuildContext context){

  List<Widget> pages = [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.t1GroupExplanation,
          style: tStyle,
        )
      ],
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.t1GroupExplanation2,
          style: tStyle,
        ),
      ],
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            AppLocalizations.of(context)!.t1GroupExplanation3,
            style: tStyle
        )
      ],
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            AppLocalizations.of(context)!.t1GroupExplanation4,
            style: tStyle
        )
      ],
    )
  ];

  pageCountGroups = pages.length;

  return ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.4,
      maxWidth:MediaQuery.of(context).size.width,
    ),
    child: Stack(
      children: [
        PageView(
          controller: pageViewControllerGroups,
          children: pages,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: PageIndicator(
            controller: pageViewControllerGroups,
            count: pageCountGroups,
            size: 8,
            layout: PageIndicatorLayout.WARM,
            activeColor: activeColor,
            scale: 0.65,
            space: 10,
          ),
        )
      ],
    ),
  );
}

TutorialCoachMark showTutorialCreateWorkoutTemplate(BuildContext context){
  CnNewWorkOutPanel cnNewWorkOutPanel = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  CnNewExercisePanel cnNewExercisePanel = Provider.of<CnNewExercisePanel>(context, listen: false);
  CnNewExercisePanel cnNewExercise = Provider.of<CnNewExercisePanel>(context, listen: false);
  CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  CnConfig cnConfig = Provider.of<CnConfig>(context, listen: false);
  tutorialIsRunning = true;
  bool continueAfterAnimatedFirstExerciseRow = false;

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  TutorialCoachMark tutorial = TutorialCoachMark(
    targets: targets, // List<TargetFocus>
    // colorShadow: Colors.black, // DEFAULT Colors.black
    // opacityShadow: 0.6,
    alignSkip: Alignment.topLeft,
    pulseEnable: true,
    // textSkip: "SKIP",
    // paddingFocus: 10,
    // opacityShadow: 0.8,
    focusAnimationDuration: const Duration(milliseconds: 400),
    unFocusAnimationDuration: const Duration(milliseconds: 400),
    // showSkipInLastTarget: false,
    onClickTargetWithTapPosition: (target, tapDetails) {

      switch(target.identify){

        case "Add Workout":{
          cnNewWorkOutPanel.openPanelAsTemplate();
          blockUserInput(context, duration: 1500);
        }

        case "Create Workout Name":{
          FocusScope.of(context).requestFocus(cnNewWorkOutPanel.focusNodeTextFieldWorkoutName);
        }

        case "Add Exercise":{
          cnNewExercisePanel.openPanel(
              workout: cnNewWorkOutPanel.workout,
              onConfirm: cnNewWorkOutPanel.confirmAddExercise
          );
          blockUserInput(context, duration: 1500);
        }

        case "Enter Exercise Name":{
          FocusScope.of(context).requestFocus(cnNewExercisePanel.focusNodeTextFieldExerciseName);
        }

        case "Header Exercise Panel":{
          if((pageViewControllerExercises.page?? 1000) >= pageCountExercises - 1 ){
            blockUserInput(context, duration: 1300);
            cnHomepage.tutorial?.next();
          }
          else{
            pageViewControllerExercises.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.fastEaseInToSlowEaseOut);
          }
        }

        case "Set Row": {
          final totalWidth = MediaQuery.of(context).size.width;

          if(tapDetails.globalPosition.dx / totalWidth > 0.4 && tapDetails.globalPosition.dx / totalWidth < 0.68){
            /// Focus weight field
            FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[0][0]);
          }
          else if(tapDetails.globalPosition.dx / totalWidth >= 0.68){
            /// Focus Amount field
            FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[0][1]);
          }
          else{
            FocusManager.instance.primaryFocus?.unfocus();
          }
        }

        case "Save Exercise": {
          blockUserInput(context, duration: 2000);
          Future.delayed(const Duration(milliseconds: 300), (){
            cnNewExercise.closePanelAndSaveExercise(context);
            cnNewWorkOutPanel.animateFirstExerciseSlide().then((value) => continueAfterAnimatedFirstExerciseRow = true);
          });
        }

        case "Explain Swipe Options": {
          if(continueAfterAnimatedFirstExerciseRow){
            cnNewWorkOutPanel.allowAnimateFirstExerciseSlide = false;
            cnNewWorkOutPanel.exercisesAndLinks.first.slidableController.close(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.fastEaseInToSlowEaseOut
            ).then((value){
              cnHomepage.tutorial?.next();
              blockUserInput(context);
              Future.delayed(const Duration(milliseconds: 1000), (){
                cnNewWorkOutPanel.animateFirstExerciseDrag();
              });
            });
          }
        }

        case "Explain Drag Options": {
          cnNewWorkOutPanel.allowAnimateFirstExerciseDrag = false;
          cnNewWorkOutPanel.tutorialAnimationController.reverse().then((value){
            blockUserInput(context, duration: 1300);
            cnHomepage.tutorial?.next();
          });
        }

        case "Add Link":{
          if((pageViewControllerGroups.page?? 1000) >= pageCountGroups - 1 ){
            blockUserInput(context, duration: 1300);
            cnHomepage.tutorial?.next();
            cnNewWorkOutPanel.addLink(context, linkName: AppLocalizations.of(context)!.t1ExampleGroup);
            Exercise e1 = Exercise.copy(cnNewWorkOutPanel.workout.exercises.first);
            Exercise e2 = Exercise.copy(cnNewWorkOutPanel.workout.exercises.first);
            e1.name = AppLocalizations.of(context)!.t1ExampleGroupedExercise;
            e2.name = AppLocalizations.of(context)!.t1ExampleGroupDisabledExercise;
            e2.blockLink = true;
            cnNewWorkOutPanel.confirmAddExercise(e1);
            cnNewWorkOutPanel.confirmAddExercise(e2);
          }
          else{
            pageViewControllerGroups.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.fastEaseInToSlowEaseOut);
          }
        }
      }
    },
    onClickOverlay: (target){},
    onSkip: (){
      currentTutorialStep = maxTutorialStep;
      cnConfig.setCurrentTutorialStep(currentTutorialStep);
      return true;
    },
    onFinish: (){
      tutorialIsRunning = false;
      cnNewWorkOutPanel.allowAnimateFirstExerciseSlide = false;
      cnNewWorkOutPanel.allowAnimateFirstExerciseDrag = false;
      currentTutorialStep = 999999;
      cnConfig.setCurrentTutorialStep(currentTutorialStep);
      SystemChrome.setPreferredOrientations([]);
      // print("finish");
    },
  );
  tutorial.show(context: context);
  return tutorial;
}