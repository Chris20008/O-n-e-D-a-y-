import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  Key listViewKey = UniqueKey();
  ScrollController scrollController = ScrollController();
  late List<List<GlobalKey>> keys = cnNewExercise.exercise.sets.map((e) => ([GlobalKey(), GlobalKey()])).toList();

  @override
  Widget build(BuildContext context) {
    cnNewExercise = Provider.of<CnNewExercisePanel>(context);

    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async{
        cnNewExercise.closePanel(doClear: false);
        return false;
      },
      child: SlidingUpPanel(
        key: cnNewExercise.key,
        controller: cnNewExercise.panelController,
        defaultPanelState: PanelState.CLOSED,
        maxHeight: size.height-50,
        minHeight: 0,
        color: Colors.black.withOpacity(0.0),
        isDraggable: true,
        borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
        // backdropEnabled: true,
        // backdropColor: Color(0xff000000),
        // onPanelSlide: onPanelSlide,
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
                    Form(
                      key: cnNewExercise._formKey,
                      child: TextFormField(
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
                        ),
                        onChanged: (value){
                          value = value.trim();
                          cnNewExercise.exercise.name = value;
                        },
                      ),
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
                        key: listViewKey,
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
                                          iconSize: 30,
                                          style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
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
                                      key: keys[index][0],
                                      onTap: ()async{
                                        if(MediaQuery.of(context).viewInsets.bottom == 0) {
                                          await Future.delayed(const Duration(milliseconds: 300));
                                        }
                                        Scrollable.ensureVisible(
                                            keys[index][0].currentContext!,
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            alignment: 0.3
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
                                      maxLength: 3,
                                    ),
                                  ),

                                  /// Amount
                                  Container(
                                    width: 60,
                                    height: 40,
                                    color: Colors.transparent,
                                    child: TextField(
                                      key: keys[index][1],
                                      onTap: ()async{
                                        if(MediaQuery.of(context).viewInsets.bottom == 0) {
                                          await Future.delayed(const Duration(milliseconds: 300));
                                        }
                                        Scrollable.ensureVisible(
                                            keys[index][1].currentContext!,
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          alignment: 0.3
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
                                      maxLength: 3,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
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
                                  cnNewExercise.exercise.sets.removeAt(index);
                                  cnNewExercise.controllers.removeAt(index);
                                  keys.removeAt(index);
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
                              ],
                            ),

                            // The child of the Slidable is what the user sees when the
                            // component is not dragged.
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
      ),
    );
  }

  void addSet(){
    if(cnNewExercise.exercise.sets.last.amount != null &&cnNewExercise.exercise.sets.last.weight != null) {
      setState(() {
        cnNewExercise.exercise.addSet();
        cnNewExercise.controllers.add([TextEditingController(),TextEditingController()]);
        keys.add([GlobalKey(), GlobalKey()]);
      });
    }
    else{
      print("no");
    }
  }

  void closePanelAndSaveExercise(){
    if (cnNewExercise._formKey.currentState!.validate()) {
      if(cnNewExercise.exercise.name.isNotEmpty && cnNewExercise.exercise.sets.first.amount != null &&cnNewExercise.exercise.sets.first.weight != null){
        List<Set> sets = List.from(cnNewExercise.exercise.sets);
        for (Set set in sets){
          if (set.amount == null || set.weight == null){
            cnNewExercise.exercise.sets.remove(set);
          }
        }
        cnNewWorkout.workout.addOrUpdateExercise(cnNewExercise.exercise);
        cnNewExercise.closePanel(doClear: true);
        cnNewWorkout.refresh();
      }
    }
  }

}

class CnNewExercisePanel extends ChangeNotifier {
  final PanelController panelController = PanelController();
  Exercise exercise = Exercise();
  late List<List<TextEditingController>> controllers = exercise.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList();
  TextEditingController exerciseNameController = TextEditingController();
  Key key = UniqueKey();
  final _formKey = GlobalKey<FormState>();

  void setExercise(Exercise ex){
    exercise = ex;
    controllers = exercise.sets.map((e) => ([TextEditingController(text: "${e.weight}"), TextEditingController(text: "${e.amount}")])).toList();
    exerciseNameController = TextEditingController(text: ex.name);
  }

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
    controllers = exercise.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList();
    exerciseNameController = TextEditingController();
    key = UniqueKey();
    // _formKey = GlobalKey<FormState>();
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}
