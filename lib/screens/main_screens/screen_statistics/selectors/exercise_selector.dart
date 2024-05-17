import 'dart:io';

import 'package:fitness_app/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../screen_statistics.dart';

class ExerciseSelector extends StatefulWidget {
  const ExerciseSelector({super.key});

  @override
  State<ExerciseSelector> createState() => _ExerciseSelectorState();
}

class _ExerciseSelectorState extends State<ExerciseSelector> {
  late CnScreenStatistics cnScreenStatistics  = Provider.of<CnScreenStatistics>(context);

  Future _showDialog(Widget child) async{
    HapticFeedback.selectionClick();

    final initExercise = cnScreenStatistics.selectedExerciseName;

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
    if(initExercise != cnScreenStatistics.selectedExerciseName){
      cnScreenStatistics.lineChartKey = UniqueKey();
      cnScreenStatistics.calcMinMaxDates();
      cnScreenStatistics.refresh();
      cnScreenStatistics.cache();
    }
  }

  @override
  Widget build(BuildContext context) {

    cnScreenStatistics.selectedExerciseName ??= cnScreenStatistics.allExerciseNames.firstOrNull;

    if(cnScreenStatistics.selectedExerciseName == null){
      return const SizedBox();
    }

    return CupertinoButton(
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
              initialItem: cnScreenStatistics.allExerciseNames.indexOf(cnScreenStatistics.selectedExerciseName!),
            ),
            // This is called when selected item is changed.
            onSelectedItemChanged: (int index) {
              // setState(() {
              cnScreenStatistics.selectedExerciseName = cnScreenStatistics.allExerciseNames[index];
              if(Platform.isAndroid){
                HapticFeedback.selectionClick();
              }
              // });
            },
            children: cnScreenStatistics.allExerciseNames.map((String exName) {
              return Center(child: OverflowSafeText(exName, maxLines: 1, minFontSize: 12));
              // return Center(child: Text(ex.name));
            }).toList()
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          OverflowSafeText(
              cnScreenStatistics.selectedExerciseName!,
              style: const TextStyle(
                fontSize: 22.0,
                color: Colors.white
              ),
          ),
          // Text(
          //   cnScreenStatistics.selectedExercise!.name,
          //   style: const TextStyle(
          //     fontSize: 22.0,
          //   ),
          // ),
          const SizedBox(width: 10,),
          const Icon(Icons.arrow_forward_ios, size: 15, color: Colors.white,)
        ],
      ),
    );
  }
}
