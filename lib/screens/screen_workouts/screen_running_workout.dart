import 'package:flutter/material.dart';
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
  late CnRunningWorkout cnRunningWorkout;
  final double _iconSize = 13;

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
        body: Padding(
          padding: const EdgeInsets.only(top:40,bottom: 10,left: 20, right: 20),
          child: Column(
            children: [
              Text(cnRunningWorkout.workout.name, textScaleFactor: 2,),
              Expanded(

                /// Each EXERCISE
                child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: cnRunningWorkout.workout.exercises.length+1,
                    itemBuilder: (BuildContext context, int index) {
                      Widget? child;

                      if (index == 0){
                        child = const SizedBox(
                          width: double.maxFinite,
                          child: Column(
                            children: [
                              Row(
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
                        );
                      }

                      else{
                        Exercise ex = cnRunningWorkout.workout.exercises[index-1];
                        child = Column(
                          children: [
                            Align(alignment: Alignment.centerLeft, child: Text(ex.name, textScaleFactor: 1.2,)),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(Icons.airline_seat_recline_normal, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
                                const SizedBox(width: 2,),
                                if (ex.seatLevel == null)
                                  const Text("-", textScaleFactor: 0.9,)
                                else
                                  Text(ex.seatLevel.toString(), textScaleFactor: 0.9,)
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.timer, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
                                const SizedBox(width: 2,),
                                if (ex.restInSeconds == 0)
                                  const Text("-", textScaleFactor: 0.9,)
                                else if (ex.restInSeconds < 60)
                                  Text("${ex.restInSeconds}s", textScaleFactor: 0.9,)
                                else if (ex.restInSeconds % 60 != 0)
                                    Text("${(ex.restInSeconds/60).floor()}:${ex.restInSeconds%60}m", textScaleFactor: 0.9,)
                                  else
                                    Text("${(ex.restInSeconds/60).round()}m", textScaleFactor: 0.9,),
                                const SizedBox(width: 10,)
                              ],
                            ),

                            /// Each Set
                            ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: ex.sets.length,
                                itemBuilder: (BuildContext context, int indexSet) {
                                  Set set = ex.sets[indexSet];
                                  Widget? child;
                                  child = Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: SizedBox(
                                      width: double.maxFinite,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(width: 80,child: Text("${indexSet + 1}", textScaleFactor: 1.2,)),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text("${set.weight}", textScaleFactor: 1.2,),
                                                const SizedBox(width: 15,),
                                                SizedBox(
                                                  width: 50,
                                                  child: TextField(
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                      // labelText: 'Rest In Seconds',
                                                      counterText: "",
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text("${set.amount}", textScaleFactor: 1.2,),
                                                SizedBox(width: 15,),
                                                SizedBox(
                                                  width: 50,
                                                  child: TextField(
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                      // labelText: 'Rest In Seconds',
                                                      counterText: "",
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 25,)
                                        ],
                                      ),
                                    ),
                                  );

                                  // if (indexSet == 0){
                                  //   child = Column(
                                  //     children: [
                                  //       child,
                                  //       const SizedBox(height: 20,),
                                  //       Container(
                                  //         height: 1,
                                  //         width: double.maxFinite - 50,
                                  //         color: Colors.amber[900]!.withOpacity(0.6),
                                  //       ),
                                  //       const SizedBox(height: 20,),
                                  //     ],
                                  //   );
                                  // }

                                  return child;
                                }
                            ),
                          ],
                        );
                      }

                      if (index > 0) {
                        child = Column(
                          children: [
                            const SizedBox(height: 20,),
                            Container(
                              height: 1,
                              width: double.maxFinite - 50,
                              color: Colors.amber[900]!.withOpacity(0.6),
                            ),
                            const SizedBox(height: 20,),
                            child
                          ],
                        );
                      }

                      if (index == cnRunningWorkout.workout.exercises.length){
                        child = Column(
                          children: [
                            child,
                            const SizedBox(height: 50,)
                          ],
                        );
                      }

                      return child;
                    }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CnRunningWorkout extends ChangeNotifier {
  Workout workout = Workout();

  void openRunningWorkout(BuildContext context, Workout w){
    setWorkout(w);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const ScreenRunningWorkout()
        ));
  }

  void closeRunningWorkout(BuildContext context){
    Navigator.pop(context);
  }

  void setWorkout(Workout w){
    workout = w;
  }

  void clear(){
    workout = Workout();
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}