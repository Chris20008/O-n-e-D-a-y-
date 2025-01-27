import 'dart:io';
import 'package:collection/collection.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/selectors/exercise_selector.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:fitness_app/util/objectbox/ob_sick_days.dart';
import 'package:fitness_app/widgets/initial_animated_screen.dart';
import 'package:fitness_app/widgets/vertical_scroll_wheel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../util/config.dart';
import '../../../util/objectbox/ob_exercise.dart';
import '../../../util/objectbox/ob_workout.dart';
import '../../../widgets/standard_popup.dart';
import '../../other_screens/screen_settings.dart';
import 'charts/exercise_line_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScreenStatistics extends StatefulWidget {
  const ScreenStatistics({super.key});

  @override
  State<ScreenStatistics> createState() => _ScreenStatisticsState();
}

class _ScreenStatisticsState extends State<ScreenStatistics> with WidgetsBindingObserver {
  late CnScreenStatistics cnScreenStatistics = Provider.of<CnScreenStatistics>(context);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  bool initOrientation = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // handleOrientation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    /// Using MediaQuery directly inside didChangeMetrics return the previous frame values.
    /// To receive the latest values after orientation change we need to use
    /// WidgetsBindings.instance.addPostFrameCallback() inside it
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        // setBottomMenuHeight();
        handleOrientation();
        // _height = orientation == Orientation.portrait? (Platform.isAndroid? 60 : 50) : (Platform.isAndroid? 35 : 30);
        // final double paddingBottom = MediaQuery.of(context).padding.bottom;
        // cnBottomMenu.height = paddingBottom + _height;
      });
    });
  }

  void handleOrientation(){
    cnScreenStatistics.orientation = MediaQuery.of(context).orientation;
    cnScreenStatistics.height = MediaQuery.of(context).size.height;
    cnScreenStatistics.width = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {

    if(cnScreenStatistics.width == 0 || cnScreenStatistics.height == 0 || initOrientation){
      initOrientation = false;
      handleOrientation();
    }

    return Stack(
      children: [
        InitialAnimatedScreen(
          animationControllerName: "ScreenStatistics",
          child: SafeArea(
            bottom: false,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: false,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              children: [
                getHeader(),
                // const SizedBox(height: 20,),
                ExerciseLineChart(key: cnScreenStatistics.lineChartKey),
                const SafeArea(top:false, child: SizedBox(height: 30,)),
              ],
            ),
          ),
        ),
        const SettingsPanel(),
      ],
    );
  }

  Widget getHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              // color: Colors.amber[200]!,
                color: Colors.white,
                onPressed: (){
                  cnScreenStatistics.saveCurrentFilterState();
                  openFilterPopUp(context);
                },
                icon: const Icon(
                  Icons.filter_list,
                )
            ),
            IconButton(
              // color: Colors.amber[200]!,
                color: Colors.white,
                onPressed: (){
                  cnScreenStatistics.openSettingsPanel();
                },
                icon: const Icon(
                  Icons.settings,
                )
            ),
          ],
        ),
        const Center(
          child: ExerciseSelector(),
        ),
      ],
    );
  }

  void openFilterPopUp(BuildContext context) {
    cnStandardPopUp.open(
        widthFactor: 0.95,
        maxWidth: 350,
        padding: const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 5),
        context: context,
        child: getPopUpChild(context),
        onConfirm: (){
          cnScreenStatistics.refreshData();
          Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime), (){
            cnScreenStatistics.refresh();
            cnScreenStatistics.cache();
          });
        },
        onCancel: (){
          cnScreenStatistics.restoreLastFilterState();
        },
        color: const Color(0xff2d2d2d)
    );
  }

  Widget getPopUpChild(BuildContext context){
    List<String> workoutNames = List.from(cnScreenStatistics.allWorkoutNames);
    /// Replace the "ALL Workouts" name in correct language
    workoutNames[0] = AppLocalizations.of(context)!.filterAllWorkouts;

    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.statisticsFilter,
          textAlign: TextAlign.center,
          textScaler: const TextScaler.linear(1.4),
          style: const TextStyle(color: Colors.white),
        ),
        mySeparator(heightTop: 5, heightBottom: 10, minusWidth: 0),
        SizedBox(
            height:50,
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_back_ios,
                  size: 15,
                  color: Color(0xFFC16A03),
                ),
                Expanded(
                  child: VerticalScrollWheel(
                    key: UniqueKey(),
                    widthOfChildren: 100,
                    heightOfChildren: 30,
                    onTap: (int index){
                      cnScreenStatistics.selectedWorkoutName = cnScreenStatistics.allWorkoutNames[index];
                      cnScreenStatistics.selectedWorkoutIndex = index;
                      HapticFeedback.selectionClick();
                    },
                    selectedIndex: cnScreenStatistics.selectedWorkoutIndex,
                    children: List<Widget>.generate(
                        workoutNames.length, (index) =>
                        OverflowSafeText(
                            workoutNames[index],
                            maxLines: 1
                        )
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                  color: Color(0xFFC16A03),
                ),
              ],
            )
        ),
        const SizedBox(height: 15,),
        Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OverflowSafeText(AppLocalizations.of(context)!.filterAvgMovWeightHead, maxLines: 2),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: OverflowSafeText(
                        AppLocalizations.of(context)!.filterAvgMovWeightText,
                        minFontSize: 9,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 30,),
              CupertinoSwitch(
                  value: cnScreenStatistics.showAvgWeightPerSetLine,
                  activeColor: const Color(0xFFC16A03),
                  onChanged: (value){
                    if(Platform.isAndroid){
                      HapticFeedback.selectionClick();
                    }
                    cnScreenStatistics.showAvgWeightPerSetLine = value;
                    cnStandardPopUp.child = getPopUpChild(context);
                    cnStandardPopUp.refresh();
                  }
              ),
            ]
        ),
        const SizedBox(height: 15,),
        Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OverflowSafeText("1RM Anzeigen", maxLines: 1),
                  ],
                ),
              ),
              const SizedBox(width: 30,),
              CupertinoSwitch(
                  value: cnScreenStatistics.showOneRepMax,
                  activeColor: const Color(0xFFC16A03),
                  onChanged: (value){
                    if(Platform.isAndroid){
                      HapticFeedback.selectionClick();
                    }
                    cnScreenStatistics.showOneRepMax = value;
                    cnStandardPopUp.child = getPopUpChild(context);
                    cnStandardPopUp.refresh();
                  }
              )
            ]
        ),
        const SizedBox(height: 15,),
        Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OverflowSafeText(AppLocalizations.of(context)!.filterOnlyWorkingSets, maxLines: 1),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: OverflowSafeText(
                        AppLocalizations.of(context)!.filterOnlyWorkingSetsText,
                        minFontSize: 9,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 30,),
              CupertinoSwitch(
                  value: cnScreenStatistics.onlyWorkingSets,
                  activeColor: const Color(0xFFC16A03),
                  onChanged: (value){
                    if(Platform.isAndroid){
                      HapticFeedback.selectionClick();
                    }
                    cnScreenStatistics.onlyWorkingSets = value;
                    cnStandardPopUp.child = getPopUpChild(context);
                    cnStandardPopUp.refresh();
                  }
              )
            ]
        ),
        const SizedBox(height: 15,),
        Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OverflowSafeText("Krankheitstage anzeigen", maxLines: 1),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 15),
                    //   child: OverflowSafeText(
                    //     AppLocalizations.of(context)!.filterOnlyWorkingSetsText,
                    //     minFontSize: 9,
                    //     maxLines: 4,
                    //     style: const TextStyle(color: Colors.grey, fontSize: 12),
                    //   ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(width: 30,),
              CupertinoSwitch(
                  value: cnScreenStatistics.showSickDays,
                  activeColor: const Color(0xFFC16A03),
                  onChanged: (value){
                    if(Platform.isAndroid){
                      HapticFeedback.selectionClick();
                    }
                    cnScreenStatistics.showSickDays = value;
                    cnStandardPopUp.child = getPopUpChild(context);
                    cnStandardPopUp.refresh();
                  }
              )
            ]
        ),
        const SizedBox(height: 10,)
      ],
    );
  }
}

