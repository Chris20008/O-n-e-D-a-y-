import 'dart:ui';
import 'dart:io';
import 'package:fitness_app/assets/custom_icons/my_icons_icons.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/widgets/cupertino_button_text.dart';
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
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  final double _widthSetWeightAmount = 55;
  late final _color = Theme.of(context).primaryColor;
  double heightHeader = 120.0;
  final textDisappearOffset = 0.1;
  bool wasShownBigChild = true;
  bool isTouchingListView = false;
  int currentIndexFocus = 0;
  int currentIndexWeightOrAmount = 0;
  bool useTutorialKey = true;

  GlobalKey addSetKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cnNewExercise.initVsync(this);
    });
  }

  @override
  Widget build(BuildContext context) {
    double insetsBottom = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: false,
      onPopInvoked: (doPop){
        if (cnNewExercise.panelController.isPanelOpen){
          cnNewExercise.closePanel(doClear: false, context: context);
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: MySlideUpPanel(
          key: cnNewExercise.key,
          controller: cnNewExercise.panelController,
          backdropOpacity: 0.25,
          color: _color,
          animationControllerName: "NewExercisePanel",
          descendantAnimationControllerName: "NewWorkoutPanel",
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
                              cnNewExercise.getRestInSecondsSelector(
                                  context: context,
                                  exercise: cnNewExercise.exercise,
                                  refresh: cnNewExercise.refresh
                              ),

                              /// Seat Level Row and Selector
                              cnNewExercise.getSeatLevelSelector(
                                  context: context,
                                  exercise: cnNewExercise.exercise,
                                  refresh: cnNewExercise.refresh
                              ),

                              /// Exercise Category Selector
                              cnNewExercise.getExerciseCategorySelector(
                                  context: context,
                                  isTemplate: cnNewExercise.exercise.isNewExercise(),
                                  exercise: cnNewExercise.exercise,
                                  refresh: cnNewExercise.refresh
                              ),

                              /// Body Weight selector
                              cnNewExercise.getBodyWeightPercentSelector(
                                  context: context,
                                  isTemplate: cnNewExercise.exercise.isNewExercise() || cnNewExercise.workout.isTemplate,
                                  exercise: cnNewExercise.exercise,
                                  refresh: cnNewExercise.refresh
                              ),
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
                                          /// Handle if tutorial
                                          if(tutorialIsRunning){
                                            if(value.isNotEmpty){
                                              FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[index][1]);
                                            }
                                            else{
                                              FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[index][0]);
                                            }
                                          }

                                          /// Handle if not tutorial
                                          else{
                                            FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[index][1]);
                                            onTapField(index, insetsBottom, 1);
                                          }
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

                                          /// Handle if tutorial
                                          if(tutorialIsRunning){
                                            if(value.isNotEmpty && cnNewExercise.controllers[index][0].text.isNotEmpty){
                                              cnHomepage.tutorial?.next();
                                              blockUserInput(context);
                                            }
                                            else{
                                              FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[index][1]);
                                            }
                                          }

                                          /// Handle if not tutorial
                                          else{
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
                                            }
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
                                  key: tutorialIsRunning && index == 0 && useTutorialKey? cnNewExercise.keySetRow : cnNewExercise.slidableKeys[index],
                                  endActionPane: cnNewExercise.exercise.sets.length > 1?
                                  ActionPane(
                                    extentRatio: 0.3,
                                    motion: const ScrollMotion(),
                                    dismissible: DismissiblePane(
                                        onDismissed: () {
                                          dismissSet(index);
                                        }),
                                    children: [
                                      SlidableAction(
                                        flex:10,
                                        onPressed: (BuildContext context){
                                          dismissSet(index);
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

                              getRowButton(
                                  key: addSetKey,
                                  context: context,
                                  minusWidth: 20,
                                  onPressed: addSet
                              ),

                              SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0? MediaQuery.of(context).viewInsets.bottom+(Platform.isAndroid? 50: 50) : 60)
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

                  SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            flex: 10,
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: CupertinoButtonText(
                                    onPressed: onCancel,
                                    text: AppLocalizations.of(context)!.cancel,
                                    textAlign: TextAlign.left
                                )
                            )
                        ),
                        Expanded(
                            flex: 11,
                            child: Center(
                              child: Text(
                              AppLocalizations.of(context)!.exercise,
                              textScaler: const TextScaler.linear(1.3),
                              textAlign: TextAlign.center,
                              ),
                            )
                        ),
                        Expanded(
                            key: cnNewExercise.keySaveButton,
                            flex: 10,
                            child: Align(
                                alignment: Alignment.centerRight,
                                child: CupertinoButtonText(
                                    onPressed: () {
                                      cnNewExercise.closePanelAndSaveExercise(context);
                                    },
                                    text: AppLocalizations.of(context)!.save,
                                    textAlign: TextAlign.right
                                )
                            )
                        ),
                      ],
                    ),
                  ),

                  // if(!tutorialIsRunning /*&& Platform.isIOS*/ && MediaQuery.of(context).viewInsets.bottom > 100 && currentIndexFocus >= 0)
                  //   KeyboardTopBar(
                  //     key: cnHomepage.keyKeyboardTopBar,
                  //     onPressedLeft: (){
                  //       int delay = 500;
                  //
                  //       if(currentIndexWeightOrAmount == 0){
                  //         currentIndexFocus -= 1;
                  //         currentIndexWeightOrAmount = 1;
                  //       } else{
                  //         currentIndexWeightOrAmount = 0;
                  //       }
                  //       if(currentIndexFocus == 0 && currentIndexWeightOrAmount == 0){
                  //         delay = 50;
                  //         insetsBottom = 0;
                  //       }
                  //
                  //       if(currentIndexFocus < 0){
                  //         FocusManager.instance.primaryFocus?.unfocus();
                  //         return;
                  //       }
                  //
                  //       if (currentIndexFocus < cnNewExercise.exercise.sets.length) {
                  //         FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[currentIndexFocus][currentIndexWeightOrAmount]);
                  //         onTapField(currentIndexFocus, insetsBottom, currentIndexWeightOrAmount, scrollDelay: delay);
                  //       } else {
                  //         FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[currentIndexFocus-1][1]);
                  //         addSet();
                  //         WidgetsBinding.instance.addPostFrameCallback((_) {
                  //           FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[currentIndexFocus][0]);
                  //           onTapField(currentIndexFocus, insetsBottom, 0, scrollDelay: delay);
                  //         });
                  //       }
                  //     },
                  //     onPressedRight: (){
                  //       int delay = 500;
                  //
                  //       if(currentIndexWeightOrAmount == 0){
                  //         currentIndexWeightOrAmount = 1;
                  //       } else{
                  //         currentIndexWeightOrAmount = 0;
                  //         currentIndexFocus += 1;
                  //       }
                  //       if(currentIndexFocus == 0 && currentIndexWeightOrAmount == 0){
                  //         delay = 50;
                  //         insetsBottom = 0;
                  //       }
                  //
                  //       if (currentIndexFocus < cnNewExercise.exercise.sets.length) {
                  //         FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[currentIndexFocus][currentIndexWeightOrAmount]);
                  //         onTapField(currentIndexFocus, insetsBottom, currentIndexWeightOrAmount, scrollDelay: delay);
                  //       }
                  //       else{
                  //         FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[currentIndexFocus-1][1]);
                  //         addSet();
                  //         WidgetsBinding.instance.addPostFrameCallback((_) {
                  //           FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[currentIndexFocus][0]);
                  //           onTapField(currentIndexFocus, insetsBottom, 0, scrollDelay: delay);
                  //         });
                  //       }
                  //
                  //     },
                  //   )
                ],
              ),
            );
          }
        )
      ),
    );
  }

  void onCancel(){
    cnNewExercise.closePanel(doClear: true, context: context);
    cnNewExercise.formKey.currentState?.reset();
    vibrateCancel();
  }

  void dismissSet(int index){
    useTutorialKey = false;
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
        final isVisible = widgetPosition.dy + widgetSize.height * 80 > 0 && widgetPosition.dy + 80 + viewInsets < screenHeight;
        if(!isVisible){
          cnNewExercise.scrollController.jumpTo(cnNewExercise.scrollController.position.pixels+41);
        }
      }
    });
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
            onTap: (){
              currentIndexWeightOrAmount = 1;
              currentIndexFocus = -1;
            },
            onFieldSubmitted: (value){
              if(tutorialIsRunning){
                if(value.isNotEmpty){
                  cnHomepage.tutorial?.next();
                  blockUserInput(context);
                  FocusManager.instance.primaryFocus?.unfocus();
                }
              }
              else{
                FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[0][0]);
                onTapField(0, 0, 0, scrollDelay: 50);
              }
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
    currentIndexFocus = index;
    currentIndexWeightOrAmount = weightOrAmountIndex;
    cnNewExercise.controllers[index][weightOrAmountIndex].selection =  TextSelection(baseOffset: 0, extentOffset: cnNewExercise.controllers[index][weightOrAmountIndex].value.text.length);
    if(insetsBottom == 0) {
      await Future.delayed(Duration(milliseconds: scrollDelay));
    }

    final position = getWidgetPosition(cnNewExercise.ensureVisibleKeys[index][0]);
    // final positionKeyboard = getWidgetPosition(cnHomepage.keyKeyboardTopBar);
    final value = Platform.isAndroid? 80 : 100;
    final height = MediaQuery.of(context).size.height;
    final relativeHeight = height - MediaQuery.of(context).viewInsets.bottom;
    double factor = (relativeHeight - value) / height;

    // if(positionKeyboard.dy == 0){
    //   return;
    // }

    if(position.dy + value > relativeHeight){
      Future.delayed(const Duration(milliseconds: 10), (){
        Scrollable.ensureVisible(
            cnNewExercise.ensureVisibleKeys[index][0].currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: factor
        );
      });
    }

  }
}

