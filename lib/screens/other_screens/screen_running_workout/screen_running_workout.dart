import 'dart:ui';
import 'package:fitness_app/screens/other_screens/screen_running_workout/selector_exercises_per_link.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/selector_exercises_to_update.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/stopwatch.dart';
import 'package:fitness_app/util/backup_functions.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/widgets/banner_running_workout.dart';
import 'package:fitness_app/widgets/initial_animated_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../main.dart';
import '../../../objects/exercise.dart';
import '../../../objects/workout.dart';
import '../../../util/constants.dart';
import '../../../widgets/bottom_menu.dart';
import '../../../widgets/spotify_bar.dart';
import '../../../widgets/standard_popup.dart';
import '../../main_screens/screen_workouts/screen_workouts.dart';
import 'animated_column.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fitness_app/assets/custom_icons/my_icons_icons.dart';

class ScreenRunningWorkout extends StatefulWidget {
  const ScreenRunningWorkout({
    super.key,
  });

  @override
  State<ScreenRunningWorkout> createState() => _ScreenRunningWorkoutState();
}

class _ScreenRunningWorkoutState extends State<ScreenRunningWorkout> {
  // late final AnimationController _controllerSelectorExUpdate = AnimationController(
  //   duration: const Duration(milliseconds: 200),
  //   vsync: this,
  // );
  // late final Animation<double> _animationSelectorExUpdate = CurvedAnimation(
  //   parent: _controllerSelectorExUpdate,
  //   curve: Curves.decelerate,
  //     // curve: Curves.easeOutBack
  // );
  // late final AnimationController _controllerSelectorExPerLink = AnimationController(
  //   duration: const Duration(milliseconds: 200),
  //   vsync: this,
  // );
  // late final Animation<double> _animationSelectorExPerLink = CurvedAnimation(
  //   parent: _controllerSelectorExPerLink,
  //   curve: Curves.decelerate,
  //     // curve: Curves.easeOutBack
  // );

  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  late CnStopwatchWidget cnStopwatchWidget = Provider.of<CnStopwatchWidget>(context, listen: false);
  late CnConfig cnConfig  = Provider.of<CnConfig>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context);
  /// listen to bottomMenu for height changes
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context);
  final double _iconSize = 20;
  final double _heightOfSetRow = 30;
  final double _widthOfTextField = 55;
  final double _setPadding = 5;
  Key selectorExerciseToUpdateKey = UniqueKey();
  Key selectorExercisePerLinkKey = UniqueKey();
  double viewInsetsBottom = 0;
  bool isAlreadyCheckingKeyboard = false;
  bool isAlreadyCheckingKeyboardPermanent = false;
  // bool showSelectorExerciseToUpdate = false;
  // bool showSelectorExercisePerLink = false;
  bool isSavingData = false;
  final _style = const TextStyle(color: Colors.white, fontSize: 15);
  String descendantNameExerciseToUpdate = "ScreenRunningWorkout";
  PanelController controllerSelectorExerciseToUpdate = PanelController();
  PanelController controllerSelectorExercisePerLink = PanelController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    cnRunningWorkout.scrollController = ScrollController(initialScrollOffset: cnRunningWorkout.lastScrollPosition);

    // if(showSelectorExerciseToUpdate){
    //   _controllerSelectorExUpdate.forward();
    // }
    // else{
    //   _controllerSelectorExUpdate.reverse();
    // }

    // if(showSelectorExercisePerLink){
    //   _controllerSelectorExPerLink.forward();
    // }
    // else{
    //   _controllerSelectorExPerLink.reverse();
    // }

    return PopScope(
      canPop: !isSavingData,
      onPopInvoked: (doPop){
        if(cnRunningWorkout.isVisible){
          cnRunningWorkout.lastScrollPosition = cnRunningWorkout.scrollController.offset;
          cnRunningWorkout.isVisible = false;
          cnWorkouts.refresh();
          cnRunningWorkout.cache();
        }
        if(cnStandardPopUp.isVisible){
          cnStandardPopUp.clear();
        }
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xffc26a0e),
                    Color(0xbb110a02)
                  ]
              )
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InitialAnimatedScreen(
                backDropEnabled: true,
                animationControllerName: "ScreenRunningWorkout",
                child: Scaffold(
                  extendBody: true,
                  bottomNavigationBar: viewInsetsBottom < 50? ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaX: 10.0,
                          sigmaY: 10.0,
                          tileMode: TileMode.mirror
                      ),
                      child: GestureDetector(
                        onTap: openPopUpFinishWorkout,
                        child: Container(
                          height: cnBottomMenu.height,
                          color: Colors.black.withOpacity(0.5),
                          child: Center(child: Text(AppLocalizations.of(context)!.finish, style: TextStyle(color: Colors.amber[800]), textScaler: const TextScaler.linear(1.4),)),
                        ),
                      ),
                    ),
                  ): const SizedBox(),
                  body: GestureDetector(
                    onTap: (){
                      FocusScope.of(context).unfocus();
                    },
                    child: Stack(
                      children: [
                        SafeArea(
                          top: false,
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.only(top:0,bottom: 0,left: 20, right: 20),
                            child: Column(
                              children: [

                                Expanded(
                                  child: ListView.builder(
                                    controller: cnRunningWorkout.scrollController,
                                    physics: const BouncingScrollPhysics(),
                                      itemCount: cnRunningWorkout.allItems.length,
                                      itemBuilder: (context, index){
                                        if(cnRunningWorkout.allItems[index] is Exercise){
                                          Exercise newEx = cnRunningWorkout.allItems[index];
                                          return Column(
                                              children: [
                                                // if (cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value is !Exercise)
                                                //   Align(
                                                //     alignment: Alignment.centerLeft,
                                                //     child: OverflowSafeText(
                                                //       cnRunningWorkout.groupedExercises.keys.toList()[indexExercise],
                                                //       textAlign: TextAlign.center,
                                                //       // fontSize: 12,
                                                //       style: const TextStyle(
                                                //           fontSize: 13,
                                                //           color: Colors.white70
                                                //       ),
                                                //       minFontSize: 12,
                                                //       maxLines: 1,
                                                //     ),
                                                //   ),
                                                Row(
                                                  children: [
                                                    // cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value is Exercise
                                                    // /// Single Exercise
                                                    //     ?
                                                    Expanded(
                                                      child: ConstrainedBox(
                                                        constraints: BoxConstraints(
                                                            maxWidth: MediaQuery.of(context).size.width-80
                                                        ),
                                                        child: OverflowSafeText(
                                                          newEx.name,
                                                          maxLines: 1,
                                                          style: const TextStyle(color: Colors.white, fontSize: 20),
                                                        ),
                                                      ),
                                                    ),
                                                    // /// Exercise Selector
                                                    //     : PullDownButton(
                                                    //   onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
                                                    //   buttonAnchor: PullDownMenuAnchor.start,
                                                    //   routeTheme: const PullDownMenuRouteTheme(backgroundColor: CupertinoColors.secondaryLabel),
                                                    //   itemBuilder: (context) {
                                                    //     final children = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value.map<PullDownMenuItem>((Exercise value) {
                                                    //       return PullDownMenuItem.selectable(
                                                    //         title: value.name,
                                                    //         selected: newEx.name == value.name,
                                                    //         onTap: () {
                                                    //           FocusManager.instance.primaryFocus?.unfocus();
                                                    //           HapticFeedback.selectionClick();
                                                    //           Future.delayed(const Duration(milliseconds: 200), (){
                                                    //             setState(() {
                                                    //               final lists = cnRunningWorkout.groupedExercises.entries.toList().where((element) => element.value is List<Exercise>);
                                                    //               final t = lists.map((element) => element.value.indexWhere((ex) {
                                                    //                 return ex.name == value.name;
                                                    //               })).toList().firstWhere((element) => element >=0);
                                                    //               cnRunningWorkout.selectedIndexes[cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].key] = t;
                                                    //             });
                                                    //             cnRunningWorkout.cache();
                                                    //           });
                                                    //         },
                                                    //       );
                                                    //     }).toList();
                                                    //     return children;
                                                    //   },
                                                    //   buttonBuilder: (context, showMenu) => CupertinoButton(
                                                    //       onPressed: (){
                                                    //         HapticFeedback.selectionClick();
                                                    //         showMenu();
                                                    //       },
                                                    //       padding: EdgeInsets.zero,
                                                    //       child: Row(
                                                    //         children: [
                                                    //           ConstrainedBox(
                                                    //             constraints: BoxConstraints(
                                                    //                 maxWidth: MediaQuery.of(context).size.width-120
                                                    //             ),
                                                    //             child: OverflowSafeText(
                                                    //                 newEx.name,
                                                    //                 style: const TextStyle(color: Colors.white, fontSize: 20),
                                                    //                 maxLines: 1
                                                    //             ),
                                                    //           ),
                                                    //           const SizedBox(width: 10,),
                                                    //           trailingChoice(size: 15, color: Colors.white)
                                                    //         ],
                                                    //       )
                                                    //   ),
                                                    // ),

                                                    // cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value is Exercise
                                                    //     ? const SizedBox()
                                                    //     : const Spacer(),

                                                //     if(cnRunningWorkout.newExNames.contains(newEx.name))
                                                //       SizedBox(
                                                //         width:40,
                                                //         child: myIconButton(
                                                //           icon:const Icon(Icons.delete_forever),
                                                //           onPressed: (){
                                                //             showCupertinoModalPopup<void>(
                                                //               context: context,
                                                //               builder: (BuildContext context) => CupertinoActionSheet(
                                                //                 cancelButton: getActionSheetCancelButton(context),
                                                //                 message: Text(AppLocalizations.of(context)!.runningWorkoutDeleteExercise),
                                                //                 actions: <Widget>[
                                                //                   CupertinoActionSheetAction(
                                                //                     /// This parameter indicates the action would perform
                                                //                     /// a destructive action such as delete or exit and turns
                                                //                     /// the action's text color to red.
                                                //                     isDestructiveAction: true,
                                                //                     onPressed: () {
                                                //                       cnRunningWorkout.deleteExercise(newEx);
                                                //                       Navigator.pop(context);
                                                //                     },
                                                //                     child: Text(AppLocalizations.of(context)!.delete),
                                                //                   ),
                                                //                 ],
                                                //               ),
                                                //             );
                                                //           },
                                                //         ),
                                                //       ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),

                                                Row(
                                                  // mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(width: 100, child: getSeatLevelSelector(newEx),),
                                                    Icon(MyIcons.tags, size: _iconSize-3, color: Colors.amber[900]!.withOpacity(0.6),),
                                                    const SizedBox(width: 8,),
                                                    Text(newEx.getCategoryName()),
                                                  ],
                                                ),

                                                /// Rest in Seconds Row and Selector
                                                getRestInSecondsSelector(newEx),

                                                const SizedBox(height: 15),

                                                /// Text for Set, Template, Weight and Amount
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                        width: _widthOfTextField,
                                                        child: OverflowSafeText(
                                                          AppLocalizations.of(context)!.set,
                                                          textAlign: TextAlign.center,
                                                          // fontSize: 12,
                                                          style: const TextStyle(
                                                              fontSize: 13,
                                                              color: Colors.white70
                                                          ),
                                                          minFontSize: 12,
                                                          maxLines: 1,
                                                        )
                                                    ),
                                                    Expanded(
                                                        flex: 2,
                                                        child: OverflowSafeText(
                                                            AppLocalizations.of(context)!.template,
                                                            textAlign: TextAlign.center,
                                                            // fontSize: 12,
                                                            style: const TextStyle(
                                                                fontSize: 13,
                                                                color: Colors.white70
                                                            ),
                                                            minFontSize: 12,
                                                            maxLines: 1
                                                        )
                                                    ),
                                                    /// TextField Headers
                                                    Expanded(
                                                        flex: 2,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            SizedBox(
                                                                width: _widthOfTextField+10,
                                                                child: OverflowSafeText(
                                                                  // AppLocalizations.of(context)!.weight,
                                                                    newEx.getLeftTitle(context),
                                                                    textAlign: TextAlign.center,
                                                                    // fontSize: 12,
                                                                    style: const TextStyle(
                                                                        fontSize: 13,
                                                                        color: Colors.white70
                                                                    ),
                                                                    minFontSize: 12,
                                                                    maxLines: 1
                                                                )
                                                            ),
                                                            const SizedBox(width: 4,),
                                                            SizedBox(
                                                                width: _widthOfTextField+10,
                                                                child: OverflowSafeText(
                                                                  // AppLocalizations.of(context)!.amount,
                                                                    newEx.getRightTitle(context),
                                                                    textAlign: TextAlign.center,
                                                                    // fontSize: 12,
                                                                    style: const TextStyle(
                                                                        fontSize: 13,
                                                                        color: Colors.white70
                                                                    ),
                                                                    minFontSize: 12,
                                                                    maxLines: 1
                                                                )
                                                            )
                                                          ],
                                                        )
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(height: 5),

                                              ],
                                        );
                                        }

                                        SingleSet set = cnRunningWorkout.allItems[index];
                                        final TextEditingController? weightController = TextEditingController();
                                        final TextEditingController? amountController = TextEditingController();

                                        Widget child = Padding(
                                          padding: EdgeInsets.only(bottom: _setPadding, top: _setPadding),
                                          child: SizedBox(
                                            width: double.maxFinite,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [

                                                /// Set
                                                // getSet(
                                                //     context: context,
                                                //     index: indexSet,
                                                //     newEx: newEx,
                                                //     width: _widthOfTextField,
                                                //     onConfirm: (){
                                                //       cnRunningWorkout.cache();
                                                //       cnRunningWorkout.refresh();
                                                //     }
                                                // ),

                                                Container(
                                                  width: _widthOfTextField,
                                                  child: Text("1"),
                                                ),

                                                /// Button to copy templates data
                                                getButtonInsertTemplatesData(set: set, newEx: Exercise(), indexSet: 0, weightController: weightController, amountController: amountController),

                                                /// Weight and Amount
                                                Expanded(
                                                  flex: 2,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [

                                                      /// Weight
                                                      SizedBox(
                                                        width: _widthOfTextField,
                                                        height: _heightOfSetRow,
                                                        child: Center(
                                                          child: TextField(
                                                            keyboardAppearance: Brightness.dark,
                                                            maxLength: (weightController?.text.contains(".")?? true)? 6 : 4,
                                                            textAlign: TextAlign.center,
                                                            keyboardType: const TextInputType.numberWithOptions(
                                                                decimal: true,
                                                                signed: false
                                                            ),
                                                            controller: weightController,
                                                            onTap: (){
                                                              weightController?.selection =  TextSelection(baseOffset: 0, extentOffset: weightController.value.text.length);
                                                            },
                                                            decoration: InputDecoration(
                                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                                // isDense: true,
                                                                counterText: "",
                                                                contentPadding: const EdgeInsets.symmetric(horizontal: 0 ,vertical: 0.0),
                                                                hintFadeDuration: const Duration(milliseconds: 200),
                                                                hintText: "${set.weight.toString().endsWith(".0")? set.weight?.toInt() : set.weight?? ""}",
                                                                hintStyle: getTextStyleForTextField((set.weight?? "").toString(), color: Colors.white.withOpacity(0.15), sizeSmall: false)
                                                            ),
                                                            style: getTextStyleForTextField(weightController?.text?? "", sizeSmall: false),
                                                            onChanged: (value){
                                                              // value = value.trim();
                                                              // if(value.isNotEmpty){
                                                              //   value = validateDoubleTextInput(value);
                                                              //   final newValue = double.tryParse(value);
                                                              //   newEx.sets[indexSet].weight = newValue;
                                                              //   if(newValue == null){
                                                              //     weightController?.clear();
                                                              //   } else{
                                                              //     weightController?.text = value;
                                                              //   }
                                                              // }
                                                              // else{
                                                              //   newEx.sets[indexSet].weight = null;
                                                              // }
                                                              // cnRunningWorkout.cache();
                                                              // setState(() => {});
                                                            },
                                                          ),
                                                        ),
                                                      ),

                                                      const SizedBox(width: 12,),

                                                      /// Amount
                                                      SizedBox(
                                                        width: _widthOfTextField,
                                                        height: _heightOfSetRow,
                                                        child: Center(
                                                          child: TextField(
                                                            keyboardAppearance: Brightness.dark,
                                                            // maxLength: newEx.categoryIsReps()? 3 : 8,
                                                            textAlign: TextAlign.center,
                                                            keyboardType: const TextInputType.numberWithOptions(
                                                                decimal: false,
                                                                signed: false
                                                            ),
                                                            controller: amountController,
                                                            onTap: (){
                                                              amountController?.selection =  TextSelection(baseOffset: 0, extentOffset: amountController.value.text.length);
                                                            },
                                                            decoration: InputDecoration(
                                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                                // isDense: true,
                                                                counterText: "",
                                                                contentPadding: const EdgeInsets.symmetric(horizontal: 0 ,vertical: 0.0),
                                                                // hintText: newEx.categoryIsReps()? "${set.amount?? ""}" : set.amountAsTime,
                                                                // hintStyle: getTextStyleForTextField(
                                                                //     newEx.categoryIsReps()? "${set.amount?? ""}" : set.amountAsTime?? "",
                                                                //     sizeSmall: false,
                                                                //     color: Colors.white.withOpacity(0.07)
                                                                // )
                                                              // hintStyle: TextStyle(color: Colors.white.withOpacity(0.07))
                                                            ),
                                                            style: getTextStyleForTextField(amountController?.text?? "", sizeSmall: false),
                                                            onChanged: (value){
                                                              // value = value.trim();
                                                              // /// For Reps
                                                              // if(newEx.categoryIsReps()){
                                                              //   if(value.isNotEmpty){
                                                              //     final newValue = int.tryParse(value);
                                                              //     newEx.sets[indexSet].amount = newValue;
                                                              //     if(newValue == null){
                                                              //       amountController?.clear();
                                                              //     }
                                                              //     if(value.length == 1){
                                                              //       setState(() => {});
                                                              //     }
                                                              //   }
                                                              //   else{
                                                              //     newEx.sets[indexSet].amount = null;
                                                              //     setState(() => {});
                                                              //   }
                                                              // }
                                                              // /// For Time
                                                              // else{
                                                              //   List result = parseTextControllerAmountToTime(value);
                                                              //   if(result[0] <= 0){
                                                              //     amountController?.text = "";
                                                              //     newEx.sets[indexSet].amount = null;
                                                              //   } else{
                                                              //     amountController?.text = result[1];
                                                              //     newEx.sets[indexSet].amount = result[0];
                                                              //   }
                                                              //   setState(() {});
                                                              // }
                                                              // cnRunningWorkout.cache();
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );

                                        return Slidable(
                                          key: UniqueKey(),
                                          // key: UniqueKey(),
                                          startActionPane: ActionPane(
                                            motion: const ScrollMotion(),
                                            dismissible: DismissiblePane(
                                                onDismissed: () {
                                                  // dismiss(newEx, templateEx, indexSet);
                                                }),
                                            children: [
                                              SlidableAction(
                                                flex:10,
                                                onPressed: (BuildContext context){
                                                  // dismiss(newEx, templateEx, indexSet);
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
                                          child: child,
                                        );
                                      }
                                  ),
                                ),

                                // Expanded(
                                //
                                //   /// Each EXERCISE
                                //   child: ListView.separated(
                                //     controller: cnRunningWorkout.scrollController,
                                //     physics: const BouncingScrollPhysics(),
                                //     shrinkWrap: true,
                                //     separatorBuilder: (BuildContext context, int index) {
                                //       return mySeparator();
                                //     },
                                //     cacheExtent: 1000000,
                                //     itemCount: cnRunningWorkout.groupedExercises.length,
                                //     itemBuilder: (BuildContext context, int indexExercise) {
                                //       Widget? child;
                                //       dynamic newEx = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value;
                                //       if(newEx is !Exercise){
                                //         try{
                                //           newEx = newEx[cnRunningWorkout.selectedIndexes[cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].key]];
                                //         }
                                //         catch (_){
                                //           if(newEx is List && newEx.first is Exercise){
                                //             newEx = newEx.first;
                                //           } else{
                                //             return const SizedBox();
                                //           }
                                //         }
                                //       }
                                //       Exercise templateEx = cnRunningWorkout.workoutTemplateModifiable.exercises.where((element) => element.name == newEx.name).first;
                                //       child = Column(
                                //         children: [
                                //           if (cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value is !Exercise)
                                //             Align(
                                //               alignment: Alignment.centerLeft,
                                //               child: OverflowSafeText(
                                //                 cnRunningWorkout.groupedExercises.keys.toList()[indexExercise],
                                //                 textAlign: TextAlign.center,
                                //                 // fontSize: 12,
                                //                 style: const TextStyle(
                                //                     fontSize: 13,
                                //                     color: Colors.white70
                                //                 ),
                                //                 minFontSize: 12,
                                //                 maxLines: 1,
                                //               ),
                                //             ),
                                //           Row(
                                //             children: [
                                //               cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value is Exercise
                                //               /// Single Exercise
                                //               ? Expanded(
                                //                 child: ConstrainedBox(
                                //                   constraints: BoxConstraints(
                                //                       maxWidth: MediaQuery.of(context).size.width-80
                                //                   ),
                                //                   child: OverflowSafeText(
                                //                     newEx.name,
                                //                     maxLines: 1,
                                //                     style: const TextStyle(color: Colors.white, fontSize: 20),
                                //                   ),
                                //                 ),
                                //               )
                                //               /// Exercise Selector
                                //               : PullDownButton(
                                //               onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
                                //               buttonAnchor: PullDownMenuAnchor.start,
                                //               routeTheme: const PullDownMenuRouteTheme(backgroundColor: CupertinoColors.secondaryLabel),
                                //               itemBuilder: (context) {
                                //                 final children = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value.map<PullDownMenuItem>((Exercise value) {
                                //                   return PullDownMenuItem.selectable(
                                //                     title: value.name,
                                //                     selected: newEx.name == value.name,
                                //                     onTap: () {
                                //                       FocusManager.instance.primaryFocus?.unfocus();
                                //                       HapticFeedback.selectionClick();
                                //                       Future.delayed(const Duration(milliseconds: 200), (){
                                //                         setState(() {
                                //                           final lists = cnRunningWorkout.groupedExercises.entries.toList().where((element) => element.value is List<Exercise>);
                                //                           final t = lists.map((element) => element.value.indexWhere((ex) {
                                //                             return ex.name == value.name;
                                //                           })).toList().firstWhere((element) => element >=0);
                                //                           cnRunningWorkout.selectedIndexes[cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].key] = t;
                                //                         });
                                //                         cnRunningWorkout.cache();
                                //                       });
                                //                     },
                                //                   );
                                //                 }).toList();
                                //                 return children;
                                //               },
                                //               buttonBuilder: (context, showMenu) => CupertinoButton(
                                //                   onPressed: (){
                                //                     HapticFeedback.selectionClick();
                                //                     showMenu();
                                //                   },
                                //                   padding: EdgeInsets.zero,
                                //                   child: Row(
                                //                     children: [
                                //                       ConstrainedBox(
                                //                         constraints: BoxConstraints(
                                //                             maxWidth: MediaQuery.of(context).size.width-120
                                //                         ),
                                //                         child: OverflowSafeText(
                                //                             newEx.name,
                                //                             style: const TextStyle(color: Colors.white, fontSize: 20),
                                //                             maxLines: 1
                                //                         ),
                                //                       ),
                                //                       const SizedBox(width: 10,),
                                //                       trailingChoice(size: 15, color: Colors.white)
                                //                     ],
                                //                   )
                                //                 ),
                                //               ),
                                //
                                //               cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value is Exercise
                                //                   ? const SizedBox()
                                //                   : const Spacer(),
                                //
                                //               if(cnRunningWorkout.newExNames.contains(newEx.name))
                                //                 SizedBox(
                                //                   width:40,
                                //                   child: myIconButton(
                                //                     icon:const Icon(Icons.delete_forever),
                                //                     onPressed: (){
                                //                       showCupertinoModalPopup<void>(
                                //                         context: context,
                                //                         builder: (BuildContext context) => CupertinoActionSheet(
                                //                           cancelButton: getActionSheetCancelButton(context),
                                //                           message: Text(AppLocalizations.of(context)!.runningWorkoutDeleteExercise),
                                //                           actions: <Widget>[
                                //                             CupertinoActionSheetAction(
                                //                               /// This parameter indicates the action would perform
                                //                               /// a destructive action such as delete or exit and turns
                                //                               /// the action's text color to red.
                                //                               isDestructiveAction: true,
                                //                               onPressed: () {
                                //                                 cnRunningWorkout.deleteExercise(newEx);
                                //                                 Navigator.pop(context);
                                //                               },
                                //                               child: Text(AppLocalizations.of(context)!.delete),
                                //                             ),
                                //                           ],
                                //                         ),
                                //                       );
                                //                     },
                                //                   ),
                                //                 ),
                                //             ],
                                //           ),
                                //           const SizedBox(height: 5),
                                //
                                //           Row(
                                //             // mainAxisSize: MainAxisSize.min,
                                //             mainAxisAlignment: MainAxisAlignment.start,
                                //             children: [
                                //               SizedBox(width: 100, child: getSeatLevelSelector(newEx),),
                                //               Icon(MyIcons.tags, size: _iconSize-3, color: Colors.amber[900]!.withOpacity(0.6),),
                                //               const SizedBox(width: 8,),
                                //               Text(newEx.getCategoryName()),
                                //             ],
                                //           ),
                                //
                                //           /// Rest in Seconds Row and Selector
                                //           getRestInSecondsSelector(newEx),
                                //
                                //           const SizedBox(height: 15),
                                //
                                //           /// Text for Set, Template, Weight and Amount
                                //           Row(
                                //             children: [
                                //               SizedBox(
                                //                   width: _widthOfTextField,
                                //                   child: OverflowSafeText(
                                //                       AppLocalizations.of(context)!.set,
                                //                       textAlign: TextAlign.center,
                                //                       // fontSize: 12,
                                //                       style: const TextStyle(
                                //                           fontSize: 13,
                                //                           color: Colors.white70
                                //                       ),
                                //                       minFontSize: 12,
                                //                       maxLines: 1,
                                //                   )
                                //               ),
                                //               Expanded(
                                //                   flex: 2,
                                //                   child: OverflowSafeText(
                                //                       AppLocalizations.of(context)!.template,
                                //                       textAlign: TextAlign.center,
                                //                       // fontSize: 12,
                                //                       style: const TextStyle(
                                //                         fontSize: 13,
                                //                         color: Colors.white70
                                //                       ),
                                //                       minFontSize: 12,
                                //                       maxLines: 1
                                //                   )
                                //               ),
                                //               /// TextField Headers
                                //               Expanded(
                                //                   flex: 2,
                                //                   child: Row(
                                //                     mainAxisAlignment: MainAxisAlignment.center,
                                //                     children: [
                                //                       SizedBox(
                                //                           width: _widthOfTextField+10,
                                //                           child: OverflowSafeText(
                                //                               // AppLocalizations.of(context)!.weight,
                                //                               newEx.getLeftTitle(context),
                                //                               textAlign: TextAlign.center,
                                //                               // fontSize: 12,
                                //                               style: const TextStyle(
                                //                                   fontSize: 13,
                                //                                   color: Colors.white70
                                //                               ),
                                //                               minFontSize: 12,
                                //                               maxLines: 1
                                //                           )
                                //                       ),
                                //                       const SizedBox(width: 4,),
                                //                       SizedBox(
                                //                           width: _widthOfTextField+10,
                                //                           child: OverflowSafeText(
                                //                               // AppLocalizations.of(context)!.amount,
                                //                               newEx.getRightTitle(context),
                                //                               textAlign: TextAlign.center,
                                //                               // fontSize: 12,
                                //                               style: const TextStyle(
                                //                                   fontSize: 13,
                                //                                   color: Colors.white70
                                //                               ),
                                //                               minFontSize: 12,
                                //                               maxLines: 1
                                //                           )
                                //                       )
                                //                     ],
                                //                   )
                                //               )
                                //             ],
                                //           ),
                                //
                                //           const SizedBox(height: 5),
                                //
                                //
                                //
                                //
                                //
                                //
                                //
                                //
                                //
                                //
                                //           /// Each Set Reorderable
                                //           Column(
                                //             children: [
                                //               ReorderableListView.builder(
                                //                   scrollController: ScrollController(),
                                //                   // physics: const BouncingScrollPhysics(),
                                //                   physics: NeverScrollableScrollPhysics(),
                                //                   padding: const EdgeInsets.all(0),
                                //                   shrinkWrap: true,
                                //                   cacheExtent: 20000,
                                //                   proxyDecorator: (
                                //                       Widget child, int index, Animation<double> animation) {
                                //                     return AnimatedBuilder(
                                //                       animation: animation,
                                //                       builder: (BuildContext context, Widget? child) {
                                //                         final double animValue = Curves.easeInOut.transform(animation.value);
                                //                         final double scale = lerpDouble(1, 1.06, animValue)!;
                                //                         return Transform.scale(
                                //                           scale: scale,
                                //                           child: ClipRRect(
                                //                             borderRadius: BorderRadius.circular(8),
                                //                             child: Material(
                                //                                 child: Container(
                                //                                     padding: const EdgeInsets.only(left: 2),
                                //                                     color: Colors.grey.withOpacity(0.1),
                                //                                     child: child
                                //                                 )
                                //                             ),
                                //                           ),
                                //                         );
                                //                       },
                                //                       child: child,
                                //                     );
                                //                   },
                                //                   onReorder: (int oldIndex, int newIndex){
                                //                     setState(() {
                                //                       if (oldIndex < newIndex) {
                                //                         newIndex -= 1;
                                //                       }
                                //                       final item = templateEx.sets.removeAt(oldIndex);
                                //                       templateEx.sets.insert(newIndex, item);
                                //                       final item2 = newEx.sets.removeAt(oldIndex);
                                //                       newEx.sets.insert(newIndex, item2);
                                //                       final weightAndAmount = cnRunningWorkout.textControllers[newEx.name]?.removeAt(oldIndex);
                                //                       cnRunningWorkout.textControllers[newEx.name]?.insert(newIndex, weightAndAmount!);
                                //                     });
                                //                     cnRunningWorkout.cache();
                                //                   },
                                //                   itemCount: newEx.sets.length,
                                //                   itemBuilder: (BuildContext context, int indexSet) {
                                //
                                //                     final TextEditingController? weightController = cnRunningWorkout.textControllers[newEx.name]?[indexSet][0];
                                //                     final TextEditingController? amountController = cnRunningWorkout.textControllers[newEx.name]?[indexSet][1];
                                //
                                //                     SingleSet set = templateEx.sets[indexSet];
                                //                     Widget? child;
                                //                     child = Padding(
                                //                       padding: EdgeInsets.only(bottom: _setPadding, top: _setPadding),
                                //                       child: SizedBox(
                                //                         width: double.maxFinite,
                                //                         child: Row(
                                //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //                           children: [
                                //
                                //                             /// Set
                                //                             getSet(
                                //                                 context: context,
                                //                                 index: indexSet,
                                //                                 newEx: newEx,
                                //                                 width: _widthOfTextField,
                                //                                 onConfirm: (){
                                //                                   cnRunningWorkout.cache();
                                //                                   cnRunningWorkout.refresh();
                                //                                 }
                                //                             ),
                                //
                                //                             /// Button to copy templates data
                                //                             getButtonInsertTemplatesData(set: set, newEx: newEx, indexSet: indexSet, weightController: weightController, amountController: amountController),
                                //
                                //                             /// Weight and Amount
                                //                             Expanded(
                                //                               flex: 2,
                                //                               child: Row(
                                //                                 mainAxisAlignment: MainAxisAlignment.center,
                                //                                 children: [
                                //
                                //                                   /// Weight
                                //                                   SizedBox(
                                //                                     width: _widthOfTextField,
                                //                                     height: _heightOfSetRow,
                                //                                     child: Center(
                                //                                       child: TextField(
                                //                                         keyboardAppearance: Brightness.dark,
                                //                                         maxLength: (weightController?.text.contains(".")?? true)? 6 : 4,
                                //                                         textAlign: TextAlign.center,
                                //                                         keyboardType: const TextInputType.numberWithOptions(
                                //                                             decimal: true,
                                //                                             signed: false
                                //                                         ),
                                //                                         controller: weightController,
                                //                                         onTap: (){
                                //                                           weightController?.selection =  TextSelection(baseOffset: 0, extentOffset: weightController.value.text.length);
                                //                                         },
                                //                                         decoration: InputDecoration(
                                //                                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                //                                             // isDense: true,
                                //                                             counterText: "",
                                //                                             contentPadding: const EdgeInsets.symmetric(horizontal: 0 ,vertical: 0.0),
                                //                                             hintFadeDuration: const Duration(milliseconds: 200),
                                //                                             hintText: "${set.weight.toString().endsWith(".0")? set.weight?.toInt() : set.weight?? ""}",
                                //                                             hintStyle: getTextStyleForTextField((set.weight?? "").toString(), color: Colors.white.withOpacity(0.15), sizeSmall: false)
                                //                                         ),
                                //                                         style: getTextStyleForTextField(weightController?.text?? "", sizeSmall: false),
                                //                                         onChanged: (value){
                                //                                           value = value.trim();
                                //                                           if(value.isNotEmpty){
                                //                                             value = validateDoubleTextInput(value);
                                //                                             final newValue = double.tryParse(value);
                                //                                             newEx.sets[indexSet].weight = newValue;
                                //                                             if(newValue == null){
                                //                                               weightController?.clear();
                                //                                             } else{
                                //                                               weightController?.text = value;
                                //                                             }
                                //                                           }
                                //                                           else{
                                //                                             newEx.sets[indexSet].weight = null;
                                //                                           }
                                //                                           cnRunningWorkout.cache();
                                //                                           setState(() => {});
                                //                                         },
                                //                                       ),
                                //                                     ),
                                //                                   ),
                                //
                                //                                   const SizedBox(width: 12,),
                                //
                                //                                   /// Amount
                                //                                   SizedBox(
                                //                                     width: _widthOfTextField,
                                //                                     height: _heightOfSetRow,
                                //                                     child: Center(
                                //                                       child: TextField(
                                //                                         keyboardAppearance: Brightness.dark,
                                //                                         maxLength: newEx.categoryIsReps()? 3 : 8,
                                //                                         textAlign: TextAlign.center,
                                //                                         keyboardType: const TextInputType.numberWithOptions(
                                //                                             decimal: false,
                                //                                             signed: false
                                //                                         ),
                                //                                         controller: amountController,
                                //                                         onTap: (){
                                //                                           amountController?.selection =  TextSelection(baseOffset: 0, extentOffset: amountController.value.text.length);
                                //                                         },
                                //                                         decoration: InputDecoration(
                                //                                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                //                                             // isDense: true,
                                //                                             counterText: "",
                                //                                             contentPadding: const EdgeInsets.symmetric(horizontal: 0 ,vertical: 0.0),
                                //                                             hintText: newEx.categoryIsReps()? "${set.amount?? ""}" : set.amountAsTime,
                                //                                             hintStyle: getTextStyleForTextField(
                                //                                                 newEx.categoryIsReps()? "${set.amount?? ""}" : set.amountAsTime?? "",
                                //                                                 sizeSmall: false,
                                //                                                 color: Colors.white.withOpacity(0.07)
                                //                                             )
                                //                                             // hintStyle: TextStyle(color: Colors.white.withOpacity(0.07))
                                //                                         ),
                                //                                         style: getTextStyleForTextField(amountController?.text?? "", sizeSmall: false),
                                //                                         onChanged: (value){
                                //                                           value = value.trim();
                                //                                           /// For Reps
                                //                                           if(newEx.categoryIsReps()){
                                //                                             if(value.isNotEmpty){
                                //                                               final newValue = int.tryParse(value);
                                //                                               newEx.sets[indexSet].amount = newValue;
                                //                                               if(newValue == null){
                                //                                                 amountController?.clear();
                                //                                               }
                                //                                               if(value.length == 1){
                                //                                                 setState(() => {});
                                //                                               }
                                //                                             }
                                //                                             else{
                                //                                               newEx.sets[indexSet].amount = null;
                                //                                               setState(() => {});
                                //                                             }
                                //                                           }
                                //                                           /// For Time
                                //                                           else{
                                //                                             List result = parseTextControllerAmountToTime(value);
                                //                                             if(result[0] <= 0){
                                //                                               amountController?.text = "";
                                //                                               newEx.sets[indexSet].amount = null;
                                //                                             } else{
                                //                                               amountController?.text = result[1];
                                //                                               newEx.sets[indexSet].amount = result[0];
                                //                                             }
                                //                                             setState(() {});
                                //                                           }
                                //                                           cnRunningWorkout.cache();
                                //                                         },
                                //                                       ),
                                //                                     ),
                                //                                   ),
                                //                                 ],
                                //                               ),
                                //                             ),
                                //                           ],
                                //                         ),
                                //                       ),
                                //                     );
                                //
                                //                     return Slidable(
                                //                       key: cnRunningWorkout.slideableKeys[newEx.name]![indexSet],
                                //                       // key: UniqueKey(),
                                //                       startActionPane: ActionPane(
                                //                         motion: const ScrollMotion(),
                                //                         dismissible: DismissiblePane(
                                //                             onDismissed: () {
                                //                               dismiss(newEx, templateEx, indexSet);
                                //                             }),
                                //                         children: [
                                //                           SlidableAction(
                                //                             flex:10,
                                //                             onPressed: (BuildContext context){
                                //                               dismiss(newEx, templateEx, indexSet);
                                //                             },
                                //                             borderRadius: BorderRadius.circular(15),
                                //                             backgroundColor: const Color(0xFFA12D2C),
                                //                             foregroundColor: Colors.white,
                                //                             icon: Icons.delete,
                                //                           ),
                                //                           SlidableAction(
                                //                             flex: 1,
                                //                             onPressed: (BuildContext context){},
                                //                             backgroundColor: Colors.transparent,
                                //                             foregroundColor: Colors.transparent,
                                //                             label: '',
                                //                           ),
                                //                         ],
                                //                       ),
                                //                       child: child,
                                //                     );
                                //                   }
                                //               ),
                                //               Row(
                                //                 children: [
                                //                   Expanded(
                                //                     child: IconButton(
                                //                         alignment: Alignment.center,
                                //                         color: Colors.amber[800],
                                //                         style: ButtonStyle(
                                //                             backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
                                //                             shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(20)))
                                //                         ),
                                //                         onPressed: () {
                                //                           addSet(newEx, templateEx);
                                //                         },
                                //                         icon: const Icon(
                                //                           Icons.add,
                                //                           size: 20,
                                //                         )
                                //                     ),
                                //                   ),
                                //                 ],
                                //               )
                                //             ],
                                //           ),
                                //         ],
                                //       );
                                //
                                //       /// Top Spacer
                                //       if (indexExercise == 0){
                                //         child = Column(
                                //           children: [
                                //             const SizedBox(height: 80,),
                                //             child
                                //           ],
                                //         );
                                //       }
                                //
                                //       /// Bottom Spacer
                                //       if (indexExercise == cnRunningWorkout.groupedExercises.length-1){
                                //         child = Column(
                                //           children: [
                                //             child,
                                //             AnimatedContainer(
                                //                 duration: const Duration(milliseconds: 250),
                                //                 height: cnStopwatchWidget.isOpened
                                //                     ? 70 + cnStopwatchWidget.heightOfTimer
                                //                     : 70
                                //             ),
                                //           ],
                                //         );
                                //       }
                                //
                                //       return child;
                                //     },
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                        /// do not make const, should be updated by rebuild
                        Hero(
                            transitionOnUserGestures: true,
                            tag: "Banner",
                            child: BannerRunningWorkout()
                        ),
                        AnimatedCrossFade(
                            layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
                              return Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Positioned(
                                    key: bottomChildKey,
                                    // bottom: 0,
                                    // left: 0,
                                    child: bottomChild,
                                  ),
                                  Positioned(
                                    key: topChildKey,
                                    child: topChild,
                                  ),
                                ],
                              );
                            },
                            firstChild: const AnimatedColumn(),
                            secondChild: const Align(
                              alignment: Alignment.bottomRight,
                                child: SizedBox(width: double.maxFinite)
                            ),
                            crossFadeState: viewInsetsBottom < 50
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                            duration: Duration(milliseconds: viewInsetsBottom < 50? cnSpotifyBar.animationTimeSpotifyBar~/2 : 0)
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if(cnRunningWorkout.dismissedSets.isNotEmpty)
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: undoDismiss,
                        icon: Icon(
                          Icons.undo,
                          color: Colors.amber[800],
                        )
                    ),
                  ),
                ),
              const StandardPopUp(),
              // AnimatedCrossFade(
              //   firstChild: Container(
              //     color: Colors.black54,
              //   ),
              //   secondChild: const SizedBox(),
              //   crossFadeState: showSelectorExerciseToUpdate || showSelectorExercisePerLink
              //       ? CrossFadeState.showFirst
              //       : CrossFadeState.showSecond,
              //   duration: const Duration(milliseconds: 200),
              //   layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
              //     return Stack(
              //       clipBehavior: Clip.none,
              //       alignment: Alignment.center,
              //       children: <Widget>[
              //         Positioned(
              //           key: bottomChildKey,
              //           child: bottomChild,
              //         ),
              //         Positioned(
              //           key: topChildKey,
              //           child: topChild,
              //         ),
              //       ],
              //     );
              //   },
              // ),
              SelectorExercisesPerLink(
                controller: controllerSelectorExercisePerLink,
                key: selectorExercisePerLinkKey,
                groupedExercises: cnRunningWorkout.groupedExercises,
                relevantLinkNames: cnRunningWorkout.linkWithMultipleExercisesStarted,
                onConfirm: confirmSelectorExPerLink,
                onCancel: (){
                  controllerSelectorExercisePerLink.close();
                },
              ),
              SelectorExercisesToUpdate(
                key: selectorExerciseToUpdateKey,
                controller: controllerSelectorExerciseToUpdate,
                descendantAnimationControllerName: descendantNameExerciseToUpdate,
                workout: Workout.clone(cnRunningWorkout.workout),
                workoutTemplate: Workout.clone(cnRunningWorkout.workoutTemplateNotModifiable),
                onConfirm: finishWorkout,
                onCancel: (){
                  // controllerSelectorExerciseToUpdate.close().then((value) => controllerSelectorExercisePerLink.close());
                  controllerSelectorExerciseToUpdate.close();
                },
              ),
              if (isSavingData)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CupertinoActivityIndicator(
                        radius: 20.0,
                        color: Colors.amber[800]
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget getButtonInsertTemplatesData({
    required SingleSet set,
    required Exercise newEx,
    required int indexSet,
    required TextEditingController? weightController,
    required TextEditingController? amountController
  }){

    String getText(){
      switch (newEx.category){
        case 1:
          return set.weight != null && set.amount != null? "${set.weightAsTrimmedDouble?? ""} kg x ${set.amount?? ""}" : "";
        case 2:
          return set.weight != null && set.amount != null? "${set.weightAsTrimmedDouble?? ""} km in ${set.amountAsTime?? ""}" : "";
        case 3:
          return set.weight != null && set.amount != null? "${set.weightAsTrimmedDouble?? ""} kg for ${set.amountAsTime?? ""}" : "";
        default:
          return "";
      }
    }

    final weightTextIsEmpty = weightController?.text.isEmpty?? false;
    final amountTextIsEmpty = weightController?.text.isEmpty?? false;

    return Expanded(
        flex: 2,
        child: IgnorePointer(
          ignoring: !(weightTextIsEmpty &&
              amountTextIsEmpty &&
              set.weight != null &&
              set.amount != null),
          child: SizedBox(
            height: _heightOfSetRow,
            child: ElevatedButton(
              style: ButtonStyle(
                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                  surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
              ),
              onPressed: (){
                if(set.weight != null &&
                    set.amount != null &&
                    weightTextIsEmpty &&
                    amountTextIsEmpty
                ){
                  vibrateConfirm();
                  weightController?.text = (set.weightAsTrimmedDouble?? "").toString();
                  newEx.sets[indexSet].weight = set.weight;
                  if(newEx.categoryIsReps()){
                    amountController?.text = set.amount!.toString();
                  }
                  else{
                    amountController?.text = set.amountAsTime.toString();
                  }
                  newEx.sets[indexSet].amount = set.amount;
                  cnRunningWorkout.refresh();
                  cnRunningWorkout.cache();
                } else{
                  setState(() {
                    FocusScope.of(context).unfocus();
                  });
                }
              },
              child: Center(
                child: OverflowSafeText(
                  maxLines: 1,
                  getText(),
                  style: TextStyle(
                      color: (weightTextIsEmpty &&
                          amountTextIsEmpty)
                          ?Colors.white
                          : Colors.white.withOpacity(0.2)
                  ),
                ),
              ),
            ),
          ),
        )
    );
  }

  void confirmSelectorExPerLink({List<String>? exToRemove, int? delay}){
    cnRunningWorkout.exercisesToRemove = exToRemove?? [];
    if(canUpdateTemplate()){
      Future.delayed(Duration(milliseconds: delay?? cnStandardPopUp.animationTime), (){
        setState(() {
          selectorExerciseToUpdateKey = UniqueKey();
          controllerSelectorExerciseToUpdate = PanelController();
        });
        Future.delayed(const Duration(milliseconds: (100)), (){
          FocusManager.instance.primaryFocus?.unfocus();
          controllerSelectorExerciseToUpdate.open();
        });
      });
    }
    else{
      finishWorkout();
    }
  }

  void addSet(Exercise ex, Exercise lastEx){
    setState(() {
      ex.addSet();
      lastEx.addSet();
      cnRunningWorkout.textControllers[ex.name]?.add([TextEditingController(), TextEditingController()]);
      cnRunningWorkout.slideableKeys[ex.name]?.add(UniqueKey());
      final newControllerPos = cnRunningWorkout.scrollController.position.pixels+_heightOfSetRow + _setPadding*2;
      if(newControllerPos >= 0 && cnRunningWorkout.scrollController.position.maxScrollExtent >= newControllerPos){
        cnRunningWorkout.scrollController.jumpTo(newControllerPos);
      }
    });
  }

  void dismiss(Exercise ex, Exercise lastEx, int index){
    setState(() {
      final dismissedSet = ex.sets.removeAt(index);
      final dismissedTemplateSet = lastEx.sets.removeAt(index);
      final dismissedControllers = cnRunningWorkout.textControllers[ex.name]?.removeAt(index);
      cnRunningWorkout.slideableKeys[ex.name]?.removeAt(index);

      cnRunningWorkout.dismissedSets.add(
          DismissedSingleSet(
              linkName: ex.linkName,
              exName: ex.name,
              index: index,
              dismissedSet: dismissedSet,
              dismissedTemplateSet: dismissedTemplateSet,
              dismissedControllers: dismissedControllers
          )
      );
    });
    cnRunningWorkout.cache();
  }

  void undoDismiss(){
    if(cnRunningWorkout.dismissedSets.isEmpty){
      return;
    }
    setState(() {
      final setsToInsert = cnRunningWorkout.dismissedSets.removeLast();
      final templateEx = cnRunningWorkout.workoutTemplateModifiable.exercises.where((element) => element.name == setsToInsert.exName).first;
      late Exercise newEx;
      if(setsToInsert.linkName != null){
        newEx = cnRunningWorkout.groupedExercises[setsToInsert.linkName].where((ex) => ex.name == setsToInsert.exName).first;
      } else{
        newEx = cnRunningWorkout.groupedExercises[setsToInsert.exName];
      }
      templateEx.sets.insert(setsToInsert.index, setsToInsert.dismissedTemplateSet);
      newEx.sets.insert(setsToInsert.index, setsToInsert.dismissedSet);
      if(setsToInsert.dismissedControllers != null){
        cnRunningWorkout.textControllers[setsToInsert.exName]?.insert(setsToInsert.index, setsToInsert.dismissedControllers!);
      } else{
        cnRunningWorkout.textControllers[setsToInsert.exName]?.insert(setsToInsert.index, [TextEditingController(), TextEditingController()]);
      }
      cnRunningWorkout.slideableKeys[setsToInsert.exName]?.insert(setsToInsert.index, UniqueKey());
    });
    cnRunningWorkout.cache();
  }

  /// Find the first indication of whether or not an Exercise has changed.
  ///
  /// Can be through:
  ///   - amount of sets
  ///   - weight
  ///   - amount
  ///   - rest in seconds
  ///   - seat level
  ///   - new Exercise added
  bool canUpdateTemplate(){
    Workout tempWo = Workout.clone(cnRunningWorkout.workout);
    tempWo.removeEmptyExercises();

    if(tempWo.exercises.isEmpty){
      return false;
    }

    /// Get exercises names of true template
    List<String> templateWorkoutExerciseNames = cnRunningWorkout.workoutTemplateNotModifiable.exercises.map((e) => e.name).toList();

    /// Iterate over every exercise in the current running (new) one
    for(Exercise ex in tempWo.exercises){
      /// Exercise name does not exist in true template yet => new exercise has been added => can update Template
      if(!templateWorkoutExerciseNames.contains(ex.name)){
        return true;
      }
      /// When the exercise name already exists, we check if the exercise of the true template and the current running one are truly the same
      Exercise tempTemplateEx = cnRunningWorkout.workoutTemplateNotModifiable.exercises.firstWhere((e) => e.name == ex.name);
      if(!tempTemplateEx.equals(ex)){
        return true;
      }
    }
    return false;
  }

  bool hasStartedWorkout(){
    Workout tempWo = Workout.clone(cnRunningWorkout.workout);
    tempWo.removeEmptyExercises();
    if(tempWo.exercises.isEmpty){
      return false;
    }
    return true;
  }

  void openPopUpFinishWorkout(){
    final bool canFinish = hasStartedWorkout();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        cancelButton: getActionSheetCancelButton(context, text: "Workout Fortsetzen"),
        title: Text(AppLocalizations.of(context)!.runningWorkoutFinishWorkout),
        actions: <Widget>[
          CupertinoActionSheetAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as delete or exit and turns
            /// the action's text color to red.
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              Future.delayed(const Duration(milliseconds: 250), (){
                openPopUpConfirmCancelWorkout();
              });
            },
            child: Text(AppLocalizations.of(context)!.runningWorkoutStopWorkout),
          ),
          if(canFinish)
            CupertinoActionSheetAction(
              /// This parameter indicates the action would perform
              /// a destructive action such as delete or exit and turns
              /// the action's text color to red.
              isDestructiveAction: false,
              onPressed: () {
                Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime), (){
                  setState(() {
                    cnRunningWorkout.checkMultipleExercisesPerLink();
                    if(cnRunningWorkout.linkWithMultipleExercisesStarted.isNotEmpty){
                      descendantNameExerciseToUpdate = "SelectorExercisePerLink";
                      selectorExercisePerLinkKey = UniqueKey();
                      controllerSelectorExercisePerLink = PanelController();
                      Future.delayed(const Duration(milliseconds: 100), (){
                        FocusManager.instance.primaryFocus?.unfocus();
                        controllerSelectorExercisePerLink.open();
                      });
                    } else{
                      descendantNameExerciseToUpdate = "ScreenRunningWorkout";
                      confirmSelectorExPerLink(delay: 0);
                    }
                  });
                });
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.finish),
            ),
        ],
      ),
    );
  }

  void openPopUpConfirmCancelWorkout() {
    // if(cnStandardPopUp.isVisible){
    //   cnStandardPopUp.clear();
    //   await Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime));
    // }
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        cancelButton: getActionSheetCancelButton(context, text: "Workout Fortsetzen"),
        title: Text(AppLocalizations.of(context)!.runningWorkoutStopWorkout),
        message: Text(AppLocalizations.of(context)!.runningWorkoutConfirmCancelWorkout),
        actions: <Widget>[
          CupertinoActionSheetAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as delete or exit and turns
            /// the action's text color to red.
            isDestructiveAction: true,
            onPressed: () {
              stopWorkout();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.runningWorkoutStopWorkout),
          ),
        ],
      ),
    );
    // cnStandardPopUp.open(
    //   context: context,
    //   widthFactor: 0.75,
    //   confirmText: AppLocalizations.of(context)!.yes,
    //   onConfirm: stopWorkout,
    //   cancelText: AppLocalizations.of(context)!.no,
    //   // confirmTextStyle: TextStyle(color: Colors.red.withOpacity(0.6)),
    //   // onConfirm: ,
    //   padding: const EdgeInsets.only(top: 20),
    //   child: Column(
    //     children: [
    //       Text(
    //         AppLocalizations.of(context)!.runningWorkoutStopWorkout,
    //         textAlign: TextAlign.center,
    //         textScaler: const TextScaler.linear(1.2),
    //         style: const TextStyle(color: Colors.white),
    //       ),
    //       const SizedBox(height: 10,),
    //       Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 10.0),
    //         child: Text(
    //           AppLocalizations.of(context)!.runningWorkoutConfirmCancelWorkout,
    //           textAlign: TextAlign.center,
    //           textScaler: const TextScaler.linear(0.9),
    //           style: const TextStyle(color: Colors.white),
    //         ),
    //       ),
    //       const SizedBox(height: 20,),
    //       // Container(
    //       //   height: 0.5,
    //       //   width: double.maxFinite,
    //       //   color: Colors.grey[700]!.withOpacity(0.5),
    //       // ),
    //       // SizedBox(
    //       //   height: 40,
    //       //   width: double.maxFinite,
    //       //   child: ElevatedButton(
    //       //     onPressed: stopWorkout,
    //       //     style: ButtonStyle(
    //       //         shadowColor: MaterialStateProperty.all(Colors.transparent),
    //       //         surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
    //       //         backgroundColor: MaterialStateProperty.all(Colors.transparent),
    //       //         shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
    //       //     ),
    //       //     child: Text(
    //       //       AppLocalizations.of(context)!.yes,
    //       //       // style: TextStyle(color: Colors.red.withOpacity(0.6)),
    //       //     ),
    //       //   ),
    //       // ),
    //     ],
    //   ),
    // );
  }

  Future stopWorkout({int? time})async{
    time = time?? cnStandardPopUp.animationTime;
    if(cnStandardPopUp.isVisible){
      cnStandardPopUp.clear();
    }
    await Future.delayed(Duration(milliseconds: time), ()async{
      cnRunningWorkout.isVisible = false;
      cnRunningWorkout.isRunning = false;
      cnHomepage.refresh();
      cnWorkouts.refresh();
      await Future.delayed(const Duration(milliseconds: 50), ()async{
        Navigator.of(context).pop();
        /// delayed that the pop context is finished, if to short, the user
        /// will se a blank page which is not wanted
        await Future.delayed(const Duration(milliseconds: 500), (){
          cnRunningWorkout.clear();
          if(cnStopwatchWidget.isRunning){
            cnStopwatchWidget.cancelTimer();
          }
        });
      });
    });
  }

  Future finishWorkout() async{
    int time = 0;

    setState(() {
      isSavingData = true;
    });


    await Future.delayed(const Duration(milliseconds: 300));
    if(controllerSelectorExerciseToUpdate.panelPosition > 0){
      await controllerSelectorExerciseToUpdate.close();
      time = 100;
    }
    if(controllerSelectorExercisePerLink.panelPosition > 0){
      await Future.delayed(Duration(milliseconds: time));
      await controllerSelectorExercisePerLink.close();
    }

    /// delay that the popup is closed
    await Future.delayed(const Duration(milliseconds: 100), ()async{
      cnRunningWorkout.workout.refreshDate();
      cnRunningWorkout.removeNotRelevantExercises();
      cnRunningWorkout.workout.removeEmptyExercises();
      if(cnRunningWorkout.workout.exercises.isNotEmpty){
        cnRunningWorkout.workout.saveToDatabase();
        cnWorkouts.refreshAllWorkouts();
      }
      if(cnStopwatchWidget.isRunning){
        cnStopwatchWidget.cancelTimer();
      }

      bool savedAutomaticBackup = false;
      bool savedCurrentData = false;

      if(cnConfig.automaticBackups){
        savedAutomaticBackup = await saveBackup(withCloud: cnConfig.saveBackupCloud, cnConfig: cnConfig) != null;
      }

      savedCurrentData = await saveCurrentData(cnConfig) != null;

      // Fluttertoast.showToast(
      //     msg: "${AppLocalizations.of(context)!.createdAutomaticBackup}: ${savedAutomaticBackup? "✅" : "❌"} \n${AppLocalizations.of(context)!.savedDataForSync}: ${savedCurrentData? "✅" : "❌"}",
      //     toastLength: Toast.LENGTH_LONG,
      //     gravity: ToastGravity.TOP,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.grey[800],
      //     textColor: Colors.white,
      //     fontSize: 16.0
      // );
      Fluttertoast.showToast(
          msg: "Workout erfolgreich abgeschlossen 🎉",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[800]?.withOpacity(0.9),
          textColor: Colors.white,
          fontSize: 16.0
      );
      vibrateSuccess();
      await stopWorkout(time: 0);
      isSavingData = false;
    });
  }

  Widget getSeatLevelSelector(Exercise newEx) {
    return SizedBox(
      height: 30,
      child: getSelectSeatLevel(
          currentSeatLevel: newEx.seatLevel,
          child: SizedBox(
            width: 100,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 100,
                height: 30,
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.airline_seat_recline_normal, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
                    const SizedBox(width: 2,),
                    if (newEx.seatLevel == null)
                      Text("-", style: _style,)
                    else
                      Text(newEx.seatLevel.toString(), style: _style,)
                  ],
                ),
              ),
            ),
          ),
          onConfirm: (dynamic value){
            if(value is int){
              newEx.seatLevel = value;
              cnRunningWorkout.refresh();
            }
            else if(value == AppLocalizations.of(context)!.clear){
              newEx.seatLevel = null;
              cnRunningWorkout.refresh();
            }
          },
        context: context
      ),
    );
  }

  getRestInSecondsSelector(Exercise newEx) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          getSelectRestInSeconds(
              currentTime: newEx.restInSeconds,
              context: context,
              child: SizedBox(
                width: 100,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(Icons.timer, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
                      const SizedBox(width: 2,),
                      Text(mapRestInSecondsToString(restInSeconds: newEx.restInSeconds), style: _style),
                      const SizedBox(width: 10,)
                    ],
                  ),
                ),
              ),
              onConfirm: (dynamic value){
                if(value is int){
                  newEx.restInSeconds = value;
                  cnRunningWorkout.refresh();
                }
                else if(value == AppLocalizations.of(context)!.clear){
                  newEx.restInSeconds = 0;
                  cnRunningWorkout.refresh();
                }
                else{
                  showDialogMinuteSecondPicker(
                    context: context,
                    initialTimeDuration: Duration(minutes: newEx.restInSeconds~/60, seconds: newEx.restInSeconds%60),
                    onConfirm: (Duration newDuration){
                      newEx.restInSeconds = newDuration.inSeconds;
                    }
                  ).then((value) => setState(() {}));
                }
              }
          ),
          const Spacer()
        ],
      ),
    );
  }
}

