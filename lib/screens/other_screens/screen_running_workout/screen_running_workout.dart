import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/selector_exercises_to_update.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/stopwatch.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/running_workout_content/running_workout_content.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/running_workout_footer/running_workout_footer.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/wrapper_screen_running_workout.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/widgets/banner_running_workout.dart';
import 'package:fitness_app/widgets/slide_up_panel/initial_animated_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../objects/exercise.dart';
import '../../../objects/workout.dart';
import '../../../util/backup_helper/save_backup.dart';
import '../../../util/backup_helper/save_current_data.dart';
import '../../../util/constants.dart';
import '../../../widgets/slide_up_panel/animation_controller_name.dart';
import '../../main_screens/screen_workouts/screen_workouts.dart';
import '../all_exercises_panel/all_exercises_panel.dart';
import 'widgets/animated_column.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScreenRunningWorkout extends StatefulWidget {
  const ScreenRunningWorkout({
    super.key,
  });

  @override
  State<ScreenRunningWorkout> createState() => _ScreenRunningWorkoutState();
}

class _ScreenRunningWorkoutState extends State<ScreenRunningWorkout>{

  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  double viewInsetsBottom = 0;
  bool isAlreadyCheckingKeyboard = false;

  @override
  Widget build(BuildContext context) {
    viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    if(!cnRunningWorkout.scrollController.hasClients){
      cnRunningWorkout.scrollController.dispose();
      cnRunningWorkout.scrollController = ScrollController(initialScrollOffset: cnRunningWorkout.lastScrollPosition);
    }

    pr("Running Workout");

    return Scaffold(
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
              animationControllerName: AnimationControllerName.screenRunningWorkout,
              child: Scaffold(
                backgroundColor: Theme.of(context).primaryColor,
                extendBody: true,
                resizeToAvoidBottomInset: false,
                bottomNavigationBar: const RunningWorkoutFooter(),
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
                      const BannerRunningWorkout(),

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

            const AllExercisesPanel(
              id: AllExercisePanelIds.runningWorkoutAllExercisesPanel,
              descendantAnimationControllerName: AnimationControllerName.screenRunningWorkout,
            ),

            const SelectorExercisesToUpdate(),

              Selector<CnRunningWorkout, bool>(
                  selector: (_, cn) => cn.isSavingData,
                  builder: (_, isSavingData, __){
                    return isSavingData ? Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Center(
                        child: CupertinoActivityIndicator(
                            radius: 20.0,
                            color: Colors.amber[800]
                        ),
                      ),
                    ) : const SizedBox();
                }
              )
          ],
        ),
      ),
    );
  }

  onPressedLeft(){
  //   if(cnRunningWorkout.currentIndexWeightOrAmount == 0){
  //     cnRunningWorkout.currentIndexFocus -= 1;
  //     cnRunningWorkout.currentIndexWeightOrAmount = 1;
  //   } else{
  //     cnRunningWorkout.currentIndexWeightOrAmount = 0;
  //   }
  //
  //   NamedSet? set = getSet(-1);
  //
  //   if(set == null){
  //     FocusManager.instance.primaryFocus?.unfocus();
  //     return;
  //   }
  //
  //   FocusNode focusNode = cnRunningWorkout.currentIndexWeightOrAmount == 0? set.focusNodeWeight : set.focusNodeAmount;
  //
  //   if (cnRunningWorkout.currentIndexFocus < cnRunningWorkout.groupedExercises.length) {
  //     FocusScope.of(context).requestFocus(focusNode);
  //     onTapField(cnRunningWorkout.currentIndexFocus, cnRunningWorkout.currentIndexWeightOrAmount, set: set);
  //   }
  }

  onPressedRight(){
  //   if(cnRunningWorkout.currentIndexWeightOrAmount == 0){
  //     cnRunningWorkout.currentIndexWeightOrAmount = 1;
  //   } else{
  //     cnRunningWorkout.currentIndexWeightOrAmount = 0;
  //     cnRunningWorkout.currentIndexFocus += 1;
  //   }
  //
  //   NamedSet? set = getSet(1);
  //
  //   if(set == null){
  //     FocusManager.instance.primaryFocus?.unfocus();
  //     return;
  //   }
  //
  //   FocusNode focusNode = cnRunningWorkout.currentIndexWeightOrAmount == 0? set.focusNodeWeight : set.focusNodeAmount;
  //
  //   if (cnRunningWorkout.currentIndexFocus < cnRunningWorkout.groupedExercises.length) {
  //     FocusScope.of(context).requestFocus(focusNode);
  //     onTapField(cnRunningWorkout.currentIndexFocus, cnRunningWorkout.currentIndexWeightOrAmount, set: set);
  //   }
  }

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
  /// Contains all Exercises - linked and non linked ones - with their
  /// corresponding sets as a Map
  SplayTreeMap<String, dynamic> groupedExercises = SplayTreeMap();
  /// Contains for each linked exercise the currently selected index for getting the right one
  /// from the groupedExercises Map
  Map<String, int> selectedIndexes = {};
  List<String> linkWithMultipleExercisesStarted = [];
  List<DismissedSingleSet> dismissedSets = [];
  double lastScrollPosition = 0;
  List<String> exerciseOrder = [];
  int currentIndexFocus = 0;
  int currentIndexWeightOrAmount = 0;
  GlobalKey keyKeyboardTopBar = GlobalKey();
  final double heightOfSetRow = 30;
  final double setPadding = 5;
  bool contentIsActive = true;
  bool isSavingData = false;
  late CnConfig cnConfig;
  late CnWorkouts cnWorkouts;
  late CnStopwatchWidget cnStopwatch;
  late CnBannerRunningWorkout cnBannerRunningWorkout;
  late CnSelectorExerciseToUpdate cnSelectorExerciseToUpdate;

  CnRunningWorkout(BuildContext context){
    cnConfig = Provider.of<CnConfig>(context, listen: false);
    cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
    cnStopwatch = Provider.of<CnStopwatchWidget>(context, listen: false);
    cnBannerRunningWorkout = Provider.of<CnBannerRunningWorkout>(context, listen: false);
    cnSelectorExerciseToUpdate = Provider.of<CnSelectorExerciseToUpdate>(context, listen: false);
  }

  void updateOrFinishWorkout({List<String>? exToRemove, int? delay, required BuildContext context}){
    if(canUpdateTemplate()){
      Future.delayed(Duration(milliseconds: delay?? 200), (){
        cnSelectorExerciseToUpdate.reset();
        cnSelectorExerciseToUpdate.initData(
          wo: workout,
          woT: workoutTemplateModifiable,
          woNM: workoutTemplateNotModifiable
        );
        Future.delayed(const Duration(milliseconds: (100)), (){
          FocusManager.instance.primaryFocus?.unfocus();
          cnSelectorExerciseToUpdate.openPanel();
        });
      });
    }
    else{
      finishWorkout(context);
    }
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
    Workout tempWo = Workout.clone(workout);
    tempWo.removeEmptyExercises();

    if(tempWo.exercises.isEmpty){
      return false;
    }

    /// Get exercises names of true template
    List<String> templateWorkoutExerciseNames = workoutTemplateNotModifiable.exercises.map((e) => e.name).toList();

    /// Iterate over every exercise in the current running (new) one
    for(Exercise ex in tempWo.exercises){
      /// Exercise name does not exist in true template yet => new exercise has been added => can update Template
      if(!templateWorkoutExerciseNames.contains(ex.name)){
        return true;
      }
      /// When the exercise name already exists, we check if the exercise of the true template and the current running one are truly the same
      Exercise tempTemplateEx = workoutTemplateNotModifiable.exercises.firstWhere((e) => e.name == ex.name);
      if(!tempTemplateEx.equals(ex)){
        return true;
      }
    }
    return false;
  }

  Future finishWorkout(BuildContext context) async{
    isSavingData = true;
    refresh();


    await Future.delayed(const Duration(milliseconds: 300));
    if(cnSelectorExerciseToUpdate.isOpened){
      await cnSelectorExerciseToUpdate.panelController.close();
    }

    /// delay that the popup is closed
    await Future.delayed(const Duration(milliseconds: 100), ()async{
      workout.refreshDate();
      workout.removeEmptyExercises();
      if(workout.exercises.isNotEmpty){
        workout.saveToDatabase();
        cnWorkouts.refreshAllWorkouts();
      }
      if(cnStopwatch.isRunning){
        cnStopwatch.cancelTimer();
      }

      if(cnConfig.automaticBackups){
        await saveBackup(withCloud: cnConfig.connectWithCloud, cnConfig: cnConfig) != null;
      }

      await saveCurrentData(cnConfig) != null;

      if(context.mounted){
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
        await stopWorkout(time: 0, context: context);
        isSavingData = false;
      }
      else {
        isSavingData = false;
        refresh();
      }
    });
  }

  Future stopWorkout({int? time, required BuildContext context})async{
    time = time?? 200;
    await Future.delayed(Duration(milliseconds: time), ()async{
      isVisible = false;
      isRunning = false;
      cnBannerRunningWorkout.reset();
      // refresh();
      cnWorkouts.refresh();
      await Future.delayed(const Duration(milliseconds: 50), ()async{
        if(context.mounted){
          Navigator.of(context).pop();
        }
        /// delayed that the pop context is finished, if to short, the user
        /// will se a blank page which is not wanted
        await Future.delayed(const Duration(milliseconds: 500), (){
          clear();
          if(cnStopwatch.isRunning){
            cnStopwatch.cancelTimer();
          }
        });
      });
    });
  }
  
  void addExercise(
      Exercise ex,
      BuildContext context,
      {double? additionalScrollPosition, Exercise? exTemplate}
      ){
    List<NamedSet> namedSets = [];
    (ex.sets).forEachIndexed((index, set){
      NamedSet newNamedSet = NamedSet(
          set: set,
          name: ex.name,
          index: index,
          ex: ex,
          // weightController: TextEditingController(text: (set.weightAsTrimmedDouble?? "").toString()),
          // amountController: TextEditingController(text: (set.getAmountAsText(ex.category)?? "").toString())
          weightController: TextEditingController(text: ("").toString()),
          amountController: TextEditingController(text: ("").toString())
      );
      namedSets.add(newNamedSet);
    });
    // SingleSet newSet = ex.sets.first;
    // NamedSet newNamedSet = NamedSet(
    //     set: newSet,
    //     name: ex.name,
    //     index: 0,
    //     ex: ex,
    //     weightController: TextEditingController(text: (newSet.weightAsTrimmedDouble?? "").toString()),
    //     amountController: TextEditingController(text: (newSet.getAmountAsText(ex.category)?? "").toString())
    // );
    double maxScrollExtend = getMaxScrollExtend(context, additionalScrollPosition: additionalScrollPosition);
    if(ex.linkName == null){
      workoutTemplateModifiable.exercises.add(Exercise.copy(exTemplate?? ex));
      workout.exercises.add(ex);
      newExNames.add(ex.name);
      exerciseOrder.add(ex.name);
      groupedExercises[ex.name] = ex;
      namedSets.forEachIndexed((index, set){
        groupedExercises[getSetKeyName(ex.name, index)] = set;
      });
      // groupedExercises[getSetKeyName(ex.name, 0)] = newNamedSet;

      /// Add one set row and Exercise size
      if(maxScrollExtend > 0){
        maxScrollExtend = maxScrollExtend + 40*namedSets.length.clamp(1, 10) + 133;
      }
      scrollController.animateTo(maxScrollExtend, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else{
      final insertIndex = workout.exercises.lastIndexWhere((e) => e.linkName == ex.linkName) + 1;
      workoutTemplateModifiable.exercises.insert(insertIndex, Exercise.copy(exTemplate?? ex));
      workout.exercises.insert(insertIndex ,ex);
      newExNames.add(ex.name);
      (groupedExercises[ex.linkName!] as GroupedExercise).add(ex);
      namedSets.forEachIndexed((index, set){
        final key = getSetKeyName(ex.linkName!, index);
        if(groupedExercises.containsKey(key)){
          (groupedExercises[key] as GroupedSet).add(set);
        } else{
          groupedExercises[key] = GroupedSet(set: set);
        }
      });
      // (groupedExercises[getSetKeyName(ex.linkName!, 0)] as GroupedSet).add(newNamedSet);

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

  bool hasStartedWorkout(){
    Workout tempWo = Workout.clone(workout);
    tempWo.removeEmptyExercises();
    if(tempWo.exercises.isEmpty){
      return false;
    }
    return true;
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
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const WrapperScreenRunningWorkout()
        ));
    cache();
  }

  void reopenRunningWorkout(BuildContext context) async{
    HapticFeedback.selectionClick();
    isVisible = true;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const WrapperScreenRunningWorkout()
        ));
    cache();
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

    /// remove set from exercise
    set.ex.sets.removeAt(set.index);
    /// remove set from template modifiable exercise
    Exercise? templateEx = workoutTemplateModifiable.exercises.where((exercise) => exercise.name == set.ex.name).firstOrNull;
    SingleSet? removedTemplateSet = templateEx?.sets.removeAt(set.index);

    /// Remove Set from groupedExercises Map
    /// Single Exercise, no Group
    if(ex.linkName == null){
      removedSet = groupedExercises[getSetKeyName(ex.name, set.index)];
      /// iterate over all higher sets and reduce index by one
      for(int i = set.index; i <= (oldSetsAmount-1); i++){
        /// when reached last set, remove the set
        if(i == oldSetsAmount-1){
          groupedExercises.remove(getSetKeyName(ex.name, i));
          break;
        }
        NamedSet nextNamedSet = groupedExercises[getSetKeyName(ex.name, i+1)];
        nextNamedSet.index -= 1;
        groupedExercises[getSetKeyName(ex.name, i)] = nextNamedSet;
      }
    }

    /// Grouped Exercise
    else {
      removedSet = groupedExercises[getSetKeyName(ex.linkName!, set.index)].getSet(ex.name);
      /// iterate over all higher sets and reduce index by one
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
    dismissedSets.clear();
    newExNames.clear();
    linkWithMultipleExercisesStarted.clear();
    scrollController = ScrollController();
    isRunning = false;
    cnConfig.setCnRunningWorkout({});
    isSavingData = false;
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}

class GroupedExercise{
  final List<Exercise> _exercises = [];

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
  late final ValueKey slidableKey = ValueKey("${ex.name}_$index");
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