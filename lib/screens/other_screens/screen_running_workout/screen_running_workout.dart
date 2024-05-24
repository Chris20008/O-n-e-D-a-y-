import 'dart:ui';
import 'package:fitness_app/screens/other_screens/screen_running_workout/selector_exercises_per_link.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/selector_exercises_to_update.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/stopwatch.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/widgets/banner_running_workout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

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

class ScreenRunningWorkout extends StatefulWidget {
  const ScreenRunningWorkout({
    super.key,
  });

  @override
  State<ScreenRunningWorkout> createState() => _ScreenRunningWorkoutState();
}

class _ScreenRunningWorkoutState extends State<ScreenRunningWorkout>  with TickerProviderStateMixin {
  late final AnimationController _controllerSelectorExUpdate = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  late final Animation<double> _animationSelectorExUpdate = CurvedAnimation(
    parent: _controllerSelectorExUpdate,
    curve: Curves.decelerate,
      // curve: Curves.easeOutBack
  );
  late final AnimationController _controllerSelectorExPerLink = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  late final Animation<double> _animationSelectorExPerLink = CurvedAnimation(
    parent: _controllerSelectorExPerLink,
    curve: Curves.decelerate,
      // curve: Curves.easeOutBack
  );

  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  late CnStopwatchWidget cnStopwatchWidget = Provider.of<CnStopwatchWidget>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context);
  /// listen to bottomMenu for height changes
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context);
  late CnConfig cnConfig  = Provider.of<CnConfig>(context, listen: false);
  final double _iconSize = 20;
  final double _heightOfSetRow = 30;
  final double _widthOfTextField = 55;
  final double _setPadding = 5;
  Key selectorExerciseToUpdateKey = UniqueKey();
  Key selectorExercisePerLinkKey = UniqueKey();
  double viewInsetsBottom = 0;
  bool isAlreadyCheckingKeyboard = false;
  bool isAlreadyCheckingKeyboardPermanent = false;
  bool showSelectorExerciseToUpdate = false;
  bool showSelectorExercisePerLink = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;

    if(showSelectorExerciseToUpdate){
      _controllerSelectorExUpdate.forward();
    } else{
      _controllerSelectorExUpdate.reverse();
    }
    if(showSelectorExercisePerLink){
      _controllerSelectorExPerLink.forward();
    } else{
      _controllerSelectorExPerLink.reverse();
    }

    return PopScope(
      onPopInvoked: (doPop){
        if(cnRunningWorkout.isVisible){
          cnRunningWorkout.isVisible = false;
          cnWorkouts.refresh();
          cnRunningWorkout.cache();
        }
        if(cnStandardPopUp.isVisible){
          cnStandardPopUp.clear();
        }
        if(MediaQuery.of(context).viewInsets.bottom > 0){
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          alignment: Alignment.center,
          children: [
            Scaffold(
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
                    Padding(
                      padding: const EdgeInsets.only(top:0,bottom: 0,left: 20, right: 20),
                      child: Column(
                        children: [

                          Expanded(

                            /// Each EXERCISE
                            child: ListView.separated(
                              controller: cnRunningWorkout.scrollController,
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              separatorBuilder: (BuildContext context, int index) {
                                return mySeparator();
                              },
                              itemCount: cnRunningWorkout.groupedExercises.length,
                              itemBuilder: (BuildContext context, int indexExercise) {
                                Widget? child;
                                dynamic newEx = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value;
                                if(newEx is! Exercise){
                                  newEx = newEx[cnRunningWorkout.selectedIndexes[cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].key]];
                                }
                                Exercise templateEx = cnRunningWorkout.workoutTemplateModifiable.exercises.where((element) => element.name == newEx.name).first;
                                child = Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value is Exercise?
                                        Expanded(
                                            child: OverflowSafeText(
                                              newEx.name,
                                              maxLines: 1,
                                              style: const TextStyle(color: Colors.white, fontSize: 20),
                                            ),
                                        ):
                                        Expanded(
                                          child: PullDownButton(
                                            buttonAnchor: PullDownMenuAnchor.start,
                                            routeTheme: const PullDownMenuRouteTheme(backgroundColor: CupertinoColors.secondaryLabel),
                                            itemBuilder: (context) {
                                              final children = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value.map<PullDownMenuItem>((Exercise value) {
                                                return PullDownMenuItem.selectable(
                                                  title: value.name,
                                                  selected: newEx.name == value.name,
                                                  onTap: () {
                                                    HapticFeedback.selectionClick();
                                                    Future.delayed(const Duration(milliseconds: 200), (){
                                                      setState(() {
                                                        final lists = cnRunningWorkout.groupedExercises.entries.toList().where((element) => element.value is List<Exercise>);
                                                        final t = lists.map((element) => element.value.indexWhere((ex) {
                                                          return ex.name == value.name;
                                                        })).toList().firstWhere((element) => element >=0);
                                                        cnRunningWorkout.selectedIndexes[cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].key] = t;
                                                      });
                                                      cnRunningWorkout.cache();
                                                    });
                                                  },
                                                );
                                              }).toList();
                                              return children;
                                              // return [
                                              //   PullDownMenuItem(
                                              //     title: AppLocalizations.of(context)!.settingsQuestion,
                                              //     onTap: () {
                                              //       HapticFeedback.selectionClick();
                                              //       Future.delayed(const Duration(milliseconds: 200), (){
                                              //         sendMail(subject: "Question");
                                              //       });
                                              //     },
                                              //   ),
                                              // ];
                                            },
                                            buttonBuilder: (context, showMenu) => CupertinoButton(
                                                onPressed: (){
                                                  HapticFeedback.selectionClick();
                                                  showMenu();
                                                },
                                                padding: EdgeInsets.zero,
                                                child: Row(
                                                  children: [
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                          maxWidth: MediaQuery.of(context).size.width-80
                                                      ),
                                                      child: OverflowSafeText(
                                                          newEx.name,
                                                          style: const TextStyle(color: Colors.white, fontSize: 20),
                                                          maxLines: 1
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10,),
                                                    const Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: 15,
                                                      color: Colors.white,
                                                    )
                                                  ],
                                                )
                                            ),
                                          )
                                        ),
                                        // Expanded(
                                        //   child: DropdownMenu<String>(
                                        //     initialSelection: newEx.name,
                                        //     onSelected: (String? value) {
                                        //       setState(() {
                                        //         final lists = cnRunningWorkout.groupedExercises.entries.toList().where((element) => element.value is List<Exercise>);
                                        //         final t = lists.map((element) => element.value.indexWhere((ex) {
                                        //           return ex.name == value;
                                        //         })).toList().firstWhere((element) => element >=0);
                                        //         cnRunningWorkout.selectedIndexes[cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].key] = t;
                                        //       });
                                        //       cnRunningWorkout.cache();
                                        //     },
                                        //     dropdownMenuEntries: cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value.map<DropdownMenuEntry<String>>((Exercise value) {
                                        //       return DropdownMenuEntry<String>(value: value.name, label: value.name);
                                        //     }).toList(),
                                        //   ),
                                        // ),
                                        if(cnRunningWorkout.newExNames.contains(newEx.name))
                                          myIconButton(
                                            icon:const Icon(Icons.delete_forever),
                                            onPressed: (){
                                              cnStandardPopUp.open(
                                                  context: context,
                                                  confirmText: AppLocalizations.of(context)!.yes,
                                                  child: Text(
                                                    AppLocalizations.of(context)!.runningWorkoutDeleteExercise,
                                                    textAlign: TextAlign.center,
                                                    textScaler: const TextScaler.linear(1.2),
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                  onConfirm: (){
                                                    cnRunningWorkout.deleteExercise(newEx);
                                                  },
                                                  onCancel: (){},
                                                  color: const Color(0xff2d2d2d)
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    GestureDetector(
                                      onTap: (){
                                        cnStandardPopUp.open(
                                          context: context,
                                          onConfirm: (){
                                            newEx.seatLevel = int.tryParse(cnRunningWorkout.controllerSeatLevel.text);
                                            vibrateCancel();
                                            cnRunningWorkout.controllerSeatLevel.clear();
                                            cnRunningWorkout.refresh();
                                            Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime), (){
                                              FocusScope.of(context).unfocus();
                                            });
                                          },
                                          onCancel: (){
                                            cnRunningWorkout.controllerSeatLevel.clear();
                                            Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime), (){
                                              FocusScope.of(context).unfocus();
                                            });
                                          },
                                          child: TextField(
                                            keyboardAppearance: Brightness.dark,
                                            controller: cnRunningWorkout.controllerSeatLevel,
                                            keyboardType: TextInputType.number,
                                            maxLength: 3,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                              labelText: AppLocalizations.of(context)!.seatLevel,
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
                                      },
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
                                                const Text("-", textScaler: TextScaler.linear(1),)
                                              else
                                                Text(newEx.seatLevel.toString(), textScaler: const TextScaler.linear(1),)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        cnStandardPopUp.open(
                                          context: context,
                                          onConfirm: (){
                                            newEx.restInSeconds = int.tryParse(cnRunningWorkout.controllerRestInSeconds.text)?? 0;
                                            vibrateCancel();
                                            cnRunningWorkout.controllerRestInSeconds.clear();
                                            cnRunningWorkout.refresh();
                                            Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime), (){
                                              FocusScope.of(context).unfocus();
                                            });
                                          },
                                          onCancel: (){
                                            cnRunningWorkout.controllerRestInSeconds.clear();
                                            Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime), (){
                                              FocusScope.of(context).unfocus();
                                            });
                                          },
                                          child: TextField(
                                            keyboardAppearance: Brightness.dark,
                                            controller: cnRunningWorkout.controllerRestInSeconds,
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
                                      },
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          width: 100,
                                          height: 30,
                                          color: Colors.transparent,
                                          child: Row(
                                            children: [
                                              Icon(Icons.timer, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
                                              const SizedBox(width: 2,),
                                              if (newEx.restInSeconds == 0)
                                                const Text("-", textScaler: TextScaler.linear(1),)
                                              else if (newEx.restInSeconds < 60)
                                                Text("${newEx.restInSeconds}s", textScaler: const TextScaler.linear(1),)
                                              else if (newEx.restInSeconds % 60 != 0)
                                                  Text("${(newEx.restInSeconds/60).floor()}:${newEx.restInSeconds%60}m", textScaler: const TextScaler.linear(1),)
                                                else
                                                  Text("${(newEx.restInSeconds/60).round()}m", textScaler: const TextScaler.linear(1),),
                                              const SizedBox(width: 10,)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// Each Set Reorderable
                                    Column(
                                      children: [
                                        ReorderableListView.builder(
                                            scrollController: ScrollController(),
                                            physics: const BouncingScrollPhysics(),
                                            padding: const EdgeInsets.all(0),
                                            shrinkWrap: true,
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
                                                final item = templateEx.sets.removeAt(oldIndex);// cnNewWorkout.exercisesAndLinks.removeAt(oldIndex);
                                                templateEx.sets.insert(newIndex, item);
                                                final item2 = newEx.sets.removeAt(oldIndex);// cnNewWorkout.exercisesAndLinks.removeAt(oldIndex);
                                                newEx.sets.insert(newIndex, item2);
                                                final weightAndAmount = cnRunningWorkout.textControllers[newEx.name]?.removeAt(oldIndex);
                                                cnRunningWorkout.textControllers[newEx.name]?.insert(newIndex, weightAndAmount!);
                                              });
                                              cnRunningWorkout.cache();
                                            },
                                            itemCount: newEx.sets.length,
                                            itemBuilder: (BuildContext context, int indexSet) {
                                              SingleSet set = templateEx.sets[indexSet];
                                              Widget? child;
                                              child = Padding(
                                                // padding: EdgeInsets.zero,
                                                padding: EdgeInsets.only(bottom: _setPadding, top: _setPadding),
                                                child: SizedBox(
                                                  width: double.maxFinite,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [

                                                      /// Set
                                                      SizedBox(
                                                          width: _widthOfTextField,
                                                          child: Text("${indexSet + 1}", textScaler: const TextScaler.linear(1.2),)
                                                      ),

                                                      /// Button to copy templates data
                                                      getButtonInsertTemplatesData(set: set, newEx: newEx, indexSet: indexSet),

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
                                                                  maxLength: (cnRunningWorkout.textControllers[newEx.name]?[indexSet][0].text.contains(".")?? true)? 6 : 4,
                                                                  textAlign: TextAlign.center,
                                                                  keyboardType: const TextInputType.numberWithOptions(
                                                                      decimal: true,
                                                                      signed: false
                                                                  ),
                                                                  controller: cnRunningWorkout.textControllers[newEx.name]?[indexSet][0],
                                                                  onTap: (){
                                                                    cnRunningWorkout.textControllers[newEx.name]?[indexSet][0].selection =  TextSelection(baseOffset: 0, extentOffset: cnRunningWorkout.textControllers[newEx.name]![indexSet][0].value.text.length);
                                                                  },
                                                                  decoration: InputDecoration(
                                                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                                      // isDense: true,
                                                                      counterText: "",
                                                                      contentPadding: const EdgeInsets.symmetric(horizontal: 0 ,vertical: 0.0),
                                                                      hintFadeDuration: const Duration(milliseconds: 200),
                                                                      hintText: "${set.weight.toString().endsWith(".0")? set.weight?.toInt() : set.weight?? ""}",
                                                                      hintStyle: getTextStyleForTextField((set.weight?? "").toString(), color: Colors.white.withOpacity(0.15))
                                                                  ),
                                                                  style: getTextStyleForTextField(cnRunningWorkout.textControllers[newEx.name]![indexSet][0].text),
                                                                  onChanged: (value){
                                                                    value = value.trim();
                                                                    if(value.isNotEmpty){
                                                                      value = validateDoubleTextInput(value);
                                                                      final newValue = double.tryParse(value);
                                                                      newEx.sets[indexSet].weight = newValue;
                                                                      if(newValue == null){
                                                                        cnRunningWorkout.textControllers[newEx.name]?[indexSet][0].clear();
                                                                      } else{
                                                                        cnRunningWorkout.textControllers[newEx.name]?[indexSet][0].text = value;
                                                                      }
                                                                    }
                                                                    else{
                                                                      newEx.sets[indexSet].weight = null;
                                                                    }
                                                                    cnRunningWorkout.cache();
                                                                    setState(() => {});
                                                                  },
                                                                ),
                                                              ),
                                                            ),

                                                            const SizedBox(width: 10,),

                                                            /// Amount
                                                            SizedBox(
                                                              width: _widthOfTextField,
                                                              height: _heightOfSetRow,
                                                              child: Center(
                                                                child: TextField(
                                                                  keyboardAppearance: Brightness.dark,
                                                                  maxLength: 3,
                                                                  textAlign: TextAlign.center,
                                                                  keyboardType: const TextInputType.numberWithOptions(
                                                                      decimal: false,
                                                                      signed: false
                                                                  ),
                                                                  controller: cnRunningWorkout.textControllers[newEx.name]?[indexSet][1],
                                                                  onTap: (){
                                                                    cnRunningWorkout.textControllers[newEx.name]?[indexSet][1].selection =  TextSelection(baseOffset: 0, extentOffset: cnRunningWorkout.textControllers[newEx.name]![indexSet][1].value.text.length);
                                                                  },
                                                                  decoration: InputDecoration(
                                                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                                      // isDense: true,
                                                                      counterText: "",
                                                                      contentPadding: const EdgeInsets.symmetric(horizontal: 0 ,vertical: 0.0),
                                                                      hintText: "${set.amount?? ""}",
                                                                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.07))
                                                                  ),
                                                                  style: const TextStyle(
                                                                    fontSize: 18,
                                                                  ),
                                                                  onChanged: (value){
                                                                    value = value.trim();
                                                                    if(value.isNotEmpty){
                                                                      final newValue = int.tryParse(value);
                                                                      newEx.sets[indexSet].amount = newValue;
                                                                      if(newValue == null){
                                                                        cnRunningWorkout.textControllers[newEx.name]?[indexSet][1].clear();
                                                                      }
                                                                      if(value.length == 1){
                                                                        setState(() => {});
                                                                      }
                                                                    }
                                                                    else{
                                                                      newEx.sets[indexSet].amount = null;
                                                                      setState(() => {});
                                                                    }
                                                                    cnRunningWorkout.cache();
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
                                                key: cnRunningWorkout.slideableKeys[newEx.name]![indexSet],
                                                // key: UniqueKey(),
                                                startActionPane: ActionPane(
                                                  motion: const ScrollMotion(),
                                                  dismissible: DismissiblePane(
                                                      onDismissed: () {
                                                        dismiss(newEx, templateEx, indexSet);
                                                      }),
                                                  children: [
                                                    SlidableAction(
                                                      flex:10,
                                                      onPressed: (BuildContext context){
                                                        dismiss(newEx, templateEx, indexSet);
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
                                        Row(
                                          children: [
                                            Expanded(
                                              child: IconButton(
                                                  alignment: Alignment.center,
                                                  color: Colors.amber[800],
                                                  style: ButtonStyle(
                                                      backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
                                                      shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(20)))
                                                  ),
                                                  onPressed: () {
                                                    addSet(newEx, templateEx);
                                                  },
                                                  icon: const Icon(
                                                    Icons.add,
                                                    size: 20,
                                                  )
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                );

                                /// Top Spacer
                                if (indexExercise == 0){
                                  child = Column(
                                    children: [
                                      const SizedBox(height: 80,),
                                      child
                                    ],
                                  );
                                }

                                /// Bottom Spacer
                                if (indexExercise == cnRunningWorkout.groupedExercises.length-1){
                                  child = Column(
                                    children: [
                                      child,
                                      AnimatedContainer(
                                          duration: const Duration(milliseconds: 250),
                                          height: cnStopwatchWidget.isOpened
                                              ? 70 + cnStopwatchWidget.heightOfTimer
                                              : 70
                                      ),
                                    ],
                                  );
                                }

                                return child;
                              },
                            ),
                          ),
                        ],
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
            AnimatedCrossFade(
              firstChild: Container(
                color: Colors.black54,
              ),
              secondChild: const SizedBox(),
              crossFadeState: showSelectorExerciseToUpdate || showSelectorExercisePerLink
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 200),
              layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                      key: bottomChildKey,
                      child: bottomChild,
                    ),
                    Positioned(
                      key: topChildKey,
                      child: topChild,
                    ),
                  ],
                );
              },
            ),
            ScaleTransition(
              scale: _animationSelectorExUpdate,
              child: SelectorExercisesToUpdate(
                key: selectorExerciseToUpdateKey,
                workout: Workout.clone(cnRunningWorkout.workout),
                workoutTemplate: Workout.clone(cnRunningWorkout.workoutTemplateNotModifiable),
                onConfirm: finishWorkout,
                onCancel: (){
                  setState(() {
                    showSelectorExerciseToUpdate = false;
                  });
                },
              ),
            ),
            ScaleTransition(
              scale: _animationSelectorExPerLink,
              child: SelectorExercisesPerLink(
                key: selectorExercisePerLinkKey,
                groupedExercises: cnRunningWorkout.groupedExercises,
                relevantLinkNames: cnRunningWorkout.linkWithMultipleExercisesStarted,
                onConfirm: confirmSelectorExPerLink,
                onCancel: (){
                  setState(() {
                    showSelectorExercisePerLink = false;
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getButtonInsertTemplatesData({
    required SingleSet set,
    required Exercise newEx,
    required int indexSet
  }){
    return Expanded(
        flex: 2,
        child: IgnorePointer(
          ignoring: !(cnRunningWorkout.textControllers[newEx.name]![indexSet][0].text.isEmpty &&
              cnRunningWorkout.textControllers[newEx.name]![indexSet][1].text.isEmpty &&
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
                if(set.weight?.toString() != null &&
                    set.amount?.toString() != null &&
                    cnRunningWorkout.textControllers[newEx.name]![indexSet][0].text.isEmpty &&
                    cnRunningWorkout.textControllers[newEx.name]![indexSet][1].text.isEmpty
                ){
                  vibrateConfirm();
                  cnRunningWorkout.textControllers[newEx.name]?[indexSet][0].text = (set.weight.toString().endsWith(".0")? set.weight?.toInt().toString() : set.weight.toString())?? "";
                  newEx.sets[indexSet].weight = set.weight;
                  cnRunningWorkout.textControllers[newEx.name]?[indexSet][1].text = set.amount!.toString();
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
                  set.weight != null && set.amount != null? "${set.weight.toString().endsWith(".0")? set.weight?.toInt() : set.weight?? ""} kg x ${set.amount?? ""}" : "",
                  style: TextStyle(
                      color: (cnRunningWorkout.textControllers[newEx.name]![indexSet][0].text.isEmpty &&
                          cnRunningWorkout.textControllers[newEx.name]![indexSet][1].text.isEmpty)
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
    setState(() {
      showSelectorExercisePerLink = false;
      cnRunningWorkout.exercisesToRemove = exToRemove?? [];
    });
    if(canUpdateTemplate()){
      // cnStandardPopUp.clear();
      Future.delayed(Duration(milliseconds: delay?? cnStandardPopUp.animationTime), (){
        setState(() {
          showSelectorExerciseToUpdate = true;
          selectorExerciseToUpdateKey = UniqueKey();
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
    print("AUTOMATIC BACKUPS: ${cnConfig.automaticBackups}");
    final bool canFinish = hasStartedWorkout();
    cnStandardPopUp.open(
      context: context,
      showCancel: false,
      confirmText: AppLocalizations.of(context)!.finish,
      canConfirm: canFinish,
      confirmTextStyle: canFinish? null : TextStyle(color: Colors.grey.withOpacity(0.2)),
      onConfirm: () {
        // cnStandardPopUp.clear(); // leads to double vibration
        Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime), (){
          setState(() {
            cnRunningWorkout.checkMultipleExercisesPerLink();
            if(cnRunningWorkout.linkWithMultipleExercisesStarted.isNotEmpty){
              showSelectorExercisePerLink = true;
              selectorExercisePerLinkKey = UniqueKey();
            } else{
              confirmSelectorExPerLink(delay: 0);
            }
          });
        });
      },
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.runningWorkoutFinishWorkout,
            textAlign: TextAlign.center,
            textScaler: const TextScaler.linear(1.2),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20,),
          Container(
            height: 0.5,
            width: double.maxFinite,
            color: Colors.grey[700]!.withOpacity(0.5),
          ),
          SizedBox(
            height: 40,
            width: double.maxFinite,
            child: ElevatedButton(
              onPressed: () => stopWorkout(),
              style: ButtonStyle(
                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                  surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
              ),
              child: Text(
                AppLocalizations.of(context)!.runningWorkoutStopWorkout,
                style: TextStyle(color: Colors.red.withOpacity(0.6)),
              ),
            ),
          ),
        ],
      ),
    );
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
        });
      });
    });
  }

  Future finishWorkout() async{
    int time;
    // final createBackup = null;
    final createAutomaticBackup = cnConfig.automaticBackups;
    if(createAutomaticBackup == null){
      return;
    }
    if(cnStandardPopUp.isVisible){
      cnStandardPopUp.clear();
      time = cnStandardPopUp.animationTime;
    } else {
      time = 0;
    }
    /// delay that the popup is closed
    await Future.delayed(Duration(milliseconds: time), ()async{
      cnRunningWorkout.workout.refreshDate();
      cnRunningWorkout.removeNotRelevantExercises();
      cnRunningWorkout.workout.removeEmptyExercises();
      if(cnRunningWorkout.workout.exercises.isNotEmpty){
        cnRunningWorkout.workout.saveToDatabase();
        cnWorkouts.refreshAllWorkouts();
      }
      await stopWorkout(time: 0);
      print("CREATE AUTOMATIC BACKUP?: ${cnConfig.automaticBackups}");
      if(cnConfig.automaticBackups){
        saveBackup(withCloud: cnConfig.syncWithCloud ?? false);
      }
    });
  }
}

class CnRunningWorkout extends ChangeNotifier {
  Workout workout = Workout();
  Workout workoutTemplateModifiable = Workout();
  Workout workoutTemplateNotModifiable = Workout();
  bool isRunning = false;
  bool isVisible = false;
  ScrollController scrollController = ScrollController();
  TextEditingController controllerRestInSeconds = TextEditingController();
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
  /// Contains all Excercises - linked and non linked ones - as a Map
  /// linked exercises are saved as another Map with key = linkName
  /// non linked Excercises are saved as the exercise itself with the ex.name as the key
  Map groupedExercises = {};
  /// Contains for each linked exercise the currently selected index for getting the right one
  /// from the groupedExercises Map
  Map<String, int> selectedIndexes = {};
  late CnConfig cnConfig;
  List<String> linkWithMultipleExercisesStarted = [];
  List<String> exercisesToRemove = [];
  List<DismissedSingleSet> dismissedSets = [];

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

  void reopenRunningWorkout(BuildContext context){
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => const ScreenRunningWorkout()
        ));
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
    workout.resetAllExercisesSets();
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