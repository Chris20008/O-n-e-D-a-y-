import 'package:fitness_app/main.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/selectors/exercise_selector.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/selectors/interval_selector.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';
import '../../../objects/exercise.dart';
import '../../../objects/workout.dart';
import '../../../util/objectbox/ob_workout.dart';
import 'charts/line_chart_exercise_weight_progress.dart';
import 'exercise_summary_per_interval.dart';
import 'selectors/interval_size_selector.dart';

class ScreenStatistics extends StatefulWidget {
  const ScreenStatistics({super.key});

  @override
  State<ScreenStatistics> createState() => _ScreenStatisticsState();
}

class _ScreenStatisticsState extends State<ScreenStatistics> {
  late CnScreenStatistics cnScreenStatistics = Provider.of<CnScreenStatistics>(context);

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      bottom: false,
      child: Column(

        children: [
          const SizedBox(height: 10),
          const IntervalSizeSelector(),
          const SizedBox(height: 20),
          const IntervalSelector(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              children: [
                const SizedBox(height: 20),
                const ExerciseSummaryPerInterval(),
                const ExerciseSelector(),
                const SizedBox(height: 20,),
                LineChartExerciseWeightProgress(key: cnScreenStatistics.lineChartKey),
                // LineChartExerciseWeightProgress(),
                const SafeArea(top:false, child: SizedBox(height: 30,)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CnScreenStatistics extends ChangeNotifier {
  bool isInitialized = false;
  bool isCalculatingData = false;
  Map<int, dynamic> workoutsSorted = {};
  Key lineChartKey = UniqueKey();
  DateTime minDate = DateTime.now();
  // DateTime minDate = DateTime(2024, 4, 5);
  DateTime maxDate = DateTime.now().add(const Duration(days: 32));
  // DateTime maxDate = DateTime(2025, 5, 26);
  /// minDate of the currenzly selected Interval
  DateTime currentMinDate = DateTime.now();
  /// maxDate of the currently selected Interval
  DateTime currentMaxDate = DateTime.now();

  /// Holds the PlainText as Key f.e. 'March 2024', 'April 2024'
  /// And for each Key the min and max dates
  /// Example:
  ///       {
  ///         'March 2024': {
  ///                         'minDate': '2024.03.01 00:00:00.0000',
  ///                         'maxDate': '2024.04.01 00:00:00.0000'
  ///                       },
  ///         'April 2024': {
  ///                         'minDate': '2024.04.01 00:00:00.0000',
  ///                         'maxDate': '2024.05.01 00:00:00.0000'
  ///                       }
  ///       }
  Map<String, Map<String, DateTime>> intervalSelectorMap = {};

  /// Contains as Key all Workout name of the currently selected Intervall f.e. 'Push', 'Pull'.
  /// The Entities are Object of Type StatisticExercise where one entitie
  /// contains one single set of one Exercise.
  /// So One Exercise with 3 Sets is split into three single entities
  /// Summarized we can say, that this Map holds all Sets named with the corresponding
  /// Exercise name of all Workouts done in a selected Interval
  Map<String, List<StatisticExercise>> exercisesPerWorkout = {};

  /// Hold the currently selected Interval as plain Text which can be used
  /// as a key to enter 'intervalSelectorMap'
  late String currentlySelectedIntervalAsText = DateFormat('MMMM y').format(DateTime.now());
  TimeInterval selectedIntervalSize = TimeInterval.monthly;
  Workout? selectedWorkout;
  Exercise? selectedExercise;
  Workout? previousSelectedWorkout;
  Exercise? previousSelectedExercise;


  ///
  Map<String, int>? sortedSummarized;


  void init() async{
    isInitialized = true;
    setMinDate();
    refreshIntervalSelectorMap();
    calculateCurrentData();
  }

  void refreshIntervalSelectorMap(){
    intervalSelectorMap.clear();
    bool isSmaller = true;
    late DateTime tempMinDate;
    switch (selectedIntervalSize){
      case TimeInterval.yearly:
        tempMinDate = DateTime(minDate.year, 1, 1, 0, 0, 0, 0, 0);
        break;
      case TimeInterval.quarterly:
        final subtractionFromMonth = (minDate.month-1)%3;
        tempMinDate = DateTime(minDate.year, minDate.month - subtractionFromMonth, 1, 0, 0, 0, 0, 0);
        break;
      default:
        tempMinDate = minDate.copyWith(day: 1, hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    }
    while (isSmaller){

      late String intervalKey;
      switch (selectedIntervalSize){
        case TimeInterval.yearly:
          intervalKey = DateFormat('y').format(tempMinDate);
          break;
        case TimeInterval.quarterly:
          intervalKey = DateFormat('QQQ y').format(tempMinDate);
          break;
        default:
          intervalKey = DateFormat('MMMM y').format(tempMinDate);
      }

      /// set temp max date
      late DateTime tempMaxDate;
      switch (selectedIntervalSize){

        /// yearly new temp max date
        case TimeInterval.yearly:
          tempMaxDate = tempMinDate.add(
              Duration(days: isLeapYear(tempMinDate.year)? 366: 365)
          ).copyWith(
              hour: 0,
              minute: 0,
              second: 0,
              millisecond: 0,
              microsecond: 0
          );
          break;

        /// quarterly new temp max date
        case TimeInterval.quarterly:
          tempMaxDate = tempMinDate.add(
              Duration(days: getMaxDaysOfMonths(tempMinDate))
          );
          for (num _ in range(1, 3)){
            tempMaxDate = tempMaxDate.add(Duration(days: getMaxDaysOfMonths(tempMaxDate)));
          }
          tempMaxDate = tempMaxDate.copyWith(hour: 0, minute: 0, second: 0);
          intervalKey = DateFormat('QQQ y').format(tempMinDate);
          break;

        /// monthly new temp max date
        default:
          tempMaxDate = tempMinDate.add(
              Duration(days: getMaxDaysOfMonths(tempMinDate))
          ).copyWith(
              hour: 0,
              minute: 0,
              second: 0,
              millisecond: 0,
              microsecond: 0
          );
          /// Due to German TimeCorrection in March and October it can happen, that the month is still
          /// the same, due to adding one day always adds 24 hours beeing to less in october where one day is 25 hours long
          if(tempMaxDate.month == tempMinDate.month){
            tempMaxDate = tempMaxDate.add(const Duration(days: 1)).copyWith(
                hour: 0,
                minute: 0,
                second: 0,
                millisecond: 0,
                microsecond: 0
            );
          }
      }
      intervalSelectorMap[intervalKey] = {
        "minDate": tempMinDate,
        "maxDate": tempMaxDate
      };

      if(DateTime.now().isAfter(tempMinDate) && DateTime.now().isBefore(tempMaxDate)){
        currentlySelectedIntervalAsText = intervalKey;
      }
      if(tempMaxDate.isAfter(maxDate)){
        isSmaller = false;
      }
      else{
        tempMinDate = tempMaxDate.copyWith(
            hour: 0,
            minute: 0,
            second: 0
        );
      }

    }
  }
  
  Future<List<Workout>> getWorkoutsInInterval()async{
    final tempObWorkouts = await objectbox.workoutBox.query(
        ObWorkout_.isTemplate.equals(false)
            .and(ObWorkout_.date.betweenDate(intervalSelectorMap[currentlySelectedIntervalAsText]!["minDate"]!, intervalSelectorMap[currentlySelectedIntervalAsText]!["maxDate"]!))
        ).order(ObWorkout_.date).build().findAsync();
    return List.from(tempObWorkouts.map((w) => Workout.fromObWorkout(w)));
  }

  Future<void> calculateCurrentData()async{
    // await Future.delayed(const Duration(milliseconds: 200), (){});
    isCalculatingData = true;
    Map<String, int> summarized = {};
    final workouts = await getWorkoutsInInterval();
    exercisesPerWorkout.clear();

    for(Workout w in workouts){
      List<StatisticExercise> exercises = exercisesPerWorkout[w.name]?? [];
      for(Exercise ex in w.exercises){
        exercises.addAll(ex.sets.map((set) =>
            StatisticExercise(
                name: ex.name,
                weight: set.weight?? 0,
                amount: set.amount?? 0,
                date: w.date!
            )
        ));
      }
      // print("ALL EXERCISES");
      // for(final e in exercises){
      //   print(e.name);
      //   print(e.date);
      //   print(e.weight);
      //   print(e.amount);
      //   print("");
      // }
      exercisesPerWorkout[w.name] = exercises;

      if(summarized.containsKey(w.name)){
        summarized[w.name] = summarized[w.name]! + 1;
      } else{
        summarized[w.name] = 1;
      }
    }

    sortedSummarized = Map.fromEntries(
        summarized.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value))
    );

    /// Set selectedWorkout and selectedExercise
    if(sortedSummarized != null && sortedSummarized!.keys.isNotEmpty /*&& selectedWorkout == null*/){
      if(sortedSummarized!.keys.contains(previousSelectedWorkout?.name)){
        await setSelectedWorkout(previousSelectedWorkout!.name);
      } else{
        await setSelectedWorkout(sortedSummarized!.keys.first);
      }
    }

    currentMinDate = intervalSelectorMap[currentlySelectedIntervalAsText]!["minDate"]!;
    currentMaxDate = intervalSelectorMap[currentlySelectedIntervalAsText]!["maxDate"]!;

    isCalculatingData = false;
    refresh();
    // getSelectedExerciseHistory();
  }

  Map<String, int>? getWorkoutsInIntervalSummarized(){
    return sortedSummarized;
  }

  Future setSelectedWorkout(String workoutName) async{
    final ObWorkout? w = await objectbox.workoutBox.query(ObWorkout_.name.equals(workoutName).and(ObWorkout_.isTemplate.equals(true))).build().findFirstAsync();
    if(w != null) {
      final newWorkout = Workout.fromObWorkout(w);
      if(newWorkout.name != selectedWorkout?.name && selectedWorkout != null){
        previousSelectedWorkout = Workout.clone(selectedWorkout!);
        lineChartKey = UniqueKey();
      }
      selectedWorkout = newWorkout;
      final exerciseNames = selectedWorkout?.exercises.map((e) => e.name);

      if(exerciseNames == null || exerciseNames.isEmpty){
        return;
      }

      if(/*selectedExercise == null &&*/ exerciseNames.contains(previousSelectedExercise?.name)){
        selectedExercise = previousSelectedExercise;
      }
      else{
        selectedExercise = selectedWorkout?.exercises.first;
      }
    } else{
      selectedWorkout = null;
    }
  }

  List<StatisticExercise>? getSelectedExerciseHistory(){
    try{
      final exercises = exercisesPerWorkout[selectedWorkout!.name]!
          .where((element) => element.name == selectedExercise!.name)
          .toList()
          .where((element) => element.date.isAfter(currentMinDate) && element.date.isBefore(currentMaxDate))
          .toList();
      return exercises;
    } on TypeError catch (_){
      return null;
    }

  }

   List<int?>? getMinMaxWeights(){
    final exercises = getSelectedExerciseHistory();
    if(exercises == null){
      return null;
    }
    int minWeight = 1000000;
    int maxWeight = 0;
    for(StatisticExercise ex in exercises){
      maxWeight = maxWeight < ex.weight? ex.weight : maxWeight;
      minWeight = minWeight < maxWeight? minWeight : maxWeight;
    }
    if(minWeight == 1000000) minWeight = 0;
    return [minWeight, maxWeight];
  }

  Map<DateTime, int>? getMaxWeightsPerDate(){
    final exercises = getSelectedExerciseHistory();
    if(exercises == null){
      return null;
    }
    Map<DateTime, int> maxWeights = {};
    for(StatisticExercise ex in exercises){
      // print("DATE: ${ex.date}");
      final int? currentWeight = maxWeights[ex.date];
      if(currentWeight != null){
        maxWeights[ex.date] = currentWeight < ex.weight? ex.weight : currentWeight;
      } else{
        maxWeights[ex.date] = ex.weight;
      }
    }
    return maxWeights;
  }

  Map<DateTime, int>? getTotalMovedWeight(){
    final exercises = getSelectedExerciseHistory();
    if(exercises == null){
      return null;
    }
    Map<DateTime, int> summedWeights = {};
    for(StatisticExercise ex in exercises){
      summedWeights[ex.date] = (summedWeights[ex.date]?? 0) + (ex.weight*ex.amount);
    }
    print("TOTAL MOVED WEIGHTS");
    for(MapEntry e in summedWeights.entries){
      print("DATE ${e.key} WEIGHT: ${e.value}");
    }
    return summedWeights;
  }

  // void setCurrentInterval(String interval){
  //   currentlySelectedIntervalAsText = interval;
  //   currentMinDate = intervalSelectorMap[interval]!["minDate"]!;
  //   currentMinDate = intervalSelectorMap[interval]!["maxDate"]!;
  // }



  // Future<Workout?> getWorkoutFromName(String workoutName) async{
  //   final ObWorkout? w = await objectbox.workoutBox.query(ObWorkout_.name.equals(workoutName).and(ObWorkout_.isTemplate.equals(true))).build().findFirstAsync();
  //   if(w == null) return null;
  //   return Workout.fromObWorkout(w);
  // }

  // void getWeeksFromMonth(int year, int month) async{
  //   final firstDayOfMonth = DateTime(year=year, month, 1);
  //   final lastDayOfMonth = DateTime(year=year, month, getMaxDaysOfMonths(firstDayOfMonth));
  //
  //   final DateTime firstMonday = getMondayOfWeekFromDay(firstDayOfMonth);
  //   final DateTime lastSunday = getSundayOfWeekFromDay(lastDayOfMonth);
  //
  //   final tempObWorkouts = await objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(false).and(ObWorkout_.date.betweenDate(firstMonday, lastSunday))).order(ObWorkout_.date).build().findAsync();
  //   List<Workout> tempWorkouts = List.from(tempObWorkouts.map((w) => Workout.fromObWorkout(w)));
  //
  // }

  // DateTime getMondayOfWeekFromDay(DateTime date){
  //   final int weekday = weekdayMapping[DateFormat('E').format(date)]!;
  //   return date.subtract(Duration(days: weekday -1));
  // }
  //
  // DateTime getSundayOfWeekFromDay(DateTime date){
  //   return getMondayOfWeekFromDay(date).add(const Duration(days: 6));
  // }

  // void calcFoundation(){
  //   bool addNewWeek = true;
  //
  //   for(num year in range(minDate.year, maxDate.year + 1)){
  //     workoutsSorted[year.toInt()] = {};
  //   }
  //   DateTime currentMonday = getMondayOfWeekFromDay(minDate);
  //   while (addNewWeek){
  //     final int dayOfMonthMonday = int.parse(DateFormat('d').format(currentMonday));
  //     final int monthMonday = int.parse(DateFormat('M').format(currentMonday));
  //     final sunday = currentMonday.add(const Duration(days: 6));
  //     final int dayOfMonthSunday = int.parse(DateFormat('d').format(sunday));
  //     final int monthSunday = int.parse(DateFormat('M').format(sunday));
  //     workoutsSorted[currentMonday.year][DateFormat('yMd').format(currentMonday)] = {
  //       "name": "$dayOfMonthMonday.$monthMonday - $dayOfMonthSunday.$monthSunday",
  //       "counter": 0
  //     };
  //     currentMonday = sunday.add(const Duration(days:1));
  //     if(maxDate.isBefore(sunday)){
  //       addNewWeek = false;
  //     }
  //   }
  // }

  void setMinDate()async{
    ObWorkout? firstWorkout = objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(false)).order(ObWorkout_.date).build().findFirst();// .getAllAsync();
    if(firstWorkout != null){
      minDate = firstWorkout.date;
    }
  }

  // void sortWorkoutsInMap(){
  //   for(Workout w in allWorkouts){
  //     final year = w.date!.year;
  //     final int weekday = weekdayMapping[DateFormat('E').format(w.date!)]!;
  //     final weekKey = DateFormat('yMd').format(w.date!.subtract(Duration(days: weekday - 1)));
  //     workoutsSorted[year][weekKey]["counter"] = workoutsSorted[year][weekKey]["counter"] + 1;
  //   }
  // }

  final weekdayMapping = {
    "Mon": 1,
    "Tue": 2,
    "Wed": 3,
    "Thu": 4,
    "Fri": 5,
    "Sat": 6,
    "Sun": 7,
  };

  int getMaxDaysOfMonths(DateTime date){
    switch (date.month){
      case 4 || 6 || 9 || 11:
        return 30;
      case 2:
        return isLeapYear(date.year)? 29: 28;
      default:
        return 31;
    }
  }

  bool isLeapYear(int year){
    return (year%4==0 && (year%100!=0 || year%400==0));
  }

  void reset(){
		if(selectedWorkout != null && selectedExercise != null){
	    previousSelectedWorkout = selectedWorkout;
	    previousSelectedExercise = selectedExercise;
		}
    // selectedWorkout = null;
    // selectedExercise = null;
    exercisesPerWorkout.clear();
  }

  void refresh(){
    notifyListeners();
  }
}
