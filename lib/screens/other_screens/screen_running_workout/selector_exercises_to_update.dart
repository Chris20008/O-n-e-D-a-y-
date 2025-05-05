import 'package:collection/collection.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/screen_running_workout.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:fitness_app/widgets/cupertino_button_text.dart';
import 'package:fitness_app/widgets/multiple_exercise_row.dart';
import 'package:fitness_app/widgets/slide_up_panel/my_slide_up_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../objects/exercise.dart';
import '../../../objects/workout.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';

class SelectorExercisesToUpdate extends StatefulWidget {

  const SelectorExercisesToUpdate({
    super.key,
  });

  @override
  State<SelectorExercisesToUpdate> createState() => _SelectorExercisesToUpdateState();
}

class _SelectorExercisesToUpdateState extends State<SelectorExercisesToUpdate> {

  /// listen to bottomMenu for height changes
  late CnBottomMenu cnBottomMenu;
  late CnRunningWorkout cnRunningWorkout;
  late CnSelectorExerciseToUpdate cnSelectorExerciseToUpdate;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    cnBottomMenu = Provider.of<CnBottomMenu>(context);
    cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen:false);
    cnSelectorExerciseToUpdate = Provider.of<CnSelectorExerciseToUpdate>(context, listen:true);

    final List<Exercise> relevantExercises = cnSelectorExerciseToUpdate.relevantExercises;
    final List isCheckedList = cnSelectorExerciseToUpdate.isCheckedList;
    final Workout workout = cnSelectorExerciseToUpdate.workout;

    return MySlideUpPanel(
      key: cnSelectorExerciseToUpdate.key,
      animationControllerName: cnSelectorExerciseToUpdate.animationControllerName,
      descendantAnimationControllerName: cnSelectorExerciseToUpdate.descendantNameExerciseToUpdate,
      backdropEnabled: true,
      backdropOpacity: 0.25,
      controller: cnSelectorExerciseToUpdate.panelController,
      panelBuilder: (context, listView){
        return SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  color: Theme.of(context).primaryColor,
                  child: listView(
                      controller: cnSelectorExerciseToUpdate.sc,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: cnBottomMenu.height+10, top: 100),
                      shrinkWrap: true,
                      separatorBuilder: (context, index){
                        return Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: mySeparator(heightBottom: 15, heightTop: 15),
                        );
                      },
                      itemCount: relevantExercises.length,
                      itemBuilder: (context, index){
                        return Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                isCheckedList[index] = !isCheckedList[index];
                                if(isCheckedList[index]){
                                  vibrateConfirm();
                                } else{
                                  vibrateCancel();
                                }
                              });
                            },
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width-100
                                      ),
                                      child: OverflowSafeText(
                                          relevantExercises[index].name,
                                          fontSize: 20,
                                          minFontSize: 16,
                                          maxLines: 1
                                      ),
                                    ),
                                    /// Container to be able to click the are to trigger the checkbox tap
                                    Expanded(child: Container(color: Colors.transparent ,height: 50,),),
                                    Transform.scale(
                                      scale: 1.4,
                                      child: Checkbox(
                                        checkColor: Colors.white,
                                        value: isCheckedList[index],
                                        shape: const CircleBorder(),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isCheckedList[index] = value?? false;
                                            if(value?? false){
                                              vibrateConfirm();
                                            } else{
                                              vibrateCancel();
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                MultipleExerciseRow(
                                  exercises: getExercises(index, context),
                                  fontSize: 15,
                                  colorFade: Theme.of(context).primaryColor,
                                  comparePreviousExercise: true,
                                )
                              ],
                            ),
                          ),
                        );
                      }
                  ),
                ),
                Container(
                  height: 84,
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    children: [
                      // Padding(
                      //     padding: const EdgeInsets.only(top:10, bottom: 10),
                      //     child: panelTopBar
                      // ),
                      const SizedBox(height: 20,),
                      Center(
                          child: OverflowSafeText(
                              relevantExercises.isEmpty
                                  ? AppLocalizations.of(context)!.runningWorkoutNoExerciseUpdate
                                  : AppLocalizations.of(context)!.runningWorkoutSelectExerciseUpdate,
                              fontSize: 22,
                              textAlign: TextAlign.center
                          )
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 83.8,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient:  LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Theme.of(context).primaryColor.withValues(alpha: 0.0),
                            Theme.of(context).primaryColor,
                          ]
                      ),
                    ),
                    height: 30,
                  ),
                ),
                /// bottom colored box
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Theme.of(context).primaryColor,
                      height: cnBottomMenu.height,
                    )
                ),
                /// bottom faded box
                Positioned(
                  bottom: cnBottomMenu.height - 0.5,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient:  LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).primaryColor.withValues(alpha: 0.0),
                            Theme.of(context).primaryColor,
                          ]
                      ),
                    ),
                    height: 30,
                  ),
                ),
                /// bottom buttons
                Positioned(
                    bottom: Platform.isAndroid? 10 : -5,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoButtonText(
                              text: relevantExercises.isNotEmpty? AppLocalizations.of(context)!.cancel : AppLocalizations.of(context)!.ok,
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                cnSelectorExerciseToUpdate.panelController.close();
                              },
                            ),
                          ),

                          const Spacer(),

                          if(relevantExercises.isNotEmpty)
                            Expanded(
                              child: CupertinoButtonText(
                                text: AppLocalizations.of(context)!.confirm,
                                onPressed: () {
                                  bool doUpdate = isCheckedList.any((state) => state);
                                  if(doUpdate){
                                    List<int> indexesToRemove = [];
                                    for (num index in range(isCheckedList.length)){
                                      if(isCheckedList[index.toInt()] == false){
                                        indexesToRemove.add(index.toInt());
                                      }
                                    }
                                    for(int index in indexesToRemove.reversed){
                                      relevantExercises.removeAt(index);
                                    }
                                  }
                                  Future.delayed(const Duration(milliseconds: 200), (){
                                    cnRunningWorkout.finishWorkout(context);
                                    if(doUpdate){
                                      workout.exercises = relevantExercises;
                                      workout.updateTemplate();
                                    }
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    )
                )
              ],
            ),
          ),
        );
      },
    );
  }

  List<Exercise> getExercises(int index, BuildContext context){
    Exercise tempNew = Exercise.copy(cnSelectorExerciseToUpdate.relevantExercises[index]);
    Exercise tempTemplate = Exercise.copy(cnSelectorExerciseToUpdate.workoutTemplate.exercises.firstWhereOrNull((ex) => ex.name == tempNew.name) ?? Exercise());

    tempNew.name = AppLocalizations.of(context)!.myNew;
    tempTemplate.name = AppLocalizations.of(context)!.template;

    return [tempTemplate, tempNew];
  }
}


