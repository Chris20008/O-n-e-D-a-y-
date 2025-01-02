import 'package:collection/collection.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/screens/main_screens/screen_workout_history/month_summary_chart.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:fitness_app/util/objectbox/ob_sick_days.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import '../../../objects/workout.dart';
import '../../../util/constants.dart';
import '../../../util/objectbox/ob_workout.dart';
import '../../../widgets/spotify_bar.dart';
import '../../../widgets/workout_expansion_tile.dart';
import '../../other_screens/screen_running_workout/screen_running_workout.dart';
import '../screen_workouts/panels/new_workout_panel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';

class ScreenWorkoutHistory extends StatefulWidget {
  const ScreenWorkoutHistory({super.key});

  @override
  State<ScreenWorkoutHistory> createState() => _ScreenWorkoutHistoryState();
}

class _ScreenWorkoutHistoryState extends State<ScreenWorkoutHistory> {

  late CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  late CnWorkoutHistory cnWorkoutHistory;

  @override
  Widget build(BuildContext context) {
    cnWorkoutHistory = Provider.of<CnWorkoutHistory>(context);
    final size = MediaQuery.of(context).size;
    // createListViewChildren();

    return SafeArea(
      top: false,
      bottom: false,
      child: SizedBox(
        height: size.height,
        child: Stack(
          children: [
            ScrollablePositionedList.separated(
                shrinkWrap: true,
                padding: EdgeInsets.only(top: Platform.isAndroid? 70 : 90, left: 20, right: 20, bottom: 0),
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 10);
                },
                addAutomaticKeepAlives: true,
                physics: const BouncingScrollPhysics(),
                key: cnWorkoutHistory.key,
                itemScrollController: cnWorkoutHistory.scrollController,
                itemCount: cnWorkoutHistory.workoutsAndSickDays.length+1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == cnWorkoutHistory.workoutsAndSickDays.length){
                    return SafeArea(
                        top: false,
                        left: false,
                        right: false,
                        child: AnimatedContainer(
                          height: cnSpotifyBar.height + 20 + (cnNewWorkout.minPanelHeight > 0? cnNewWorkout.minPanelHeight-MediaQuery.paddingOf(context).bottom : 0),
                          duration: const Duration(milliseconds: 300),
                        )
                    );
                  }

                  // if(index == 0){
                  //   return MonthSummaryChart();
                  // }

                  Widget child = Container();
                  // Widget childWithHeader = Container();
                  DateTime? dateOfWorkout;
                  final DateTime? previousDate = index > 0
                      ? cnWorkoutHistory.workoutsAndSickDays[index-1] is Workout
                        ? cnWorkoutHistory.workoutsAndSickDays[index-1].date
                        : cnWorkoutHistory.workoutsAndSickDays[index-1].startDate
                      : null;

                  if(cnWorkoutHistory.workoutsAndSickDays[index] is Workout){
                    dateOfWorkout = cnWorkoutHistory.workoutsAndSickDays[index].date;
                    child = WorkoutExpansionTile(
                      // key: UniqueKey(),
                        workout: cnWorkoutHistory.workoutsAndSickDays[index],
                        padding: EdgeInsets.zero,
                        onExpansionChange: (bool isOpen) => cnWorkoutHistory.opened[index] = isOpen,
                        initiallyExpanded: cnWorkoutHistory.opened[index]
                    );
                  }
                  else if(cnWorkoutHistory.workoutsAndSickDays[index] is ObSickDays){
                    print(cnWorkoutHistory.workoutsAndSickDays[index].startDate);
                    print(cnWorkoutHistory.workoutsAndSickDays[index].endDate);
                    print("");
                    dateOfWorkout = cnWorkoutHistory.workoutsAndSickDays[index].startDate;
                    child = sickDayWidget(cnWorkoutHistory.workoutsAndSickDays[index]);
                  }

                  final double heightOfSpacer = previousDate == null? 0 : 40;

                  /// check if date is not null
                  if (dateOfWorkout != null) {

                    /// Future
                    if(dateOfWorkout.isInFuture()){
                      if(previousDate == null){
                        child = getChildWithTimeHeader(
                            child: child,
                            headerText: AppLocalizations.of(context)!.historyFuture,
                            heightSpacer: heightOfSpacer,
                            textScaler: 1.8
                        );
                      }
                      // else{
                      //   childWithHeader = child;
                      // }
                    }

                    /// Today
                    else if(dateOfWorkout.isToday()){
                      if(previousDate == null || !previousDate.isToday()){
                        child = getChildWithTimeHeader(
                          child: child,
                          headerText: AppLocalizations.of(context)!.historyToday,
                          heightSpacer: previousDate == null? 0 : 40,
                          textScaler: 1.8,
                          /// with week header
                          dateForWeekDecoration: previousDate == null || !dateOfWorkout.isSameWeek(previousDate)? dateOfWorkout : null
                        );
                      }
                      // else{
                      //   childWithHeader = child;
                      // }
                    }

                    /// Yesterday
                    else if(dateOfWorkout.isYesterday()){
                      if(previousDate == null || !previousDate.isYesterday()){
                        child = getChildWithTimeHeader(
                            child: child,
                            headerText: AppLocalizations.of(context)!.historyYesterday,
                            heightSpacer: heightOfSpacer,
                            textScaler: 1.7,
                            /// with week header
                            dateForWeekDecoration: previousDate == null || !dateOfWorkout.isSameWeek(previousDate)? dateOfWorkout : null
                        );
                      }
                      // else{
                      //   childWithHeader = child;
                      // }
                    }

                    /// Last 7 days
                    else if(dateOfWorkout.isInLastSevenDays()){
                      if(previousDate == null
                          || previousDate.isToday()
                          || previousDate.isYesterday()
                          || previousDate.isInFuture() ){
                        child = getChildWithTimeHeader(
                            child: child,
                            headerText: AppLocalizations.of(context)!.historyLast7Days,
                            heightSpacer: heightOfSpacer,
                            textScaler: 1.7,
                            /// with week header
                            dateForWeekDecoration: previousDate == null || !dateOfWorkout.isSameWeek(previousDate)? dateOfWorkout : null
                        );
                      }
                      // else{
                      //   childWithHeader = child;
                      // }
                    }

                    /// Month Header
                    else if(previousDate == null
                        || previousDate.isInLastSevenDays()
                        || previousDate.isInFuture()
                        || !previousDate.isSameMonth(dateOfWorkout)
                    ){
                      child = getChildWithTimeHeader(
                          child: child,
                          headerText: DateFormat('MMMM y', Localizations.localeOf(context).languageCode).format(dateOfWorkout),
                          heightSpacer: heightOfSpacer,
                          textScaler: 1.7,
                          /// with week header
                          dateForWeekDecoration: previousDate == null || !dateOfWorkout.isSameWeek(previousDate)? dateOfWorkout : null,
                          summary: cnWorkoutHistory.monthSummaries.firstWhereOrNull((summ) => summ.date.isSameMonth(dateOfWorkout))
                      );
                    }
                    /// Week Header
                    else if(!dateOfWorkout.isSameWeek(previousDate)){
                      child = Column(
                        children: [
                          const SizedBox(height: 15,),
                          getWeekDecoration(Jiffy.parseFromDateTime(dateOfWorkout).weekOfYear.toString()),
                          const SizedBox(height: 5),
                          child
                        ],
                      );
                    }
                    // else{
                    //   childWithHeader = child;
                    // }
                  }

                  return child;
                },
            ),

            /// Calendar upper right corner
            SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: buildCalendarDialogButton(
                      context: context,
                      cnNewWorkout:
                      cnNewWorkout,
                      justShow: false,
                      buttonIsCalender: true,
                      onConfirm: (List<DateTime?> values){
                        if(values.isNotEmpty){
                          int? index;
                          DateTime selectedDate = values.first!;
                          while (true){
                            String key = DateFormat('yyyyMMdd').format(selectedDate);
                            if(cnWorkoutHistory.indexOfWorkout.keys.contains(key)){
                              index = cnWorkoutHistory.indexOfWorkout[key];
                            }
                            else if(cnWorkoutHistory.indexOfWorkout.keys.isNotEmpty &&
                                double.parse(key) > double.parse(cnWorkoutHistory.indexOfWorkout.keys.firstOrNull?? "0")
                            ){
                              index = 0;
                            }
                            if(index != null){
                              cnWorkoutHistory.scrollController.scrollTo(
                                  index: index,
                                  duration: const Duration(seconds: 1),
                                  alignment: index == 0
                                      ? 0.05 : index >= cnWorkoutHistory.indexOfWorkout.keys.length-1
                                      ? 0.6 : index >= cnWorkoutHistory.indexOfWorkout.keys.length-2
                                      ? 0.5 : index >= cnWorkoutHistory.indexOfWorkout.keys.length-3
                                      ? 0.3 :  0.1,
                                  curve: Curves.easeInOut
                              ).then((value) {
                                // setState(() {
                                //   cnWorkoutHistory.opened[index] = true;
                                // });
                              });
                              break;
                            }
                            else {
                              selectedDate = selectedDate.add(const Duration(days: 1, hours: 1)).toDate();
                            }
                          }
                        }
                      }
                  ),
                )
            )
          ],
        ),
      ),
    );
  }

  Widget getWeekDecoration(String weekOfYear){
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black.withOpacity(0.6),
        ),
        child: Text(
          "${AppLocalizations.of(context)!.historyWeek} $weekOfYear",
          textScaler: const TextScaler.linear(1),
        ),
      ),
    );
  }

  Widget getChildWithTimeHeader({
    required Widget child,
    required String headerText,
    required double heightSpacer,
    double textScaler = 1.7,
    DateTime? dateForWeekDecoration,
    MonthSummary? summary
  }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: heightSpacer),
        Center(
          child: Text(
            headerText,
            textScaler: TextScaler.linear(textScaler),
          ),
        ),
        if(summary != null)
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              MonthSummaryChart(summary: summary),
            ],
          ),
        if(dateForWeekDecoration != null)
          getWeekDecoration(Jiffy.parseFromDateTime(dateForWeekDecoration).weekOfYear.toString()),
        const SizedBox(height: 5),
        child
      ],
    );
  }

  Widget sickDayWidget(ObSickDays sickDay){
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.maxFinite,
        color: Colors.black.withOpacity(0.5),
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE d. MMMM', Localizations.localeOf(context).languageCode).format(sickDay.endDate),
                  textScaler: const TextScaler.linear(0.9),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w200
                  ),
                ),
                Text(
                  DateFormat('EEEE d. MMMM', Localizations.localeOf(context).languageCode).format(sickDay.startDate),
                  textScaler: const TextScaler.linear(0.9),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w200
                  ),
                ),
                const Text(
                  "Krank",
                  style: TextStyle(fontSize: 26),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 50),
              child: IconButton(
                  onPressed: () {
                    cnNewWorkout.editWorkout(sickDays: sickDay);
                  },
                  icon: Icon(Icons.edit,
                    color: Colors.grey.withOpacity(0.4),
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CnWorkoutHistory extends ChangeNotifier {
  List<Workout> workouts = [];
  List<ObSickDays> sickDays = [];
  Key key = UniqueKey();
  List<bool> opened = [];
  ItemScrollController scrollController = ItemScrollController();
  Map<String, int> indexOfWorkout = {};
  List workoutsAndSickDays = [];
  List<MonthSummary> monthSummaries = [];

  Future refreshAllWorkouts() async{
    List<Workout> tempWorkouts = [];
    Map<String, int> tempindexOfWorkout = {};
    List<ObSickDays> tempSickDays = [];
    List tempWorkoutsAndSickDays = [];
    List<MonthSummary> tempMonthSummaries = [];

    MonthSummary initSummary(DateTime date, int value) {
      MonthSummary summ = MonthSummary(DateTime(date.year, date.month+1, 0));
      if (value != 0) {
        summ.uniqueWorkouts.add("Krank");
        summ.workoutCounts["Krank"] = value;
      }
      return summ;
    }

    final builder = objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(false)).order(ObWorkout_.date, flags: Order.descending).build();
    List<ObWorkout> obWorkouts = await builder.findAsync();

    final builder2 = objectbox.sickDaysBox.query().order(ObSickDays_.startDate, flags: Order.descending).build();
    tempSickDays = await builder2.findAsync();
    List<ObSickDays> temp2SickDays = List.from(tempSickDays);

    int index = 0;
    for (ObWorkout w in obWorkouts) {
      Workout wo = Workout.fromObWorkout(w);
      tempWorkouts.add(wo);

      if (temp2SickDays.isNotEmpty && wo.date!.isBefore(temp2SickDays[0].startDate)){
        tempWorkoutsAndSickDays.add(temp2SickDays[0]);
        temp2SickDays.removeAt(0);
        index += 1;
      }
      tempWorkoutsAndSickDays.add(wo);

      final key = DateFormat('yyyyMMdd').format(w.date);
      if(!tempindexOfWorkout.containsKey(key)){
        tempindexOfWorkout[key] = index;
      }
      index += 1;
    }

    workouts = tempWorkouts;
    indexOfWorkout = tempindexOfWorkout;
    sickDays = tempSickDays;
    workoutsAndSickDays = tempWorkoutsAndSickDays;

    // for(ObSickDays d in sickDays){
    //   print(d.startDate);
    //   print(d.endDate);
    // }
    // print("second");
    // for(var d in workoutsAndSickDays){
    //   if(d is ObSickDays){
    //    print(d.startDate);
    //    print(d.endDate);
    //   }
    // }

    MonthSummary? summary = null;
    int cachedSickDays = 0;
    for(var item in workoutsAndSickDays){
      if(item is Workout){
        if(summary == null || !(summary.date.isSameMonth(item.date!))){
          if(summary != null) {
            tempMonthSummaries.add(summary);
          }
          summary = initSummary(item.date!, cachedSickDays);
          cachedSickDays = 0;
        }
        // else{
        summary.uniqueWorkouts.add(item.name);
        summary.workoutCounts[item.name] = (summary.workoutCounts[item.name]?? 0) + 1;
        // }
      }
      else if(item is ObSickDays){
        if(summary == null || !(summary.date.isSameMonth(item.endDate))){
          if(summary != null) {
            tempMonthSummaries.add(summary);
          }
          summary = initSummary(item.endDate, cachedSickDays);
          cachedSickDays = 0;
          summary.uniqueWorkouts.add("Krank");
          if(!item.startDate.isSameMonth(item.endDate)){
            summary.workoutCounts["Krank"] = (summary.workoutCounts["Krank"]?? 0) + item.endDate.day;
            cachedSickDays = item.startDate.numOfDaysTillLastDayOfMonth();
          }
          else{
            summary.workoutCounts["Krank"] = (summary.workoutCounts["Krank"]?? 0) + item.endDate.difference(item.startDate).inDays + 1;
          }
        }
        else{
          summary.uniqueWorkouts.add("Krank");
          if(!item.startDate.isSameMonth(item.endDate)){
            summary.workoutCounts["Krank"] = (summary.workoutCounts["Krank"]?? 0) + item.endDate.day;
            cachedSickDays = item.startDate.numOfDaysTillLastDayOfMonth();
          }
          else{
            summary.workoutCounts["Krank"] = (summary.workoutCounts["Krank"]?? 0) + item.endDate.difference(item.startDate).inDays + 1;
          }
        }
      }
    }
    if(summary != null){
      tempMonthSummaries.add(summary);
    }
    monthSummaries = tempMonthSummaries;
    // print("FINISHED");
    // for(MonthSummary summ in monthSummaries){
    //   print(summ.date);
    //   print(summ.workoutCounts);
    //   print("");
    // }

    opened = workoutsAndSickDays.map((e) => false).toList();

    // double pos = scrollController.position.pixels;
    refresh();
    // scrollController.jumpTo(pos);
  }

  void refresh(){
    notifyListeners();
  }
}

class MonthSummary{
  // int year;
  // int month;
  DateTime date;
  MonthSummary(this.date);
  Set<String> uniqueWorkouts = {};
  Map<String, int> workoutCounts = {};
}