class CnScreenStatistics extends ChangeNotifier {
  bool isInitialized = false;
  Orientation orientation = Orientation.portrait;
  double width = 0;
  double height = 0;
  Key lineChartKey = UniqueKey();
  DateTime minDate = DateTime.now();
  DateTime maxDate = DateTime.now().add(const Duration(days: 32));
  late List<String> allWorkoutNames = getAllWorkoutNames();
  late List<String> allExerciseNames = getAllExerciseNames();
  List<ObSickDays> allSickDays = [];

  String? selectedExerciseName;
  String? selectedWorkoutName;
  int selectedWorkoutIndex = 0;
  bool showAvgWeightPerSetLine = true;
  bool onlyWorkingSets = false;
  bool showOneRepMax = false;
  bool showSickDays = false;

  String? selectedWorkoutNameLast;
  int selectedWorkoutIndexLast = 0;
  bool showAvgWeightPerSetLineLast = true;
  bool onlyWorkingSetsLast = true;
  bool showOneRepMaxLast = true;
  bool showSickDaysLast = false;

  double currentVisibleDays = 0;
  double maxVisibleDays = 1900;
  double offsetMinX = 0;
  double offsetMaxX = 0;
  late CnConfig cnConfig;
  final health = Health();
  List<HealthDataPointWrapper> healthData = [];