class CnSelectorExerciseToUpdate extends ChangeNotifier {
  final String animationControllerName = "SelectorExerciseToUpdate";
  final String descendantNameExerciseToUpdate = "ScreenRunningWorkout";
  PanelController panelController = PanelController();
  List<bool> isCheckedList = [];
  List<Exercise> relevantExercises = [];
  ScrollController sc = ScrollController();
  Workout workoutTemplate =  Workout();
  Workout workout = Workout();
  UniqueKey key = UniqueKey();

  CnSelectorExerciseToUpdate();

  void reset(){
    isCheckedList.clear();
    relevantExercises.clear();
    sc = ScrollController();
  }

  void initData({
    required Workout woT,
    required Workout wo,
    bool withRefresh = true
  }){
    workoutTemplate =  Workout.clone(woT);
    workout = Workout.clone(wo);
    workout.removeEmptyExercises();
    relevantExercises.clear();
    final List<String> allExNamesTemplate = workoutTemplate.exercises.map((e) => e.name).toList();
    for(Exercise ex in workout.exercises){
      if(!allExNamesTemplate.contains(ex.name)){
        relevantExercises.add(ex);
        continue;
      }
      final tempEx = workoutTemplate.exercises.firstWhere((e) => ex.name == e.name);
      if(!ex.equals(tempEx)){
        relevantExercises.add(ex);
      }
    }
    isCheckedList = List<bool>.generate(relevantExercises.length, (index) => false);
    if(withRefresh){
      refresh();
    }
  }

  Future openPanel() async{
    await panelController.animatePanelToPosition(
        1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastEaseInToSlowEaseOut
    );
  }

  bool get isOpened => panelController.panelPosition > 0;

  void refresh(){
    notifyListeners();
  }
}