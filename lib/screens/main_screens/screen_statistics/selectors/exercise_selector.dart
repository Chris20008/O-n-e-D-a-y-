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
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
    if(initExercise != cnScreenStatistics.selectedExerciseName){
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
      onPressed: () => _showDialog(
        CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: 32,
            scrollController: FixedExtentScrollController(
              initialItem: cnScreenStatistics.allExerciseNames.indexOf(cnScreenStatistics.selectedExerciseName!),
            ),
            onSelectedItemChanged: (int index) {
              cnScreenStatistics.selectedExerciseName = cnScreenStatistics.allExerciseNames[index];
              if(Platform.isAndroid){
                HapticFeedback.selectionClick();
              }
            },
            children: cnScreenStatistics.allExerciseNames.map((String exName) {
              return SizedBox(width: cnScreenStatistics.width-150, child: Center(child: OverflowSafeText(exName, maxLines: 1, minFontSize: 12)));
            }).toList()
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: cnScreenStatistics.width - 50
            ),
            child: OverflowSafeText(
                cnScreenStatistics.selectedExerciseName!,
                style: const TextStyle(
                  fontSize: 22.0,
                  color: Colors.white
                ),
                maxLines: 1
            ),
          ),
          const SizedBox(width: 10,),
          trailingChoice(size: 17, color: Colors.white),
        ],
      ),
    );
  }
}
