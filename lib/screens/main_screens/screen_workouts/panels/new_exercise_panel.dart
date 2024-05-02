import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../../objects/exercise.dart';
import '../../../../util/constants.dart';
import '../../../screen_running_workout/screen_running_workout.dart';
import '../screen_workouts.dart';
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
  final double _iconSize = 25;
  final double _widthSetWeightAmount = 50;

  @override
  Widget build(BuildContext context) {
    cnNewExercise = Provider.of<CnNewExercisePanel>(context);

    final insetsBottom = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: false,
      onPopInvoked: (doPop){
        if (cnNewExercise.panelController.isPanelOpen){
          cnNewExercise.closePanel(doClear: false);
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: LayoutBuilder(
          builder: (context, constraints){
            return SlidingUpPanel(
              key: cnNewExercise.key,
              controller: cnNewExercise.panelController,
              defaultPanelState: PanelState.CLOSED,
              maxHeight: constraints.maxHeight - 50,
              minHeight: 0,
              color: Colors.transparent,
              isDraggable: true,
              borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
              panel: ClipRRect(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 0, right: 20.0, left: 20.0, top: 10),
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                Color(0xff160d05),
                                Color(0xff0a0604),
                              ]
                          )
                      ),
                      child: GestureDetector(
                        // onTap: () {
                        //   FocusScope.of(context).unfocus();
                        // },
                        child: Column(
                          children: [
                            Container(
                              height: 2,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(2)
                              ),
                            ),
                            const SizedBox(height: 15,),
                            const Text("Exercise", textScaleFactor: 1.5),
                            const SizedBox(height: 10,),

                            /// Exercise name
                            Form(
                              key: cnNewExercise._formKey,
                              child: TextFormField(
                                maxLength: 40,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter Exercise name';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                    fontSize: 20
                                ),
                                controller: cnNewExercise.exerciseNameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  labelText: 'Name',
                                  counterText: "",
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8 ,vertical: 0.0),
                                ),
                                onChanged: (value){
                                  value = value.trim();
                                  cnNewExercise.exercise.name = value;
                                },
                              ),
                            ),
                            const SizedBox(height: 15,),
                            SizedBox(
                              height: 35,
                              child: Row(
                                children: [
                                  Icon(Icons.timer, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
                                  // Icon(Icons.airline_seat_recline_normal, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
                                  const SizedBox(width: 5,),
                                  const Text("Rest In Seconds", textScaler: TextScaler.linear(1.2),),
                                  const Spacer(flex: 4,),
                                  SizedBox(
                                    width: 50,
                                    child: TextField(
                                      controller: cnNewExercise.restController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 3,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        labelText: "",
                                        counterText: "",
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 0 ,vertical: 0.0),
                                      ),
                                      style: const TextStyle(
                                          fontSize: 18
                                      ),
                                      textAlign: TextAlign.center,
                                      onChanged: (value){
                                        value = value.trim();
                                        if (value.isNotEmpty){
                                          cnNewExercise.exercise.restInSeconds = int.tryParse(value) ?? 0;
                                        }
                                        else{
                                          cnNewExercise.exercise.restInSeconds = 0;
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10,),
                            SizedBox(
                              height: 35,
                              child: Row(
                                children: [
                                  Icon(Icons.airline_seat_recline_normal, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
                                  const SizedBox(width: 5,),
                                  const Text("Seat Level", textScaler: TextScaler.linear(1.2),),
                                  const Spacer(flex: 4,),
                                  SizedBox(
                                    width: 50,
                                    child: TextField(
                                      controller: cnNewExercise.seatLevelController,
                                      maxLength: 2,
                                      style: const TextStyle(
                                          fontSize: 18,
                                      ),
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        labelText: '',
                                        counterText: "",
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 0 ,vertical: 0.0),
                                      ),
                                      onChanged: (value){
                                        value = value.trim();
                                        if (value.isNotEmpty){
                                          cnNewExercise.exercise.seatLevel = int.tryParse(value);
                                        }
                                        else{
                                          cnNewExercise.exercise.seatLevel = null;
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25,),
                            Container(
                              height: 1,
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(2)
                              ),
                            ),
                            const SizedBox(height: 15,),
                            const Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(child: Center(child: Text("Set", textScaleFactor: 1.2))),
                                Expanded(child: Center(child: Text("Weight", textScaleFactor: 1.2))),
                                Expanded(child: Center(child: Text("Amount", textScaleFactor: 1.2))),
                              ],
                            ),
                            Expanded(
                              /// ListView of single sets
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                controller: cnNewExercise.scrollControllerSets,
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
                                          ],
                                        ),
                                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0? MediaQuery.of(context).viewInsets.bottom : 60)
                                      ],
                                    );
                                  }
                                  else{
                                    child = Padding(
                                      padding: const EdgeInsets.only(top: 2, bottom: 2),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          SizedBox(
                                              width: _widthSetWeightAmount,
                                              height: 40,
                                              child: Center(child: Text("${index+1}", textScaler: const TextScaler.linear(1.3),))
                                          ),

                                          /// Weight
                                          Container(
                                            width: _widthSetWeightAmount,
                                            height: 35,
                                            color: Colors.transparent,
                                            child: TextField(
                                              key: cnNewExercise.ensureVisibleKeys[index][0],
                                              maxLength: 3,
                                              style: const TextStyle(
                                                  fontSize: 18,
                                              ),
                                              onTap: ()async{
                                                // cnNewExercise.controllers[index][0].text = "";
                                                // cnNewExercise.exercise.sets[index].weight = null;
                                                cnNewExercise.controllers[index][0].selection =  TextSelection(baseOffset: 0, extentOffset: cnNewExercise.controllers[index][0].value.text.length);
                                                if(insetsBottom == 0) {
                                                  await Future.delayed(const Duration(milliseconds: 300));
                                                }
                                                Scrollable.ensureVisible(
                                                    cnNewExercise.ensureVisibleKeys[index][0].currentContext!,
                                                    duration: const Duration(milliseconds: 300),
                                                    curve: Curves.easeInOut,
                                                    alignment: 0.2
                                                );
                                              },
                                              textAlign: TextAlign.center,
                                              controller: cnNewExercise.controllers[index][0],
                                              keyboardType: TextInputType.number,
                                              keyboardAppearance: Brightness.dark,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                counterText: "",
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 8 ,vertical: 0.0),
                                              ),
                                              onChanged: (value) {
                                                value = value.trim();
                                                if(value.isNotEmpty){
                                                  cnNewExercise.exercise.sets[index].weight = int.tryParse(value);
                                                }
                                                else{
                                                  cnNewExercise.exercise.sets[index].weight = null;
                                                }
                                              },
                                            ),
                                          ),

                                          /// Amount
                                          Container(
                                            width: _widthSetWeightAmount,
                                            height: 35,
                                            color: Colors.transparent,
                                            child: TextField(
                                              key: cnNewExercise.ensureVisibleKeys[index][1],
                                              maxLength: 3,
                                              style: const TextStyle(
                                                  fontSize: 18
                                              ),
                                              onTap: ()async{
                                                // cnNewExercise.controllers[index][1].text = "";
                                                // cnNewExercise.exercise.sets[index].amount = null;
                                                cnNewExercise.controllers[index][1].selection =  TextSelection(baseOffset: 0, extentOffset: cnNewExercise.controllers[index][1].value.text.length);
                                                if(insetsBottom == 0) {
                                                  await Future.delayed(const Duration(milliseconds: 300));
                                                }
                                                Scrollable.ensureVisible(
                                                    cnNewExercise.ensureVisibleKeys[index][1].currentContext!,
                                                    duration: const Duration(milliseconds: 300),
                                                    curve: Curves.easeInOut,
                                                    alignment: 0.2
                                                );
                                              },
                                              textAlign: TextAlign.center,
                                              controller: cnNewExercise.controllers[index][1],
                                              keyboardType: TextInputType.number,
                                              keyboardAppearance: Brightness.dark,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                counterText: "",
                                                contentPadding: EdgeInsets.symmetric(horizontal: 8 ,vertical: 0.0),
                                              ),
                                              onChanged: (value){
                                                value = value.trim();
                                                if(value.isNotEmpty){
                                                  cnNewExercise.exercise.sets[index].amount = int.tryParse(value);
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
                          ],
                        ),
                      ),
                    ),
                    /// faded box bottom screen
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 60,
                        decoration: const BoxDecoration(
                            gradient:  LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black,
                                ]
                            )
                        ),
                      ),
                    ),
                    /// bottom row with icons
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, left: 30, right: 30),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            myIconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  cnNewExercise.closePanel(doClear: true);
                                  cnNewExercise._formKey.currentState?.reset();
                                },
                            ),
                            myIconButton(
                                icon: const Icon(Icons.check),
                                onPressed: closePanelAndSaveExercise
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
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
    // if(cnNewExercise.exercise.sets.last.amount != null &&cnNewExercise.exercise.sets.last.weight != null) {
    setState(() {
      cnNewExercise.exercise.addSet();
      cnNewExercise.controllers.add([TextEditingController(),TextEditingController()]);
      cnNewExercise.ensureVisibleKeys.add([GlobalKey(), GlobalKey()]);
      cnNewExercise.scrollControllerSets.jumpTo(cnNewExercise.scrollControllerSets.position.pixels+44);
    });
    // }
    // else{
    //   print("no");
    // }
  }

  void closePanelAndSaveExercise(){
    if (cnNewExercise._formKey.currentState!.validate()
        && cnNewExercise.exercise.name.isNotEmpty
        // && cnNewExercise.exercise.sets.first.amount != null
        // && cnNewExercise.exercise.sets.first.weight != null
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
  ScrollController scrollControllerSets = ScrollController();

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
    HapticFeedback.selectionClick();
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