class CnRunningWorkout extends ChangeNotifier {
  Workout workout = Workout();
  Workout workoutTemplateModifiable = Workout();
  Workout workoutTemplateNotModifiable = Workout();
  bool isRunning = false;
  bool isVisible = false;
  ScrollController scrollController = ScrollController();
  // TextEditingController controllerRestInSeconds = TextEditingController();
  TextEditingController controllerSeatLevel = TextEditingController();
  List<String> newExNames = [];
  late Map<String, List<Key>> slideableKeys = {
    for (var e in workout.exercises)
      e.name :
      e.generateKeyForEachSet()
  };
  late Map<String, List<List<TextEditingController>>> textControllers = {
    for (var e in workout.exercises)
      e.name :
      e.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList()
  };
  /// Contains all Exercises - linked and non linked ones - as a Map
  /// linked exercises are saved as another Map with key = linkName
  /// non linked Exercises are saved as the exercise itself with the ex.name as the key
  Map groupedExercises = {};
  /// Contains for each linked exercise the currently selected index for getting the right one
  /// from the groupedExercises Map
  Map<String, int> selectedIndexes = {};
  late CnConfig cnConfig;
  List<String> linkWithMultipleExercisesStarted = [];
  List<String> exercisesToRemove = [];
  List<DismissedSingleSet> dismissedSets = [];
  double lastScrollPosition = 0;
  List<dynamic> allItems = [];

