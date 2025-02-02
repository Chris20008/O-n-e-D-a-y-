import 'dart:math';
import 'dart:ui';
import 'package:fitness_app/assets/custom_icons/my_icons_icons.dart';
import 'package:fitness_app/widgets/my_slide_up_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  late CnNewExercisePanel cnNewExercise = Provider.of<CnNewExercisePanel>(context);
  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  double _iconSize = 25;
  final double _widthSetWeightAmount = 55;
  final _formKey = GlobalKey<FormState>();
  final double _heightBottomColoredBox = Platform.isAndroid? 15 : 25;
  final double _totalHeightBottomBox = Platform.isAndroid? 70 : 80;
  late TextStyle _style = TextStyle(color: Colors.white, fontSize: 18 - shrinkOffset * 8);
  final _color = const Color(0xff1c1001);
  final heightHeader = 280.0;
  final textDisappearOffset = 0.1;

  GlobalKey addSetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      cnNewExercise.scrollControllerSets.addListener(() {
        setState(() {

        });
      });
    });
  }

  double get shrinkOffset {
    final value = cnNewExercise.scrollControllerSets.hasClients
        ? (cnNewExercise.scrollControllerSets.offset / 150.0).clamp(0.0, 1.0)
        : 0.0;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final insetsBottom = MediaQuery.of(context).viewInsets.bottom;
    // print(_style.fontSize);
    // _style = TextStyle(color: Colors.white, fontSize: 18 - shrinkOffset * 2);
    // _iconSize = 25 - shrinkOffset * 2;
    // _style.cop

    return PopScope(
      canPop: false,
      onPopInvoked: (doPop){
        if (cnNewExercise.panelController.isPanelOpen){
          cnNewExercise.closePanel(doClear: false);
        }
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: MySlideUpPanel(
              onPanelSlide: onPanelSlide,
              key: cnNewExercise.key,
              controller: cnNewExercise.panelController,
              backdropOpacity: 0.25,
              color: _color,
              animationControllerName: "NewExercisePanel",
              descendantAnimationControllerName: "NewWorkoutPanel",
              panel: ClipRRect(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 0, right: 20.0, left: 20.0, top: 10),
                      child: GestureDetector(
                        // onTap: () {
                        //   FocusScope.of(context).unfocus();
                        // },
                        child: ListView(
                          padding: EdgeInsets.only(top: heightHeader),
                          controller: cnNewExercise.scrollControllerSets,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            // Center(child: panelTopBar),
                            // const SizedBox(height: 15,),
                            // Center(child: Text(AppLocalizations.of(context)!.exercise, textScaler: const TextScaler.linear(1.5))),
                            // const SizedBox(height: 10,),
                            //
                            // getHeader(),
                            //
                            // const SizedBox(height: 25,),
                            // Container(
                            //   height: 1,
                            //   decoration: BoxDecoration(
                            //       color: Colors.white.withOpacity(0.5),
                            //       borderRadius: BorderRadius.circular(2)
                            //   ),
                            // ),
                            const SizedBox(height: 15,),
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(child: Center(child: OverflowSafeText(AppLocalizations.of(context)!.set, maxLines: 1))),
                                Expanded(child: Center(child: OverflowSafeText(cnNewExercise.exercise.getLeftTitle(context), maxLines: 1))),
                                Expanded(child: Center(child: OverflowSafeText(cnNewExercise.exercise.getRightTitle(context), maxLines: 1))),
                              ],
                            ),
                            ReorderableListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              // controller: ScrollController(),
                              padding: const EdgeInsets.only(top: 10),
                              shrinkWrap: true,
                              // key: listViewKey,
                              itemCount: cnNewExercise.exercise.sets.length,
                              // itemCount: cnNewExercise.exercise.sets.length,
                              itemBuilder: (BuildContext context, int index) {
                                Widget? child;
                                child = Padding(
                                  padding: const EdgeInsets.only(top: 3, bottom: 3),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      getSet(
                                          context: context,
                                          index: index,
                                          newEx: cnNewExercise.exercise,
                                          width: 50,
                                          onConfirm: (){
                                            cnNewExercise.refresh();
                                          }
                                      ),

                                      /// Weight
                                      Container(
                                        width: _widthSetWeightAmount,
                                        height: 35,
                                        color: Colors.transparent,
                                        child: TextField(
                                          keyboardAppearance: Brightness.dark,
                                          key: cnNewExercise.ensureVisibleKeys[index][0],
                                          maxLength: cnNewExercise.controllers[index][0].text.contains(".")? 6 : 4,
                                          style: getTextStyleForTextField(cnNewExercise.controllers[index][0].text),
                                          onTap: ()async{
                                            cnNewExercise.controllers[index][0].selection =  TextSelection(baseOffset: 0, extentOffset: cnNewExercise.controllers[index][0].value.text.length);
                                            if(insetsBottom == 0) {
                                              await Future.delayed(const Duration(milliseconds: 500));
                                            }
                                            Scrollable.ensureVisible(
                                                cnNewExercise.ensureVisibleKeys[index][0].currentContext!,
                                                duration: const Duration(milliseconds: 300),
                                                curve: Curves.easeInOut,
                                                alignment: 0.4
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
                                            setState(() {});
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
                                          maxLength: cnNewExercise.exercise.categoryIsReps()? 3 : 8,
                                          style: cnNewExercise.exercise.categoryIsReps()
                                              ? const TextStyle(fontSize: 18)
                                              : getTextStyleForTextField(cnNewExercise.controllers[index][1].text),
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
                                            /// For Reps
                                            if(cnNewExercise.exercise.categoryIsReps()){
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
                                            }
                                            /// For Time
                                            else{
                                              List result = parseTextControllerAmountToTime(value);
                                              cnNewExercise.controllers[index][1].text = result[1];
                                              cnNewExercise.exercise.sets[index].amount = result[0];
                                              setState(() {});
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                return Slidable(
                                    key: cnNewExercise.slidableKeys[index],
                                    // key: UniqueKey(),
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
                              proxyDecorator: (
                                  Widget child, int index, Animation<double> animation) {
                                return AnimatedBuilder(
                                  animation: animation,
                                  builder: (BuildContext context, Widget? child) {
                                    final double animValue = Curves.easeInOut.transform(animation.value);
                                    final double scale = lerpDouble(1, 1.06, animValue)!;
                                    return Transform.scale(
                                      scale: scale,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Material(
                                            child: Container(
                                                padding: const EdgeInsets.only(left: 2),
                                                color: Colors.grey.withOpacity(0.1),
                                                child: child
                                            )
                                        ),
                                      ),
                                    );
                                  },
                                  child: child,
                                );
                              },
                              onReorder: (int oldIndex, int newIndex){
                                setState(() {
                                  if (oldIndex < newIndex) {
                                    newIndex -= 1;
                                  }
                                  final item = cnNewExercise.exercise.sets.removeAt(oldIndex);
                                  cnNewExercise.exercise.sets.insert(newIndex, item);
                                  final weightAndAmount = cnNewExercise.controllers.removeAt(oldIndex);
                                  cnNewExercise.controllers.insert(newIndex, weightAndAmount);
                                });
                              },
                            ),
                            Column(
                              children: [
                                const SizedBox(height: 15,),

                                Row(
                                  children: [
                                    Expanded(
                                      child: IconButton(
                                          key: addSetKey,
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
                            )
                          ],
                        ),
                      ),
                    ),

                    // Dynamischer Header
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        // height: heightHeader - ((shrinkOffset > 0.26? sqrt(shrinkOffset-0.26) : 0) * 185).clamp(0, 90), // Verkleinerung beim Scrollen
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.bottomLeft,
                        color: _color,
                        // decoration: BoxDecoration(
                        //   color: Colors.blue, ///.withOpacity(1 - shrinkOffset * 0.8),
                        //   borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                        // ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10,),
                            Center(child: panelTopBar),
                            const SizedBox(height: 15,),
                            if (shrinkOffset < 0.6)
                              SizedBox(
                                  height: 30 - (30 * shrinkOffset),
                                  child: Center(
                                      child: Text(
                                          AppLocalizations.of(context)!.exercise,
                                          textScaler: TextScaler.linear(1.5 - (1.5 * shrinkOffset))
                                      )
                                  )
                              )
                            else
                              SizedBox(height: 12),
                            const SizedBox(height: 10,),

                            getHeader(),

                            // const SizedBox(height: 25,),
                            // Text(
                            //   "Max Mustermann",
                            //   style: TextStyle(
                            //     fontSize: 24 - shrinkOffset * 8, // Schrumpft mit Scroll
                            //     fontWeight: FontWeight.bold,
                            //     color: Colors.white,
                            //   ),
                            // ),
                            // if (shrinkOffset < 0.8)
                            //   Opacity(
                            //     opacity: (1 - shrinkOffset),
                            //     child: Text(
                            //       "Zusätzliche Infos",
                            //       style: TextStyle(fontSize: 16, color: Colors.white70),
                            //     ),
                            //   ),
                            // SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(onPressed: onCancel, child: const Text("Abbrechen")),
                        CupertinoButton(onPressed: closePanelAndSaveExercise, child: const Text("Speichern")),
                      ],
                    )
                  ],
                ),
              )
            )
          ),
        ],
      ),
    );
  }

  void onCancel(){
    cnNewExercise.closePanel(doClear: true);
    _formKey.currentState?.reset();
    vibrateCancel();
  }

  void onPanelSlide(value){

    /// Clear panel when it's completely closed
    if(value == 0){
      /// add animationTime delay to prevent clearing while opening since opening
      /// can trigger one call with value 0
      Future.delayed(Duration(milliseconds: cnNewExercise.animationTime), (){
        /// After delay we check again if the value is still null
        if(cnNewExercise.panelController.panelPosition == 0){
          _formKey.currentState?.reset();
          cnNewExercise.clear();
        }
      });
    }
  }

  void dismissExercise(int index){
    setState(() {
      cnNewExercise.exercise.sets.removeAt(index);
      cnNewExercise.slidableKeys.removeAt(index);
      cnNewExercise.controllers.removeAt(index);
      cnNewExercise.ensureVisibleKeys.removeAt(index);
    });
  }

  void addSet(){
    setState(() {
      cnNewExercise.exercise.addSet();
      cnNewExercise.slidableKeys.add(UniqueKey());
      cnNewExercise.controllers.add([TextEditingController(),TextEditingController()]);
      cnNewExercise.ensureVisibleKeys.add([GlobalKey(), GlobalKey()]);
      final RenderObject? renderObject = addSetKey.currentContext?.findRenderObject();
      if (renderObject is RenderBox) {
        final Offset widgetPosition = renderObject.localToGlobal(Offset.zero);
        final Size widgetSize = renderObject.size;
        final double screenHeight = MediaQuery.of(context).size.height;

        final viewInsets = MediaQuery.of(context).viewInsets.bottom;
        final isVisible = widgetPosition.dy + widgetSize.height * 80 > 0 &&
            widgetPosition.dy + 80 + viewInsets < screenHeight;
        if(!isVisible){
          cnNewExercise.scrollControllerSets.jumpTo(cnNewExercise.scrollControllerSets.position.pixels+41);
        }
      }
    });
  }

  void closePanelAndSaveExercise(){
    if (_formKey.currentState!.validate() && cnNewExercise.exercise.name.isNotEmpty) {
      final copy = Exercise.copy(cnNewExercise.exercise);
      copy.removeEmptySets();

      if(copy.sets.isNotEmpty){
        vibrateConfirm();
        cnNewExercise.exercise.removeEmptySets();
        if(cnNewExercise.onConfirm != null){
          cnNewExercise.onConfirm!(cnNewExercise.exercise);
        }

        cnNewExercise.closePanel(doClear: true);
        _formKey.currentState?.reset();
      }
      else{
        setState(() {
          Fluttertoast.showToast(
              msg: "Add at least one Set",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.SNACKBAR,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey[800]?.withOpacity(0.9),
              textColor: Colors.white,
              fontSize: 16.0
          );
        });
      }
    }
  }

  Widget getRestInSecondsSelector(TextStyle descriptionStyle) {
    return getSelectRestInSeconds(
        currentTime: cnNewExercise.exercise.restInSeconds,
        context: context,
        child: SizedBox(
          height: 35,
          child: Row(
            children: [
              Icon(Icons.timer, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
              const SizedBox(width: 5,),
              if(shrinkOffset < textDisappearOffset)
                Text(AppLocalizations.of(context)!.restTime, style: descriptionStyle),
              const Spacer(),
              Text(mapRestInSecondsToString(restInSeconds: cnNewExercise.exercise.restInSeconds), style: _style),
              const SizedBox(width: 10),
              trailingChoice()
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
            if(value == AppLocalizations.of(context)!.clear){
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

  Widget getSeatLevelSelector(TextStyle descriptionStyle) {
    return getSelectSeatLevel(
      currentSeatLevel: cnNewExercise.exercise.seatLevel,
      context: context,
      onConfirm: (dynamic value){
        if(value is int){
          cnNewExercise.exercise.seatLevel = value;
          cnNewExercise.refresh();
        }
        else if(value == AppLocalizations.of(context)!.clear){
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
            if(shrinkOffset < textDisappearOffset)
              Text(AppLocalizations.of(context)!.seatLevel, style: descriptionStyle),
            const Spacer(),
            const Spacer(flex: 4,),
            Text(cnNewExercise.exercise.seatLevel == null? "-" : cnNewExercise.exercise.seatLevel.toString(), style: _style),
            const SizedBox(width: 10),
            trailingChoice()
          ],
        ),
      )
    );
  }

  Widget getExerciseCategorySelector(TextStyle descriptionStyle) {
    return getSelectCategory(
        context: context,
        currentCategory: cnNewExercise.exercise.category,
        onConfirm: (int category){
          cnNewExercise.exercise.category = category;
          cnNewExercise.refresh();
          cnNewExercise.clearTextControllers();
        },
        child: SizedBox(
          height: 35,
          child: Row(
            children: [
              Icon(MyIcons.tags, size: _iconSize-3, color: Colors.amber[900]!.withOpacity(0.6),),
              const SizedBox(width: 8,),
              if(shrinkOffset < textDisappearOffset)
                Text("Kategorie", style: descriptionStyle),
              const Spacer(),
              const Spacer(flex: 4,),
              Text(cnNewExercise.exercise.getCategoryName(), style: _style),
              const SizedBox(width: 10),
              trailingChoice()
            ],
          ),
        )
    );
  }

  Widget getBodyWeightPercentSelector(TextStyle descriptionStyle) {
    return getSelectBodyWeightPercent(
        context: context,
        currentBodyWeightPercent: cnNewExercise.exercise.bodyWeightPercent,
        onConfirm: (int bodyWeight){
          cnNewExercise.exercise.bodyWeightPercent = bodyWeight/100;
          cnNewExercise.refresh();
        },
        child: SizedBox(
          height: 35,
          child: Row(
            children: [
              Icon(MyIcons.weight, size: _iconSize-4, color: Colors.amber[900]!.withOpacity(0.6),),
              const SizedBox(width: 8,),
              if(shrinkOffset < textDisappearOffset)
                Text("Körpergewicht", style: descriptionStyle),
              const Spacer(),
              const Spacer(flex: 4,),
              Text("${(cnNewExercise.exercise.bodyWeightPercent * 100).toInt()} %", style: _style),
              const SizedBox(width: 10),
              trailingChoice()
            ],
          ),
        )
    );
  }

  getHeader() {
    return LayoutBuilder(
        builder: (context, constraints){
          final widthSelectors = (constraints.maxWidth - (constraints.maxWidth * (sqrt(shrinkOffset)))).clamp(constraints.maxWidth*0.5, constraints.maxWidth);
          final TextStyle _descriptionStyle = _style.copyWith(
              color: _style.color?.withOpacity(1 - (shrinkOffset*10).clamp(0, 1)),
              fontSize: _style.fontSize! - (2 * shrinkOffset*30)
          );
          return Wrap(
            key: cnNewExercise.keyHeader,
            children: [
              /// Exercise name
              Form(
                key: _formKey,
                child: TextFormField(
                  focusNode: cnNewExercise.focusNodeTextFieldExerciseName,
                  key: cnNewExercise.keyExerciseName,
                  keyboardAppearance: Brightness.dark,
                  maxLength: 40,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.panelExEnterName;
                    }
                    else if(
                    exerciseNameExistsInWorkout(workout: cnNewExercise.workout, exerciseName: cnNewExercise.exercise.name) &&
                        cnNewExercise.exercise.originalName?.toLowerCase() != cnNewExercise.exercise.name.toLowerCase()
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
              ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: widthSelectors),
                  child: getRestInSecondsSelector(_descriptionStyle)
              ),

              const SizedBox(height: 0),

              /// Seat Level Row and Selector
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: widthSelectors),
                child: getSeatLevelSelector(_descriptionStyle),
              ),

              const SizedBox(height: 5),

              /// Exercise Category Selector
              ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: widthSelectors),
                  child: cnNewExercise.exercise.isNewExercise()
                      ? getExerciseCategorySelector(_descriptionStyle)
                      : Listener(
                    onPointerUp: (PointerUpEvent event)async{
                      HapticFeedback.selectionClick();
                      notificationPopUp(
                          context: context,
                          title: 'Change category',
                          message: "You can't change the Category of an existing exercise"
                      );
                    },
                    child: SizedBox(
                      height: 35,
                      child: Row(
                        children: [
                          Icon(MyIcons.tags, size: _iconSize-3, color: Colors.amber[900]!.withOpacity(0.6),),
                          const SizedBox(width: 8,),
                          if(shrinkOffset < textDisappearOffset)
                            Text("Kategorie", style: _descriptionStyle),
                          // const Spacer(),
                          // const Spacer(flex: 4,),
                          Expanded(child: OverflowSafeText(cnNewExercise.exercise.getCategoryName(), style: _style, maxLines: 1, textAlign: TextAlign.end, minFontSize: 15)),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ),
              ),

              // /// Exercise Category Selector
              // if(cnNewExercise.exercise.isNewExercise())
              //   getExerciseCategorySelector()
              // else
              //   Listener(
              //     onPointerUp: (PointerUpEvent event)async{
              //       HapticFeedback.selectionClick();
              //       notificationPopUp(
              //           context: context,
              //           title: 'Change category',
              //           message: "You can't change the Category of an existing exercise"
              //       );
              //     },
              //     child: SizedBox(
              //       height: 35,
              //       child: Row(
              //         children: [
              //           Icon(MyIcons.tags, size: _iconSize-3, color: Colors.amber[900]!.withOpacity(0.6),),
              //           const SizedBox(width: 8,),
              //           Text("Kategorie", style: _style),
              //           const Spacer(),
              //           const Spacer(flex: 4,),
              //           Text(cnNewExercise.exercise.getCategoryName(), style: _style),
              //           const SizedBox(width: 20),
              //         ],
              //       ),
              //     ),
              //   ),

              const SizedBox(height: 5),

              /// Seat Level Row and Selector
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: widthSelectors),
                child: cnNewExercise.exercise.isNewExercise()
                    ? getBodyWeightPercentSelector(_descriptionStyle)
                    : Listener(
                  onPointerUp: (PointerUpEvent event)async{
                    HapticFeedback.selectionClick();
                    notificationPopUp(
                        context: context,
                        title: "Bodyweight",
                        message: "You can't change the used bodyweight of an existing exercise"
                    );
                  },
                  child: SizedBox(
                    height: 35,
                    child: Row(
                      children: [
                        Icon(MyIcons.weight, size: _iconSize-4, color: Colors.amber[900]!.withOpacity(0.6),),
                        const SizedBox(width: 8,),
                        if(shrinkOffset < textDisappearOffset)
                          Text("Körpergewicht", style: _descriptionStyle),
                        const Spacer(),
                        const Spacer(flex: 4,),
                        Text("${(cnNewExercise.exercise.bodyWeightPercent * 100).toInt()} %", style: _style),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                ),
              ),

              // /// Seat Level Row and Selector
              // if(cnNewExercise.exercise.isNewExercise())
              //   getBodyWeightPercentSelector()
              // else
              //   Listener(
              //     onPointerUp: (PointerUpEvent event)async{
              //       HapticFeedback.selectionClick();
              //       notificationPopUp(
              //           context: context,
              //           title: "Bodyweight",
              //           message: "You can't change the used bodyweight of an existing exercise"
              //       );
              //     },
              //     child: SizedBox(
              //       height: 35,
              //       child: Row(
              //         children: [
              //           Icon(MyIcons.weight, size: _iconSize-4, color: Colors.amber[900]!.withOpacity(0.6),),
              //           const SizedBox(width: 8,),
              //           Text("Körpergewicht", style: _style),
              //           const Spacer(),
              //           const Spacer(flex: 4,),
              //           Text("${(cnNewExercise.exercise.bodyWeightPercent * 100).toInt()} %", style: _style),
              //           const SizedBox(width: 20),
              //         ],
              //       ),
              //     ),
              //   ),
            ],
          );
        }
    );
  }
}

class CnNewExercisePanel extends ChangeNotifier {
  final PanelController panelController = PanelController();

  GlobalKey keyHeader = GlobalKey();
  GlobalKey keyExerciseName = GlobalKey();
  final FocusNode focusNodeTextFieldExerciseName = FocusNode();
  Key key = UniqueKey();
  Exercise exercise = Exercise();
  Workout workout = Workout();
  TextEditingController exerciseNameController = TextEditingController();
  TextEditingController restController = TextEditingController();
  TextEditingController seatLevelController = TextEditingController();
  ScrollController scrollControllerSets = ScrollController();
  late List<Key> slidableKeys = exercise.generateKeyForEachSet();
  Function? onConfirm;
  final int animationTime = 500;

  late List<List<TextEditingController>> controllers = exercise.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList();
  late List<List<GlobalKey>> ensureVisibleKeys = exercise.sets.map((e) => ([GlobalKey(), GlobalKey()])).toList();

  CnNewExercisePanel(){
    clear();
  }

  void setExercise(Exercise ex){
    exercise = ex;
    slidableKeys = exercise.generateKeyForEachSet();
    controllers = exercise.sets.map((set) => ([TextEditingController(text: "${set.weightAsTrimmedDouble}"), TextEditingController(text: "${exercise.categoryIsReps()? (set.amount) : parseTextControllerAmountToTime(set.amount)[1]}")])).toList();
    ensureVisibleKeys = exercise.sets.map((e) => ([GlobalKey(), GlobalKey()])).toList();
    exerciseNameController = TextEditingController(text: ex.name);
    restController = TextEditingController(text: ex.restInSeconds > 0? ex.restInSeconds.toString() : "");
    seatLevelController = TextEditingController(text: ex.seatLevel != null? ex.seatLevel.toString() : "");
  }

  void clearTextControllers(){
    for (var element in controllers) {
      element[0].text = "";
      element[1].text = "";
    }
    for (SingleSet set in exercise.sets) {
      set.weight = null;
      set.amount = null;
    }
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
        curve: Curves.fastEaseInToSlowEaseOut
    );
  }

  void closePanel({bool doClear = false}){
    panelController.animatePanelToPosition(
        0,
        duration: Duration(milliseconds: animationTime-150),
        curve: Curves.decelerate
    ).then((value) => {
      if(doClear){
        clear()
      }
    });
  }

  void clear(){
    exercise = Exercise();
    workout = Workout();
    controllers = exercise.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList();
    exerciseNameController = TextEditingController();
    restController = TextEditingController();
    seatLevelController = TextEditingController();
    // key = UniqueKey();
    ensureVisibleKeys = exercise.sets.map((e) => ([GlobalKey(), GlobalKey()])).toList();
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}
