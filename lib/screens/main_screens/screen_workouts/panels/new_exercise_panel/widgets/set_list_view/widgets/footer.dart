import 'dart:io';

import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class Footer extends StatelessWidget {

  const Footer({super.key});

  @override
  Widget build(BuildContext context) {


    late CnNewExercisePanel cnNewExercise = Provider.of<CnNewExercisePanel>(context, listen: false);
    double insetsBottom = MediaQuery.of(context).viewInsets.bottom;
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        const SizedBox(height: 15,),

        getRowButton(
            key: cnNewExercise.getKeyAddSet(context),
            context: context,
            minusWidth: 20,
            onPressed: () => cnNewExercise.addSet(
                screenHeight: screenHeight,
                insetsBottom: insetsBottom,
                context: context
            )
        ),

        SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0? MediaQuery.of(context).viewInsets.bottom+(Platform.isAndroid? 50: 50) : 60)
      ],
    );
  }
}
