import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../objects/exercise.dart';
import 'new_workout_panel.dart';

class NewExercisePanel extends StatefulWidget {
  const NewExercisePanel({super.key});

  @override
  State<NewExercisePanel> createState() => _NewExercisePanelState();
}

class _NewExercisePanelState extends State<NewExercisePanel> {
  late CnNewExercisePanel cnNewExercise;
  late CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    cnNewExercise = Provider.of<CnNewExercisePanel>(context);

    final size = MediaQuery.of(context).size;

    return SlidingUpPanel(
      key: cnNewExercise.key,
      controller: cnNewExercise.panelController,
      defaultPanelState: PanelState.CLOSED,
      maxHeight: size.height-50,
      minHeight: 0,
      isDraggable: false,
      borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
      backdropEnabled: true,
      backdropColor: Colors.black,
      // onPanelSlide: onPanelSlide,
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
              const Text("Exercise", textScaleFactor: 1.5),
              const SizedBox(height: 10,),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  labelText: 'Name',
                ),
                onChanged: (value){
                  cnNewExercise.exercise.name = value;
                },
              ),
              const SizedBox(height: 25,),
              Container(width: double.maxFinite, height: 2, color: Colors.grey[400],),
              const SizedBox(height: 15,),
              const Text("Sets", textScaleFactor: 1.2),
              const SizedBox(height: 15,),
              const Row(
                children: [
                  Text("Satz 1", textScaleFactor: 1.2),
                ]
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
                          addSet();
                        },
                        icon: const Icon(
                            Icons.add
                        )
                    ),
                  ),
                  const SizedBox(width: 30,)
                ],
              ),
              Expanded(child: SizedBox()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: cnNewExercise.closePanel,
                      icon: Icon(Icons.close)
                  ),
                  IconButton(
                      onPressed: closePanelAndSaveExercise,
                      icon: Icon(Icons.check)
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void addSet(){

  }

  void closePanelAndSaveExercise(){
    if(cnNewExercise.exercise.name.isNotEmpty){
      cnNewExercise.closePanel(doClear: true);
      cnNewWorkout.workout.addExercise(cnNewExercise.exercise);
      cnNewWorkout.refresh();
      // cnNewExercise.clear();
      for (Exercise ex in cnNewWorkout.workout.exercises) {
        print(ex.name);
      }
    }
  }

}

class CnNewExercisePanel extends ChangeNotifier {
  final PanelController panelController = PanelController();
  Exercise exercise = Exercise();
  Key key = UniqueKey();

  void openPanel(){
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
      if(doClear){
        clear()
      }
    });
  }

  void clear(){
    exercise = Exercise();
    key = UniqueKey();
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}
