import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/widgets/multiple_exercise_row.dart';
import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';
import '../../objects/exercise.dart';
import '../../objects/workout.dart';

class SelectorExercisesToUpdate extends StatefulWidget {

  final Workout workout;
  final Workout workoutTemplate;
  final Function onConfirm;
  final Function onCancel;

  const SelectorExercisesToUpdate({
    super.key,
    required this.workout,
    required this.workoutTemplate,
    required this.onConfirm,
    required this.onCancel
  });

  @override
  State<SelectorExercisesToUpdate> createState() => _SelectorExercisesToUpdateState();
}

class _SelectorExercisesToUpdateState extends State<SelectorExercisesToUpdate> {

  late List<bool> isCheckedList;
  late Workout workout;

  @override
  void initState() {
    workout = Workout.clone(widget.workout);
    workout.removeEmptyExercises();
    isCheckedList = List<bool>.generate(workout.exercises.length, (index) => false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        GestureDetector(
          onTap: (){
            widget.onCancel();
            isCheckedList = List<bool>.generate(widget.workout.exercises.length, (index) => false);
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
                        padding: workout.exercises.isEmpty? const EdgeInsets.only(bottom: 50, top: 50) : const EdgeInsets.only(bottom: 60, top: 65),
                        shrinkWrap: true,
                        separatorBuilder: (context, index){
                          return Container(
                            margin: const EdgeInsets.only(top: 15, left: 15, right: 15),
                            height: 1,
                            width: double.maxFinite - 50,
                            color: Colors.amber[900]!.withOpacity(0.4),
                          );
                        },
                        itemCount: workout.exercises.length,
                        itemBuilder: (context, index){
                          return Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  isCheckedList[index] = !isCheckedList[index];
                                  if(isCheckedList[index]){
                                    vibrateLightToHeavy();
                                  } else{
                                    vibrateHeavyToLight();
                                  }
                                });
                              },
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      OverflowSafeText(
                                          workout.exercises[index].name,
                                          minFontSize: 20
                                      ),
                                      // Text(workout.exercises[index].name, textScaler: const TextScaler.linear(1.35),),
                                      Expanded(child: Container(color: Colors.transparent ,height: 50,),),
                                      Transform.scale(
                                        scale: 1.4,
                                        child: Checkbox(
                                          checkColor: Colors.white,
                                          value: isCheckedList[index],
                                          shape: const CircleBorder(),
                                          onChanged: (bool? value) {
                                            setState(() {
                                              isCheckedList[index] = value!;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Stack(
                                    children: [
                                      MultipleExerciseRow(
                                        exercises: getExercises(index),
                                        fontSize: 15,
                                        colorFade: Theme.of(context).primaryColor,
                                      ),
                                    ],
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
                    child: Center(
                        child: Text(
                          workout.exercises.isEmpty? "No Exercise To Update" : "Select Exercises To Update",
                          textScaler: const TextScaler.linear(1.5),
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
                          if(workout.exercises.isNotEmpty)
                            Expanded(
                                child: ElevatedButton(
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
                                          workout.exercises.removeAt(index);
                                        }
                                      }
                                      /// cancel just closes the widget
                                      widget.onCancel();
                                      Future.delayed(const Duration(milliseconds: 200), (){
                                        widget.onConfirm();
                                        vibrateSuccess();
                                        if(doUpdate){
                                          workout.updateTemplate();
                                        }
                                      });
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
                                  child: Text(workout.exercises.isNotEmpty? "Cancel" : "Ok")
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

  List<Exercise> getExercises(int index){
    Exercise tempNew = Exercise.clone(workout.exercises[index]);
    Exercise tempTemplate = Exercise.clone(widget.workoutTemplate.exercises.firstWhere((ex) => ex.name == tempNew.name));

    tempNew.name = "New";
    tempTemplate.name = "Template";

    return [tempTemplate, tempNew];
  }
}
