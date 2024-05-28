import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../objects/exercise.dart';
import '../../../util/constants.dart';
import '../../../widgets/multiple_exercise_row.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectorExercisesPerLink extends StatefulWidget {
  final Map groupedExercises;
  final Function onConfirm;
  final Function onCancel;
  final List<String> relevantLinkNames;

  const SelectorExercisesPerLink({
    super.key,
    required this.groupedExercises,
    required this.onConfirm,
    required this.onCancel,
    required this.relevantLinkNames
  });

  @override
  State<SelectorExercisesPerLink> createState() => _SelectorExercisesPerLinkState();
}

class _SelectorExercisesPerLinkState extends State<SelectorExercisesPerLink> {
  late List<List<bool>> isCheckedList;
  Map groupedExercises = {};

  @override
  void initState() {
    for(MapEntry e in widget.groupedExercises.entries){
      if(!widget.relevantLinkNames.contains(e.key) || e.value is Exercise){
        continue;
      }
      groupedExercises[e.key] = e.value.map((ex) => Exercise.copy(ex)).toList();
      for(Exercise ex in groupedExercises[e.key]){
        ex.removeEmptySets();
      }
    }
    isCheckedList = groupedExercises.entries.map((e) => List<bool>.generate(e.value.length, (index) => true)).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final linkNames = groupedExercises.keys.toList();

    return Stack(
      children: [
        GestureDetector(
          onTap: (){
            HapticFeedback.selectionClick();
            widget.onCancel();
          },
        ),
        SafeArea(
          top: false,
          bottom: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).orientation == Orientation.portrait? 60 : 20, horizontal: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      color: Theme.of(context).primaryColor,
                      child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 60, top: 95),
                          shrinkWrap: true,
                          separatorBuilder: (context, index){
                            return Padding(
                              padding: const EdgeInsets.only(left: 15, right: 15),
                              child: mySeparator(heightBottom: 15, heightTop: 15),
                            );
                          },
                          itemCount: groupedExercises.keys.length,
                          itemBuilder: (context, index){
                            return Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: OverflowSafeText(
                                              "${AppLocalizations.of(context)!.runningWorkoutGroup}: ${linkNames[index]}",
                                              minFontSize: 20,
                                              maxLines: 1
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15,),
                                  for(Exercise ex in groupedExercises[linkNames[index]])
                                    /// show only exercises that actually to have filled sets
                                    /// In a Group with 3 or more Exercises it is likely to happen
                                    /// that the user fills two exercises. However the not filled
                                    /// exercises are still in the group. Here we filter for only those
                                    /// that actually have filled sets
                                    if(ex.sets.isNotEmpty)
                                      GestureDetector(
                                        onTap: (){
                                          setState(() {
                                            final currentState = isCheckedList[index][groupedExercises[linkNames[index]].indexOf(ex)];
                                            isCheckedList[index][groupedExercises[linkNames[index]].indexOf(ex)] = !currentState;
                                            if(!currentState){
                                              vibrateConfirm();
                                            } else{
                                              vibrateCancel();
                                            }
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: MultipleExerciseRow(
                                                exercises: [ex],
                                                fontSize: 15,
                                                colorFade: Theme.of(context).primaryColor,
                                              ),
                                            ),
                                            Transform.scale(
                                              scale: 1.4,
                                              child: Checkbox(
                                                checkColor: Colors.white,
                                                value: isCheckedList[index][groupedExercises[linkNames[index]].indexOf(ex)],
                                                shape: const CircleBorder(),
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    isCheckedList[index][groupedExercises[linkNames[index]].indexOf(ex)] = value?? false;
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
                                      )
                                ],
                              ),
                            );
                          }
                      ),
                    ),
                    Container(
                      height: 80,
                      padding: const EdgeInsets.all(10),
                      color: Theme.of(context).primaryColor,
                      child: Center(
                          child: OverflowSafeText(
                            AppLocalizations.of(context)!.runningWorkoutSelectGroup,
                            textAlign: TextAlign.center,
                            fontSize: 22,
                          )
                      ),
                    ),
                    Positioned(
                      top: 79.8,
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
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Theme.of(context).primaryColor,
                          height: 40,
                        )
                    ),
                    Positioned(
                      bottom: 39.5,
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
                    Positioned(
                        bottom: -5,
                        left: 0,
                        right: 0,
                        child: Row(
                          children: [
                            // if(workout.exercises.isNotEmpty)
                            Expanded(
                                child: ElevatedButton(
                                    onPressed: () {
                                      List<String> exToRemove = [];
                                      int index = 0;
                                      int indexJ = 0;
                                      for(List<bool> checks in isCheckedList){
                                        for(bool check in checks){
                                          if(check){
                                            indexJ += 1;
                                            continue;
                                          }
                                          exToRemove.add(groupedExercises[linkNames[index]][indexJ].name);
                                          indexJ += 1;
                                        }
                                        indexJ = 0;
                                        index += 1;
                                      }
                                      HapticFeedback.selectionClick();
                                      widget.onConfirm(exToRemove: exToRemove);
                                    },
                                    style: ButtonStyle(
                                        shadowColor: MaterialStateProperty.all(Colors.transparent),
                                        surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
                                        backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
                                    ),
                                    child: Text(AppLocalizations.of(context)!.confirm)
                                )
                            ),
                            SizedBox(height: 37, child: verticalGreySpacer),
                            Expanded(
                                child: ElevatedButton(
                                    onPressed: () {
                                      HapticFeedback.selectionClick();
                                      widget.onCancel();
                                    },
                                    style: ButtonStyle(
                                        shadowColor: MaterialStateProperty.all(Colors.transparent),
                                        surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
                                        backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                        // backgroundColor: MaterialStateProperty.all(Colors.grey[800]!.withOpacity(0.6)),
                                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
                                    ),
                                    child: Text(AppLocalizations.of(context)!.cancel)
                                )
                            ),
                          ],
                        )
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
