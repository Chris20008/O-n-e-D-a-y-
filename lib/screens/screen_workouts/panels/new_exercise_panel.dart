import 'dart:ui';

import 'package:fitness_app/screens/screen_workouts/screen_workouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../objects/exercise.dart';
import '../screen_running_workout.dart';
import 'new_workout_panel.dart';

class NewExercisePanel extends StatefulWidget {
  const NewExercisePanel({super.key});

  @override
  State<NewExercisePanel> createState() => _NewExercisePanelState();
}

class _NewExercisePanelState extends State<NewExercisePanel> {
  late CnNewExercisePanel cnNewExercise;
  late CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    cnNewExercise = Provider.of<CnNewExercisePanel>(context);

    return WillPopScope(
      onWillPop: () async{
        if (cnNewExercise.panelController.isPanelOpen){
          cnNewExercise.closePanel(doClear: false);
          return false;
        }
        return true;
      },
      child: LayoutBuilder(
        builder: (context, constraints){
          return SlidingUpPanel(
            key: cnNewExercise.key,
            controller: cnNewExercise.panelController,
            defaultPanelState: PanelState.CLOSED,
            maxHeight: cnRunningWorkout.isRunning? constraints.maxHeight :constraints.maxHeight - 50,
            minHeight: 0,
            color: Colors.black.withOpacity(0.0),
            isDraggable: true,
            borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
            panel: ClipRRect(
              borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 30.0,
                  sigmaY: 30.0,
                ),
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
                        const Text("Exercise", textScaleFactor: 1.5),
                        const SizedBox(height: 10,),

                        /// Exercise name
                        Form(
                          key: cnNewExercise._formKey,
                          child: TextFormField(
                            maxLength: 30,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter Exercise name';
                              }
                              return null;
                            },
                            controller: cnNewExercise.exerciseNameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              labelText: 'Name',
                              counterText: "",
                            ),
                            onChanged: (value){
                              value = value.trim();
                              cnNewExercise.exercise.name = value;
                            },
                          ),
                        ),
                        const SizedBox(height: 25,),
                        Row(
                          children: [

                            /// Rest in Seconds
                            Expanded(
                              child: TextField(
                                controller: cnNewExercise.restController,
                                keyboardType: TextInputType.number,
                                maxLength: 3,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  labelText: 'Rest In Seconds',
                                  counterText: "",
                                ),
                                onChanged: (value){
                                  value = value.trim();
                                  if (value.isNotEmpty){
                                    cnNewExercise.exercise.restInSeconds = int.parse(value);
                                  }
                                  else{
                                    cnNewExercise.exercise.restInSeconds = 0;
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 25,),

                            /// Seat level
                            Expanded(
                              child: TextField(
                                controller: cnNewExercise.seatLevelController,
                                maxLength: 2,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  labelText: 'Seat Level',
                                  counterText: "",
                                ),
                                onChanged: (value){
                                  value = value.trim();
                                  if (value.isNotEmpty){
                                    cnNewExercise.exercise.seatLevel = int.parse(value);
                                  }
                                  else{
                                    cnNewExercise.exercise.seatLevel = null;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25,),
                        Container(width: double.maxFinite, height: 2, color: Colors.grey[400],),
                        const SizedBox(height: 15,),
                        const Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(child: Center(child: Text("Sets", textScaleFactor: 1.2))),
                            Expanded(child: Center(child: Text("Weight", textScaleFactor: 1.2))),
                            Expanded(child: Center(child: Text("Amount", textScaleFactor: 1.2))),
                          ],
                        ),
                        Expanded(
                          /// ListView of single sets
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            controller: scrollController,
                            padding: const EdgeInsets.all(0),
                            shrinkWrap: true,
                            // key: listViewKey,
                            itemCount: cnNewExercise.exercise.sets.length+1,
                            itemBuilder: (BuildContext context, int index) {
                              Widget? child;
                              if (index == cnNewExercise.exercise.sets.length){
                                child = Column(
                                  children: [
                                    const SizedBox(height: 15,),

                                    Row(
                                      children: [
                                        const SizedBox(width: 30,),
                                        Expanded(
                                          child: IconButton(
                                              color: Colors.amber[800],
                                              style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
                                                  shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(20)))
                                              ),
                                              onPressed: () {
                                                addSet();
                                              },
                                              icon: const Icon(
                                                Icons.add,
                                                size: 20,
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
                                child = Padding(
                                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                          width: 60,
                                          height: 40,
                                          child: Center(child: Text("${index+1}", textScaleFactor: 1.2))
                                      ),

                                      /// Weight
                                      Container(
                                        width: 60,
                                        height: 40,
                                        color: Colors.transparent,
                                        child: TextField(
                                          key: cnNewExercise.ensureVisibleKeys[index][0],
                                          maxLength: 3,
                                          onTap: ()async{
                                            if(MediaQuery.of(context).viewInsets.bottom == 0) {
                                              await Future.delayed(const Duration(milliseconds: 300));
                                            }
                                            Scrollable.ensureVisible(
                                                cnNewExercise.ensureVisibleKeys[index][0].currentContext!,
                                                duration: const Duration(milliseconds: 300),
                                                curve: Curves.easeInOut,
                                                alignment: 0.2
                                            );
                                          },
                                          controller: cnNewExercise.controllers[index][0],
                                          keyboardType: TextInputType.number,
                                          textAlignVertical: const TextAlignVertical(y: -0.8),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                            counterText: "",
                                          ),
                                          onChanged: (value) {
                                            value = value.trim();
                                            if(value.isNotEmpty){
                                              cnNewExercise.exercise.sets[index].weight = int.parse(value);
                                            }
                                            else{
                                              cnNewExercise.exercise.sets[index].weight = null;
                                            }
                                          },
                                        ),
                                      ),

                                      /// Amount
                                      Container(
                                        width: 60,
                                        height: 40,
                                        color: Colors.transparent,
                                        child: TextField(
                                          key: cnNewExercise.ensureVisibleKeys[index][1],
                                          maxLength: 3,
                                          onTap: ()async{
                                            if(MediaQuery.of(context).viewInsets.bottom == 0) {
                                              await Future.delayed(const Duration(milliseconds: 300));
                                            }
                                            Scrollable.ensureVisible(
                                                cnNewExercise.ensureVisibleKeys[index][1].currentContext!,
                                                duration: const Duration(milliseconds: 300),
                                                curve: Curves.easeInOut,
                                                alignment: 0.2
                                            );
                                          },
                                          controller: cnNewExercise.controllers[index][1],
                                          keyboardType: TextInputType.number,
                                          textAlignVertical: const TextAlignVertical(y: -0.8),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                            counterText: "",
                                          ),
                                          onChanged: (value){
                                            value = value.trim();
                                            if(value.isNotEmpty){
                                              cnNewExercise.exercise.sets[index].amount = int.parse(value);
                                            }
                                            else{
                                              cnNewExercise.exercise.sets[index].amount = null;
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return Slidable(
                                  key: UniqueKey(),
                                  startActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    dismissible: DismissiblePane(
                                        onDismissed: () {
                                          dismissExercise(index);
                                        }),
                                    children: [
                                      SlidableAction(
                                        flex:10,
                                        onPressed: (BuildContext context){
                                          dismissExercise(index);
                                        },
                                        borderRadius: BorderRadius.circular(15),
                                        backgroundColor: const Color(0xFFA12D2C),
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
                                  child: child
                              );
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () {
                                  cnNewExercise.closePanel(doClear: true);
                                  cnNewExercise._formKey.currentState?.reset();
                                },
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
              ),
            ),
          );
        },
      ),
    );
  }

  void dismissExercise(int index){
    setState(() {
      cnNewExercise.exercise.sets.removeAt(index);
      cnNewExercise.controllers.removeAt(index);
      cnNewExercise.ensureVisibleKeys.removeAt(index);
    });
  }

  void addSet(){
    if(cnNewExercise.exercise.sets.last.amount != null &&cnNewExercise.exercise.sets.last.weight != null) {
      setState(() {
        cnNewExercise.exercise.addSet();
        cnNewExercise.controllers.add([TextEditingController(),TextEditingController()]);
        cnNewExercise.ensureVisibleKeys.add([GlobalKey(), GlobalKey()]);
      });
    }
    else{
      print("no");
    }
  }

  void closePanelAndSaveExercise(){
    if (cnNewExercise._formKey.currentState!.validate()
        && cnNewExercise.exercise.name.isNotEmpty
        && cnNewExercise.exercise.sets.first.amount != null
        && cnNewExercise.exercise.sets.first.weight != null
    ) {
      cnNewExercise.exercise.removeEmptySets();
      cnNewWorkout.workout.addOrUpdateExercise(cnNewExercise.exercise);
      cnNewExercise.closePanel(doClear: true);
      cnNewWorkout.refreshExercise(cnNewExercise.exercise);
      cnNewWorkout.updateExercisesAndLinksList();
      cnNewWorkout.updateExercisesLinks();
      cnNewWorkout.refresh();
      // }
    }
  }

}

class CnNewExercisePanel extends ChangeNotifier {
  final _formKey = GlobalKey<FormState>();
  final PanelController panelController = PanelController();

  Key key = UniqueKey();
  Exercise exercise = Exercise();
  TextEditingController exerciseNameController = TextEditingController();
  TextEditingController restController = TextEditingController();
  TextEditingController seatLevelController = TextEditingController();

  late List<List<TextEditingController>> controllers = exercise.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList();
  late List<List<GlobalKey>> ensureVisibleKeys = exercise.sets.map((e) => ([GlobalKey(), GlobalKey()])).toList();

  void setExercise(Exercise ex){
    exercise = ex;
    controllers = exercise.sets.map((e) => ([TextEditingController(text: "${e.weight}"), TextEditingController(text: "${e.amount}")])).toList();
    ensureVisibleKeys = exercise.sets.map((e) => ([GlobalKey(), GlobalKey()])).toList();
    exerciseNameController = TextEditingController(text: ex.name);
    restController = TextEditingController(text: ex.restInSeconds > 0? ex.restInSeconds.toString() : "");
    seatLevelController = TextEditingController(text: ex.seatLevel != null? ex.seatLevel.toString() : "");
  }

  void openPanel(){
    panelController.animatePanelToPosition(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut
    );
  }

  void closePanel({bool doClear = false}){
    print("close panel exercise");
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
    controllers = exercise.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList();
    exerciseNameController = TextEditingController();
    restController = TextEditingController();
    seatLevelController = TextEditingController();
    key = UniqueKey();
    ensureVisibleKeys = exercise.sets.map((e) => ([GlobalKey(), GlobalKey()])).toList();
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}
