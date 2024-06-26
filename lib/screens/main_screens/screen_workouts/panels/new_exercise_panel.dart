import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../../objects/exercise.dart';
import '../../../../objects/workout.dart';
import '../../../../util/constants.dart';
import '../../../../widgets/standard_popup.dart';
import '../../../other_screens/screen_running_workout/screen_running_workout.dart';
import '../screen_workouts.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewExercisePanel extends StatefulWidget {
  const NewExercisePanel({super.key});

  @override
  State<NewExercisePanel> createState() => _NewExercisePanelState();
}

class _NewExercisePanelState extends State<NewExercisePanel> {
  late CnNewExercisePanel cnNewExercise;
  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  final double _iconSize = 25;
  final double _widthSetWeightAmount = 55;
  final _formKey = GlobalKey<FormState>();
  final double _heightBottomColoredBox = Platform.isAndroid? 15 : 25;
  final double _totalHeightBottomBox = Platform.isAndroid? 70 : 80;
  final _style = const TextStyle(color: Colors.white, fontSize: 18);

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
              onPanelSlide: onPanelSlide,
              key: cnNewExercise.key,
              controller: cnNewExercise.panelController,
              defaultPanelState: PanelState.CLOSED,
              maxHeight: constraints.maxHeight - (Platform.isAndroid? 50 : 70),
              minHeight: 0,
              backdropEnabled: true,
              backdropColor: Colors.black,
              backdropOpacity: 0.5,
              color: const Color(0xff120a01),
              isDraggable: true,
              borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
              panel: ClipRRect(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 0, right: 20.0, left: 20.0, top: 10),
                      child: GestureDetector(
                        // onTap: () {
                        //   FocusScope.of(context).unfocus();
                        // },
                        child: Column(
                          children: [
                            panelTopBar,
                            const SizedBox(height: 15,),
                            Text(AppLocalizations.of(context)!.exercise, textScaler: const TextScaler.linear(1.5)),
                            const SizedBox(height: 10,),

                            /// Exercise name
                            Form(
                              key: _formKey,
                              child: TextFormField(
                                keyboardAppearance: Brightness.dark,
                                maxLength: 40,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  value = value?.trim();
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(context)!.panelExEnterName;
                                  } else if(exerciseNameExistsInWorkout(workout: cnNewExercise.workout, exerciseName: cnNewExercise.exercise.name) &&
                                            cnNewExercise.exercise.originalName != cnNewExercise.exercise.name
                                  ){
                                    return AppLocalizations.of(context)!.panelExAlreadyExists;
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                    fontSize: 20
                                ),
                                controller: cnNewExercise.exerciseNameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  labelText: AppLocalizations.of(context)!.name,
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

                            /// Rest in Seconds Row and Selector
                            getRestInSecondsSelector(),

                            const SizedBox(height: 0,),

                            /// Seat Level Row and Selector
                            getSeatLevelSelector(),

                            // SizedBox(
                            //   height: 35,
                            //   child: Row(
                            //     children: [
                            //       Icon(Icons.airline_seat_recline_normal, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
                            //       const SizedBox(width: 5,),
                            //       Text(AppLocalizations.of(context)!.
                            //         seatLevel, textScaler: const TextScaler.linear(1.2),),
                            //       const Spacer(flex: 4,),
                            //       SizedBox(
                            //         width: 50,
                            //         child: TextField(
                            //           keyboardAppearance: Brightness.dark,
                            //           controller: cnNewExercise.seatLevelController,
                            //           maxLength: 2,
                            //           style: const TextStyle(
                            //               fontSize: 18,
                            //           ),
                            //           textAlign: TextAlign.center,
                            //           keyboardType: TextInputType.number,
                            //           decoration: InputDecoration(
                            //             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            //             labelText: '',
                            //             counterText: "",
                            //             contentPadding: const EdgeInsets.symmetric(horizontal: 0 ,vertical: 0.0),
                            //           ),
                            //           onChanged: (value){
                            //             value = value.trim();
                            //             if (value.isNotEmpty){
                            //               cnNewExercise.exercise.seatLevel = int.tryParse(value);
                            //             }
                            //             else{
                            //               cnNewExercise.exercise.seatLevel = null;
                            //             }
                            //           },
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            const SizedBox(height: 25,),
                            Container(
                              height: 1,
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(2)
                              ),
                            ),
                            const SizedBox(height: 15,),
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(child: Center(child: Text(AppLocalizations.of(context)!.set, textScaler: const TextScaler.linear(1.2)))),
                                Expanded(child: Center(child: Text(AppLocalizations.of(context)!.weight, textScaler: const TextScaler.linear(1.2)))),
                                Expanded(child: Center(child: Text(AppLocalizations.of(context)!.amount, textScaler: const TextScaler.linear(1.2)))),
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
                                              keyboardAppearance: Brightness.dark,
                                              key: cnNewExercise.ensureVisibleKeys[index][0],
                                              maxLength: 6,
                                              style: getTextStyleForTextField(cnNewExercise.controllers[index][0].text),
                                              onTap: ()async{
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
                                              keyboardType: const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                  signed: false
                                              ),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                counterText: "",
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 8 ,vertical: 0.0),
                                              ),
                                              onChanged: (value) {
                                                value = value.trim();
                                                if(value.isNotEmpty){
                                                  value = validateDoubleTextInput(value);
                                                  final newValue = double.tryParse(value);
                                                  cnNewExercise.exercise.sets[index].weight = newValue;
                                                  if(newValue == null){
                                                    cnNewExercise.controllers[index][0].clear();
                                                  } else{
                                                    cnNewExercise.controllers[index][0].text = value;
                                                  }
                                                }
                                                else{
                                                  cnNewExercise.exercise.sets[index].weight = null;
                                                }
                                                setState(() {

                                                });
                                              },
                                            ),
                                          ),

                                          /// Amount
                                          Container(
                                            width: _widthSetWeightAmount,
                                            height: 35,
                                            color: Colors.transparent,
                                            child: TextField(
                                              keyboardAppearance: Brightness.dark,
                                              key: cnNewExercise.ensureVisibleKeys[index][1],
                                              maxLength: 3,
                                              style: const TextStyle(
                                                  fontSize: 18
                                              ),
                                              onTap: ()async{
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
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                counterText: "",
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 8 ,vertical: 0.0),
                                              ),
                                              onChanged: (value){
                                                value = value.trim();
                                                if(value.isNotEmpty){
                                                  final newValue = int.tryParse(value);
                                                  cnNewExercise.exercise.sets[index].amount = newValue;
                                                  if(newValue == null){
                                                    cnNewExercise.controllers[index][1].clear();
                                                  }
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
                      child: SizedBox(
                        height: _totalHeightBottomBox,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            /// faded container
                            Positioned(
                              bottom: _heightBottomColoredBox - 0.2,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: _totalHeightBottomBox - _heightBottomColoredBox,
                                decoration: BoxDecoration(
                                    gradient:  LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          // Colors.transparent,
                                          // Colors.black,
                                          const Color(0xff120a01).withOpacity(0.0),
                                          const Color(0xff120a01)
                                        ]
                                    )
                                ),
                              ),
                            ),
                            /// just colored container below faded container
                            Container(
                              height: _heightBottomColoredBox,
                              // color: Colors.black,
                              color: const Color(0xff120a01),
                            ),
                            /// bottom row with icons
                            Padding(
                              padding: EdgeInsets.only(bottom: Platform.isAndroid? 20 : 30, left: 30, right: 30),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  myIconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: onCancel
                                  ),
                                  myIconButton(
                                      icon: const Icon(Icons.check),
                                      onPressed: closePanelAndSaveExercise
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void onCancel(){
    cnNewExercise.closePanel(doClear: true);
    _formKey.currentState?.reset();
  }

  void onPanelSlide(value){
    cnWorkouts.animationControllerWorkoutPanel.value = 0.5 + value*0.5;

    /// Clear panel when it's completely closed
    if(value == 0){
      /// add animationTime delay to prevent clearing while opening since opening
      /// can trigger one call with value 0
      Future.delayed(Duration(milliseconds: cnNewExercise.animationTime), (){
        /// After delay we check again if the value is still null
        if(cnNewExercise.panelController.panelPosition == 0){
          cnNewExercise.clear();
        }
      });
    }
  }

  void dismissExercise(int index){
    setState(() {
      cnNewExercise.exercise.sets.removeAt(index);
      cnNewExercise.controllers.removeAt(index);
      cnNewExercise.ensureVisibleKeys.removeAt(index);
    });
  }

  void addSet(){
    setState(() {
      cnNewExercise.exercise.addSet();
      cnNewExercise.controllers.add([TextEditingController(),TextEditingController()]);
      cnNewExercise.ensureVisibleKeys.add([GlobalKey(), GlobalKey()]);
      cnNewExercise.scrollControllerSets.jumpTo(cnNewExercise.scrollControllerSets.position.pixels+44);
    });
  }

  void closePanelAndSaveExercise(){
    if (_formKey.currentState!.validate() && cnNewExercise.exercise.name.isNotEmpty) {
      cnNewExercise.exercise.removeEmptySets();

      if(cnNewExercise.onConfirm != null){
        cnNewExercise.onConfirm!(cnNewExercise.exercise);
      }

      cnNewExercise.closePanel(doClear: true);
      _formKey.currentState?.reset();
    }
  }

  Widget getRestInSecondsSelector() {
    return getSelectRestInSeconds(
        child: SizedBox(
          height: 35,
          child: Row(
            children: [
              Icon(Icons.timer, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
              const SizedBox(width: 5,),
              Text(AppLocalizations.of(context)!.restInSeconds, style: _style),
              const Spacer(),
              Text(mapRestInSecondsToString(restInSeconds: cnNewExercise.exercise.restInSeconds), style: _style),
              const SizedBox(width: 10),
              trailingArrow
            ],
          ),
        ),
        onConfirm: (dynamic value){
          if(value is int){
            cnNewExercise.exercise.restInSeconds = value;
            cnNewExercise.restController.text = value.toString();
            cnNewExercise.refresh();
          }
          else{
            if(value == "Clear"){
              cnNewExercise.exercise.restInSeconds = 0;
              cnNewExercise.restController.clear();
              cnNewExercise.refresh();
            }
            else{
              // cnNewExercise.restController.clear();
              cnStandardPopUp.open(
                context: context,
                onConfirm: (){
                  cnNewExercise.exercise.restInSeconds = int.tryParse(cnNewExercise.restController.text)?? 0;
                  vibrateCancel();
                  // cnNewExercise.restController.clear();
                  cnNewExercise.refresh();
                  Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime), (){
                    FocusScope.of(context).unfocus();
                  });
                },
                onCancel: (){
                  cnNewExercise.restController.text = cnNewExercise.exercise.restInSeconds.toString();
                  // cnNewExercise.restController.clear();
                  Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime), (){
                    FocusScope.of(context).unfocus();
                  });
                },
                child: TextField(
                  keyboardAppearance: Brightness.dark,
                  controller: cnNewExercise.restController,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    labelText: AppLocalizations.of(context)!.restInSeconds,
                    counterText: "",
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8 ,vertical: 0.0),
                  ),
                  style: const TextStyle(
                      fontSize: 18
                  ),
                  textAlign: TextAlign.center,
                  onChanged: (value){},
                ),
              );
            }
          }
        }
    );
  }

  Widget getSeatLevelSelector() {
    return getSelectSeatLevel(
      onConfirm: (dynamic value){
        if(value is int){
          cnNewExercise.exercise.seatLevel = value;
          cnNewExercise.refresh();
        }
        else if(value == "Clear"){
          cnNewExercise.exercise.seatLevel = null;
          cnNewExercise.refresh();
        }
      },
      child: SizedBox(
        height: 35,
        child: Row(
          children: [
            Icon(Icons.airline_seat_recline_normal, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
            const SizedBox(width: 5,),
            Text(AppLocalizations.of(context)!.seatLevel, style: _style),
            const Spacer(),
            const Spacer(flex: 4,),
            Text(cnNewExercise.exercise.seatLevel == null? "-" : cnNewExercise.exercise.seatLevel.toString(), style: _style),
            const SizedBox(width: 10),
            trailingArrow
          ],
        ),
      )
    );
  }

}

