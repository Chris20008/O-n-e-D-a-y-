import 'dart:convert';

import '../../../main.dart';
import '../backup_constants.dart';

List getWorkoutsAsStringList(){
  final allObWorkouts = objectbox.workoutBox.getAll();
  final allObSickDays = objectbox.sickDaysBox.getAll();
  final allWorkouts = List<String>.from(allObWorkouts.map((workout) => jsonEncode(workout.asMap())));
  final allSickDays = List<String>.from(allObSickDays.map((sickDay) => jsonEncode(sickDay.asMap())));

  return allWorkouts + [workoutSickDaySeparator] + allSickDays;
}