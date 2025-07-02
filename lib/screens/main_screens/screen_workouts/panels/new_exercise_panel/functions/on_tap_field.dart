import 'dart:io';

import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/cupertino.dart';

Future onTapField({
  required int index,
  required double insetsBottom,
  required double screenHeight,
  required int weightOrAmountIndex,
  int scrollDelay = 500,
  required CnNewExercisePanel cnNewExercise,
  required GlobalKey? key
  }) async{

  /// responsible for textSelection when tap on field
  cnNewExercise.currentIndexFocus = index;
  cnNewExercise.currentIndexWeightOrAmount = weightOrAmountIndex;
  cnNewExercise.controllers[index][weightOrAmountIndex].selection =  TextSelection(baseOffset: 0, extentOffset: cnNewExercise.controllers[index][weightOrAmountIndex].value.text.length);
  if(insetsBottom == 0) {
    await Future.delayed(Duration(milliseconds: scrollDelay));
  }

  if(key == null){
    return;
  }

  final position = getWidgetPosition(key);
  final value = Platform.isAndroid? 80 : 100;
  final relativeHeight = screenHeight - insetsBottom;
  double factor = (relativeHeight - value) / screenHeight;

  if(position.dy + value > relativeHeight){
    Future.delayed(const Duration(milliseconds: 10), (){
      Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: factor
      );
    });
  }
}