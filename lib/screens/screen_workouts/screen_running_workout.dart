import 'dart:ui';

import 'package:fitness_app/screens/screen_workouts/screen_workouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../objects/exercise.dart';
import '../../objects/workout.dart';

class ScreenRunningWorkout extends StatefulWidget {
  const ScreenRunningWorkout({
    super.key,
  });

  @override
  State<ScreenRunningWorkout> createState() => _ScreenRunningWorkoutState();
}

class _ScreenRunningWorkoutState extends State<ScreenRunningWorkout> {
  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout;
  final double _iconSize = 13;
  final double _heightOfSetRow = 50;
  final double _setPadding = 5;

  @override
  Widget build(BuildContext context) {
    cnRunningWorkout = Provider.of<CnRunningWorkout>(context);

    return MaterialApp(
      themeMode: ThemeMode.dark,
      title: 'Flutter Demo',
      darkTheme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber[800] ?? Colors.amber),
          useMaterial3: true,
          splashFactory: InkSparkle.splashFactory
      ),
      home: Scaffold(
        extendBody: true,
        // resizeToAvoidBottomInset: false,
        body: Stack(
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
                      itemCount: cnRunningWorkout.workout.exercises.length,
                      itemBuilder: (BuildContext context, int index) {
                        Widget? child;

                        Exercise lastEx = cnRunningWorkout.lastWorkout.exercises[index];
                        Exercise newEx = cnRunningWorkout.workout.exercises[index];
                        child = Column(
                          children: [
                            Align(alignment: Alignment.centerLeft, child: Text(newEx.name, textScaleFactor: 1.2,)),
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
                                // separatorBuilder: (BuildContext context, int index) {
                                //   return const SizedBox(height: 15,);
                                // },
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

                                  Set set = lastEx.sets[indexSet];
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
                                                      cnRunningWorkout.textControllers[newEx.name]?[indexSet][0].text = set.weight?.toString()?? "";
                                                      newEx.sets[indexSet].weight = set.weight;
                                                      cnRunningWorkout.refresh();
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
                                                      cnRunningWorkout.textControllers[newEx.name]?[indexSet][1].text = set.amount?.toString()?? "";
                                                      newEx.sets[indexSet].amount = set.amount;
                                                      cnRunningWorkout.refresh();
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
                                    key: cnRunningWorkout.slideableKeys[cnRunningWorkout.workout.exercises[index].name]![indexSet],
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

                        if (index == 0){
                          child = Column(
                            children: [
                              const SizedBox(height: 110,),
                              child
                            ],
                          );
                        }

                        if (index == cnRunningWorkout.workout.exercises.length-1){
                          child = Column(
                            children: [
                              child,
                              const SizedBox(height: 70,)
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
            ClipRRect(
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    height: 120,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(20),bottomLeft: Radius.circular(20)),
                    ),
                  )
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 30),
                height: 120,
                width: double.maxFinite,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          // Colors.black.withOpacity(0.8),
                          Colors.black.withOpacity(0.0),
                        ]
                    )
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20,),
                      Text(cnRunningWorkout.workout.name, textScaleFactor: 2,),
                      const SizedBox(height: 20,),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Set", textScaleFactor: 1.5,),
                          SizedBox(width: 20,),
                          Text("Weight", textScaleFactor: 1.5,),
                          SizedBox(width: 1,),
                          Text("Amount", textScaleFactor: 1.5,),
                          SizedBox(width: 1,)
                        ],
                      ),
                    ],
                  ),
                ),
            ),
            if(MediaQuery.of(context).viewInsets.bottom < 50)
              Positioned(
                bottom: 10,
                left: 20,
                right: 20,
                child: ElevatedButton(
                    onPressed: finishWorkout,
                    child: const Text("Finish")
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

  void finishWorkout(){
    cnRunningWorkout.workout.refreshDate();
    cnRunningWorkout.workout.clearAllExercisesEmptySets();
    if(cnRunningWorkout.workout.exercises.any((ex) => ex.sets.isNotEmpty)){
      cnRunningWorkout.workout.saveToDatabase();
      cnWorkouts.refreshAllWorkouts();
    }
    Navigator.of(context).pop();
  }
}

class CnRunningWorkout extends ChangeNotifier {
  Workout workout = Workout();
  Workout lastWorkout = Workout();
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

  void openRunningWorkout(BuildContext context, Workout w){
    setLastWorkout(w);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const ScreenRunningWorkout()
        ));
  }

  void closeRunningWorkout(BuildContext context){
    Navigator.pop(context);
  }

  void setLastWorkout(Workout w){
    lastWorkout = w;

    workout = Workout.copy(lastWorkout);
    workout.resetAllExercisesSets();

    slideableKeys = {
      for (var e in workout.exercises)
        e.name :
        e.generateKeyForEachSet()
    };

    textControllers = {
      for (var e in workout.exercises)
        e.name :
        e.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList()
    };
  }

  void clear(){
    workout = Workout();
    textControllers.clear();
    slideableKeys.clear();
    scrollController = ScrollController();
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}