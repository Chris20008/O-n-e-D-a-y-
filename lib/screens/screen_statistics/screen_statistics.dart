import 'package:fitness_app/main.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';

import '../../objects/workout.dart';
import 'general_overview.dart';

class ScreenStatistics extends StatefulWidget {
  const ScreenStatistics({super.key});

  @override
  State<ScreenStatistics> createState() => _ScreenStatisticsState();
}

class _ScreenStatisticsState extends State<ScreenStatistics> {
  late CnScreenStatistics cnScreenStatistics;

  @override
  Widget build(BuildContext context) {
    cnScreenStatistics = Provider.of<CnScreenStatistics>(context);

    return GeneralOverview();
  }
}

class CnScreenStatistics extends ChangeNotifier {
  bool isInitialized = false;
  late List<Workout> allWorkouts;
  Map<int, dynamic> workoutsSorted = {};
  DateTime minDate = DateTime.now();
  DateTime maxDate = DateTime.now();

  void init() async{
    final tempObWorkouts = await objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(false)).order(ObWorkout_.date).build().findAsync();// .getAllAsync();
    allWorkouts = List.from(tempObWorkouts.map((w) => Workout.fromObWorkout(w)));
    isInitialized = true;
    setMinDate();
    calcFoundation();
    sortWorkoutsInMap();
    print(workoutsSorted);
    print(minDate);
    print(maxDate);
  }

  void calcFoundation(){
    bool addNewWeek = true;
    // final int dayOfMonth = int.parse(DateFormat('d').format(minDate));
    final int weekday = weekdayMapping[DateFormat('E').format(minDate)]!;
    // final int month = int.parse(DateFormat('M').format(minDate));

    for(num year in range(minDate.year, maxDate.year + 1)){
      workoutsSorted[year.toInt()] = {};
    }
    DateTime currentMonday = minDate.subtract(Duration(days: weekday -1));
    // DateTime currentMonday = firstMonday;
    int weekCounter = 1;
    while (addNewWeek){
      final int dayOfMonthMonday = int.parse(DateFormat('d').format(currentMonday));
      final int monthMonday = int.parse(DateFormat('M').format(currentMonday));
      final sunday = currentMonday.add(const Duration(days: 6));
      final int dayOfMonthSunday = int.parse(DateFormat('d').format(sunday));
      final int monthSunday = int.parse(DateFormat('M').format(sunday));
      workoutsSorted[currentMonday.year][DateFormat('yMd').format(currentMonday)] = {
        "name": "$dayOfMonthMonday.$monthMonday - $dayOfMonthSunday.$monthSunday",
        "counter": 0
      };
      currentMonday = sunday.add(const Duration(days:1));
      weekCounter += 1;
      if(maxDate.isBefore(sunday)){
        addNewWeek = false;
      }
    }
  }

  void setMinDate(){
    if(allWorkouts.isNotEmpty){
      minDate = allWorkouts.first.date!;
    }
  }

  void sortWorkoutsInMap(){
    for(Workout w in allWorkouts){
      final year = w.date!.year;
      final int weekday = weekdayMapping[DateFormat('E').format(w.date!)]!;
      final weekKey = DateFormat('yMd').format(w.date!.subtract(Duration(days: weekday - 1)));
      workoutsSorted[year][weekKey]["counter"] = workoutsSorted[year][weekKey]["counter"] + 1;
    }
  }

  void refresh(){
    notifyListeners();
  }
}
