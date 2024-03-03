import 'dart:ui';

import 'package:fitness_app/screens/screen_workouts/panels/new_exercise_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../objects/exercise.dart';
import '../../../objects/workout.dart';
import '../../../widgets/bottom_menu.dart';

import '../../../widgets/exerciseRow.dart';
import '../../screen_workout_history/screen_workout_history.dart';
import '../screen_workouts.dart';

class NewWorkOutPanel extends StatefulWidget {
  const NewWorkOutPanel({super.key});

  @override
  State<NewWorkOutPanel> createState() => _NewWorkOutPanelState();
}

class _NewWorkOutPanelState extends State<NewWorkOutPanel> {
  late CnNewWorkOutPanel cnNewWorkout;
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  late CnNewExercisePanel cnNewExercisePanel = Provider.of<CnNewExercisePanel>(context, listen: false);
  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnWorkoutHistory cnWorkoutHistory = Provider.of<CnWorkoutHistory>(context, listen: false);

  // Key listViewKey = UniqueKey();
  // Key slideableKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context);

    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async{
        if (cnNewWorkout.panelController.isPanelOpen && !cnNewExercisePanel.panelController.isPanelOpen){
          cnNewWorkout.closePanel(doClear: false);
          return false;
        }
        return true;
      },
      child: SlidingUpPanel(
        controller: cnNewWorkout.panelController,
        defaultPanelState: PanelState.CLOSED,
        maxHeight: size.height-50,
        minHeight: 0,
        isDraggable: true,
        borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
        backdropEnabled: true,
        backdropColor: Colors.black,
        color: Colors.black.withOpacity(0.0),
        onPanelSlide: onPanelSlide,
        panel: ClipRRect(
          borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 30.0,
              sigmaY: 30.0,
            ),
            child: Container(
              color: Colors.black.withOpacity(0.1),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  height: double.maxFinite,
                  width: double.maxFinite,
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      const Text("Workout", textScaleFactor: 1.5),
                      const SizedBox(height: 10,),
                      TextField(
                        controller: cnNewWorkout.workoutNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          labelText: 'Name',
                        ),
                        onChanged: (value){
                          cnNewWorkout.workout.name = value;
                        },
                      ),
                      const SizedBox(height: 25,),
                      Container(width: double.maxFinite, height: 1, color: Colors.grey[400],),
                      const SizedBox(height: 15,),
                      const Text("Exercises", textScaleFactor: 1.2),
                      const SizedBox(height: 15,),


                      Expanded(
                        child: ListView.builder(
                          controller: ScrollController(),
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(0),
                          shrinkWrap: true,
                          // key: listViewKey,
                          itemCount: cnNewWorkout.workout.exercises.length+1,
                          itemBuilder: (BuildContext context, int index) {
                            Widget? child;
                            if (index == cnNewWorkout.workout.exercises.length){
                              child = Column(
                                children: [
                                  const SizedBox(height: 15,),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: IconButton(
                                            color: Colors.amber[800],
                                            style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
                                                shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(20)))
                                            ),
                                            onPressed: () {
                                              addExercise();
                                            },
                                            icon: const Icon(
                                              Icons.add,
                                              size: 20,
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom-50 > 0? MediaQuery.of(context).viewInsets.bottom-50 : 0)
                                ],
                              );
                            }
                            else{
                              child = Slidable(
                                key: UniqueKey(),
                                startActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  dismissible: DismissiblePane(
                                      onDismissed: () {dismiss(index);
                                  }),
                                  children: [
                                    SlidableAction(
                                      flex:10,
                                      onPressed: (BuildContext context){
                                        dismiss(index);
                                      },
                                      borderRadius: BorderRadius.circular(15),
                                      backgroundColor: Color(0xFFA12D2C),
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                    ),
                                    SlidableAction(
                                      flex: 1,
                                      onPressed: (BuildContext context){},
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.transparent,
                                      label: '',
                                    ),
                                  ],
                                ),

                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  dismissible: DismissiblePane(
                                      confirmDismiss: ()async {
                                        openExercise(cnNewWorkout.workout.exercises[index]);
                                        return false;
                                      },
                                      onDismissed: () {}),
                                  children: [
                                    SlidableAction(
                                      padding: const EdgeInsets.all(0),
                                      flex:10,
                                      onPressed: (BuildContext context){
                                        // openExercise(cnNewWorkout.workout.exercises[index], copied: true);
                                      },
                                      borderRadius: BorderRadius.circular(15),
                                      backgroundColor: Color(0xFF5F9561),
                                      // backgroundColor: Colors.white.withOpacity(0.1),
                                      foregroundColor: Colors.white,
                                      icon: Icons.add_link,
                                    ),
                                    SlidableAction(
                                      flex: 1,
                                      onPressed: (BuildContext context){},
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.transparent,
                                      label: '',
                                    ),
                                    SlidableAction(
                                      padding: const EdgeInsets.all(0),
                                      flex:10,
                                      onPressed: (BuildContext context){
                                        openExercise(cnNewWorkout.workout.exercises[index], copied: true);
                                      },
                                      borderRadius: BorderRadius.circular(15),
                                      backgroundColor: Color(0xFF617EB1),
                                      // backgroundColor: Colors.white.withOpacity(0.1),
                                      foregroundColor: Colors.white,
                                      icon: Icons.copy,
                                    ),
                                    SlidableAction(
                                      flex: 1,
                                      onPressed: (BuildContext context){},
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.transparent,
                                      label: '',
                                    ),
                                    SlidableAction(
                                      padding: const EdgeInsets.all(0),
                                      flex:10,
                                      onPressed: (BuildContext context){
                                        openExercise(cnNewWorkout.workout.exercises[index]);
                                      },
                                      borderRadius: BorderRadius.circular(15),
                                      backgroundColor: const Color(0xFFAE7B32),
                                      // backgroundColor: Colors.white.withOpacity(0.1),
                                      foregroundColor: Colors.white,
                                      icon: Icons.edit,
                                    ),
                                  ],
                                ),
                                child: exerciseRow(
                                  exercise: cnNewWorkout.workout.exercises[index],
                                  textScaleFactor: 1.3,
                                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                ),
                              );
                            }
                            return child;
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: onCancel,
                              icon: const Icon(Icons.close)
                          ),
                          if(cnNewWorkout.isUpdating)
                            IconButton(
                                onPressed: onDelete,
                                icon: const Icon(Icons.delete_forever)
                            ),
                          IconButton(
                              onPressed: onConfirm,
                              icon: const Icon(Icons.check)
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void dismiss(int index){
    setState(() {
      print("DISMISS");
      cnNewWorkout.workout.exercises.removeAt(index);
      print(cnNewWorkout.workout.exercises.length);
    });
  }

  void addExercise(){
    if(cnNewWorkout.panelController.isPanelOpen){
      cnNewExercisePanel.openPanel();
    }
  }

  void openExercise(Exercise ex, {bool copied = false}){
    /// Clone exercise to prevent directly change settings in original exercise before saving
    /// f.e. when user goes back or just slides down panel
    Exercise clonedEx = Exercise.clone(ex);

    if(copied) {
      /// If copied means a copy of the original exercise is made to create a completely new exercise
      clonedEx.name = "";
    } else {
      /// Otherwise the user is editing the exercise so we keep track of the origina name in case
      /// the user changes the exercises name
      clonedEx.originalName = ex.name;
    }

    if(cnNewWorkout.panelController.isPanelOpen){
      cnNewExercisePanel.setExercise(clonedEx);
      cnNewExercisePanel.openPanel();
      cnNewExercisePanel.refresh();
    }
  }

  void onCancel(){
    cnNewWorkout.closePanel(doClear: true);
    cnNewExercisePanel.clear();
  }

  void onDelete(){
    cnNewWorkout.workout.deleteFromDatabase();
    cnWorkouts.refreshAllWorkouts();
    cnWorkoutHistory.refreshAllWorkouts();
    cnNewWorkout.closePanel(doClear: true);
    cnNewExercisePanel.clear();
  }

  void onConfirm(){
    if(!cnNewWorkout.isUpdating){
      cnNewWorkout.workout.isTemplate = true;
    } else{
      print("is updating");
    }
    cnNewWorkout.workout.saveToDatabase();
    cnWorkouts.refreshAllWorkouts();
    cnWorkoutHistory.refreshAllWorkouts();
    cnNewWorkout.closePanel(doClear: true);
    cnNewExercisePanel.clear();
  }

  void onPanelSlide(value){
    if(value < 0.05 && !cnBottomMenu.isVisible){
      SystemChrome.setPreferredOrientations([]);
      cnBottomMenu.setVisibility(true);
    }
    else if(value > 0.05 && cnBottomMenu.isVisible){
      cnBottomMenu.setVisibility(false);
    }
  }

}

class CnNewWorkOutPanel extends ChangeNotifier {
  final PanelController panelController = PanelController();
  Workout workout = Workout();
  TextEditingController workoutNameController = TextEditingController();
  bool isUpdating = false;

  void openPanel(){
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    panelController.animatePanelToPosition(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut
    );
  }

  void closePanel({bool doClear = false}){
    panelController.animatePanelToPosition(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut
    ).then((value) => {
      SystemChrome.setPreferredOrientations([]),
      if(doClear){
        clear()
      }
    });
  }

  void setWorkout(Workout w){
    workout = w;
    workoutNameController = TextEditingController(text: w.name);
  }

  void clear(){
    workout = Workout();
    workoutNameController = TextEditingController();
    isUpdating = false;
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}