  CnRunningWorkout(BuildContext context){
    cnConfig = Provider.of<CnConfig>(context, listen: false);
  }
  
  void addExercise(Exercise ex){
    workoutTemplateModifiable.exercises.add(Exercise.copy(ex));
    workout.exercises.add(ex);
    newExNames.add(ex.name);
    slideableKeys[ex.name] = ex.generateKeyForEachSet();
    groupedExercises[ex.name] = ex;
    textControllers[ex.name] = ex.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList();
    cache();
    refresh();
  }

  void deleteExercise(Exercise ex){
    workoutTemplateModifiable.exercises.removeWhere((e) => e.name == ex.name);
    dismissedSets.removeWhere((e) => e.exName == ex.name);
    workout.exercises.removeWhere((e) => e.name == ex.name);
    newExNames.removeWhere((e) => e == ex.name);
    slideableKeys.remove(ex.name);
    groupedExercises.remove(ex.name);
    refresh();
  }

  void initCachedData(Map data){
    if(
      data.containsKey("workout") &&
      data.containsKey("workoutTemplateModifiable") &&
      data.containsKey("workoutTemplateNotModifiable") &&
      data.containsKey("isRunning") &&
      data.containsKey("isVisible") &&
      data.containsKey("testControllerValues") &&
      data.containsKey("selectedIndexes") &&
      data.containsKey("newExNames")
    ){
      isRunning = data["isRunning"];
      isVisible = data["isVisible"];
      newExNames = List<String>.from(data["newExNames"]);
      for(MapEntry entry in data["selectedIndexes"].entries){
        selectedIndexes[entry.key] = entry.value;
      }
      workout = Workout().fromMap(data["workout"]) ?? Workout();
      workoutTemplateModifiable = Workout().fromMap(data["workoutTemplateModifiable"]) ?? Workout();
      workoutTemplateNotModifiable = Workout().fromMap(data["workoutTemplateNotModifiable"]) ?? Workout();
      initSlideableKeys();
      initGroupedExercises();
      initTextControllers();
      setTextControllerValues(data["testControllerValues"]);
    }
  }

