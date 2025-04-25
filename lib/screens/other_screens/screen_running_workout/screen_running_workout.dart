import 'dart:collection';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/selector_exercises_per_link.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/selector_exercises_to_update.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/stopwatch.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/running_workout_content/running_workout_content.dart';
import 'package:fitness_app/util/backup_helper/backup_functions.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/widgets/banner_running_workout.dart';
import 'package:fitness_app/widgets/slide_up_panel/initial_animated_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:io';
import '../../../main.dart';
import '../../../objects/exercise.dart';
import '../../../objects/workout.dart';
import '../../../util/constants.dart';
import '../../../widgets/bottom_menu.dart';
import '../../../widgets/spotify_bar.dart';
import '../../../widgets/standard_popup.dart';
import '../../main_screens/screen_workouts/screen_workouts.dart';
import 'animated_column.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScreenRunningWorkout extends StatefulWidget {
  const ScreenRunningWorkout({
    super.key,
  });

  @override
  State<ScreenRunningWorkout> createState() => _ScreenRunningWorkoutState();
}

class _ScreenRunningWorkoutState extends State<ScreenRunningWorkout> {

  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  late CnStopwatchWidget cnStopwatchWidget = Provider.of<CnStopwatchWidget>(context, listen: false);
  late CnConfig cnConfig  = Provider.of<CnConfig>(context, listen: false);
  late CnBannerRunningWorkout cnBannerRunningWorkout = Provider.of<CnBannerRunningWorkout>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout;
  /// listen to bottomMenu for height changes
  late CnBottomMenu cnBottomMenu;
  // final double _heightOfSetRow = 30;
  // final double _setPadding = 5;
  Key selectorExerciseToUpdateKey = UniqueKey();
  Key selectorExercisePerLinkKey = UniqueKey();
  double viewInsetsBottom = 0;
  bool isAlreadyCheckingKeyboard = false;
  bool isAlreadyCheckingKeyboardPermanent = false;
  bool isSavingData = false;
  // final _style = const TextStyle(color: Colors.white, fontSize: 15);
  String descendantNameExerciseToUpdate = "ScreenRunningWorkout";
  PanelController controllerSelectorExerciseToUpdate = PanelController();
  PanelController controllerSelectorExercisePerLink = PanelController();
  int timeAnimatedColumn = 1000;
  bool isShowingAnimatedColumn = true;
  // bool showContent = false;

  @override
  void initState() {
    super.initState();
    // Future.delayed(const Duration(milliseconds: 500), (){
    //   cnRunningWorkout.lastScrollPosition = cnRunningWorkout.scrollController.offset;
    //   cnRunningWorkout.scrollController = ScrollController(initialScrollOffset: cnRunningWorkout.lastScrollPosition);
    //   cnRunningWorkout.contentIsActive = true;
    //   cnRunningWorkout.refresh();
    // });
  }

