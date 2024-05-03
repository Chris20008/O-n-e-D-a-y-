import 'dart:ui';
import 'package:fitness_app/screens/screen_running_workout/selector_exercises_to_update.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/widgets/animated_column.dart';
import 'package:fitness_app/widgets/banner_running_workout.dart';
import 'package:fitness_app/widgets/stopwatch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../objects/exercise.dart';
import '../../objects/workout.dart';
import '../../util/constants.dart';
import '../../widgets/bottom_menu.dart';
import '../../widgets/spotify_bar.dart';
import '../../widgets/standard_popup.dart';
import '../main_screens/screen_workouts/screen_workouts.dart';

class ScreenRunningWorkout extends StatefulWidget {
  const ScreenRunningWorkout({
    super.key,
  });

  @override
  State<ScreenRunningWorkout> createState() => _ScreenRunningWorkoutState();
}

class _ScreenRunningWorkoutState extends State<ScreenRunningWorkout>  with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.decelerate,
  );

  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  late CnStopwatchWidget cnStopwatchWidget = Provider.of<CnStopwatchWidget>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context);
  final double _iconSize = 20;
  final double _heightOfSetRow = 30;
  final double _setPadding = 5;
  Key selectorExerciseToUpdateKey = UniqueKey();
  double viewInsetsBottom = 0;
  bool isAlreadyCheckingKeyboard = false;
  bool isAlreadyCheckingKeyboardPermanent = false;
  bool showSelectorExerciseToUpdate = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;

    if(showSelectorExerciseToUpdate){
      _controller.forward();
    } else{
      _controller.reverse();
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
                      child: Center(child: Text("Finish", style: TextStyle(color: Colors.amber[800]), textScaleFactor: 1.4,)),
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
                                return Column(
                                  children: [
                                    const SizedBox(height: 20,),
                                    Container(
                                      height: 1,
                                      width: double.maxFinite - 50,
                                      color: Colors.amber[900]!.withOpacity(0.6),
                                    ),
                                    const SizedBox(height: 20,),
                                  ],
                                );
                              },
                              itemCount: cnRunningWorkout.groupedExercises.length,
                              itemBuilder: (BuildContext context, int indexExercise) {
                                Widget? child;
                                dynamic newEx = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value;
                                if(newEx is! Exercise){
                                  newEx = newEx[cnRunningWorkout.selectedIndexes[cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].key]];
                                }
                                Exercise lastEx = cnRunningWorkout.workoutTemplate.exercises.where((element) => element.name == newEx.name).first;
                                child = Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value is Exercise?
                                        Expanded(
                                            child: OverflowSafeText(
                                                newEx.name,
                                                maxLines: 1
                                            ),
                                        ):
                                        DropdownMenu<String>(
                                          initialSelection: newEx.name,
                                          onSelected: (String? value) {
                                            setState(() {
                                              final lists = cnRunningWorkout.groupedExercises.entries.toList().where((element) => element.value is List<Exercise>);
                                              final t = lists.map((element) => element.value.indexWhere((ex) {
                                                return ex.name == value;
                                              })).toList().firstWhere((element) => element >=0);
                                              cnRunningWorkout.selectedIndexes[cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].key] = t;
                                            });
                                            cnRunningWorkout.cache();
                                          },
                                          dropdownMenuEntries: cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value.map<DropdownMenuEntry<String>>((Exercise value) {
                                            return DropdownMenuEntry<String>(value: value.name, label: value.name);
                                          }).toList(),
                                        ),
                                        if(cnRunningWorkout.newExNames.contains(newEx.name))
                                          myIconButton(
                                            icon:const Icon(Icons.delete_forever),
                                            onPressed: (){
                                              cnStandardPopUp.open(
                                                  context: context,
                                                  child: const Text(
                                                    "Do you really want to delete this Exercise?",
                                                    textAlign: TextAlign.center,
                                                    textScaleFactor: 1.2,
                                                    style: TextStyle(color: Colors.white),
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
                                            if(cnRunningWorkout.controllerSeatLevel.text.isNotEmpty){
                                              newEx.seatLevel = int.tryParse(cnRunningWorkout.controllerSeatLevel.text);
                                              vibrateCancel();
                                            }
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
                                            controller: cnRunningWorkout.controllerSeatLevel,
                                            keyboardType: TextInputType.number,
                                            keyboardAppearance: Brightness.dark,
                                            maxLength: 3,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                              labelText: "Seat Level",
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
                                                const Text("-", textScaleFactor: 1,)
                                              else
                                                Text(newEx.seatLevel.toString(), textScaleFactor: 1,)
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
                                            if(cnRunningWorkout.controllerRestInSeconds.text.isNotEmpty){
                                              newEx.restInSeconds = int.tryParse(cnRunningWorkout.controllerRestInSeconds.text);
                                            }
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
                                            controller: cnRunningWorkout.controllerRestInSeconds,
                                            keyboardType: TextInputType.number,
                                            keyboardAppearance: Brightness.dark,
                                            maxLength: 3,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                              labelText: "Rest In Seconds",
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
                                                const Text("-", textScaleFactor: 1,)
                                              else if (newEx.restInSeconds < 60)
                                                Text("${newEx.restInSeconds}s", textScaleFactor: 1,)
                                              else if (newEx.restInSeconds % 60 != 0)
                                                  Text("${(newEx.restInSeconds/60).floor()}:${newEx.restInSeconds%60}m", textScaleFactor: 1,)
                                                else
                                                  Text("${(newEx.restInSeconds/60).round()}m", textScaleFactor: 1,),
                                              const SizedBox(width: 10,)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// Each Set
                                    ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: newEx.sets.length+1,
                                        itemBuilder: (BuildContext context, int indexSet) {
                                          if(indexSet == newEx.sets.length){
                                            return Row(
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
                                                        addSet(newEx, lastEx);
                                                      },
                                                      icon: const Icon(
                                                        Icons.add,
                                                        size: 20,
                                                      )
                                                  ),
                                                ),
                                              ],
                                            );
                                          }

                                          SingleSet set = lastEx.sets[indexSet];
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
                                                      width: 50,
                                                      child: Text("${indexSet + 1}", textScaleFactor: 1.2,)
                                                  ),

                                                  /// Button to copy templates data
                                                  Expanded(
                                                    flex: 3,
                                                    child: SizedBox(
                                                      height: _heightOfSetRow,
                                                      child: Row(
                                                        children: [
                                                          const Spacer(),
                                                          IgnorePointer(
                                                            ignoring: !(cnRunningWorkout.textControllers[newEx.name]![indexSet][0].text.isEmpty &&
                                                                        cnRunningWorkout.textControllers[newEx.name]![indexSet][1].text.isEmpty &&
                                                                        set.weight != null &&
                                                                        set.amount != null),
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
                                                                  cnRunningWorkout.textControllers[newEx.name]?[indexSet][0].text = set.weight!.toString();
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
                                                              child: Container(
                                                                color: Colors.transparent,
                                                                width: 100,
                                                                child: Center(
                                                                  child: OverflowSafeText(
                                                                    maxLines: 1,
                                                                    set.weight != null && set.amount != null? "${set.weight?? ""} kg x ${set.amount?? ""}" : "",
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
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ),

                                                  Expanded(
                                                    flex: 2,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        /// Weight
                                                        SizedBox(
                                                          width: 50,
                                                          height: _heightOfSetRow,
                                                          child: Center(
                                                            child: TextField(
                                                              maxLength: 3,
                                                              textAlign: TextAlign.center,
                                                              keyboardType: TextInputType.number,
                                                              keyboardAppearance: Brightness.dark,
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
                                                                  hintText: "${set.weight?? ""}",
                                                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.07))
                                                              ),
                                                              style: const TextStyle(
                                                                fontSize: 18,
                                                              ),
                                                              onChanged: (value){
                                                                value = value.trim();
                                                                if(value.isNotEmpty){
                                                                  newEx.sets[indexSet].weight = int.tryParse(value);
                                                                }
                                                                else{
                                                                  newEx.sets[indexSet].weight = null;
                                                                }
                                                                cnRunningWorkout.cache();
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 10,),
                                                        /// Amount
                                                        SizedBox(
                                                          width: 50,
                                                          height: _heightOfSetRow,
                                                          child: Center(
                                                            child: TextField(
                                                              maxLength: 3,
                                                              textAlign: TextAlign.center,
                                                              keyboardType: TextInputType.number,
                                                              keyboardAppearance: Brightness.dark,
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
                                                                  newEx.sets[indexSet].amount = int.tryParse(value);
                                                                }
                                                                else{
                                                                  newEx.sets[indexSet].amount = null;
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
                                                    dismiss(newEx, lastEx, indexSet);
                                                  }),
                                              children: [
                                                SlidableAction(
                                                  flex:10,
                                                  onPressed: (BuildContext context){
                                                    dismiss(newEx, lastEx, indexSet);
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
            const StandardPopUp(),
            AnimatedCrossFade(
              firstChild: Container(
                color: Colors.black54,
              ),
              secondChild: const SizedBox(),
              crossFadeState: showSelectorExerciseToUpdate
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
              scale: _animation,
              child: SelectorExercisesToUpdate(
                key: selectorExerciseToUpdateKey,
                workout: Workout.clone(cnRunningWorkout.workout),
                workoutTemplate: Workout.clone(cnRunningWorkout.workoutTemplate),
                onConfirm: finishWorkout,
                onCancel: (){
                  setState(() {
                    showSelectorExerciseToUpdate = false;
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void addSet(Exercise ex, Exercise lastEx){
    setState(() {
      ex.addSet();
      lastEx.addSet();
      cnRunningWorkout.textControllers[ex.name]?.add([TextEditingController(), TextEditingController()]);
      cnRunningWorkout.slideableKeys[ex.name]?.add(UniqueKey());
      cnRunningWorkout.scrollController.jumpTo(cnRunningWorkout.scrollController.position.pixels+_heightOfSetRow + _setPadding*2);
    });
  }

  void dismiss(Exercise ex, Exercise lastEx, int index){
    setState(() {
      ex.sets.removeAt(index);
      lastEx.sets.removeAt(index);
      cnRunningWorkout.textControllers[ex.name]?.removeAt(index);
      cnRunningWorkout.slideableKeys[ex.name]?.removeAt(index);
    });
  }

  void openPopUpFinishWorkout(){
    cnStandardPopUp.open(
      context: context,
      showCancel: false,
      confirmText: "Finish",
      onConfirm: finishWorkout,
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          const Text(
              "Finish Workout?",
            textAlign: TextAlign.center,
            textScaleFactor: 1.2,
            style: TextStyle(color: Colors.white),
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
              child: const Text(
                  "STOP Workout"
              ),
            ),
          ),
          Container(
            height: 0.5,
            width: double.maxFinite,
            color: Colors.grey[700]!.withOpacity(0.5),
          ),
          SizedBox(
            height: 40,
            width: double.maxFinite,
            child: ElevatedButton(
                onPressed: () {
                  cnStandardPopUp.clear();
                  Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime), (){
                    setState(() {
                      showSelectorExerciseToUpdate = true;
                      selectorExerciseToUpdateKey = UniqueKey();
                    });
                  });
                },
                style: ButtonStyle(
                    shadowColor: MaterialStateProperty.all(Colors.transparent),
                    surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
                ),
                child: const Text(
                  "Finish And Update Template"
                ),
            ),
          ),
        ],
    ),
    );
  }

  void stopWorkout({int? time}){
    time = time?? cnStandardPopUp.animationTime;
    if(cnStandardPopUp.isVisible){
      cnStandardPopUp.clear();
    }
    Future.delayed(Duration(milliseconds: time), (){
      cnRunningWorkout.isVisible = false;
      cnRunningWorkout.isRunning = false;
      cnHomepage.refresh();
      cnWorkouts.refresh();
      Future.delayed(const Duration(milliseconds: 50), (){
        Navigator.of(context).pop();
        /// delayed that the pop context is finished, if to short, the user
        /// will se a blank page which is not wanted
        Future.delayed(const Duration(milliseconds: 500), (){
          cnRunningWorkout.clear();
        });
      });
    });
  }

  void finishWorkout(){
    int time;
    if(cnStandardPopUp.isVisible){
      cnStandardPopUp.clear();
      time = cnStandardPopUp.animationTime;
    } else {
      time = 0;
    }
    /// delay that the popup is closed
    Future.delayed(Duration(milliseconds: time), (){
      cnRunningWorkout.workout.refreshDate();
      cnRunningWorkout.removeNotSelectedExercises();
      cnRunningWorkout.workout.removeEmptyExercises();
      if(cnRunningWorkout.workout.exercises.isNotEmpty){
        cnRunningWorkout.workout.saveToDatabase();
        cnWorkouts.refreshAllWorkouts();
      }
      stopWorkout(time: 0);
    });
  }
}

class CnRunningWorkout extends ChangeNotifier {
  Workout workout = Workout();
  Workout workoutTemplate = Workout();
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

  CnRunningWorkout(BuildContext context){
    cnConfig = Provider.of<CnConfig>(context, listen: false);
  }
  
  void addExercise(Exercise ex){
    // print("SCROLL CONTROLLER POSITION 1");
    // print(scrollController.position.pixels);
    // print(scrollController.position.maxScrollExtent);
    workoutTemplate.exercises.add(Exercise.clone(ex));
    workout.exercises.add(ex);
    newExNames.add(ex.name);
    slideableKeys[ex.name] = ex.generateKeyForEachSet();
    groupedExercises[ex.name] = ex;
    textControllers[ex.name] = ex.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList();
    cache();
    refresh();
    // print("SCROLL CONTROLLER POSITION 2");
    // print(scrollController.position.pixels);
    // print(scrollController.position.maxScrollExtent);
    // Future.delayed(const Duration(milliseconds: 800), (){
    //   print("SCROLL CONTROLLER POSITION 3");
    //   print(scrollController.position.pixels);
    //   print(scrollController.position.maxScrollExtent);
    //   scrollController.animateTo(
    //       scrollController.position.maxScrollExtent,
    //       duration: const Duration(milliseconds: 1000),
    //       curve: Curves.easeInOut
    //   );
    // });
  }

  void deleteExercise(Exercise ex){
    workoutTemplate.exercises.removeWhere((e) => e.name == ex.name);
    workout.exercises.removeWhere((e) => e.name == ex.name);
    newExNames.removeWhere((e) => e == ex.name);
    slideableKeys.remove(ex.name);
    groupedExercises.remove(ex.name);
    refresh();
  }

  void initCachedData(Map data){
    print("Received Cached Data");
    print(data);
    if(
      data.containsKey("workout") &&
      data.containsKey("workoutTemplate") &&
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
      workoutTemplate = Workout().fromMap(data["workoutTemplate"]) ?? Workout();
      initSlideableKeys();
      initGroupedExercises();
      initTextControllers();
      setTextControllerValues(data["testControllerValues"]);
      // if(isVisible && isRunning){
      //   Navigator.push(
      //       context,
      //       CupertinoPageRoute(
      //           builder: (context) => const ScreenRunningWorkout()
      //       ));
      // }
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
  }

  void reopenRunningWorkout(BuildContext context){
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => const ScreenRunningWorkout()
        ));
    isVisible = true;
  }
  
  void removeNotSelectedExercises(){
    for (MapEntry entry in List.from(groupedExercises.entries)){
      if(entry.value is Exercise) continue;
      groupedExercises[entry.key] = groupedExercises[entry.key][selectedIndexes[entry.key]];
    }
    workout.exercises = List.from(groupedExercises.entries.map((entry) => entry.value));
  }

  void setWorkoutTemplate(Workout w){
    workoutTemplate = w;
    workout = Workout.copy(workoutTemplate);
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

  Future<void> cache()async{
    Map data = {
      "workout": workout.asMap(),
      "workoutTemplate": workoutTemplate.asMap(),
      "isRunning": isRunning,
      "isVisible": isVisible,
      "testControllerValues": getTextControllerValues(),
      "selectedIndexes": selectedIndexes,
      "newExNames": newExNames
    };
    cnConfig.config.cnRunningWorkout = data;
    await cnConfig.config.save();
  }

  // Map<String, List<List<dynamic>>> getTextControllerValues(){
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

  void clear(){
    workout = Workout();
    textControllers.clear();
    slideableKeys.clear();
    selectedIndexes.clear();
    groupedExercises.clear();
    newExNames.clear();
    scrollController = ScrollController();
    isRunning = false;
    cnConfig.setCnRunningWorkout({});
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}