import 'package:fitness_app/screens/screen_statistics/screen_statistics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../objects/exercise.dart';

class WorkoutHistoryInInterval extends StatefulWidget {
  const WorkoutHistoryInInterval({super.key});

  @override
  State<WorkoutHistoryInInterval> createState() => _WorkoutHistoryInIntervalState();
}

class _WorkoutHistoryInIntervalState extends State<WorkoutHistoryInInterval> {
  late CnScreenStatistics cnScreenStatistics  = Provider.of<CnScreenStatistics>(context);

  @override
  Widget build(BuildContext context) {

    print("REBUILD EX SELECTOR");

    if(cnScreenStatistics.selectedWorkout == null || cnScreenStatistics.selectedWorkout!.exercises.isEmpty){
      print("RETURN EMPTY");
      return const SizedBox();
    }


    // cnScreenStatistics.selectedWorkout ??= cnScreenStatistics.intervalSelectorMap.keys.first;


    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            DropdownMenu<String>(
              width: constraints.maxWidth-20,
              menuHeight: constraints.maxHeight-50,
              menuStyle: MenuStyle(
                backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),bottomLeft: Radius.circular(20))))
              ),
              initialSelection: cnScreenStatistics.selectedExercise?.name,
              onSelected: (String? value) async{
                if(value != null) {
                  // cnScreenStatistics.selectedWorkout = await cnScreenStatistics.getWorkoutFromName(value);
                  setState((){
                    cnScreenStatistics.selectedExercise = cnScreenStatistics.selectedWorkout!.exercises.firstWhere((ex) => ex.name == value);
                  });
                }
              },
              dropdownMenuEntries: cnScreenStatistics.selectedWorkout!.exercises.map<DropdownMenuEntry<String>>((Exercise ex) {
                return DropdownMenuEntry<String>(value: ex.name, label: ex.name);
              }).toList(),
            )
          ],
        );
      }
    );
  }
}