  @override
  Widget build(BuildContext context) {
    cnRunningWorkout = Provider.of<CnRunningWorkout>(context);
    cnBottomMenu = Provider.of<CnBottomMenu>(context);
    viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    if(!cnRunningWorkout.scrollController.hasClients){
      cnRunningWorkout.scrollController = ScrollController(initialScrollOffset: cnRunningWorkout.lastScrollPosition);
    }

    print("Running Workout");

    return PopScope(
      canPop: !isSavingData,
      onPopInvokedWithResult: (doPop, res){
        if(cnRunningWorkout.isVisible){
          cnRunningWorkout.lastScrollPosition = cnRunningWorkout.scrollController.offset;
          cnRunningWorkout.isVisible = false;
          cnRunningWorkout.cache();
          cnBannerRunningWorkout.activateButton();
        }
        else{
          cnBannerRunningWorkout.reset();
        }
        FocusManager.instance.primaryFocus?.unfocus();
        cnRunningWorkout.contentIsActive = false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: const BoxDecoration(
            color: Colors.black
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InitialAnimatedScreen(
                backDropEnabled: true,
                animationControllerName: "ScreenRunningWorkout",
                child: Scaffold(
                  backgroundColor: Theme.of(context).primaryColor,
                  extendBody: true,
                  resizeToAvoidBottomInset: false,
                  bottomNavigationBar: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaX: 10.0,
                          sigmaY: 10.0,
                          tileMode: TileMode.mirror
                      ),
                      child: Container(
                        height: cnBottomMenu.height,
                        color: Colors.black.withValues(alpha: 0.5),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: openPopUpFinishWorkout,
                          child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.finish,
                                  style: TextStyle(
                                      color: Colors.amber[800]
                                  ),
                                  textScaler: const TextScaler.linear(1.2)
                              )
                          ),
                        ),
                      ),
                    ),
                  ),
                  body: GestureDetector(
                    onTap: (){
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Stack(
                      children: [
                        SafeArea(
                          top: false,
                          bottom: false,
                          child: Padding(
                            padding: EdgeInsets.only(top:0,bottom: viewInsetsBottom ,left: 20, right: 20),
                            child: const Column(
                              children: [

                                Expanded(

                                  /// Each EXERCISE and SET
                                  child: RunningWorkoutContent(),
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// do not make const, should be updated by rebuild
                        Hero(
                            transitionOnUserGestures: true,
                            tag: "Banner",
                            child: BannerRunningWorkout()
                        ),

                        AnimatedCrossFade(
                            layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
                              return Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Positioned(
                                    key: bottomChildKey,
                                    child: bottomChild,
                                  ),
                                  Positioned(
                                    key: topChildKey,
                                    child: topChild,
                                  ),
                                ],
                              );
                            },
                            firstChild: const AnimatedColumn(),
                            secondChild: const Align(
                              alignment: Alignment.bottomRight,
                                child: SizedBox(width: double.maxFinite)
                            ),
                            crossFadeState: viewInsetsBottom < 100
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                            duration: Duration(milliseconds: viewInsetsBottom < 100? 150 : 0)
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // if(cnRunningWorkout.dismissedSets.isNotEmpty)
              //   SafeArea(
              //     child: Align(
              //       alignment: Alignment.topRight,
              //       child: IconButton(
              //           onPressed: undoDismiss,
              //           icon: Icon(
              //             Icons.undo,
              //             color: Colors.amber[800],
              //           )
              //       ),
              //     ),
              //   ),

              // const StandardPopUp(),

              SelectorExercisesPerLink(
                controller: controllerSelectorExercisePerLink,
                key: selectorExercisePerLinkKey,
                groupedExercises: cnRunningWorkout.groupedExercises,
                relevantLinkNames: cnRunningWorkout.linkWithMultipleExercisesStarted,
                onConfirm: confirmSelectorExPerLink,
                onCancel: (){
                  controllerSelectorExercisePerLink.close();
                },
              ),

              SelectorExercisesToUpdate(
                key: selectorExerciseToUpdateKey,
                controller: controllerSelectorExerciseToUpdate,
                descendantAnimationControllerName: descendantNameExerciseToUpdate,
                workout: Workout.clone(cnRunningWorkout.workout),
                workoutTemplate: Workout.clone(cnRunningWorkout.workoutTemplateNotModifiable),
                onConfirm: finishWorkout,
                onCancel: (){
                  controllerSelectorExerciseToUpdate.close();
                },
              ),

              if (isSavingData)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: CupertinoActivityIndicator(
                        radius: 20.0,
                        color: Colors.amber[800]
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  bool showAnimatedColumn(){
    if(100 > viewInsetsBottom && !isShowingAnimatedColumn){
      isShowingAnimatedColumn = true;
      timeAnimatedColumn = 1000;
      return true;
    }
    else if(viewInsetsBottom > 0 && isShowingAnimatedColumn){
      isShowingAnimatedColumn = false;
      timeAnimatedColumn = 0;
      return false;
    }
    return isShowingAnimatedColumn;
  }

  onPressedLeft(){
    if(cnRunningWorkout.currentIndexWeightOrAmount == 0){
      cnRunningWorkout.currentIndexFocus -= 1;
      cnRunningWorkout.currentIndexWeightOrAmount = 1;
    } else{
      cnRunningWorkout.currentIndexWeightOrAmount = 0;
    }

    NamedSet? set = getSet(-1);

    if(set == null){
      FocusManager.instance.primaryFocus?.unfocus();
      return;
    }

    FocusNode focusNode = cnRunningWorkout.currentIndexWeightOrAmount == 0? set.focusNodeWeight : set.focusNodeAmount;

    if (cnRunningWorkout.currentIndexFocus < cnRunningWorkout.groupedExercises.length) {
      FocusScope.of(context).requestFocus(focusNode);
      onTapField(cnRunningWorkout.currentIndexFocus, cnRunningWorkout.currentIndexWeightOrAmount, set: set);
    }
  }

  onPressedRight(){
    if(cnRunningWorkout.currentIndexWeightOrAmount == 0){
      cnRunningWorkout.currentIndexWeightOrAmount = 1;
    } else{
      cnRunningWorkout.currentIndexWeightOrAmount = 0;
      cnRunningWorkout.currentIndexFocus += 1;
    }

    NamedSet? set = getSet(1);

    if(set == null){
      FocusManager.instance.primaryFocus?.unfocus();
      return;
    }

    FocusNode focusNode = cnRunningWorkout.currentIndexWeightOrAmount == 0? set.focusNodeWeight : set.focusNodeAmount;

    if (cnRunningWorkout.currentIndexFocus < cnRunningWorkout.groupedExercises.length) {
      FocusScope.of(context).requestFocus(focusNode);
      onTapField(cnRunningWorkout.currentIndexFocus, cnRunningWorkout.currentIndexWeightOrAmount, set: set);
    }
  }

  NamedSet? getSet(int direction){
    NamedSet? tempSet;

    try {
      while (tempSet == null && cnRunningWorkout.currentIndexFocus <cnRunningWorkout.groupedExercises.length) {
        dynamic item = cnRunningWorkout.groupedExercises.entries.toList()[cnRunningWorkout.currentIndexFocus].value;

        if (item is! NamedSet && item is! GroupedSet) {
          cnRunningWorkout.currentIndexFocus += (2*direction);
          item = cnRunningWorkout.groupedExercises.entries.toList()[cnRunningWorkout.currentIndexFocus].value;
        }

        String groupedExerciseKey = cnRunningWorkout.groupedExercises.entries.toList()[cnRunningWorkout.currentIndexFocus].key;

        if (item is NamedSet) {
          tempSet = item;
        }
        else {
          item = item as GroupedSet;
          String linkName = groupedExerciseKey.split("_").first;
          Exercise ex = (cnRunningWorkout.groupedExercises[linkName] as GroupedExercise).getExercise(cnRunningWorkout.selectedIndexes[linkName]!)!;
          tempSet = item.getSet(ex.name);
        }
        if(tempSet == null){
          cnRunningWorkout.currentIndexFocus += (1*direction);
        }
      }
      if (tempSet == null) {
        return null;
      }
      return tempSet;
    }
    catch (e){
      return null;
    }
  }

  Future onTapField(int index, int weightOrAmountIndex, {required NamedSet set}) async{
    cnRunningWorkout.currentIndexFocus = index;
    cnRunningWorkout.currentIndexWeightOrAmount = weightOrAmountIndex;
    TextEditingController controller = weightOrAmountIndex == 0? set.weightController : set.amountController;
    controller.selection =  TextSelection(baseOffset: 0, extentOffset: controller.value.text.length);
    // await Future.delayed(Duration(milliseconds: 50));
    // // double factor = Platform.isAndroid? 0.8 : 1;
    // // final positionKeyboard = getWidgetPosition(cnHomepage.keyKeyboardTopBar);
    // final value = Platform.isAndroid? 80 : 100;
    // final height = MediaQuery.of(context).size.height;
    // final relativeHeight = height - MediaQuery.of(context).viewInsets.bottom;
    // // double factor = (relativeHeight - 90) / relativeHeight;
    // double factor = (relativeHeight - value) / height;
    // Scrollable.ensureVisible(
    //     set.weightKey.currentContext!,
    //     duration: const Duration(milliseconds: 300),
    //     curve: Curves.easeInOut,
    //     alignment: factor
    // );
  }

  void confirmSelectorExPerLink({List<String>? exToRemove, int? delay}){
    cnRunningWorkout.exercisesToRemove = exToRemove?? [];
    if(canUpdateTemplate()){
      Future.delayed(Duration(milliseconds: delay?? cnStandardPopUp.animationTime), (){
        setState(() {
          selectorExerciseToUpdateKey = UniqueKey();
          controllerSelectorExerciseToUpdate = PanelController();
        });
        Future.delayed(const Duration(milliseconds: (100)), (){
          FocusManager.instance.primaryFocus?.unfocus();
          // controllerSelectorExerciseToUpdate.open();
          controllerSelectorExerciseToUpdate.animatePanelToPosition(
              1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastEaseInToSlowEaseOut
          );
        });
      });
    }
    else{
      finishWorkout();
    }
  }

  // void addSet(Exercise ex, Exercise lastEx){
  //   int newIndex = ex.sets.length;
  //   ex.addSet();
  //   lastEx.addSet();
  //   SingleSet newSet = ex.sets[newIndex];
  //   NamedSet newNamedSet = NamedSet(
  //       set: newSet,
  //       name: ex.name,
  //       index: newIndex,
  //       ex: ex,
  //       weightController: TextEditingController(text: (newSet.weightAsTrimmedDouble?? "").toString()),
  //       amountController: TextEditingController(text: (newSet.getAmountAsText(ex.category)?? "").toString())
  //   );
  //   if(ex.linkName == null){
  //     cnRunningWorkout.groupedExercises[getSetKeyName(ex.name, newIndex)] = newNamedSet;
  //   } else{
  //     final String newSetKey = getSetKeyName(ex.linkName!, newIndex);
  //     if(cnRunningWorkout.groupedExercises.containsKey(newSetKey)){
  //       (cnRunningWorkout.groupedExercises[getSetKeyName(ex.linkName!, newIndex)] as GroupedSet).add(newNamedSet);
  //     } else{
  //       cnRunningWorkout.groupedExercises[getSetKeyName(ex.linkName!, newIndex)] = GroupedSet(set: newNamedSet);
  //     }
  //   }
  //   final newControllerPos = cnRunningWorkout.scrollController.position.pixels+_heightOfSetRow + _setPadding*2;
  //   cnRunningWorkout.scrollController.jumpTo(newControllerPos);
  //   cnRunningWorkout.refresh();
  // }

  void undoDismiss(){
    // if(cnRunningWorkout.dismissedSets.isEmpty){
    //   return;
    // }
    // setState(() {
    //   final setsToInsert = cnRunningWorkout.dismissedSets.removeLast();
    //   final templateEx = cnRunningWorkout.workoutTemplateModifiable.exercises.where((element) => element.name == setsToInsert.exName).first;
    //   late Exercise newEx;
    //   if(setsToInsert.linkName != null){
    //     newEx = cnRunningWorkout.groupedExercises[setsToInsert.linkName].where((ex) => ex.name == setsToInsert.exName).first;
    //   } else{
    //     newEx = cnRunningWorkout.groupedExercises[setsToInsert.exName];
    //   }
    //   templateEx.sets.insert(setsToInsert.index, setsToInsert.dismissedTemplateSet);
    //   newEx.sets.insert(setsToInsert.index, setsToInsert.dismissedSet);
    //   if(setsToInsert.dismissedControllers != null){
    //     cnRunningWorkout.textControllers[setsToInsert.exName]?.insert(setsToInsert.index, setsToInsert.dismissedControllers!);
    //   } else{
    //     cnRunningWorkout.textControllers[setsToInsert.exName]?.insert(setsToInsert.index, [TextEditingController(), TextEditingController()]);
    //   }
    //   cnRunningWorkout.slidableKeys[setsToInsert.exName]?.insert(setsToInsert.index, UniqueKey());
    // });
    // cnRunningWorkout.cache();
  }

  /// Find the first indication of whether or not an Exercise has changed.
  ///
  /// Can be through:
  ///   - amount of sets
  ///   - weight
  ///   - amount
  ///   - rest in seconds
  ///   - seat level
  ///   - new Exercise added
  bool canUpdateTemplate(){
    Workout tempWo = Workout.clone(cnRunningWorkout.workout);
    tempWo.removeEmptyExercises();

    if(tempWo.exercises.isEmpty){
      return false;
    }

    /// Get exercises names of true template
    List<String> templateWorkoutExerciseNames = cnRunningWorkout.workoutTemplateNotModifiable.exercises.map((e) => e.name).toList();

    /// Iterate over every exercise in the current running (new) one
    for(Exercise ex in tempWo.exercises){
      /// Exercise name does not exist in true template yet => new exercise has been added => can update Template
      if(!templateWorkoutExerciseNames.contains(ex.name)){
        return true;
      }
      /// When the exercise name already exists, we check if the exercise of the true template and the current running one are truly the same
      Exercise tempTemplateEx = cnRunningWorkout.workoutTemplateNotModifiable.exercises.firstWhere((e) => e.name == ex.name);
      if(!tempTemplateEx.equals(ex)){
        return true;
      }
    }
    return false;
  }

  bool hasStartedWorkout(){
    Workout tempWo = Workout.clone(cnRunningWorkout.workout);
    tempWo.removeEmptyExercises();
    if(tempWo.exercises.isEmpty){
      return false;
    }
    return true;
  }

  void openPopUpFinishWorkout(){
    final bool canFinish = hasStartedWorkout();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        cancelButton: getActionSheetCancelButton(context, text: AppLocalizations.of(context)!.runningWorkoutContinueWorkout),
        title: Text(AppLocalizations.of(context)!.runningWorkoutFinishWorkout),
        actions: <Widget>[
          CupertinoActionSheetAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as delete or exit and turns
            /// the action's text color to red.
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              Future.delayed(const Duration(milliseconds: 250), (){
                openPopUpConfirmCancelWorkout();
              });
            },
            child: Text(AppLocalizations.of(context)!.runningWorkoutStopWorkout, style: cupButtonTextStyleOnlyFontSize),
          ),
          if(canFinish)
            CupertinoActionSheetAction(
              /// This parameter indicates the action would perform
              /// a destructive action such as delete or exit and turns
              /// the action's text color to red.
              isDestructiveAction: false,
              onPressed: () {
                Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime), (){
                  setState(() {
                    cnRunningWorkout.checkMultipleExercisesPerLink();
                    if(cnRunningWorkout.linkWithMultipleExercisesStarted.isNotEmpty){
                      descendantNameExerciseToUpdate = "SelectorExercisePerLink";
                      selectorExercisePerLinkKey = UniqueKey();
                      controllerSelectorExercisePerLink = PanelController();
                      Future.delayed(const Duration(milliseconds: 100), (){
                        FocusManager.instance.primaryFocus?.unfocus();
                        controllerSelectorExercisePerLink.animatePanelToPosition(
                            1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.fastEaseInToSlowEaseOut
                        );
                      });
                    } else{
                      descendantNameExerciseToUpdate = "ScreenRunningWorkout";
                      confirmSelectorExPerLink(delay: 0);
                    }
                  });
                });
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.finish, style: cupButtonTextStyle),
            ),
        ],
      ),
    );
  }

  void openPopUpConfirmCancelWorkout() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        cancelButton: getActionSheetCancelButton(context, text: AppLocalizations.of(context)!.runningWorkoutContinueWorkout),
        title: Text(AppLocalizations.of(context)!.runningWorkoutStopWorkout),
        message: Text(AppLocalizations.of(context)!.runningWorkoutConfirmCancelWorkout),
        actions: <Widget>[
          CupertinoActionSheetAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as delete or exit and turns
            /// the action's text color to red.
            isDestructiveAction: true,
            onPressed: () {
              stopWorkout();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.runningWorkoutStopWorkout, style: cupButtonTextStyleOnlyFontSize),
          ),
        ],
      ),
    );
  }

  Future stopWorkout({int? time})async{
    time = time?? cnStandardPopUp.animationTime;
    if(cnStandardPopUp.isVisible){
      cnStandardPopUp.clear();
    }
    await Future.delayed(Duration(milliseconds: time), ()async{
      cnRunningWorkout.isVisible = false;
      cnRunningWorkout.isRunning = false;
      cnBannerRunningWorkout.reset();
      cnHomepage.refresh();
      cnWorkouts.refresh();
      await Future.delayed(const Duration(milliseconds: 50), ()async{
        Navigator.of(context).pop();
        /// delayed that the pop context is finished, if to short, the user
        /// will se a blank page which is not wanted
        await Future.delayed(const Duration(milliseconds: 500), (){
          cnRunningWorkout.clear();
          if(cnStopwatchWidget.isRunning){
            cnStopwatchWidget.cancelTimer();
          }
        });
      });
    });
  }

  Future finishWorkout() async{
    int time = 0;

    setState(() {
      isSavingData = true;
    });


    await Future.delayed(const Duration(milliseconds: 300));
    if(controllerSelectorExerciseToUpdate.panelPosition > 0){
      await controllerSelectorExerciseToUpdate.close();
      time = 100;
    }
    if(controllerSelectorExercisePerLink.panelPosition > 0){
      await Future.delayed(Duration(milliseconds: time));
      await controllerSelectorExercisePerLink.close();
    }

    /// delay that the popup is closed
    await Future.delayed(const Duration(milliseconds: 100), ()async{
      cnRunningWorkout.workout.refreshDate();
      cnRunningWorkout.removeNotRelevantExercises();
      cnRunningWorkout.workout.removeEmptyExercises();
      if(cnRunningWorkout.workout.exercises.isNotEmpty){
        cnRunningWorkout.workout.saveToDatabase();
        cnWorkouts.refreshAllWorkouts();
      }
      if(cnStopwatchWidget.isRunning){
        cnStopwatchWidget.cancelTimer();
      }

      if(cnConfig.automaticBackups){
        await saveBackup(withCloud: cnConfig.saveBackupCloud, cnConfig: cnConfig) != null;
      }

      await saveCurrentData(cnConfig) != null;

      Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.runningWorkoutCompletedWorkout,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[800]?.withValues(alpha: 0.9),
          textColor: Colors.white,
          fontSize: 16.0
      );
      vibrateSuccess();
      await stopWorkout(time: 0);
      isSavingData = false;
    });
  }

  // Widget getSeatLevelSelector(Exercise newEx) {
  //   return SizedBox(
  //     height: 30,
  //     child: getSelectSeatLevel(
  //         currentSeatLevel: newEx.seatLevel,
  //         child: SizedBox(
  //           width: 100,
  //           child: Align(
  //             alignment: Alignment.centerLeft,
  //             child: Container(
  //               width: 100,
  //               height: 30,
  //               color: Colors.transparent,
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 children: [
  //                   Icon(Icons.airline_seat_recline_normal, size: _iconSize),
  //                   const SizedBox(width: 2,),
  //                   if (newEx.seatLevel == null)
  //                     Text("-", style: _style,)
  //                   else
  //                     Text(newEx.seatLevel.toString(), style: _style,)
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //         onConfirm: (dynamic value){
  //           if(value is int){
  //             newEx.seatLevel = value;
  //             cnRunningWorkout.refresh();
  //           }
  //           else if(value == AppLocalizations.of(context)!.clear){
  //             newEx.seatLevel = null;
  //             cnRunningWorkout.refresh();
  //           }
  //         },
  //       context: context
  //     ),
  //   );
  // }

  // getRestInSecondsSelector(Exercise newEx) {
  //   return SizedBox(
  //     height: 30,
  //     child: Row(
  //       children: [
  //         getSelectRestInSeconds(
  //             currentTime: newEx.restInSeconds,
  //             context: context,
  //             child: SizedBox(
  //               width: 100,
  //               child: Align(
  //                 alignment: Alignment.centerLeft,
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.max,
  //                   children: [
  //                     Icon(CupertinoIcons.timer, size: _iconSize),
  //                     const SizedBox(width: 2,),
  //                     Text(mapRestInSecondsToString(restInSeconds: newEx.restInSeconds), style: _style),
  //                     const SizedBox(width: 10,)
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             onConfirm: (dynamic value){
  //               if(value is int){
  //                 newEx.restInSeconds = value;
  //                 cnRunningWorkout.refresh();
  //               }
  //               else if(value == AppLocalizations.of(context)!.clear){
  //                 newEx.restInSeconds = 0;
  //                 cnRunningWorkout.refresh();
  //               }
  //               else{
  //                 showDialogMinuteSecondPicker(
  //                   context: context,
  //                   initialTimeDuration: Duration(minutes: newEx.restInSeconds~/60, seconds: newEx.restInSeconds%60),
  //                   onConfirm: (Duration newDuration){
  //                     newEx.restInSeconds = newDuration.inSeconds;
  //                   }
  //                 ).then((value) => setState(() {}));
  //               }
  //             }
  //         ),
  //         const Spacer()
  //       ],
  //     ),
  //   );
  // }
}

class CnRunningWorkout extends ChangeNotifier {
  Workout workout = Workout();
  /// Modifiable Workout template
  /// Exercises can be delete
  Workout workoutTemplateModifiable = Workout();
  /// NOT Modifiable Workout template - for comparison what have changed
  Workout workoutTemplateNotModifiable = Workout();
  bool isRunning = false;
  bool isVisible = false;
  ScrollController scrollController = ScrollController();
  List<String> newExNames = [];
  /// Contains all Exercises - linked and non linked ones - as a Map
  /// linked exercises are saved as another Map with key = linkName
  /// non linked Exercises are saved as the exercise itself with the ex.name as the key
  SplayTreeMap<String, dynamic> groupedExercises = SplayTreeMap();
  /// Contains for each linked exercise the currently selected index for getting the right one
  /// from the groupedExercises Map
  Map<String, int> selectedIndexes = {};
  late CnConfig cnConfig;
  List<String> linkWithMultipleExercisesStarted = [];
  List<String> exercisesToRemove = [];
  List<DismissedSingleSet> dismissedSets = [];
  double lastScrollPosition = 0;
  List<String> exerciseOrder = [];
  int currentIndexFocus = 0;
  int currentIndexWeightOrAmount = 0;
  GlobalKey keyKeyboardTopBar = GlobalKey();
  final double heightOfSetRow = 30;
  final double setPadding = 5;
  bool contentIsActive = false;

  CnRunningWorkout(BuildContext context){
    cnConfig = Provider.of<CnConfig>(context, listen: false);
  }
  
  void addExercise(
      Exercise ex,
      BuildContext context,
      {double? additionalScrollPosition}
      ){
    SingleSet newSet = ex.sets.first;
    NamedSet newNamedSet = NamedSet(
        set: newSet,
        name: ex.name,
        index: 0,
        ex: ex,
        weightController: TextEditingController(text: (newSet.weightAsTrimmedDouble?? "").toString()),
        amountController: TextEditingController(text: (newSet.getAmountAsText(ex.category)?? "").toString())
    );
    double maxScrollExtend = getMaxScrollExtend(context, additionalScrollPosition: additionalScrollPosition);
    if(ex.linkName == null){
      workoutTemplateModifiable.exercises.add(Exercise.copy(ex));
      workout.exercises.add(ex);
      newExNames.add(ex.name);
      exerciseOrder.add(ex.name);
      groupedExercises[ex.name] = ex;
      groupedExercises[getSetKeyName(ex.name, 0)] = newNamedSet;

      /// Add one set row and Exercise size
      if(maxScrollExtend > 0){
        maxScrollExtend = maxScrollExtend + 40 + 133;
      }
      scrollController.animateTo(maxScrollExtend, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else{
      final insertIndex = workout.exercises.lastIndexWhere((e) => e.linkName == ex.linkName) + 1;
      workoutTemplateModifiable.exercises.insert(insertIndex, Exercise.copy(ex));
      workout.exercises.insert(insertIndex ,ex);
      newExNames.add(ex.name);
      (groupedExercises[ex.linkName!] as GroupedExercise).add(ex);
      (groupedExercises[getSetKeyName(ex.linkName!, 0)] as GroupedSet).add(newNamedSet);

      final lastIndex = groupedExercises.keys.toList().indexWhere((element) => element == getSetKeyName(ex.linkName!, 0));
      List<MapEntry<String, dynamic>> tempGroupedExercises = groupedExercises.entries.whereIndexed((index, element) => index <= lastIndex).toList();

      final amountNamedSets = tempGroupedExercises.where((element) => element.value is NamedSet).length;
      List<dynamic> groupedSets = tempGroupedExercises.where((element) => element.value is GroupedSet).toList();
      final amountExercises = tempGroupedExercises.where((element) => element.value is Exercise).length;
      final amountGroupedExercises = tempGroupedExercises.where((element) => element.value is GroupedExercise).length - 1;
      final amountSeparators = tempGroupedExercises.where((element) => element.key.contains("|Separator")).length;
      int amountGroupedSets = 0;
      for(String linkName in selectedIndexes.keys){
        final exercise = (groupedExercises[linkName] as GroupedExercise).getExercise(selectedIndexes[linkName]!);
        for (MapEntry<String, dynamic> s in groupedSets){
          if(s.value.getSet(exercise!.name) != null){
            amountGroupedSets += 1;
          }
        }
      }
      final position = amountNamedSets * 40
          + (amountGroupedSets-1) * 40
          + amountExercises * 133
          + amountSeparators * 89
          + amountGroupedExercises * 167.0;
      /// subtract one Separator size
      if(maxScrollExtend > 89){
        maxScrollExtend = maxScrollExtend - 89;
      }
      scrollController.animateTo(position.clamp(0, maxScrollExtend), duration: const Duration(milliseconds: 1000), curve: Curves.easeInOut)
          .then((value) {
        selectedIndexes[ex.linkName!] = (groupedExercises[ex.linkName] as GroupedExercise).exercises.length-1;
        refresh();
      });
    }
    checkSeparator(ex);
    cache();
    refresh();
  }

  void addSet({required Exercise ex, required Exercise lastEx}){
    int newIndex = ex.sets.length;
    ex.addSet();
    lastEx.addSet();
    SingleSet newSet = ex.sets[newIndex];
    NamedSet newNamedSet = NamedSet(
        set: newSet,
        name: ex.name,
        index: newIndex,
        ex: ex,
        weightController: TextEditingController(text: (newSet.weightAsTrimmedDouble?? "").toString()),
        amountController: TextEditingController(text: (newSet.getAmountAsText(ex.category)?? "").toString())
    );
    if(ex.linkName == null){
      groupedExercises[getSetKeyName(ex.name, newIndex)] = newNamedSet;
    } else{
      final String newSetKey = getSetKeyName(ex.linkName!, newIndex);
      if(groupedExercises.containsKey(newSetKey)){
        (groupedExercises[getSetKeyName(ex.linkName!, newIndex)] as GroupedSet).add(newNamedSet);
      } else{
        groupedExercises[getSetKeyName(ex.linkName!, newIndex)] = GroupedSet(set: newNamedSet);
      }
    }
    final newControllerPos = scrollController.position.pixels+heightOfSetRow + setPadding*2;
    scrollController.jumpTo(newControllerPos);
    refresh();
  }

  double getMaxScrollExtend(BuildContext context, {double? additionalScrollPosition}){
    final amountNamedSets = groupedExercises.values.whereType<NamedSet>().length;
    final groupedSets = groupedExercises.values.whereType<GroupedSet>();
    final amountExercises = groupedExercises.values.whereType<Exercise>().length;
    final amountGroupedExercises = groupedExercises.values.whereType<GroupedExercise>().length;
    final amountSeparators = groupedExercises.keys.where((element) => element.contains("|Separator")).length;
    int amountGroupedSets = 0;
    for(String linkName in selectedIndexes.keys){
      final exercise = (groupedExercises[linkName] as GroupedExercise).getExercise(selectedIndexes[linkName]!);
      for (GroupedSet s in groupedSets){
        if(s.getSet(exercise!.name) != null){
          amountGroupedSets += 1;
        }
      }
    }
    double scrollExtend = amountNamedSets * 40
        + amountGroupedSets * 40
        + amountExercises * 133
        + amountSeparators * 89
        + amountGroupedExercises * 167
        + (Platform.isAndroid? 80 : 115) /// Top Spacer
        + 39                             /// Bottom Spacer
        - MediaQuery.of(context).size.height
        + (additionalScrollPosition?? 0);
    if(scrollExtend < 0){
      return 0;
    }
    return scrollExtend;
  }

  void deleteExercise(Exercise ex){
    workoutTemplateModifiable.exercises.removeWhere((e) => e.name == ex.name);
    dismissedSets.removeWhere((e) => e.exName == ex.name);
    workout.exercises.removeWhere((e) => e.name == ex.name);
    newExNames.removeWhere((e) => e == ex.name);
    groupedExercises.remove(ex.name);
    refresh();
  }

  void initCachedData(Map data){
    if(
      data.containsKey("workout") &&
      data.containsKey("workoutTemplateModifiable") &&
      data.containsKey("workoutTemplateNotModifiable") &&
      data.containsKey("isRunning") &&
      data.containsKey("isVisible") &&
      data.containsKey("selectedIndexes") &&
      data.containsKey("newExNames")
    ){
      isRunning = data["isRunning"];
      isVisible = data["isVisible"];
      newExNames = List<String>.from(data["newExNames"]);
      for(MapEntry entry in data["selectedIndexes"].entries){
        selectedIndexes[entry.key] = entry.value;
      }
      workout = Workout().fromMap(data["workout"]) ?? Workout();
      workoutTemplateModifiable = Workout().fromMap(data["workoutTemplateModifiable"]) ?? Workout();
      workoutTemplateNotModifiable = Workout().fromMap(data["workoutTemplateNotModifiable"]) ?? Workout();
      initGroupedExercises();
    }
  }

  void openRunningWorkout(BuildContext context, Workout w) async{
    setWorkoutTemplate(w);
    isRunning = true;
    isVisible = true;
    // refresh();
    // await Future.delayed(const Duration(milliseconds: 500));
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const ScreenRunningWorkout()
        ));
    cache();
  }

  void reopenRunningWorkout(BuildContext context) async{
    HapticFeedback.selectionClick();
    isVisible = true;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const ScreenRunningWorkout()
        ));
    cache();
  }

  void removeNotRelevantExercises(){
    workout.exercises.removeWhere((ex) => exercisesToRemove.contains(ex.name));
  }

  void setWorkoutTemplate(Workout w){
    workoutTemplateModifiable = w;
    workout = Workout.copy(w);
    workoutTemplateNotModifiable = Workout.copy(w);
    workout.resetAllExercisesSets(keepSetType: true);
    initSelectedIndexes();
    initGroupedExercises();
  }

  void initSelectedIndexes(){
    selectedIndexes = {
      for (String link in workout.linkedExercises)
        link:
        0
    };
  }

  void initGroupedExercises(){
    groupedExercises.clear();
    exerciseOrder.clear();

    for (Exercise ex in workout.exercises){

      /// single exercise
      if (ex.linkName == null){
        if(!exerciseOrder.contains(ex.name)){
          exerciseOrder.add(ex.name);
        }
        groupedExercises[ex.name] = ex;
        for(var i = 0; i < ex.sets.length; i++){
          groupedExercises[getSetKeyName(ex.name, i)] = NamedSet(
              set: ex.sets[i],
              name: ex.name,
              index: i,
              ex: ex,
              weightController: TextEditingController(text: (ex.sets[i].weightAsTrimmedDouble?? "").toString()),
              amountController: TextEditingController(text: (ex.sets[i].getAmountAsText(ex.category)?? "").toString())
          );
        }
      }

      /// linked exercise
      else{
        if(!exerciseOrder.contains(ex.linkName)){
          exerciseOrder.add(ex.linkName!);
        }
        if(!groupedExercises.containsKey(ex.linkName)){
          groupedExercises[ex.linkName!] = GroupedExercise(ex: ex);
        }
        else{
          (groupedExercises[ex.linkName] as GroupedExercise).add(ex);
        }
        for(var i = 0; i < ex.sets.length; i++){
          NamedSet namedSet = NamedSet(
              set: ex.sets[i],
              name: ex.name,
              index: i,
              ex: ex,
              weightController: TextEditingController(text: (ex.sets[i].weightAsTrimmedDouble?? "").toString()),
              amountController: TextEditingController(text: (ex.sets[i].getAmountAsText(ex.category)?? "").toString())
          );
          final String keyName = getSetKeyName(ex.linkName??"", i);
          if(groupedExercises.containsKey(keyName)){
            (groupedExercises[keyName] as GroupedSet).add(namedSet);
          } else{
            groupedExercises[keyName] = GroupedSet(set: namedSet);
          }
        }
      }

      checkSeparator(ex);
    }

    int customComparator(String a, String b) {
      String aFirst = a.split("_").first;
      String bFirst = b.split("_").first;
      String aLast = a.split("_").last;
      String bLast = b.split("_").last;
      final indexA = exerciseOrder.indexOf(aFirst);
      final indexB = exerciseOrder.indexOf(bFirst);
      if(indexA == indexB){
        if(aFirst == aLast && bFirst != bLast){
          return -1;
        } else if(aFirst != aLast && bFirst == bLast){
          return 1;
        }
        return aLast.compareTo(bLast);
      } else if(indexA > indexB){
        return 1;
      } else{
        return -1;
      }
    }
    SplayTreeMap<String, dynamic> rightOrderedGroupedExercises = SplayTreeMap<String, dynamic>(customComparator)..addAll(groupedExercises);
    groupedExercises = rightOrderedGroupedExercises;
  }

  void checkSeparator(Exercise ex){
    /// Use | before Separator String, so that it comes after the single sets because | is after the characters in ASCII table
    if(exerciseOrder.last.split("_").last != "|Separator"){
      exerciseOrder.add("${ex.linkName?? ex.name}_|Separator");
      groupedExercises["${ex.linkName?? ex.name}_|Separator"] = "Separator";
    }
  }

  Future<void> cache() async{
    Map data = {
      "workout": workout.asMap(),
      "workoutTemplateModifiable": workoutTemplateModifiable.asMap(),
      "workoutTemplateNotModifiable": workoutTemplateNotModifiable.asMap(),
      "isRunning": isRunning,
      "isVisible": isVisible,
      "selectedIndexes": selectedIndexes,
      "newExNames": newExNames
    };
    cnConfig.config.cnRunningWorkout = data;
    await cnConfig.config.save();
  }

  NamedSet? removeSpecificSetFromExercise(NamedSet set){
    NamedSet? removedSet;
    Exercise ex = set.ex;
    final oldSetsAmount = ex.sets.length;

    set.ex.sets.removeAt(set.index);
    Exercise? templateEx = workoutTemplateModifiable.exercises.where((exercise) => exercise.name == set.ex.name).firstOrNull;
    SingleSet? removedTemplateSet = templateEx?.sets.removeAt(set.index);

    if(ex.linkName == null){
      removedSet = groupedExercises[getSetKeyName(ex.name, set.index)];
      for(int i = set.index; i <= (oldSetsAmount-1); i++){
        if(i == oldSetsAmount-1){
          groupedExercises.remove(getSetKeyName(ex.name, i));
          break;
        }
        NamedSet nextNamedSet = groupedExercises[getSetKeyName(ex.name, i+1)];
        nextNamedSet.index -= 1;
        groupedExercises[getSetKeyName(ex.name, i)] = nextNamedSet;
      }
    }
    else {
      removedSet = groupedExercises[getSetKeyName(ex.linkName!, set.index)].getSet(ex.name);
      for(int i = set.index; i <= (oldSetsAmount-1); i++){
        if(i == oldSetsAmount-1){
          groupedExercises[getSetKeyName(ex.linkName!, i)].remove(ex.name);
          if(groupedExercises[getSetKeyName(ex.linkName!, i)].isEmpty()){
            groupedExercises.remove(getSetKeyName(ex.linkName!, i));
          }
          break;
        }
        NamedSet nextNamedSet = groupedExercises[getSetKeyName(ex.linkName!, i+1)].getSet(ex.name);
        nextNamedSet.index -= 1;
        groupedExercises[getSetKeyName(ex.linkName!, i)].set(nextNamedSet);
      }
    }
    removedSet?.templateSet = removedTemplateSet;
    return removedSet;
  }

  void addSpecificSetToExercise(NamedSet set){
    Exercise ex = set.ex;
    final oldSetsAmount = ex.sets.length;
    ex.sets.insert(set.index, set.set);

    Exercise? templateEx = workoutTemplateModifiable.exercises.where((exercise) => exercise.name == set.ex.name).firstOrNull;
    templateEx?.sets.insert(set.index, set.templateSet?? SingleSet());

    if(ex.linkName == null){
      for(int i = oldSetsAmount; i >= set.index; i--){
        if(i == set.index){
          groupedExercises[getSetKeyName(ex.name, i)] = set;
          break;
        }
        NamedSet previousNamedSet = groupedExercises[getSetKeyName(ex.name, i-1)];
        previousNamedSet.index += 1;
        groupedExercises[getSetKeyName(ex.name, i)] = previousNamedSet;
      }
    }
    else {
      for(int i = oldSetsAmount; i >= set.index; i--){
        if(i == set.index){
          if(groupedExercises.containsKey(getSetKeyName(ex.linkName!, i))){
            groupedExercises[getSetKeyName(ex.linkName!, i)].set(set);
          } else{
            groupedExercises[getSetKeyName(ex.linkName!, i)] = GroupedSet(set: set);
          }
          break;
        }
        NamedSet previousNamedSet = groupedExercises[getSetKeyName(ex.linkName!, i-1)].getSet(ex.name);
        previousNamedSet.index += 1;
        if(groupedExercises.containsKey(getSetKeyName(ex.linkName!, i))){
          groupedExercises[getSetKeyName(ex.linkName!, i)].set(previousNamedSet);
        } else{
          groupedExercises[getSetKeyName(ex.linkName!, i)] = GroupedSet(set: previousNamedSet);
        }
      }
    }
  }

  void checkMultipleExercisesPerLink(){
    Map<String, int> linkCounter = {};
    Workout tempWo = Workout.clone(workout);
    tempWo.removeEmptyExercises();
    for(Exercise ex in tempWo.exercises){
      if(ex.linkName == null){
        continue;
      }
      if(linkCounter.containsKey(ex.linkName)){
        linkCounter[ex.linkName!] = linkCounter[ex.linkName]! + 1;
      } else{
        linkCounter[ex.linkName!] = 1;
      }
    }
    linkCounter.removeWhere((key, value) => value <= 1);
    linkWithMultipleExercisesStarted = linkCounter.entries.map((e) => e.key).toList();
  }

  void clear(){
    lastScrollPosition = 0;
    workout = Workout();
    selectedIndexes.clear();
    groupedExercises.clear();
    exercisesToRemove.clear();
    dismissedSets.clear();
    newExNames.clear();
    linkWithMultipleExercisesStarted.clear();
    scrollController = ScrollController();
    isRunning = false;
    cnConfig.setCnRunningWorkout({});
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}