class CnNewExercisePanel extends ChangeNotifier {
  final PanelController panelController = PanelController();

  Key key = UniqueKey();
  Exercise exercise = Exercise();
  Workout workout = Workout();
  TextEditingController exerciseNameController = TextEditingController();
  TextEditingController restController = TextEditingController();
  TextEditingController seatLevelController = TextEditingController();
  ScrollController scrollControllerSets = ScrollController();
  Function? onConfirm;
  final int animationTime = 300;

  late List<List<TextEditingController>> controllers = exercise.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList();
  late List<List<GlobalKey>> ensureVisibleKeys = exercise.sets.map((e) => ([GlobalKey(), GlobalKey()])).toList();

  CnNewExercisePanel(){
    clear();
  }

  void setExercise(Exercise ex){
    exercise = ex;
    controllers = exercise.sets.map((e) => ([TextEditingController(text: "${e.weight}"), TextEditingController(text: "${e.amount}")])).toList();
    ensureVisibleKeys = exercise.sets.map((e) => ([GlobalKey(), GlobalKey()])).toList();
    exerciseNameController = TextEditingController(text: ex.name);
    restController = TextEditingController(text: ex.restInSeconds > 0? ex.restInSeconds.toString() : "");
    seatLevelController = TextEditingController(text: ex.seatLevel != null? ex.seatLevel.toString() : "");
  }

  void openPanel({required Workout workout, Exercise? exercise, Function? onConfirm}){
    if(exercise != null){
      setExercise(exercise);
    }
    this.workout = workout;
    this.onConfirm = onConfirm;
    HapticFeedback.selectionClick();
    panelController.animatePanelToPosition(
        1,
        duration: Duration(milliseconds: animationTime),
        curve: Curves.easeOut
    );
  }

  void closePanel({bool doClear = false}){
    panelController.animatePanelToPosition(
        0,
        duration: Duration(milliseconds: animationTime),
        curve: Curves.decelerate
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
