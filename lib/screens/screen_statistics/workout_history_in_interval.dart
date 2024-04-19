import 'package:fitness_app/screens/screen_statistics/screen_statistics.dart';
import 'package:flutter/cupertino.dart';
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
    setState(() {});
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
              // List<Widget>.generate(cnScreenStatistics.selectedWorkout!.exercises.length, (int index) {
              //   return Center(child: Text(_fruitNames[index]));
              // }),
            ),
          ),
          // This displays the selected fruit name.
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
              SizedBox(width: 10,),
              const Icon(Icons.arrow_forward_ios, size: 15,)
            ],
          ),
        ),
      ],
    );

    // return LayoutBuilder(
    //   builder: (context, constraints) {
    //     return ListView(
    //       shrinkWrap: true,
    //       padding: const EdgeInsets.symmetric(horizontal: 10),
    //       children: [
    //         // DropdownMenu<String>(
    //         //   width: constraints.maxWidth-20,
    //         //   menuHeight: constraints.maxHeight-50,
    //         //   menuStyle: MenuStyle(
    //         //     backgroundColor: MaterialStateColor.resolveWith((states) => Colors.white),
    //         //     shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),bottomLeft: Radius.circular(20))))
    //         //   ),
    //         //   initialSelection: cnScreenStatistics.selectedExercise?.name,
    //         //   onSelected: (String? value) async{
    //         //     if(value != null) {
    //         //       // cnScreenStatistics.selectedWorkout = await cnScreenStatistics.getWorkoutFromName(value);
    //         //       setState((){
    //         //         cnScreenStatistics.selectedExercise = cnScreenStatistics.selectedWorkout!.exercises.firstWhere((ex) => ex.name == value);
    //         //       });
    //         //     }
    //         //   },
    //         //   dropdownMenuEntries: cnScreenStatistics.selectedWorkout!.exercises.map<DropdownMenuEntry<String>>((Exercise ex) {
    //         //     return DropdownMenuEntry<String>(value: ex.name, label: ex.name);
    //         //   }).toList(),
    //         // ),
    //         CupertinoButton(
    //           padding: EdgeInsets.zero,
    //           // Display a CupertinoPicker with list of fruits.
    //           onPressed: () => _showDialog(
    //             CupertinoPicker(
    //               magnification: 1.22,
    //               squeeze: 1.2,
    //               useMagnifier: true,
    //               itemExtent: 32,
    //               // This sets the initial item.
    //               scrollController: FixedExtentScrollController(
    //                 initialItem: cnScreenStatistics.selectedWorkout!.exercises.indexOf(cnScreenStatistics.selectedExercise!),
    //               ),
    //               // This is called when selected item is changed.
    //               onSelectedItemChanged: (int index) {
    //                 // setState(() {
    //                   cnScreenStatistics.selectedExercise = cnScreenStatistics.selectedWorkout!.exercises[index];
    //                 // });
    //               },
    //               children: cnScreenStatistics.selectedWorkout!.exercises.map((Exercise ex) {
    //                 return Center(child: Text(ex.name));
    //               }).toList()
    //               // List<Widget>.generate(cnScreenStatistics.selectedWorkout!.exercises.length, (int index) {
    //               //   return Center(child: Text(_fruitNames[index]));
    //               // }),
    //             ),
    //           ),
    //           // This displays the selected fruit name.
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             mainAxisSize: MainAxisSize.min,
    //             children: [
    //               Text(
    //                 cnScreenStatistics.selectedExercise!.name,
    //                 style: const TextStyle(
    //                   fontSize: 22.0,
    //                 ),
    //               ),
    //               SizedBox(width: 10,),
    //               const Icon(Icons.arrow_forward_ios, size: 15,)
    //             ],
    //           ),
    //         ),
    //       ],
    //     );
    //   }
    // );
  }
}