  void openRunningWorkout(BuildContext context, Workout w){
    setWorkoutTemplate(w);
    isRunning = true;
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => const ScreenRunningWorkout()
        ));
    isVisible = true;
    cache();
  }

  void reopenRunningWorkout(BuildContext context) async{
    HapticFeedback.selectionClick();
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => const ScreenRunningWorkout()
        ));

    // while(true){
    //   await Future.delayed(const Duration(milliseconds: 5), (){});
    //   if(scrollController.hasClients){
    //     print(scrollController.position.pixels);
    //     scrollController.jumpTo(lastScrollPosition);
    //     break;
    //   }
    // }
    isVisible = true;
    cache();
  }

  void removeNotRelevantExercises(){
    workout.exercises.removeWhere((ex) => exercisesToRemove.contains(ex.name));
  }

  void setWorkoutTemplate(Workout w){
    workoutTemplateModifiable = w;
    workout = Workout.copy(w);
    workoutTemplateNotModifiable = Workout.copy(w);
    workout.resetAllExercisesSets(keepSetType: true);
    initSlideableKeys();
    initSelectedIndexes();
    initGroupedExercises();
    initTextControllers();
  }

  void initSlideableKeys(){
    slideableKeys = {
      for (var e in workout.exercises)
        e.name :
        e.generateKeyForEachSet()
    };
  }

  void initSelectedIndexes(){
    selectedIndexes = {
      for (String link in workout.linkedExercises)
        link:
        0
    };
  }

  void initGroupedExercises(){
    groupedExercises.clear();
    allItems.clear();

    for (Exercise ex in workout.exercises){
      if (ex.linkName == null){
        groupedExercises[ex.name] = ex;
      }
      else if(!groupedExercises.containsKey(ex.linkName)){
        groupedExercises[ex.linkName] = [ex];
      }
      else{
        groupedExercises[ex.linkName] = groupedExercises[ex.linkName] + [ex];
      }
      allItems.add(ex);
      allItems.addAll(ex.sets);
    }
    for(MapEntry entry in groupedExercises.entries){
      if(entry.value is List){
        (entry.value as List).sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      }
    }
  }

  void initTextControllers(){
    textControllers = {
      for (var e in workout.exercises)
        e.name :
        e.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList()
    };
  }

  Future<void> cache() async{
    Map data = {
      "workout": workout.asMap(),
      "workoutTemplateModifiable": workoutTemplateModifiable.asMap(),
      "workoutTemplateNotModifiable": workoutTemplateNotModifiable.asMap(),
      "isRunning": isRunning,
      "isVisible": isVisible,
      "testControllerValues": getTextControllerValues(),
      "selectedIndexes": selectedIndexes,
      "newExNames": newExNames
    };
    cnConfig.config.cnRunningWorkout = data;
    await cnConfig.config.save();
  }

  Map<String, List<dynamic>> getTextControllerValues(){
    return {
      for (MapEntry entry in textControllers.entries)
        entry.key :
        entry.value.map((controllers) => [controllers[0].text, controllers[1].text]).toList()
    };
  }

  void setTextControllerValues(Map<String, dynamic> textControllersValues){
    for (MapEntry entry in textControllersValues.entries){
      // textControllers[entry.key] = entry.value.map((e) => [TextEditingController(text: e[0]), TextEditingController(text: e[0])]).toList();
      textControllers[entry.key] = List<List<TextEditingController>>.from(entry.value.map((e) => [TextEditingController(text: e[0]), TextEditingController(text: e[1])]));
    }
  }

  void checkMultipleExercisesPerLink(){
    Map<String, int> linkCounter = {};
    Workout tempWo = Workout.clone(workout);
    tempWo.removeEmptyExercises();
    for(Exercise ex in tempWo.exercises){
      if(ex.linkName == null){
        continue;
      }
      if(linkCounter.containsKey(ex.linkName)){
        linkCounter[ex.linkName!] = linkCounter[ex.linkName]! + 1;
      } else{
        linkCounter[ex.linkName!] = 1;
      }
    }
    linkCounter.removeWhere((key, value) => value <= 1);
    linkWithMultipleExercisesStarted = linkCounter.entries.map((e) => e.key).toList();
  }

  void clear(){
    lastScrollPosition = 0;
    workout = Workout();
    textControllers.clear();
    slideableKeys.clear();
    selectedIndexes.clear();
    groupedExercises.clear();
    exercisesToRemove.clear();
    dismissedSets.clear();
    newExNames.clear();
    linkWithMultipleExercisesStarted.clear();
    scrollController = ScrollController();
    isRunning = false;
    cnConfig.setCnRunningWorkout({});
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}