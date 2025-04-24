import 'dart:io';
import 'package:collection/collection.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/objects/exercise.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/selectors/exercise_selector.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:fitness_app/util/objectbox/ob_sick_days.dart';
import 'package:fitness_app/widgets/cupertino_button_text.dart';
import 'package:fitness_app/widgets/slide_up_panel/initial_animated_screen.dart';
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
import '../../other_screens/screen_settings/screen_settings.dart';
import 'charts/exercise_line_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScreenStatistics extends StatefulWidget {
  const ScreenStatistics({super.key});

  @override
  State<ScreenStatistics> createState() => _ScreenStatisticsState();
}

class _ScreenStatisticsState extends State<ScreenStatistics> with WidgetsBindingObserver {
  late CnScreenStatistics cnScreenStatistics;
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
        handleOrientation();
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
    print("Refresh Screen statistics");
    cnScreenStatistics = Provider.of<CnScreenStatistics>(context);

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

  void openFilterPopUp(BuildContext context) async{

    final result = await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context){
        return getFilterWidget(context);
      }
    );

    print("RESULT $result");

    if(result == true){
      cnScreenStatistics.refreshData(context);
      Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime), (){
        cnScreenStatistics.refresh();
        cnScreenStatistics.cache();
      });
    } else{
      cnScreenStatistics.restoreLastFilterState();
    }

  }

  Widget getFilterWidget(BuildContext context){
    List<String> workoutNames = List.from(cnScreenStatistics.allWorkoutNames);
    /// Replace the "ALL Workouts" name in correct language
    workoutNames[0] = AppLocalizations.of(context)!.filterAllWorkouts;

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: MediaQuery.of(context).size.height*0.6,
        color: Theme.of(context).primaryColor,
        child: StatefulBuilder(
          builder: (context, setModalState){
            return Stack(
              children: [
                ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 50,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                          height:50,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.arrow_back_ios,
                                size: 15,
                              ),
                              Expanded(
                                child: VerticalScrollWheel(
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
                              ),
                            ],
                          )
                      ),
                    ),
                    CupertinoListSection.insetGrouped(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor
                      ),
                      backgroundColor: Colors.transparent,
                      header: const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text("Graph", style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w300),),
                      ),
                      // footer: GestureDetector(
                      //   onTap: () async{
                      //     HapticFeedback.selectionClick();
                      //   },
                      //   child: Padding(
                      //     padding: const EdgeInsets.only(left: 10),
                      //     child: Row(
                      //       children: [
                      //         const Icon(
                      //           Icons.info,
                      //           size:12,
                      //           color: Colors.white,
                      //         ),
                      //         const SizedBox(width: 5,),
                      //         Text(AppLocalizations.of(context)!.settingsBackupMoreInfo, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w300),),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      children: [
                        CupertinoListTile(
                          title: OverflowSafeText(
                              maxLines: 1,
                              AppLocalizations.of(context)!.statisticsFilter1RM,
                              style: const TextStyle(color: Colors.white)
                          ),
                          trailing: CupertinoSwitch(
                              value: cnScreenStatistics.showOneRepMax,
                              activeTrackColor: activeColor,
                              onChanged: (value){
                                setModalState(() {
                                  if(Platform.isAndroid){
                                    HapticFeedback.selectionClick();
                                  }
                                  cnScreenStatistics.showOneRepMax = value;
                                });
                              }
                          ),
                        ),

                        CupertinoListTile(
                          title: OverflowSafeText(
                              maxLines: 2,
                              AppLocalizations.of(context)!.filterAvgMovWeightHead,
                              style: const TextStyle(color: Colors.white)
                          ),
                          trailing: CupertinoSwitch(
                              value: cnScreenStatistics.showAvgWeightPerSetLine,
                              activeTrackColor: activeColor,
                              onChanged: (value){
                                setModalState(() {
                                  if(Platform.isAndroid){
                                    HapticFeedback.selectionClick();
                                  }
                                  cnScreenStatistics.showAvgWeightPerSetLine = value;
                                });
                              }
                          ),
                        ),
                        CupertinoListTile(
                            title: OverflowSafeText(
                                maxLines: 1,
                                AppLocalizations.of(context)!.statisticsFilterSickDays,
                                style: const TextStyle(color: Colors.white)
                            ),
                            trailing: CupertinoSwitch(
                                value: cnScreenStatistics.showSickDays,
                                activeTrackColor: activeColor,
                                onChanged: (value){
                                  setModalState(() {
                                    if(Platform.isAndroid){
                                      HapticFeedback.selectionClick();
                                    }
                                    cnScreenStatistics.showSickDays = value;
                                  });
                                }
                            )
                        ),
                      ],
                    ),

                    CupertinoListSection.insetGrouped(
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor
                      ),
                      backgroundColor: Colors.transparent,
                      header: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(AppLocalizations.of(context)!.other, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w300),),
                      ),
                      children: [
                        CupertinoListTile(
                            title: OverflowSafeText(
                                maxLines: 1,
                                AppLocalizations.of(context)!.filterOnlyWorkingSets,
                                style: const TextStyle(color: Colors.white)
                            ),
                            trailing: CupertinoSwitch(
                                value: cnScreenStatistics.onlyWorkingSets,
                                activeTrackColor: activeColor,
                                onChanged: (value){
                                  setModalState(() {
                                    if(Platform.isAndroid){
                                      HapticFeedback.selectionClick();
                                    }
                                    cnScreenStatistics.onlyWorkingSets = value;
                                  });
                                }
                            )
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 10,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: CupertinoButtonText(
                                  onPressed: (){
                                    Navigator.of(context).pop(false);
                                  },
                                  text: AppLocalizations.of(context)!.cancel,
                                  textAlign: TextAlign.left
                              )
                          )
                      ),
                      Expanded(
                          flex: 11,
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.statisticsFilter,
                              textScaler: const TextScaler.linear(1.3),
                              textAlign: TextAlign.center,
                            ),
                          )
                      ),
                      Expanded(
                          flex: 10,
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: CupertinoButtonText(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  text: AppLocalizations.of(context)!.save,
                                  textAlign: TextAlign.right
                              )
                          )
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
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
  late List<String> allExerciseNames;
  List<ObSickDays> allSickDays = [];
  GlobalKey backupOptionsKey = GlobalKey();

  Exercise selectedExerciseFirst = Exercise();
  Exercise selectedExerciseLast = Exercise();
  Exercise? selectedExerciseTemplate;
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
  final PanelController panelControllerSettings = PanelController();

  CnScreenStatistics(BuildContext context){
    cnConfig = Provider.of<CnConfig>(context, listen: false);
  }
  final types = [
    HealthDataType.WEIGHT
  ];

  void init(Map? data, BuildContext context) async{
    isInitialized = true;
    await health.configure();
    await refreshHealthData();
    allExerciseNames = getAllExerciseNames(context);
    calcMinMaxDates(context);
    if(data != null){
      initCachedData(data, context);
    }
  }

  Future<bool> refreshHealthData() async{
    if(!cnConfig.useHealthData){
      healthData.clear();
      return false;
    }
    var now = DateTime.now();
    DateTime startTime = DateTime(2000, 1, 1);
    try{
      healthData = await health.getHealthDataFromTypes(
          startTime: startTime,
          endTime: now,
          types: types
      ).then((value) => value.map((hdp) => HealthDataPointWrapper(hdp: hdp)).toList());
      if(Platform.isAndroid){
        healthData = healthData.reversed.toList();
      }
      if(healthData.isEmpty){
        return false;
      }
      return true;
    }
    catch (_){
      return false;
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
  
  List<String> getAllExerciseNames(BuildContext context){
    final builder = objectbox.exerciseBox.query();
    builder.backlinkMany(ObWorkout_.exercises, ObWorkout_.isTemplate.equals(false));
    if(selectedWorkoutName != null && selectedWorkoutName != "All Workouts") {
      builder.backlinkMany(ObWorkout_.exercises, ObWorkout_.name.equals(selectedWorkoutName!));
    }
    final query = builder.build().property(ObExercise_.name);
    query.distinct = true;
    final res = query.find();
    res.sort();
    if((selectedExerciseName == null || !res.contains(selectedExerciseName)) && (selectedExerciseName != AppLocalizations.of(context)!.statisticsWeight || !cnConfig.useHealthData)){
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

  Map<DateTime, double>? getMaxWeightsPerDate(BuildContext context){
    if(selectedExerciseName == AppLocalizations.of(context)!.statisticsWeight){
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
      if(healthData.isNotEmpty && (
          (selectedExerciseTemplate != null && selectedExerciseTemplate!.bodyWeightPercent > 0.0) ||
          (selectedExerciseTemplate == null && selectedExerciseLast.bodyWeightPercent > 0)
      )){
        HealthDataPointWrapper datesBodyWeight = healthData.firstWhereOrNull((hdp) => hdp.dateFrom.isBefore(entry.key) | hdp.dateFrom.isSameDate(entry.key))??
            healthData.reversed.firstWhere((hdp) => hdp.dateFrom.isAfter(entry.key));
        double bodyWeightPercent = selectedExerciseTemplate?.bodyWeightPercent?? selectedExerciseLast.bodyWeightPercent;
        bodyWeight = datesBodyWeight.weight * bodyWeightPercent;
      }
      for(List set in zip([entry.value.weights, entry.value.amounts, entry.value.setTypes])){
        if(onlyWorkingSets && set[2] == 1){
          continue;
        }
        final tempOneRepMax = calcEpley(weight: set[0], reps: set[1], bodyWeight: bodyWeight);
        if(tempOneRepMax > oneRepMax){
          oneRepMax = tempOneRepMax;
        }
      }
      oneRepMaxPerDate[entry.key] = oneRepMax;
    }
    return oneRepMaxPerDate;
  }

  void calcMinMaxDates(BuildContext context)async{
    if (selectedExerciseName == AppLocalizations.of(context)!.statisticsWeight){
      minDate = healthData.last.dateFrom;
      maxDate = healthData.first.dateFrom;
      return;
    }
    setExerciseTemplate(context);
    setExerciseFirst(context);
    setExerciseLast(context);
  }

  void setExerciseFirst(BuildContext context){
    if (selectedExerciseName == AppLocalizations.of(context)!.statisticsWeight){
      return;
    }
    ObWorkout? firstWorkout;
    final firstBuilder = objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(false));
    if(selectedExerciseName != null) {
      firstBuilder.linkMany(ObWorkout_.exercises, ObExercise_.name.equals(selectedExerciseName!));
    }
    firstWorkout = firstBuilder.order(ObWorkout_.date).build().findFirst();
    if(firstWorkout != null){
      minDate = firstWorkout.date;
      selectedExerciseFirst = Exercise.fromObExercise(firstWorkout.exercises.firstWhere((ex) => ex.name == selectedExerciseName));
    }
  }

  void setExerciseLast(BuildContext context){
    if (selectedExerciseName == AppLocalizations.of(context)!.statisticsWeight){
      return;
    }
    ObWorkout? lastWorkout;
    final lastBuilder = objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(false));
    if(selectedExerciseName != null) {
      lastBuilder.linkMany(ObWorkout_.exercises, ObExercise_.name.equals(selectedExerciseName!));
    }
    lastWorkout = lastBuilder.order(ObWorkout_.date, flags: Order.descending).build().findFirst();
    if(lastWorkout != null){
      maxDate = lastWorkout.date;
      selectedExerciseLast = Exercise.fromObExercise(lastWorkout.exercises.firstWhere((ex) => ex.name == selectedExerciseName));
    }
  }

  void setExerciseTemplate(BuildContext context){
    if (selectedExerciseName == AppLocalizations.of(context)!.statisticsWeight){
      return;
    }
    ObWorkout? templateWorkout;
    final lastBuilder = objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(true));
    if(selectedExerciseName != null) {
      lastBuilder.linkMany(ObWorkout_.exercises, ObExercise_.name.equals(selectedExerciseName!));
      templateWorkout = lastBuilder.order(ObWorkout_.date, flags: Order.descending).build().findFirst();
      if(templateWorkout != null){
        selectedExerciseTemplate = Exercise.fromObExercise(templateWorkout.exercises.firstWhere((ex) => ex.name == selectedExerciseName));
      }
      else{
        selectedExerciseTemplate = null;
      }
      return;
    }
    selectedExerciseTemplate = null;
  }

  void openSettingsPanel(){
    HapticFeedback.selectionClick();
    panelControllerSettings.animatePanelToPosition(
        1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastEaseInToSlowEaseOut
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

  void refreshData(BuildContext context){
    allWorkoutNames = getAllWorkoutNames();
    allExerciseNames = getAllExerciseNames(context);
    if(cnConfig.useHealthData){
      allExerciseNames.insert(0, AppLocalizations.of(context)!.statisticsWeight);
    }
    calcMinMaxDates(context);
    allSickDays = objectbox.sickDaysBox.getAll();
  }

  void initCachedData(Map data, BuildContext context){
    if(data.containsKey("selectedExerciseName")){
      if((allExerciseNames.contains(data["selectedExerciseName"])) | (data["selectedExerciseName"] == AppLocalizations.of(context)!.statisticsWeight && cnConfig.useHealthData)){
        selectedExerciseName = data["selectedExerciseName"];
      }
    }
    showAvgWeightPerSetLine = data["showAvgWeightPerSetLine"] ?? false;
    onlyWorkingSets = data["onlyWorkingSets"] ?? true;
    showSickDays = data["showSickDays"] ?? false;
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
    print("Should notify Listeners");
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