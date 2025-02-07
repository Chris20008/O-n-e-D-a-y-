import 'package:collection/collection.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:fitness_app/widgets/multiple_exercise_row.dart';
import 'package:fitness_app/widgets/my_slide_up_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../objects/exercise.dart';
import '../../../objects/workout.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectorExercisesToUpdate extends StatefulWidget {

  final Workout workout;
  final Workout workoutTemplate;
  final Function onConfirm;
  final Function onCancel;
  final PanelController controller;
  final String descendantAnimationControllerName;

  const SelectorExercisesToUpdate({
    super.key,
    required this.workout,
    required this.workoutTemplate,
    required this.onConfirm,
    required this.onCancel,
    required this.controller,
    required this.descendantAnimationControllerName
  });

  @override
  State<SelectorExercisesToUpdate> createState() => _SelectorExercisesToUpdateState();
}

class _SelectorExercisesToUpdateState extends State<SelectorExercisesToUpdate> {

  late List<bool> isCheckedList;
  late Workout workout;
  List<Exercise> relevantExercises = [];
  ScrollController sc = ScrollController();

  /// listen to bottomMenu for height changes
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context);

  @override
  void initState() {
    workout = Workout.clone(widget.workout);
    workout.removeEmptyExercises();
    final List<String> allExNamesTemplate = widget.workoutTemplate.exercises.map((e) => e.name).toList();
    for(Exercise ex in workout.exercises){
      if(!allExNamesTemplate.contains(ex.name)){
        relevantExercises.add(ex);
        continue;
      }
      final tempEx = widget.workoutTemplate.exercises.firstWhere((e) => ex.name == e.name);
      if(!ex.equals(tempEx)){
        relevantExercises.add(ex);
      }
    }
    isCheckedList = List<bool>.generate(relevantExercises.length, (index) => false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return MySlideUpPanel(
      animationControllerName: "SelectorExerciseToUpdate",
      descendantAnimationControllerName: widget.descendantAnimationControllerName,
      backdropEnabled: true,
      backdropOpacity: 0.25,
      controller: widget.controller,
      bounce: false,
      // maxHeight: ((relevantExercises.length == 1? 192 : relevantExercises.length * 207) + cnBottomMenu.height + 94),
      panel: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ClipRRect(
            // borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  color: Theme.of(context).primaryColor,
                  child: ListView.separated(
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
                      Padding(
                          padding: const EdgeInsets.only(top:10, bottom: 10),
                          child: panelTopBar
                      ),
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
                            Theme.of(context).primaryColor.withOpacity(0.0),
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
                      height: cnBottomMenu.height-10,
                    )
                ),
                /// bottom faded box
                Positioned(
                  bottom: cnBottomMenu.height - 10.5,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient:  LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.0),
                            Theme.of(context).primaryColor,
                          ]
                      ),
                    ),
                    height: 30,
                  ),
                ),
                /// bottom buttons
                Positioned(
                    bottom: -10,
                    left: 0,
                    right: 0,
                    child: Row(
                      children: [
                        if(relevantExercises.isNotEmpty)
                        Expanded(
                          child: CupertinoButton(
                            child: SizedBox(
                                height: cnBottomMenu.height-10,
                                child: Center(child: Text(AppLocalizations.of(context)!.confirm))
                            ),
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
                                widget.onConfirm();
                                if(doUpdate){
                                  workout.exercises = relevantExercises;
                                  workout.updateTemplate();
                                }
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: CupertinoButton(
                            child: SizedBox(
                                height: cnBottomMenu.height-10,
                                child: Center(child: Text(relevantExercises.isNotEmpty? AppLocalizations.of(context)!.cancel : AppLocalizations.of(context)!.ok))
                            ),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              widget.onCancel();
                            },
                          ),
                        ),
                      ],
                    )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Exercise> getExercises(int index, BuildContext context){
    Exercise tempNew = Exercise.copy(relevantExercises[index]);
    Exercise tempTemplate = Exercise.copy(widget.workoutTemplate.exercises.firstWhereOrNull((ex) => ex.name == tempNew.name) ?? Exercise());

    tempNew.name = AppLocalizations.of(context)!.myNew;
    tempTemplate.name = AppLocalizations.of(context)!.template;

    return [tempTemplate, tempNew];
  }
}
