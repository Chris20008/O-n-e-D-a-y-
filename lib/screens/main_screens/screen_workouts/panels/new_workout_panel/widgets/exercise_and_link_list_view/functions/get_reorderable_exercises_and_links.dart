import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/exercise_and_link_list_view/widgets/exercise_with_slide_action/exercise_with_slide_action.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/exercise_and_link_list_view/widgets/link_with_slide_action.dart';
import 'package:flutter/cupertino.dart';

List<Widget> getReorderableExercisesAndLinks({
  required CnNewWorkOutPanel cnNewWorkout,
}){

  // CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);

  List <Widget> children = [];
  for(int index = 0; index < cnNewWorkout.exercisesAndLinks.length; index+=1) {
    Widget child = const SizedBox();
    if(cnNewWorkout.exercisesAndLinks[index].isExercise) {
      child = ExerciseWithSlideAction(
        key: index == 0 && tutorialIsRunning? cnNewWorkout.keyFirstExercise : ValueKey(cnNewWorkout.exercisesAndLinks[index].exercise!.name),
        index: index,
        cnNewWorkout: cnNewWorkout,
      );
    }
    else if(cnNewWorkout.exercisesAndLinks[index].isLink) {
      child = LinkWithSlideAction(
          key: ValueKey(cnNewWorkout.exercisesAndLinks[index].linkName),
          index: index
      );
    }

    if(index == 0 && tutorialIsRunning){
      child = AnimatedBuilder(
        key: ValueKey(cnNewWorkout.exercisesAndLinks[index].name + index.toString()),
        animation: cnNewWorkout.tutorialAnimationController,
        builder: (context, c){

          double value = cnNewWorkout.tutorialAnimationController.value;

          double factor = (1 + value*0.8).clamp(1, 1.05);
          if(value > 0.9375){
            factor = factor - ((value - 0.9375)*0.8);
          }

          double y = 0;
          double distance = 40;

          if(value <= 0.25){
            y = value * distance;
          }
          else if(value <= 0.5){
            y = (0.25 * distance * 2) - (value * distance);
          }
          else if(value <= 0.75){
            y = -((value-0.5) * distance);
          }
          else{
            y = (0.25 * -distance * 2) +((value-0.5) * distance);
          }

          return Transform(
            transform: Matrix4.translationValues(
              ///x
                0,
                ///y
                y,
                ///z
                0),
            child: Transform.scale(
              scale: factor,
              child: c,
            ),
          );
        },
        child: child,
      );
    }

    children.add(child);
  }
  return children;
}