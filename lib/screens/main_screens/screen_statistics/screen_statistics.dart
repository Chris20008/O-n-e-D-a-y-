import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/selectors/exercise_selector.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:fitness_app/widgets/vertical_scroll_wheel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../util/config.dart';
import '../../../util/objectbox/ob_exercise.dart';
import '../../../util/objectbox/ob_workout.dart';
import '../../../widgets/standard_popup.dart';
import '../../other_screens/screen_settings.dart';
import 'charts/line_chart_exercise_weight_progress.dart';

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
        AnimatedBuilder(
          animation: cnScreenStatistics.animationControllerSettingPanel,
          builder: (context, child) {
            double scale = 1.0 - (cnScreenStatistics.animationControllerSettingPanel.value * 0.1);
            return Transform.scale(
              scale: scale,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(30 -  (scale*10-9)*25),
                  child: child
              ),
            );
          },
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    children: [
                      getHeader(),
                      const SizedBox(height: 20,),
                      LineChartExerciseWeightProgress(key: cnScreenStatistics.lineChartKey),
                      const SafeArea(top:false, child: SizedBox(height: 30,)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SettingsPanel()
      ],
    );
  }

  Widget getHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          // color: Colors.amber[200]!,
            color: Colors.white,
            onPressed: (){
              cnScreenStatistics.openSettingsPanel();
              // Navigator.push(
              //     context,
              //     CupertinoPageRoute(
              //         builder: (context) => const SettingsPanel()
              //     ));
            },
            icon: const Icon(
              Icons.settings,
            )
        ),
        SizedBox(height: 10,),
        SizedBox(
          height: 40,
          child: Stack(
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: ExerciseSelector(),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  // color: Colors.amber[200]!,
                    color: Colors.white,
                    onPressed: (){
                      cnScreenStatistics.saveCurrentFilterState();
                      openFilterPopUp();
                    },
                    icon: const Icon(
                      Icons.filter_list,
                    )
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void openFilterPopUp() {
    cnStandardPopUp.open(
        widthFactor: 0.95,
        maxWidth: 350,
        padding: const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 5),
        context: context,
        child: getPopUpChild(cnScreenStatistics.showAvgWeightPerSetLine),
        onConfirm: (){
          cnScreenStatistics.refreshData();
          Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime), (){
            // cnScreenStatistics.lineChartKey = UniqueKey();
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

  Widget getPopUpChild(bool isOn){
    return Column(
      children: [
        const Text(
          "Filter",
          textAlign: TextAlign.center,
          textScaler: TextScaler.linear(1.4),
          style: TextStyle(color: Colors.white),
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
                        cnScreenStatistics.allWorkoutNames.length, (index) =>
                        OverflowSafeText(
                            cnScreenStatistics.allWorkoutNames[index],
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
                    OverflowSafeText("Average Moved Weight Per Set", maxLines: 1),
                    Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: OverflowSafeText(
                        "Shows an additional line in the graph that indicates the average moved weight per set",
                        minFontSize: 9,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 30,),
              CupertinoSwitch(
                  value: isOn,
                  activeColor: const Color(0xFFC16A03),
                  onChanged: (value){
                    if(Platform.isAndroid){
                      HapticFeedback.selectionClick();
                    }
                    cnScreenStatistics.showAvgWeightPerSetLine = value;
                    cnStandardPopUp.child = getPopUpChild(cnScreenStatistics.showAvgWeightPerSetLine);
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
  String? selectedExerciseName;
  String? selectedWorkoutName;
  int selectedWorkoutIndex = 0;
  bool showAvgWeightPerSetLine = true;
  String? selectedWorkoutNameLast;
  int selectedWorkoutIndexLast = 0;
  bool showAvgWeightPerSetLineLast = true;
  late CnConfig cnConfig;

  /// Settings variables
  late final AnimationController animationControllerSettingPanel;
  final PanelController panelControllerSettings = PanelController();

  CnScreenStatistics(BuildContext context){
    cnConfig = Provider.of<CnConfig>(context, listen: false);
  }


  void init(Map? data) async{
    isInitialized = true;
    calcMinMaxDates();
    if(data != null){
      initCachedData(data);
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
    if(selectedExerciseName == null || !res.contains(selectedExerciseName)){
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

   List<double?>? getMinMaxWeights(){
    final exercises = getSelectedExerciseHistory();
    if(exercises == null){
      return null;
    }
    double minWeight = exercises.values.map((e) => e.weights.min).min;
    double maxWeight = exercises.values.map((e) => e.weights.max).max;
    return [minWeight, maxWeight];
  }

  Map<DateTime, double>? getMaxWeightsPerDate(){
    final Map<DateTime, ObExercise>? obExercises = getSelectedExerciseHistory();
    if(obExercises == null){
      return null;
    }
    Map<DateTime, double> maxWeights = {};
    for(MapEntry<DateTime, ObExercise> entry in obExercises.entries){
      maxWeights[entry.key] = entry.value.weights.max;
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
        for(List res in zip([entry.value.weights, entry.value.amounts])){
          totalWeight = totalWeight + res[0] * res[1];
        }
        final avgMovedWeightPerSet = totalWeight/entry.value.amounts.length;
        summedWeights[entry.key] = (summedWeights[entry.key]?? 0) + (avgMovedWeightPerSet);
      }
      return summedWeights;
    }

  void calcMinMaxDates()async{
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
        return date.isLeapYear()? 29: 28;
      default:
        return 31;
    }
  }

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
  }

  void restoreLastFilterState(){
    selectedWorkoutName = selectedWorkoutNameLast;
    selectedWorkoutIndex = selectedWorkoutIndexLast;
    showAvgWeightPerSetLine = showAvgWeightPerSetLineLast;
  }

  void refreshData(){
    allWorkoutNames = getAllWorkoutNames();
    allExerciseNames = getAllExerciseNames();
    calcMinMaxDates();
  }

  void initCachedData(Map data){
    if(data.containsKey("selectedExerciseName")){
      if(allExerciseNames.contains(data["selectedExerciseName"])){
        selectedExerciseName = data["selectedExerciseName"];
      }
    }
    showAvgWeightPerSetLine = data["showAvgWeightPerSetLine"] ?? true;
  }

  Future<void> cache() async{
    Map data = {
      "selectedExerciseName": selectedExerciseName,
      "showAvgWeightPerSetLine": showAvgWeightPerSetLine,
    };
    cnConfig.config.cnScreenStatistics = data;
    await cnConfig.config.save();
  }

  void refresh(){
    notifyListeners();
  }
}