class GroupedExercise{
  List<Exercise> _exercises = [];

   GroupedExercise({required Exercise ex}){
     _exercises.add(ex);
   }

   Exercise? getExercise(int index){
     if(index > _exercises.length-1){
       return null;
     }
     return _exercises[index];
   }

   void add(Exercise ex){
     _exercises.add(ex);
   }

   List<Exercise> get exercises => _exercises;
}

class NamedSet{
  final String name;
  final SingleSet set;
  SingleSet? templateSet;
  int index;
  final Exercise ex;
  final TextEditingController weightController;
  final TextEditingController amountController;
  final UniqueKey slidableKey = UniqueKey();
  final GlobalKey weightKey = GlobalKey();
  final GlobalKey amountKey = GlobalKey();
  final FocusNode focusNodeWeight = FocusNode();
  final FocusNode focusNodeAmount = FocusNode();

  NamedSet({
    required this.set,
    required this.name,
    required this.index,
    required this.ex,
    required this.weightController,
    required this.amountController,
    this.templateSet
  });

}

class GroupedSet{
  final Map<String, NamedSet> _sets = {};

  GroupedSet({required NamedSet set}){
    _sets[set.name] = set;
  }

  NamedSet? getSet(String exName){
    return _sets[exName];
  }

  void add(NamedSet set){
    _sets[set.name] = set;
  }

  void set(NamedSet set){
    _sets[set.name] = set;
  }

  NamedSet? remove(String key){
    NamedSet? s = _sets.remove(key);
    return s;
  }

  isEmpty(){
    return _sets.isEmpty;
  }
}