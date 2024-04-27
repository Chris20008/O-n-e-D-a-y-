import 'dart:ui';

import 'package:fitness_app/screens/screen_workouts/screen_workouts.dart';
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

class ScreenRunningWorkout extends StatefulWidget {
  const ScreenRunningWorkout({
    super.key,
  });

  @override
  State<ScreenRunningWorkout> createState() => _ScreenRunningWorkoutState();
}

class _ScreenRunningWorkoutState extends State<ScreenRunningWorkout> {
  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  late CnStopwatchWidget cnStopwatchWidget = Provider.of<CnStopwatchWidget>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context);
  final double _iconSize = 13;
  final double _heightOfSetRow = 50;
  final double _setPadding = 5;
  double viewInsetsBottom = 0;
  bool isAlreadyCheckingKeyboard = false;
  bool isAlreadyCheckingKeyboardPermanent = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), (){
      print("-------------- REFRESH WORKOUTS --------------");
      // cnWorkouts.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      onPopInvoked: (doPop){
        if(cnRunningWorkout.isVisible){
          cnRunningWorkout.isVisible = false;
          cnWorkouts.refresh();
          cnRunningWorkout.cache();
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
                              // key: listViewKey,
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
                                Exercise lastEx = cnRunningWorkout.lastWorkout.exercises.where((element) => element.name == newEx.name).first;
                                child = Column(
                                  children: [
                                    Align(
                                        alignment: Alignment.centerLeft,
                                        child: cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value is Exercise?
                                        ExerciseNameText(newEx.name):
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
                                        )
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(Icons.airline_seat_recline_normal, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
                                        const SizedBox(width: 2,),
                                        if (newEx.seatLevel == null)
                                          const Text("-", textScaleFactor: 0.9,)
                                        else
                                          Text(newEx.seatLevel.toString(), textScaleFactor: 0.9,)
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.timer, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
                                        const SizedBox(width: 2,),
                                        if (newEx.restInSeconds == 0)
                                          const Text("-", textScaleFactor: 0.9,)
                                        else if (newEx.restInSeconds < 60)
                                          Text("${newEx.restInSeconds}s", textScaleFactor: 0.9,)
                                        else if (newEx.restInSeconds % 60 != 0)
                                            Text("${(newEx.restInSeconds/60).floor()}:${newEx.restInSeconds%60}m", textScaleFactor: 0.9,)
                                          else
                                            Text("${(newEx.restInSeconds/60).round()}m", textScaleFactor: 0.9,),
                                        const SizedBox(width: 10,)
                                      ],
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
                                            padding: EdgeInsets.only(bottom: _setPadding, top: _setPadding),
                                            child: SizedBox(
                                              width: double.maxFinite,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  SizedBox(width: 80,child: Text("${indexSet + 1}", textScaleFactor: 1.2,)),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        Expanded(
                                                          child: GestureDetector(
                                                            onTap: (){
                                                              if(set.weight?.toString() != null){
                                                                cnRunningWorkout.textControllers[newEx.name]?[indexSet][0].text = set.weight!.toString();
                                                                newEx.sets[indexSet].weight = set.weight;
                                                                cnRunningWorkout.refresh();
                                                                cnRunningWorkout.cache();
                                                              }
                                                            },
                                                            child: Container(
                                                              height: _heightOfSetRow,
                                                              color: Colors.transparent,
                                                              child: Center(child: Text("${set.weight?? ""}", textScaleFactor: 1.2,)),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 50,
                                                          height: _heightOfSetRow,
                                                          /// Input weight
                                                          child: Center(
                                                            child: TextField(
                                                              maxLength: 3,
                                                              textAlignVertical: TextAlignVertical.center,
                                                              keyboardType: TextInputType.number,
                                                              controller: cnRunningWorkout.textControllers[newEx.name]?[indexSet][0],
                                                              decoration: InputDecoration(
                                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                                isDense: true,
                                                                counterText: "",
                                                              ),
                                                              onChanged: (value){
                                                                value = value.trim();
                                                                if(value.isNotEmpty){
                                                                  newEx.sets[indexSet].weight = int.parse(value);
                                                                }
                                                                else{
                                                                  newEx.sets[indexSet].weight = null;
                                                                }
                                                                cnRunningWorkout.cache();
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const Spacer(flex: 1),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        Expanded(
                                                          child: GestureDetector(
                                                            onTap: (){
                                                              if(set.amount?.toString() != null){
                                                                cnRunningWorkout.textControllers[newEx.name]?[indexSet][1].text = set.amount!.toString();
                                                                newEx.sets[indexSet].amount = set.amount;
                                                                cnRunningWorkout.refresh();
                                                                cnRunningWorkout.cache();
                                                              }
                                                            },
                                                            child: Container(
                                                              height: _heightOfSetRow,
                                                              color: Colors.transparent,
                                                              child: Center(child: Text("${set.amount?? ""}", textScaleFactor: 1.2,)),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 50,
                                                          height: _heightOfSetRow,

                                                          /// Input amount
                                                          child: Center(
                                                            child: TextField(
                                                              maxLength: 3,
                                                              textAlignVertical: TextAlignVertical.center,
                                                              keyboardType: TextInputType.number,
                                                              controller: cnRunningWorkout.textControllers[newEx.name]?[indexSet][1],
                                                              decoration: InputDecoration(
                                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                                isDense: true,
                                                                counterText: "",
                                                              ),
                                                              onChanged: (value){
                                                                value = value.trim();
                                                                if(value.isNotEmpty){
                                                                  newEx.sets[indexSet].amount = int.parse(value);
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
                                                  const SizedBox(width: 25,)
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
                                                  backgroundColor: Color(0xFFA12D2C),
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
                    const Hero(
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
                    )
                    // if(viewInsetsBottom < 50)
                    //   const AnimatedColumn(),
                  ],
                ),
              ),
            ),
            const StandardPopUp(),
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
                onPressed: () => finishWorkout(doUpdate: true),
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

  void stopWorkout(){
    cnStandardPopUp.clear();
    Future.delayed(const Duration(milliseconds: 500), (){
      cnRunningWorkout.isVisible = false;
      cnRunningWorkout.clear();
      cnHomepage.refresh();
      cnWorkouts.refresh();
      Future.delayed(const Duration(milliseconds: 100), (){
        Navigator.of(context).pop();
      });
    });
  }

  void finishWorkout({bool doUpdate = false}){
    cnStandardPopUp.clear();
    /// delay that the popup is closed
    Future.delayed(const Duration(milliseconds: 500), (){
      cnRunningWorkout.workout.refreshDate();
      cnRunningWorkout.removeNotSelectedExercises();
      cnRunningWorkout.workout.removeEmptyExercises();
      if(cnRunningWorkout.workout.exercises.isNotEmpty){
        cnRunningWorkout.workout.saveToDatabase();
        if(doUpdate){
          cnRunningWorkout.workout.updateTemplate();
        }
        cnWorkouts.refreshAllWorkouts();
      }
      cnRunningWorkout.isVisible = false;
      cnRunningWorkout.clear();
      cnHomepage.refresh();
      cnWorkouts.refresh();
      Future.delayed(const Duration(milliseconds: 100), (){
        Navigator.of(context).pop();
      });
    });
  }
}

class CnRunningWorkout extends ChangeNotifier {
  Workout workout = Workout();
  Workout lastWorkout = Workout();
  bool isRunning = false;
  bool isVisible = false;
  ScrollController scrollController = ScrollController();
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

  void initCachedData(Map data, BuildContext context){
    if(
      data.containsKey("workout") &&
      data.containsKey("lastWorkout") &&
      data.containsKey("isRunning") &&
      data.containsKey("isVisible") &&
      data.containsKey("testControllerValues") &&
      data.containsKey("selectedIndexes")
    ){
      isRunning = data["isRunning"];
      isVisible = data["isVisible"];
      for(MapEntry entry in data["selectedIndexes"].entries){
        selectedIndexes[entry.key] = entry.value;
      }
      workout = Workout().fromMap(data["workout"]) ?? Workout();
      lastWorkout = Workout().fromMap(data["lastWorkout"]) ?? Workout();
      initSlideableKeys();
      initGroupedExercises();
      initTextControllers();
      setTextControllerValues(data["testControllerValues"]);
      if(isVisible && isRunning){
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => const ScreenRunningWorkout()
            ));
      }
    }
  }

  void openRunningWorkout(BuildContext context, Workout w){
    setLastWorkout(w);
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

  void setLastWorkout(Workout w){
    lastWorkout = w;
    workout = Workout.copy(lastWorkout);
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
      "lastWorkout": lastWorkout.asMap(),
      "isRunning": isRunning,
      "isVisible": isVisible,
      "testControllerValues": getTextControllerValues(),
      "selectedIndexes": selectedIndexes,
    };
    cnConfig.config.cnRunningWorkout = data;
    final res = await cnConfig.config.save();
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
    scrollController = ScrollController();
    isRunning = false;
    cnConfig.setCnRunningWorkout({});
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}