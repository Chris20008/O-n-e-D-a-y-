import 'dart:ui';

import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/screen_workouts/panels/new_exercise_panel.dart';
import 'package:fitness_app/util/objectbox/ob_exercise.dart';
import 'package:fitness_app/util/objectbox/ob_workout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../objectbox.g.dart';
import '../../../objects/exercise.dart';
import '../../../objects/workout.dart';
import '../../../widgets/bottom_menu.dart';

import '../../../widgets/exerciseRow.dart';
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

  Key listViewKey = UniqueKey();
  Key akey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context);

    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async{
        cnNewWorkout.closePanel();
        return false;
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
                          padding: const EdgeInsets.all(0),
                          shrinkWrap: true,
                          key: listViewKey,
                          itemCount: cnNewWorkout.workout.exercises.length+1,
                          itemBuilder: (BuildContext context, int index) {
                            Widget? child;
                            if (index == cnNewWorkout.workout.exercises.length){
                              child = Column(
                                children: [
                                  const SizedBox(height: 15,),

                                  Row(
                                    children: [
                                      const SizedBox(width: 30,),
                                      Expanded(
                                        child: IconButton(
                                            color: Colors.amber[800],
                                            iconSize: 30,
                                            style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
                                                shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(10)))
                                            ),
                                            onPressed: () {
                                              addExercise();
                                            },
                                            icon: const Icon(
                                                Icons.add
                                            )
                                        ),
                                      ),
                                      const SizedBox(width: 30,)
                                    ],
                                  ),
                                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom-50 > 0? MediaQuery.of(context).viewInsets.bottom-50 : 0)
                                ],
                              );
                            }
                            else{
                              child = Slidable(
                                key: akey,
                                // Specify a key if the Slidable is dismissible.
                                // key: const ValueKey(0),

                                // The start action pane is the one at the left or the top side.
                                startActionPane: ActionPane(
                                  // A motion is a widget used to control how the pane animates.
                                  motion: const ScrollMotion(),

                                  // A pane can dismiss the Slidable.
                                  dismissible: DismissiblePane(
                                      onDismissed: () {dismiss(index);
                                  }),

                                  // All actions are defined in the children parameter.
                                  children: [
                                    // A SlidableAction can have an icon and/or a label.
                                    SlidableAction(
                                      onPressed: (BuildContext context){
                                        dismiss(index);
                                      },
                                      // backgroundColor: Color(0xFFFE4A49),
                                      backgroundColor: Color(0xFFA12D2C),
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      // label: 'Delete',
                                    ),
                                  ],
                                ),

                                endActionPane: ActionPane(
                                  // A motion is a widget used to control how the pane animates.
                                  motion: const ScrollMotion(),

                                  // A pane can dismiss the Slidable.
                                  dismissible: DismissiblePane(
                                      confirmDismiss: ()async {
                                        editExercise(Exercise.clone(cnNewWorkout.workout.exercises[index]));
                                        Future.delayed(const Duration(milliseconds: 500), (){
                                          print("now");
                                          akey = UniqueKey();
                                          setState(() {

                                          });
                                        });
                                        return false;
                                      },
                                      onDismissed: () {
                                    // dismiss(index);
                                  }),

                                  // All actions are defined in the children parameter.
                                  children: [
                                    // A SlidableAction can have an icon and/or a label.
                                    SlidableAction(
                                      onPressed: (BuildContext context){
                                        cloneExercise(Exercise.clone(cnNewWorkout.workout.exercises[index]));
                                      },
                                      // backgroundColor: Color(0xFF8BB5FE),
                                      backgroundColor: Color(0xFF617EB1),
                                      foregroundColor: Colors.white,
                                      icon: Icons.copy,
                                      // label: 'Delete',
                                    ),
                                    SlidableAction(
                                      onPressed: (BuildContext context){
                                        editExercise(Exercise.clone(cnNewWorkout.workout.exercises[index]));
                                      },
                                      // backgroundColor: const Color(0xFFFEB349),
                                      backgroundColor: const Color(0xFFAE7B32),
                                      foregroundColor: Colors.white,
                                      icon: Icons.edit,
                                      // label: 'Delete',
                                    ),
                                  ],
                                ),

                                // The child of the Slidable is what the user sees when the
                                // component is not dragged.
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
                              onPressed: () {
                                cnNewWorkout.closePanel(doClear: true);
                                cnNewExercisePanel.clear();
                              },
                              icon: Icon(Icons.close)
                          ),
                          if(cnNewWorkout.isUpdating)
                            IconButton(
                                onPressed: () {
                                  deleteWorkout();
                                  cnNewWorkout.closePanel(doClear: true);
                                  cnNewExercisePanel.clear();
                                },
                                icon: Icon(Icons.delete_forever)
                            ),
                          IconButton(
                              onPressed: () {
                                // saveWorkout();
                                saveOrUpdateWorkout();
                              },
                              icon: Icon(Icons.check)
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
      cnNewWorkout.workout.exercises.removeAt(index);
      listViewKey = UniqueKey();
    });
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

  void addExercise(){
    if(cnNewWorkout.panelController.isPanelOpen){
      cnNewExercisePanel.openPanel();
    }
  }

  void editExercise(Exercise ex){
    if(cnNewWorkout.panelController.isPanelOpen){
      cnNewExercisePanel.setExercise(ex);
      cnNewExercisePanel.exercise.originalName = ex.name;
      cnNewExercisePanel.openPanel();
      cnNewExercisePanel.refresh();
    }
  }

  void cloneExercise(Exercise ex){
    if(cnNewWorkout.panelController.isPanelOpen){
      ex.name = "";
      cnNewExercisePanel.setExercise(ex);
      cnNewExercisePanel.openPanel();
      cnNewExercisePanel.refresh();
    }
  }

  void saveOrUpdateWorkout(){
    /// checks if workout exists
    ObWorkout? w = objectbox.workoutBox.query(ObWorkout_.id.equals(cnNewWorkout.workout.id)).build().findUnique();

    /// workout already exists
    if(w != null){
      /// find and delete all exercises from this workout
      List<ObExercise> obExercises = w.exercises;
      objectbox.exerciseBox.removeMany(obExercises.map((e) => e.id).toList());

      ///change name of saved workout to name of new workout and the save the workout
      w.name = cnNewWorkout.workout.name;
      saveWorkout(workout: w);
    }

    /// otherwise build an new ObWorkout from the workout and save it
    else{
      saveWorkout();
    }
  }

  void saveWorkout({ObWorkout? workout}) async{
    List<ObExercise> exercises = cnNewWorkout.workout.exercises.map((e) => e.toObExercise()).toList();

    workout = workout?? cnNewWorkout.workout.toObWorkout();
    workout.exercises.addAll(exercises);
    objectbox.workoutBox.put(workout);
    objectbox.exerciseBox.putMany(exercises);

    cnWorkouts.refreshAllWorkouts();
    cnNewWorkout.closePanel(doClear: true);
    cnNewExercisePanel.clear();
  }

  void deleteWorkout(){
    ObWorkout? w = objectbox.workoutBox.query(ObWorkout_.id.equals(cnNewWorkout.workout.id)).build().findUnique();
    if(w != null){
      List<ObExercise> obExercises = w.exercises;
      objectbox.exerciseBox.removeMany(obExercises.map((e) => e.id).toList());
      objectbox.workoutBox.remove(w.id);
      cnWorkouts.refreshAllWorkouts();
    }
  }

}

class CnNewWorkOutPanel extends ChangeNotifier {
  final PanelController panelController = PanelController();
  Workout workout = Workout();
  TextEditingController workoutNameController = TextEditingController();
  bool isUpdating = false;

  void openPanel(){
    print("------------------------ open panel");
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    panelController.animatePanelToPosition(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut
    );
  }

  void closePanel({bool doClear = false}){
    print("------------------------ close panel");
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