  /// Settings variables
  // late final AnimationController animationControllerStatisticsScreen;
  final PanelController panelControllerSettings = PanelController();

  CnScreenStatistics(BuildContext context){
    cnConfig = Provider.of<CnConfig>(context, listen: false);
  }
  final types = [
    HealthDataType.WEIGHT
  ];

  void init(Map? data) async{
    isInitialized = true;
    calcMinMaxDates();
    if(data != null){
      initCachedData(data);
    }
    await health.configure();
    await refreshHealthData();
  }

  Future refreshHealthData() async{
    var now = DateTime.now();
    DateTime startTime = DateTime(2000, 1, 1);
    healthData = await health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: now,
        types: types
    ).then((value) => value.map((hdp) => HealthDataPointWrapper(hdp: hdp)).toList());
    if(Platform.isAndroid){
      healthData = healthData.reversed.toList();
    }
    for(final l in healthData){
      print(l.dateFrom);
      print(l.weight);
      print("");
    }
  }

  List<String> getAllWorkoutNames(){
    final query = objectbox.workoutBox.query().build().property(ObWorkout_.name);
    query.distinct = true;
    final res = query.find();
    res.sort();
    res.insert(0, "All Workouts");
    return res;
  }
  
  List<String> getAllExerciseNames(){
    final builder = objectbox.exerciseBox.query();
    builder.backlinkMany(ObWorkout_.exercises, ObWorkout_.isTemplate.equals(false));
    if(selectedWorkoutName != null && selectedWorkoutName != "All Workouts") {
      builder.backlinkMany(ObWorkout_.exercises, ObWorkout_.name.equals(selectedWorkoutName!));
    }
    final query = builder.build().property(ObExercise_.name);
    query.distinct = true;
    final res = query.find();
    res.sort();
    if((selectedExerciseName == null || !res.contains(selectedExerciseName)) && selectedExerciseName != "Gewicht"){
      selectedExerciseName = res.firstOrNull;
    }
    return res;
  }

  Map<DateTime, ObExercise>? getSelectedExerciseHistory(){
    try{
      final List<ObWorkout> obWorkouts = objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(false)).order(ObWorkout_.date).build().find();
      Map<DateTime, ObExercise> datesAndExercises = {};

      for(ObWorkout obw in obWorkouts){
        final ObExercise? obEx = obw.exercises.firstWhereOrNull((e) => e.name == selectedExerciseName);
        if(obEx == null){
          continue;
        }
        datesAndExercises[obw.date] = obEx;
      }
      return datesAndExercises;
    } on TypeError catch (_){
      return null;
    }

  }

  //  List<double?>? getMinMaxWeights(){
  //   final exercises = getSelectedExerciseHistory();
  //   if(exercises == null){
  //     return null;
  //   }
  //   double minWeight = exercises.values.map((e) => e.weights.min).min;
  //   double maxWeight = exercises.values.map((e) => e.weights.max).max;
  //   return [minWeight, maxWeight];
  // }

  Map<DateTime, double>? getMaxWeightsPerDate(){
    if(selectedExerciseName == "Gewicht"){
      return { for (var e in healthData) e.dateFrom : e.weight };
    }
    final Map<DateTime, ObExercise>? obExercises = getSelectedExerciseHistory();
    if(obExercises == null){
      return null;
    }
    Map<DateTime, double> maxWeights = {};
    for(MapEntry<DateTime, ObExercise> entry in obExercises.entries){
      List<int> indexToRemove = [];
      if(onlyWorkingSets){
        entry.value.setTypes.forEachIndexed((index, element) {
          if(element == 1){
            indexToRemove.add(index);
          }
        });
        List<double> cleanedEntry = entry.value.weights.whereIndexed((index, element) => !indexToRemove.contains(index)).toList();
        if(cleanedEntry.isNotEmpty){
          maxWeights[entry.key] = entry.value.weights.whereIndexed((index, element) => !indexToRemove.contains(index)).max;
        }
      } else{
        maxWeights[entry.key] = entry.value.weights.max;
      }
    }
    return maxWeights;
  }

  Map<DateTime, double>? getAvgMovedWeightPerSet(){
      final exercises = getSelectedExerciseHistory();
      if(exercises == null){
        return null;
      }
      Map<DateTime, double> summedWeights = {};
      for(MapEntry<DateTime, ObExercise> entry in exercises.entries){
        double totalWeight = 0;
        int countingSets = 0;
        for(List res in zip([entry.value.weights, entry.value.amounts, entry.value.setTypes])){
          if(onlyWorkingSets && res[2] == 1){
            continue;
          }
          totalWeight = totalWeight + res[0] * res[1];
          countingSets += 1;
        }
        if(countingSets == 0){
          continue;
        }
        final avgMovedWeightPerSet = totalWeight/countingSets;
        summedWeights[entry.key] = (summedWeights[entry.key]?? 0) + (avgMovedWeightPerSet);
      }
      return summedWeights;
    }

  Map<DateTime, double>? getOneRepMaxPerDate(){
    double bodyWeight = 0;
    // if(["Dips Max", "Dips Reps", "Klimmzüge Hypertrophie", "Klimmzüge Maximalkraft", "Squat Langhantel"].contains(selectedExerciseName)){
    //   bodyWeight = 82;
    // }
    final exercises = getSelectedExerciseHistory();
    if(exercises == null){
      return null;
    }
    Map<DateTime, double> oneRepMaxPerDate = {};
    for(MapEntry<DateTime, ObExercise> entry in exercises.entries){
      double oneRepMax = 0;
      if(healthData.isNotEmpty){
        HealthDataPointWrapper datesBodyWeight = healthData.firstWhereOrNull((hdp) => hdp.dateFrom.isBefore(entry.key) | hdp.dateFrom.isSameDate(entry.key))??
            healthData.reversed.firstWhere((hdp) => hdp.dateFrom.isAfter(entry.key));
        bodyWeight = datesBodyWeight.weight;
        print("SELECT Weight Point ${datesBodyWeight.dateFrom} for date ${entry.key}");
      }
      for(List set in zip([entry.value.weights, entry.value.amounts, entry.value.setTypes])){
        if(onlyWorkingSets && set[2] == 1){
          continue;
        }
        print(bodyWeight);
        final tempOneRepMax = calcEpley(weight: set[0], reps: set[1], bodyWeight: bodyWeight);
        if(tempOneRepMax > oneRepMax){
          oneRepMax = tempOneRepMax;
        }
      }
      oneRepMaxPerDate[entry.key] = oneRepMax;
    }
    return oneRepMaxPerDate;
  }

  void calcMinMaxDates()async{
    if (selectedExerciseName == "Gewicht"){
      minDate = healthData.last.dateFrom;
      maxDate = healthData.first.dateFrom;
    }
    ObWorkout? firstWorkout;
    final firstBuilder = objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(false));
    if(selectedExerciseName != null) {
      firstBuilder.linkMany(ObWorkout_.exercises, ObExercise_.name.equals(selectedExerciseName!));
    }
    firstWorkout = firstBuilder.order(ObWorkout_.date).build().findFirst();
    if(firstWorkout != null){
      minDate = firstWorkout.date;
    }

    ObWorkout? lastWorkout;
    final lastBuilder = objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(false));
    if(selectedExerciseName != null) {
      lastBuilder.linkMany(ObWorkout_.exercises, ObExercise_.name.equals(selectedExerciseName!));
    }
    lastWorkout = lastBuilder.order(ObWorkout_.date, flags: Order.descending).build().findFirst();
    if(lastWorkout != null){
      maxDate = lastWorkout.date;
    }
  }

  // final weekdayMapping = {
  //   "Mon": 1,
  //   "Tue": 2,
  //   "Wed": 3,
  //   "Thu": 4,
  //   "Fri": 5,
  //   "Sat": 6,
  //   "Sun": 7,
  // };

  // int getMaxDaysOfMonths(DateTime date){
  //   switch (date.month){
  //     case 4 || 6 || 9 || 11:
  //       return 30;
  //     case 2:
  //       return date.isLeapYear()? 29: 28;
  //     default:
  //       return 31;
  //   }
  // }

  void openSettingsPanel(){
    HapticFeedback.selectionClick();
    panelControllerSettings.animatePanelToPosition(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.decelerate
    );
  }

  void saveCurrentFilterState(){
    selectedWorkoutNameLast = selectedWorkoutName;
    selectedWorkoutIndexLast = selectedWorkoutIndex;
    showAvgWeightPerSetLineLast = showAvgWeightPerSetLine;
    onlyWorkingSetsLast = onlyWorkingSets;
    showOneRepMaxLast = showOneRepMax;
    showSickDaysLast = showSickDays;
  }

  void restoreLastFilterState(){
    selectedWorkoutName = selectedWorkoutNameLast;
    selectedWorkoutIndex = selectedWorkoutIndexLast;
    showAvgWeightPerSetLine = showAvgWeightPerSetLineLast;
    onlyWorkingSets = onlyWorkingSetsLast;
    showOneRepMax = showOneRepMaxLast;
    showSickDays = showSickDaysLast;
  }

  void refreshData(){
    allWorkoutNames = getAllWorkoutNames();
    allExerciseNames = getAllExerciseNames();
    allExerciseNames.insert(0, "Gewicht");
    calcMinMaxDates();
    allSickDays = objectbox.sickDaysBox.getAll();
  }

  void initCachedData(Map data){
    if(data.containsKey("selectedExerciseName")){
      if(allExerciseNames.contains(data["selectedExerciseName"])){
        selectedExerciseName = data["selectedExerciseName"];
      }
    }
    showAvgWeightPerSetLine = data["showAvgWeightPerSetLine"] ?? true;
    onlyWorkingSets = data["onlyWorkingSets"] ?? false;
    showSickDays = data["showSickDays"] ?? true;
    showOneRepMax = data["showOneRepMax"] ?? true;
  }

  void resetGraph({bool withKeyReset = true}){
    maxVisibleDays = 1900;
    offsetMinX = 0;
    offsetMaxX = 0;
    if(withKeyReset){
      lineChartKey = UniqueKey();
    }
  }

  Future<void> cache() async{
    Map data = {
      "selectedExerciseName": selectedExerciseName,
      "showAvgWeightPerSetLine": showAvgWeightPerSetLine,
      "onlyWorkingSets": onlyWorkingSets,
      "showSickDays": showSickDays,
      "showOneRepMax": showOneRepMax,
    };
    cnConfig.config.cnScreenStatistics = data;
    await cnConfig.config.save();
  }

  void refresh(){
    notifyListeners();
  }
}

class HealthDataPointWrapper{
  final HealthDataPoint hdp;
  late final Map<String, dynamic> json;

  HealthDataPointWrapper({
    required this.hdp
  }){
   json = hdp.toJson();
  }

  DateTime get dateFrom => hdp.dateFrom;
  DateTime get dateTo => hdp.dateTo;
  double get weight => json['value']['numericValue'];
}