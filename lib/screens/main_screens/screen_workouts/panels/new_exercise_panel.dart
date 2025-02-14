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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewExercisePanel extends StatefulWidget {
  const NewExercisePanel({super.key});

  @override
  State<NewExercisePanel> createState() => _NewExercisePanelState();
}

class _NewExercisePanelState extends State<NewExercisePanel> with TickerProviderStateMixin{
  late CnNewExercisePanel cnNewExercise = Provider.of<CnNewExercisePanel>(context);
  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  double _iconSize = 25;
  final double _widthSetWeightAmount = 55;
  late TextStyle _style = TextStyle(color: Colors.white, fontSize: 18 - shrinkOffset * 8);
  late final _color = Theme.of(context).primaryColor;
  double heightHeader = 120.0;
  final textDisappearOffset = 0.1;
  bool wasShownBigChild = true;
  bool isTouchingListView = false;

  GlobalKey addSetKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cnNewExercise.initVsync(this);
      cnNewExercise.scrollController.addListener(() {
        // for (SlidableExerciseOrLink item in cnNewWorkout.exercisesAndLinks) {
        //   SlidableController controller = item.slidableController;
        //   if(controller.animation.value > 0 && !controller.closing){
        //     controller.close();
        //   }
        // }
      });
    });
  }

  double get shrinkOffset {
    final value = cnNewExercise.scrollController.hasClients
        ? (cnNewExercise.scrollController.offset / 150.0).clamp(0.0, 1.0)
        : 0.0;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final insetsBottom = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: false,
      onPopInvoked: (doPop){
        if (cnNewExercise.panelController.isPanelOpen){
          cnNewExercise.closePanel(doClear: false, context: context);
        }
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: MySlideUpPanel(
              // onPanelSlide: onPanelSlide,
              // isTouchingListView: isTouchingListView,
              key: cnNewExercise.key,
              controller: cnNewExercise.panelController,
              backdropOpacity: 0.25,
              color: _color,
              animationControllerName: "NewExercisePanel",
              descendantAnimationControllerName: "NewWorkoutPanel",
              // scrollControllerInnerList: cnNewExercise.scrollController,
              panelBuilder: (context, listView) {
                return ClipRRect(
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: SlidableAutoCloseBehavior(
                          child: listView(
                            padding: EdgeInsets.only(top: heightHeader),
                            controller: cnNewExercise.scrollController,
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            children: [

                              CupertinoListSection.insetGrouped(
                                key: cnNewExercise.keyHeader,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor
                                ),
                                backgroundColor: Colors.transparent,
                                children: [
                                  /// Rest in Seconds Row and Selector
                                  getRestInSecondsSelector(),

                                  /// Seat Level Row and Selector
                                  getSeatLevelSelector(),

                                  /// Exercise Category Selector
                                  getExerciseCategorySelector(isTemplate: cnNewExercise.exercise.isNewExercise()),

                                  /// Body Weight selector
                                  getBodyWeightPercentSelector(isTemplate: cnNewExercise.exercise.isNewExercise() || cnNewExercise.workout.isTemplate),
                                ],
                              ),

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
                                padding: const EdgeInsets.only(top: 10),
                                shrinkWrap: true,
                                itemCount: cnNewExercise.exercise.sets.length,
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
                                            focusNode: cnNewExercise.focusNodes[index][0],
                                            onSubmitted: (value){
                                              FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[index][1]);
                                              onTapField(index, insetsBottom, 1);
                                            },
                                            textInputAction: TextInputAction.next,
                                            keyboardAppearance: Brightness.dark,
                                            key: cnNewExercise.ensureVisibleKeys[index][0],
                                            maxLength: cnNewExercise.controllers[index][0].text.contains(".")? 6 : 4,
                                            style: getTextStyleForTextField(cnNewExercise.controllers[index][0].text),
                                            onTap: ()async{
                                              onTapField(index, insetsBottom, 0);
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
                                            focusNode: cnNewExercise.focusNodes[index][1],
                                            onSubmitted: (value){
                                              if (index < cnNewExercise.exercise.sets.length - 1) {
                                                FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[index + 1][0]);
                                                onTapField(index+1, insetsBottom, 0);
                                              } else {
                                                FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[index][1]);
                                                addSet();
                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                  FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[index + 1][0]);
                                                    onTapField(index+1, insetsBottom, 0);
                                                });
                                                // FocusScope.of(context).unfocus();
                                              }
                                            },
                                            textInputAction: TextInputAction.next,
                                            keyboardAppearance: Brightness.dark,
                                            key: cnNewExercise.ensureVisibleKeys[index][1],
                                            maxLength: cnNewExercise.exercise.categoryIsReps()? 3 : 8,
                                            style: cnNewExercise.exercise.categoryIsReps()
                                                ? const TextStyle(fontSize: 18)
                                                : getTextStyleForTextField(cnNewExercise.controllers[index][1].text),
                                            onTap: ()async{
                                              onTapField(index, insetsBottom, 1);
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
                                      endActionPane: cnNewExercise.exercise.sets.length > 1?
                                      ActionPane(
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
                                            backgroundColor: const Color(0xFFA12D2C),
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete,
                                          ),
                                        ],
                                      ) : null,
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
                                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0? MediaQuery.of(context).viewInsets.bottom+10 : 60)
                                ],
                              )
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.bottomLeft,
                            color: _color,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 67,),
                                getHeader(),
                              ],
                            )
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 10,
                              child: CupertinoButton(onPressed: onCancel, child: Text(AppLocalizations.of(context)!.cancel, textAlign: TextAlign.left))
                          ),
                          Expanded(
                              flex: 13,
                              child: Text(
                              AppLocalizations.of(context)!.exercise,
                              textScaler: const TextScaler.linear(1.3),
                              textAlign: TextAlign.center,
                              // style: TextStyle(color: Colors.grey)
                          )),
                          Expanded(
                              flex: 10,
                              child: CupertinoButton(onPressed: closePanelAndSaveExercise, child: const Text("Speichern", textAlign: TextAlign.right))
                          ),
                        ],
                      )
                    ],
                  ),
                );
              }
            )
          ),
        ],
      ),
    );
  }

  void onCancel(){
    cnNewExercise.closePanel(doClear: true, context: context);
    cnNewExercise.formKey.currentState?.reset();
    vibrateCancel();
  }

  void dismissExercise(int index){
    setState(() {
      cnNewExercise.exercise.sets.removeAt(index);
      cnNewExercise.slidableKeys.removeAt(index);
      cnNewExercise.controllers.removeAt(index);
      cnNewExercise.ensureVisibleKeys.removeAt(index);
      cnNewExercise.focusNodes.removeAt(index);
    });
  }

  void addSet(){
    setState(() {
      final previousSet = cnNewExercise.exercise.sets.last;
      cnNewExercise.exercise.addSet(weight: previousSet.weight, amount: previousSet.amount);
      cnNewExercise.slidableKeys.add(UniqueKey());
      cnNewExercise.controllers.add([
        TextEditingController(text: cnNewExercise.controllers.last[0].text),
        TextEditingController(text: cnNewExercise.controllers.last[1].text)
      ]);
      cnNewExercise.ensureVisibleKeys.add([GlobalKey(), GlobalKey()]);
      cnNewExercise.focusNodes.add([FocusNode(), FocusNode()]);
      final RenderObject? renderObject = addSetKey.currentContext?.findRenderObject();
      if (renderObject is RenderBox) {
        final Offset widgetPosition = renderObject.localToGlobal(Offset.zero);
        final Size widgetSize = renderObject.size;
        final double screenHeight = MediaQuery.of(context).size.height;

        final viewInsets = MediaQuery.of(context).viewInsets.bottom;
        final isVisible = widgetPosition.dy + widgetSize.height * 80 > 0 &&
            widgetPosition.dy + 80 + viewInsets < screenHeight;
        if(!isVisible){
          cnNewExercise.scrollController.jumpTo(cnNewExercise.scrollController.position.pixels+41);
        }
      }
    });
  }

  void closePanelAndSaveExercise(){
    if (cnNewExercise.formKey.currentState!.validate() && cnNewExercise.exercise.name.isNotEmpty) {
      final copy = Exercise.copy(cnNewExercise.exercise);
      copy.removeEmptySets();

      if(copy.sets.isNotEmpty){
        vibrateConfirm();
        cnNewExercise.exercise.removeEmptySets();
        if(cnNewExercise.onConfirm != null){
          cnNewExercise.onConfirm!(cnNewExercise.exercise);
        }

        cnNewExercise.closePanel(doClear: true, context: context);
        cnNewExercise.formKey.currentState?.reset();
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

  Widget getRestInSecondsSelector() {
    return getSelectRestInSeconds(
        currentTime: cnNewExercise.exercise.restInSeconds,
        context: context,
        child: CupertinoListTile(
          leading: Icon(Icons.timer, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
          title: Row(
            children: [
              Text(AppLocalizations.of(context)!.restTime, style: _style),
              const Spacer(),
              Text(mapRestInSecondsToString(restInSeconds: cnNewExercise.exercise.restInSeconds), style: _style),
              const SizedBox(width: 10),
            ],
          ),
          trailing: trailingChoice(),
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
                    FocusManager.instance.primaryFocus?.unfocus();
                  });
                },
                onCancel: (){
                  cnNewExercise.restController.text = cnNewExercise.exercise.restInSeconds.toString();
                  // cnNewExercise.restController.clear();
                  Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime), (){
                    FocusManager.instance.primaryFocus?.unfocus();
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
        child: CupertinoListTile(
          leading: Icon(Icons.airline_seat_recline_normal, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
          trailing: trailingChoice(),
            title: Row(
            children: [
              Text(AppLocalizations.of(context)!.seatLevel, style: _style),
              const Spacer(),
              Text(cnNewExercise.exercise.seatLevel == null? "-" : cnNewExercise.exercise.seatLevel.toString(), style: _style),
              const SizedBox(width: 10)
            ],
          ),
        )
    );
  }

  Widget getExerciseCategorySelector({
    required bool isTemplate
  }) {
    Widget child = CupertinoListTile(
        leading: Icon(MyIcons.tags, size: _iconSize-3, color: Colors.amber[900]!.withOpacity(0.6),),
        title: Row(
          children: [
            Text("Kategorie", style: _style),
            const Spacer(),
            Text(cnNewExercise.exercise.getCategoryName(), style: _style),
            const SizedBox(width: 10)
          ],
        ),
        trailing: isTemplate? trailingChoice() : null
    );

    if(isTemplate){
      return getSelectCategory(
          context: context,
          currentCategory: cnNewExercise.exercise.category,
          onConfirm: (int category){
            cnNewExercise.exercise.category = category;
            cnNewExercise.refresh();
            cnNewExercise.clearTextControllers();
          },
          child: child
      );
    }

    return CupertinoButton(
      onPressed: (){
        HapticFeedback.selectionClick();
        notificationPopUp(
            context: context,
            title: 'Change category',
            message: "You can't change the Category of an existing exercise"
        );
      },
      padding: EdgeInsets.zero,
      child: child
    );
  }

  Widget getBodyWeightPercentSelector({
    required bool isTemplate
  }) {
    Widget child = CupertinoListTile(
        leading: Icon(MyIcons.weight, size: _iconSize-4, color: Colors.amber[900]!.withOpacity(0.6),),
        title: Row(
          children: [
            Text("Körpergewicht", style: _style),
            const Spacer(),
            Text("${(cnNewExercise.exercise.bodyWeightPercent * 100).toInt()} %", style: _style),
            const SizedBox(width: 10),
          ],
        ),
        trailing: isTemplate? trailingChoice() : null
    );

    if(isTemplate){
      return getSelectBodyWeightPercent(
          context: context,
          currentBodyWeightPercent: cnNewExercise.exercise.bodyWeightPercent,
          onConfirm: (int bodyWeight){
            cnNewExercise.exercise.bodyWeightPercent = bodyWeight/100;
            cnNewExercise.refresh();
          },
          child: child
      );
    }

    return CupertinoButton(
        onPressed: (){
          HapticFeedback.selectionClick();
          notificationPopUp(
              context: context,
              title: "Bodyweight",
              message: "You can change the bodyweight only in the exercise template. The changes will be applied to all exercises with the same name."
          );
        },
        padding: EdgeInsets.zero,
        child: child
    );
  }

  Widget getHeader() {

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Exercise name
        Form(
          key: cnNewExercise.formKey,
          child: TextFormField(
            focusNode: cnNewExercise.focusNodeTextFieldExerciseName,
            key: cnNewExercise.keyExerciseName,
            keyboardAppearance: Brightness.dark,
            maxLength: 40,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (value){
              FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[0][0]);
              onTapField(0, 0, 0, scrollDelay: 50);
            },
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
      ],
    );
  }

  Future onTapField(int index, double insetsBottom, int weightOrAmountIndex, {int scrollDelay = 500}) async{
    cnNewExercise.controllers[index][weightOrAmountIndex].selection =  TextSelection(baseOffset: 0, extentOffset: cnNewExercise.controllers[index][weightOrAmountIndex].value.text.length);
    if(insetsBottom == 0) {
      await Future.delayed(Duration(milliseconds: scrollDelay));
    }
    Scrollable.ensureVisible(
        cnNewExercise.ensureVisibleKeys[index][0].currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.38
    );
  }

  // Future onTapAmount(int index, double insetsBottom) async {
  //   cnNewExercise.controllers[index][1].selection = TextSelection(baseOffset: 0,
  //       extentOffset: cnNewExercise.controllers[index][1].value.text.length);
  //   if (insetsBottom == 0) {
  //     await Future.delayed(const Duration(milliseconds: 300));
  //   }
  //   Scrollable.ensureVisible(
  //       cnNewExercise.ensureVisibleKeys[index][1].currentContext!,
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeInOut,
  //       alignment: 0.38
  //   );
  // }
}

class CnNewExercisePanel extends ChangeNotifier {
  final PanelController panelController = PanelController();

  GlobalKey keyHeader = GlobalKey();
  GlobalKey keyExerciseName = GlobalKey();
  final formKey = GlobalKey<FormState>();
  final FocusNode focusNodeTextFieldExerciseName = FocusNode();
  Key key = UniqueKey();
  Exercise exercise = Exercise();
  Workout workout = Workout();
  TextEditingController exerciseNameController = TextEditingController();
  TextEditingController restController = TextEditingController();
  TextEditingController seatLevelController = TextEditingController();
  ScrollController scrollController = ScrollController();
  late List<Key> slidableKeys = exercise.generateKeyForEachSet();
  Function? onConfirm;
  final int animationTime = 500;
  late TickerProvider vsync;

  late List<List<TextEditingController>> controllers = exercise.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList();
  late List<List<GlobalKey>> ensureVisibleKeys = exercise.sets.map((e) => ([GlobalKey(), GlobalKey()])).toList();
  late List<List<FocusNode>> focusNodes = exercise.sets.map((e) => ([FocusNode(), FocusNode()])).toList();

  CnNewExercisePanel(){
    clear();
  }

  void initVsync(TickerProvider vsync){
    this.vsync = vsync;
  }

  void setExercise(Exercise ex){
    exercise = ex;
    slidableKeys = exercise.generateKeyForEachSet();
    controllers = exercise.sets.map((set) => ([TextEditingController(text: "${set.weightAsTrimmedDouble}"), TextEditingController(text: "${exercise.categoryIsReps()? (set.amount) : parseTextControllerAmountToTime(set.amount)[1]}")])).toList();
    ensureVisibleKeys = exercise.sets.map((e) => ([GlobalKey(), GlobalKey()])).toList();
    focusNodes = exercise.sets.map((e) => ([FocusNode(), FocusNode()])).toList();
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
    formKey.currentState?.reset();
    clear();
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

  void closePanel({bool doClear = false, required BuildContext context}) async {
    if(MediaQuery.of(context).viewInsets.bottom > 0){
      FocusManager.instance.primaryFocus?.unfocus();
      await Future.delayed(const Duration(milliseconds: 300));
    }
    panelController.animatePanelToPosition(
        0,
        duration: Duration(milliseconds: animationTime-150),
        curve: Curves.decelerate
    ).then((value) => {
      if(doClear){
        clear()
      },
      // animationController.reset()
    });
  }

  void clear({bool withRefresh = true}){
    exercise = Exercise();
    workout = Workout();
    controllers = exercise.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList();
    exerciseNameController = TextEditingController();
    restController = TextEditingController();
    seatLevelController = TextEditingController();
    ensureVisibleKeys = exercise.sets.map((e) => ([GlobalKey(), GlobalKey()])).toList();
    focusNodes = exercise.sets.map((e) => ([FocusNode(), FocusNode()])).toList();
    if(withRefresh){
      refresh();
    }
  }

  void refresh(){
    notifyListeners();
  }
}
