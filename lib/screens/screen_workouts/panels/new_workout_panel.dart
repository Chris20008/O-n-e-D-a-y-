import 'package:fitness_app/screens/screen_workouts/panels/new_exercise_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../objects/workout.dart';
import '../../../widgets/bottom_menu.dart';

class NewWorkOutPanel extends StatefulWidget {
  const NewWorkOutPanel({super.key});

  @override
  State<NewWorkOutPanel> createState() => _NewWorkOutPanelState();
}

class _NewWorkOutPanelState extends State<NewWorkOutPanel> {
  late CnNewWorkOutPanel cnNewWorkout;
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  late CnNewExercisePanel cnNewExercisePanel = Provider.of<CnNewExercisePanel>(context, listen: false);

  Key listViewKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context);

    final size = MediaQuery.of(context).size;

    return SlidingUpPanel(
      controller: cnNewWorkout.panelController,
      defaultPanelState: PanelState.CLOSED,
      maxHeight: size.height-50,
      minHeight: 0,
      isDraggable: true,
      borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
      backdropEnabled: true,
      backdropColor: Colors.black,
      onPanelSlide: onPanelSlide,
      panel: GestureDetector(
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  labelText: 'Name',
                ),
                onChanged: (value){
                  cnNewWorkout.workout.name = value;
                  print(cnNewWorkout.workout.name);
                },
              ),
              const SizedBox(height: 25,),
              Container(width: double.maxFinite, height: 2, color: Colors.grey[400],),
              const SizedBox(height: 15,),
              const Text("Exercises", textScaleFactor: 1.2),
              const SizedBox(height: 15,),
              LimitedBox(
                maxHeight: size.height*0.6,
                child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  shrinkWrap: true,
                  key: listViewKey,
                    itemCount: cnNewWorkout.workout.exercises.length,
                    itemBuilder: (BuildContext context, int index) {
                      // return Text(cnNewWorkout.workout.exercises[0].name);
                      return Slidable(
                        // Specify a key if the Slidable is dismissible.
                        key: const ValueKey(0),

                        // The start action pane is the one at the left or the top side.
                        startActionPane: ActionPane(
                          // A motion is a widget used to control how the pane animates.
                          motion: const ScrollMotion(),

                          // A pane can dismiss the Slidable.
                          dismissible: DismissiblePane(onDismissed: () {
                            setState(() {
                              cnNewWorkout.workout.exercises.removeAt(index);
                              listViewKey = UniqueKey();
                            });
                          }),

                          // All actions are defined in the children parameter.
                          children: const [
                            // A SlidableAction can have an icon and/or a label.
                            SlidableAction(
                              onPressed: null,
                              backgroundColor: Color(0xFFFE4A49),
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              // label: 'Delete',
                            ),
                            // SlidableAction(
                            //   onPressed: null,
                            //   backgroundColor: Color(0xFF21B7CA),
                            //   foregroundColor: Colors.white,
                            //   icon: Icons.share,
                            //   // label: 'Share',
                            // ),
                          ],
                        ),

                        // The end action pane is the one at the right or the bottom side.
                        endActionPane: const ActionPane(
                          motion: ScrollMotion(),
                          children: [
                            SlidableAction(
                              // An action can be bigger than the others.
                              flex: 2,
                              onPressed: null,
                              backgroundColor: Color(0xFF7BC043),
                              foregroundColor: Colors.white,
                              icon: Icons.archive,
                              // label: 'Archive',
                            ),
                            SlidableAction(
                              onPressed: null,
                              backgroundColor: Color(0xFF0392CF),
                              foregroundColor: Colors.white,
                              icon: Icons.save,
                              // label: 'Save',
                            ),
                          ],
                        ),

                        // The child of the Slidable is what the user sees when the
                        // component is not dragged.
                        child: ListTile(title: Text(cnNewWorkout.workout.exercises[index].name)),
                      );
                    },
                ),
              ),
              Row(
                children: [
                  const SizedBox(width: 30,),
                  Expanded(
                    child: IconButton(
                        iconSize: 30,
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.grey[400]),
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
            ],
          ),
        ),
      ),
    );
  }

  void onPanelSlide(value){
    if(value < 0.05 && !cnBottomMenu.isVisible){
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

}

class CnNewWorkOutPanel extends ChangeNotifier {
  final PanelController panelController = PanelController();
  Workout workout = Workout();

  void openPanel(){
    panelController.animatePanelToPosition(
        1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut
    );
  }

  void closePanel(){
    panelController.animatePanelToPosition(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut
    );
  }

  void refresh(){
    notifyListeners();
  }
}
