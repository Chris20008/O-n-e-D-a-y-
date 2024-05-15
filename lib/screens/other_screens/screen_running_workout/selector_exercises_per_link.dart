import 'package:flutter/material.dart';

import '../../../objects/exercise.dart';
import '../../../util/constants.dart';
import '../../../widgets/multiple_exercise_row.dart';

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
    print("RELEVANT LINKS");
    print(widget.relevantLinkNames);
    for(MapEntry e in widget.groupedExercises.entries){
      if(!widget.relevantLinkNames.contains(e.key) || e.value is Exercise){
        continue;
      }
      groupedExercises[e.key] = e.value.map((ex) => Exercise.copy(ex)).toList();
      for(Exercise ex in groupedExercises[e.key]){
        ex.removeEmptySets();
      }
      // groupedExercises[e.key].removeWhere((ex) => ex.sets.isEmpty);
    }
    // groupedExercises = Map.from(widget.groupedExercises);
    // groupedExercises.removeWhere((key, value) => value is Exercise);
    isCheckedList = groupedExercises.entries.map((e) => List<bool>.generate(e.value.length, (index) => true)).toList();
    // isCheckedList = List<bool>.generate(groupedExercises.keys.length, (index) => false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final linkNames = groupedExercises.keys.toList();

    return Stack(
      children: [
        GestureDetector(
          onTap: (){
            widget.onCancel();
            // isCheckedList = List<bool>.generate(widget.workout.exercises.length, (index) => false);
          },
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    color: Theme.of(context).primaryColor,
                    child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 60, top: 65),
                        shrinkWrap: true,
                        separatorBuilder: (context, index){
                          return Container(
                            margin: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 15),
                            height: 1,
                            width: double.maxFinite - 50,
                            color: Colors.amber[900]!.withOpacity(0.4),
                          );
                        },
                        itemCount: groupedExercises.keys.length,
                        itemBuilder: (context, index){
                          return Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: GestureDetector(
                              onTap: (){
                                // setState(() {
                                //   isCheckedList[index] = !isCheckedList[index];
                                //   if(isCheckedList[index]){
                                //     vibrateConfirm();
                                //   } else{
                                //     vibrateCancel();
                                //   }
                                // });
                              },
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      OverflowSafeText(
                                          "Group: ${linkNames[index]}",
                                          minFontSize: 20
                                      ),
                                      // Expanded(child: Container(color: Colors.transparent ,height: 50,),),
                                      // Transform.scale(
                                      //   scale: 1.4,
                                      //   child: Checkbox(
                                      //     checkColor: Colors.white,
                                      //     value: isCheckedList[index],
                                      //     shape: const CircleBorder(),
                                      //     onChanged: (bool? value) {
                                      //       setState(() {
                                      //         isCheckedList[index] = value!;
                                      //       });
                                      //     },
                                      //   ),
                                      // ),
                                    ],
                                  ),
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
                                                    isCheckedList[index][groupedExercises[linkNames[index]].indexOf(ex)] = value!;
                                                    if(value){
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
                            ),
                          );
                        }
                    ),
                  ),
                  Container(
                    height: 50,
                    color: Theme.of(context).primaryColor,
                    child: const Center(
                        child: Text(
                          "Select Group Exercises To Track",
                          textScaler: TextScaler.linear(1.5),
                        )
                    ),
                  ),
                  Positioned(
                    top: 49.8,
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
                                    print("EX TO REMOVE");
                                    print(exToRemove);
                                    widget.onConfirm(exToRemove: exToRemove);
                                  },
                                  style: ButtonStyle(
                                      shadowColor: MaterialStateProperty.all(Colors.transparent),
                                      surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
                                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                      // backgroundColor: MaterialStateProperty.all(Colors.grey[800]!.withOpacity(0.6)),
                                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
                                  ),
                                  child: const Text("Confirm")
                              )
                          ),
                          Expanded(
                              child: ElevatedButton(
                                  onPressed: () {
                                    widget.onCancel();
                                  },
                                  style: ButtonStyle(
                                      shadowColor: MaterialStateProperty.all(Colors.transparent),
                                      surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
                                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                      // backgroundColor: MaterialStateProperty.all(Colors.grey[800]!.withOpacity(0.6)),
                                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
                                  ),
                                  child: Text("Cancel")
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
      ],
    );
  }
}