class CnNewExercisePanel extends ChangeNotifier {
  final PanelController panelController = PanelController();

  GlobalKey keyHeader = GlobalKey();
  GlobalKey keyExerciseName = GlobalKey();
  GlobalKey keySetRow = GlobalKey();
  GlobalKey keySaveButton = GlobalKey();

  final formKey = GlobalKey<FormState>();
  final FocusNode focusNodeTextFieldExerciseName = FocusNode();
  Key key = UniqueKey();
  Exercise exercise = Exercise();
  Workout workout = Workout();
  TextEditingController exerciseNameController = TextEditingController();
  // TextEditingController restController = TextEditingController();
  // TextEditingController seatLevelController = TextEditingController();
  ScrollController scrollController = ScrollController();
  late List<Key> slidableKeys = exercise.generateKeyForEachSet();
  Function? onConfirm;
  final int animationTime = 500;
  late TickerProvider vsync;
  double iconSize = 25;
  final TextStyle _style = const TextStyle(color: Colors.white, fontSize: 18);

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
    // restController = TextEditingController(text: ex.restInSeconds > 0? ex.restInSeconds.toString() : "");
    // seatLevelController = TextEditingController(text: ex.seatLevel != null? ex.seatLevel.toString() : "");
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

  void closePanelAndSaveExercise(BuildContext context) async{
    if (formKey.currentState!.validate() && exercise.name.isNotEmpty) {
      final copy = Exercise.copy(exercise);
      copy.removeEmptySets();

      if(copy.sets.isNotEmpty){
        await closePanel(doClear: true, context: context);
        exercise.removeEmptySets();
        if(onConfirm != null){
          onConfirm!(exercise);
        }
      }
      else{
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.panelWoAddAtLeastOneSet,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.SNACKBAR,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[800]?.withOpacity(0.9),
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }
  }

  /// SELECTORS
  // Color(0xffdb7b01)
  Widget getRestInSecondsSelector({
    required BuildContext context,
    required Exercise exercise,
    required Function refresh
  }) {
    return getSelectRestInSeconds(
        currentTime: exercise.restInSeconds,
        context: context,
        child: CupertinoListTile(
          leading: Icon(CupertinoIcons.timer, size: iconSize),
          title: Row(
            children: [
              Text(AppLocalizations.of(context)!.restTime, style: _style),
              const Spacer(),
              Text(mapRestInSecondsToString(restInSeconds: exercise.restInSeconds), style: _style),
              const SizedBox(width: 10),
            ],
          ),
          trailing: trailingChoice(),
        ),
        onConfirm: (dynamic value){
          if(value is int){
            exercise.restInSeconds = value;
            refresh();
          }
          else{
            showDialogMinuteSecondPicker(
                context: context,
                initialTimeDuration: Duration(minutes: exercise.restInSeconds~/60, seconds: exercise.restInSeconds%60),
                onConfirm: (Duration newDuration){
                  exercise.restInSeconds = newDuration.inSeconds;
                }
            ).then((value) => refresh());
          }
        }
    );
  }

  Widget getSeatLevelSelector({
    required BuildContext context,
    required Exercise exercise,
    required Function refresh
  }) {
    return getSelectSeatLevel(
        currentSeatLevel: exercise.seatLevel,
        context: context,
        onConfirm: (dynamic value){
          if(value is int){
            exercise.seatLevel = value;
            refresh();
          }
          else if(value == AppLocalizations.of(context)!.clear){
            exercise.seatLevel = null;
            refresh();
          }
        },
        child: CupertinoListTile(
          leading: Icon(Icons.airline_seat_recline_normal, size: iconSize),
          trailing: trailingChoice(),
          title: Row(
            children: [
              Text(AppLocalizations.of(context)!.seatLevel, style: _style),
              const Spacer(),
              Text(exercise.seatLevel == null? "-" : exercise.seatLevel.toString(), style: _style),
              const SizedBox(width: 10)
            ],
          ),
        )
    );
  }

  Widget getExerciseCategorySelector({
    required BuildContext context,
    required bool isTemplate,
    required Exercise exercise,
    required Function refresh
  }) {
    Widget child = CupertinoListTile(
        leading: Icon(MyIcons.tags, size: iconSize-3),
        title: Row(
          children: [
            Text(AppLocalizations.of(context)!.category, style: _style),
            const Spacer(),
            Text(exercise.getCategoryName(), style: _style),
            const SizedBox(width: 10)
          ],
        ),
        trailing: isTemplate? trailingChoice() : null
    );

    if(isTemplate){
      return getSelectCategory(
          context: context,
          currentCategory: exercise.category,
          onConfirm: (int category){
            exercise.category = category;
            refresh();
            clearTextControllers();
          },
          child: child
      );
    }

    return CupertinoButton(
        onPressed: (){
          HapticFeedback.selectionClick();
          notificationPopUp(
              context: context,
              title: AppLocalizations.of(context)!.panelExChangeCategoryHeader,
              message: AppLocalizations.of(context)!.panelExChangeCategoryText
          );
        },
        padding: EdgeInsets.zero,
        child: child
    );
  }

  Widget getBodyWeightPercentSelector({
    required BuildContext context,
    required bool isTemplate,
    required Exercise exercise,
    required Function refresh
  }) {
    Widget child = CupertinoListTile(
        leading: Icon(MyIcons.weight, size: iconSize-4),
        title: Row(
          children: [
            Text(AppLocalizations.of(context)!.bodyweight, style: _style),
            const Spacer(),
            Text("${(exercise.bodyWeightPercent * 100).toInt()} %", style: _style),
            const SizedBox(width: 10),
          ],
        ),
        trailing: isTemplate? trailingChoice() : null
    );

    if(isTemplate){
      return getSelectBodyWeightPercent(
          context: context,
          currentBodyWeightPercent: exercise.bodyWeightPercent,
          onConfirm: (int bodyWeight){
            exercise.bodyWeightPercent = bodyWeight/100;
            refresh();
          },
          child: child
      );
    }

    return CupertinoButton(
        onPressed: (){
          HapticFeedback.selectionClick();
          notificationPopUp(
              context: context,
              title: AppLocalizations.of(context)!.panelExChangeBodyWeightHeader,
              message: AppLocalizations.of(context)!.panelExChangeBodyWeightText
          );
        },
        padding: EdgeInsets.zero,
        child: child
    );
  }

  /// -------------------------

  Future openPanel({required Workout workout, Exercise? exercise, Function? onConfirm})async{
    formKey.currentState?.reset();
    clear();
    if(exercise != null){
      setExercise(exercise);
    }
    this.workout = workout;
    this.onConfirm = onConfirm;
    HapticFeedback.selectionClick();
    // if(scrollController.hasClients){
    //   scrollController.jumpTo(0);
    // }
    await panelController.animatePanelToPosition(
        1,
        duration: Duration(milliseconds: animationTime),
        curve: Curves.fastEaseInToSlowEaseOut
    );
    return;
  }

  Future closePanel({bool doClear = false, required BuildContext context}) async {
    if(MediaQuery.of(context).viewInsets.bottom > 0){
      FocusManager.instance.primaryFocus?.unfocus();
      await Future.delayed(const Duration(milliseconds: 300));
    }
    await panelController.animatePanelToPosition(
        0,
        duration: Duration(milliseconds: animationTime-150),
        curve: Curves.decelerate
    );
    return;
  }

  void clear({bool withRefresh = true}){
    exercise = Exercise();
    workout = Workout();
    formKey.currentState?.reset();
    controllers = exercise.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList();
    exerciseNameController = TextEditingController();
    // restController = TextEditingController();
    // seatLevelController = TextEditingController();
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
