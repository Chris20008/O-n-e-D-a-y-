import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../objects/exercise.dart';
import '../screen_statistics.dart';

class ExerciseSelector extends StatefulWidget {
  const ExerciseSelector({super.key});

  @override
  State<ExerciseSelector> createState() => _ExerciseSelectorState();
}

class _ExerciseSelectorState extends State<ExerciseSelector> {
  late CnScreenStatistics cnScreenStatistics  = Provider.of<CnScreenStatistics>(context);

  Future _showDialog(Widget child) async{
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
    // setState(() {});
    cnScreenStatistics.lineChartKey = UniqueKey();
    cnScreenStatistics.refresh();
  }

  @override
  Widget build(BuildContext context) {

    print("REBUILD EX SELECTOR");

    if(cnScreenStatistics.selectedWorkout == null || cnScreenStatistics.selectedWorkout!.exercises.isEmpty){
      print("RETURN EMPTY");
      return const SizedBox();
    }


    // cnScreenStatistics.selectedWorkout ??= cnScreenStatistics.intervalSelectorMap.keys.first;

    return Column(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          // Display a CupertinoPicker with list of fruits.
          onPressed: () => _showDialog(
            CupertinoPicker(
                magnification: 1.22,
                squeeze: 1.2,
                useMagnifier: true,
                itemExtent: 32,
                // This sets the initial item.
                scrollController: FixedExtentScrollController(
                  initialItem: cnScreenStatistics.selectedWorkout!.exercises.indexOf(cnScreenStatistics.selectedExercise!),
                ),
                // This is called when selected item is changed.
                onSelectedItemChanged: (int index) {
                  // setState(() {
                  cnScreenStatistics.selectedExercise = cnScreenStatistics.selectedWorkout!.exercises[index];
                  // });
                },
                children: cnScreenStatistics.selectedWorkout!.exercises.map((Exercise ex) {
                  return Center(child: Text(ex.name));
                }).toList()
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                cnScreenStatistics.selectedExercise!.name,
                style: const TextStyle(
                  fontSize: 22.0,
                ),
              ),
              const SizedBox(width: 10,),
              const Icon(Icons.arrow_forward_ios, size: 15,)
            ],
          ),
        ),
      ],
    );
  }
}
