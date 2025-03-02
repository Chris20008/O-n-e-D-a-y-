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
  /// Overlay to prevent user seeing the jump of the scrollController when initializing the page
  /// Since ItemScrollController has no initialScrollOffset like the normal ScrollController
  /// Happens when user switches between ScreenWorkoutHistory and ScreenStatistics
  bool showOverlay = true;

  void jumpToLastPosition() async{
    while(!cnWorkoutHistory.scrollController.isAttached){
      await Future.delayed(const Duration(milliseconds: 1), (){});
    }
    cnWorkoutHistory.scrollController.jumpTo(index: cnWorkoutHistory.lastScrollIndex);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// executes after build
      cnWorkoutHistory.scrollController.jumpTo(index: cnWorkoutHistory.lastScrollIndex);
      Future.delayed(const Duration(milliseconds: 10), (){
        setState(() {
          showOverlay = false;
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    cnWorkoutHistory.saveLastScrollIndex();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    cnWorkoutHistory = Provider.of<CnWorkoutHistory>(context);

    final size = MediaQuery.of(context).size;

    return SafeArea(
      top: false,
      bottom: false,
      child: SizedBox(
        height: size.height,
        child: Stack(
          children: [
            ScrollablePositionedList.separated(
                itemPositionsListener: cnWorkoutHistory.itemPositionsListener,
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

                  Widget child = Container();
                  DateTime? dateOfWorkout;
                  final DateTime? previousDate = index > 0
                      ? cnWorkoutHistory.workoutsAndSickDays[index-1] is Workout
                        ? cnWorkoutHistory.workoutsAndSickDays[index-1].date
                        : cnWorkoutHistory.workoutsAndSickDays[index-1].startDate
                      : null;

                  if(cnWorkoutHistory.workoutsAndSickDays[index] is Workout){
                    dateOfWorkout = cnWorkoutHistory.workoutsAndSickDays[index].date;
                    child = WorkoutExpansionTile(
                      workout: cnWorkoutHistory.workoutsAndSickDays[index],
                      padding: EdgeInsets.zero,
                      onExpansionChange: (bool isOpen) => cnWorkoutHistory.opened[index] = isOpen,
                      initiallyExpanded: cnWorkoutHistory.opened[index],
                    );
                  }
                  else if(cnWorkoutHistory.workoutsAndSickDays[index] is ObSickDays){
                    dateOfWorkout = cnWorkoutHistory.workoutsAndSickDays[index].startDate;
                    child = sickDayWidget(
                        cnWorkoutHistory.workoutsAndSickDays[index]
                    );
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
                            textScaler: 1.8,
                            isSameWeek: previousDate?.isSameWeek(dateOfWorkout)?? false
                        );
                      }
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
                          dateForWeekDecoration: previousDate == null || !dateOfWorkout.isSameWeek(previousDate)? dateOfWorkout : null,
                          isSameWeek: previousDate?.isSameWeek(dateOfWorkout)?? false
                        );
                      }
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
                            dateForWeekDecoration: previousDate == null || !dateOfWorkout.isSameWeek(previousDate)? dateOfWorkout : null,
                            isSameWeek: previousDate?.isSameWeek(dateOfWorkout)?? false
                        );
                      }
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
                            dateForWeekDecoration: previousDate == null || !dateOfWorkout.isSameWeek(previousDate)? dateOfWorkout : null,
                            isSameWeek: previousDate?.isSameWeek(dateOfWorkout)?? false
                        );
                      }
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
                          summary: cnWorkoutHistory.monthSummaries.values.firstWhereOrNull((summ) => summ.date.isSameMonth(dateOfWorkout)),
                          isSameWeek: previousDate?.isSameWeek(dateOfWorkout)?? false
                      );
                    }
                    /// Week Header
                    else if(!dateOfWorkout.isSameWeek(previousDate)){
                      child = Column(
                        children: [
                          const SizedBox(height: 15,),
                          getWeekDecoration(Jiffy.parseFromDateTime(dateOfWorkout).weekOfYear.toString()),
                          const SizedBox(height: 5),
                          child,
                        ],
                      );
                    }
                  }
                  return child;
                },
            ),

            if(showOverlay)
              /// Overlay to prevent user seeing the jump of the scrollController when initializing the page
              Container(
                height: double.maxFinite,
                width: double.maxFinite,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0xffc26a0e),
                          Color(0xff110a02)
                        ]
                    )
                ),
              ),

            /// Calendar upper right corner
            SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Listener(
                    onPointerDown: (PointerDownEvent event){
                      cnWorkoutHistory.refresh();
                    },
                    child: buildCalendarDialogButton(
                        context: context,
                        cnNewWorkout: cnNewWorkout,
                        justShow: false,
                        buttonIsCalender: true,
                        dateValues: getCurrentDate(),
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
                                setState(() {
                                  cnWorkoutHistory.opened[index!] = true;
                                });
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
                                  // Future.delayed(const Duration(seconds: 1), (){
                                  //   setState(() {
                                  //     cnWorkoutHistory.opened[index!] = true;
                                  //     print(cnWorkoutHistory.opened);
                                  //   });
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
                  ),
                )
            ),
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
    MonthSummary? summary,
    required bool isSameWeek
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
              if(isSameWeek)
                const SizedBox(height: 20)
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
                Text(
                  AppLocalizations.of(context)!.statisticsSick,
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

  List<DateTime> getCurrentDate() {
    if(cnWorkoutHistory.workoutsAndSickDays.isEmpty){
      return [DateTime.now()];
    }
    final sortedValues = cnWorkoutHistory.itemPositionsListener.itemPositions.value.sorted((a, b) => a.index.compareTo(b.index));
    int index = (sortedValues.firstWhereOrNull((element) => element.itemLeadingEdge > -0.02)?.index?? 0);
    index = (index > (cnWorkoutHistory.workoutsAndSickDays.length-1))? index-1 : index;
    final item = cnWorkoutHistory.workoutsAndSickDays[index >= 0 ? index : 0];
    return [(item is Workout)? item.date : item.startDate];
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
  Map<DateTime, MonthSummary> monthSummaries = {};
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  int lastScrollIndex = 0;

  Future refreshAllWorkouts() async{
    List<Workout> tempWorkouts = [];
    Map<String, int> tempindexOfWorkout = {};
    List<ObSickDays> tempSickDays = [];
    List tempWorkoutsAndSickDays = [];
    Map<DateTime, MonthSummary> tempMonthSummaries = {};

    MonthSummary initSummary(DateTime date, List<DateTime> cachedSickDates) {
      while(true){
        if(tempMonthSummaries.keys.contains(cachedSickDates.lastOrNull?? "")){
          tempMonthSummaries[cachedSickDates.last]?.differentDaysWithWorkoutOrSick["Sick"]?.addAll(cachedSickDates.where((element) => element.isSameMonth(cachedSickDates.last)));
          tempMonthSummaries[cachedSickDates.last]?.uniqueWorkouts.add("Sick");
          cachedSickDates = cachedSickDates.where((d) => !d.isSameMonth(cachedSickDates.last)).toList();
        } else{
          break;
        }
      }
      MonthSummary summ = tempMonthSummaries[DateTime(date.year, date.month+1, 0).toDate()]?? MonthSummary(DateTime(date.year, date.month+1, 0));
      List<DateTime> tempDates = cachedSickDates.where((d) => d.isSameMonth(date)).toList();
      if (cachedSickDates.isNotEmpty) {
        summ.uniqueWorkouts.add("Sick");
        summ.workoutCounts["Sick"] = tempDates.length;
      }
      summ.differentDaysWithWorkoutOrSick["Sick"]?.addAll(tempDates);
      cachedSickDates = cachedSickDates.where((d) => !d.isSameMonth(date)).toList();
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

      while (temp2SickDays.isNotEmpty && wo.date!.isBefore(temp2SickDays[0].startDate)){
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

    MonthSummary? summary = null;
    List<DateTime> cachedSickDates = [];
    for(var item in workoutsAndSickDays){
      /// do workout logic
      if(item is Workout){
        if(summary == null || !(summary.date.isSameMonth(item.date!))){
          if(summary != null) {
            tempMonthSummaries[summary.date] = summary;
          }
          summary = initSummary(item.date!, cachedSickDates);
        }
        summary.uniqueWorkouts.add(item.name);
        summary.workoutCounts[item.name] = (summary.workoutCounts[item.name]?? 0) + 1;
        summary.differentDaysWithWorkoutOrSick["Workouts"]?.add(item.date!.toDate());
      }
      /// do sick day logic
      else if(item is ObSickDays){
        if(summary == null || !(summary.date.isSameMonth(item.endDate))){
          if(summary != null) {
            tempMonthSummaries[summary.date] = summary;
          }
          summary = initSummary(item.endDate, cachedSickDates);
          summary.uniqueWorkouts.add("Sick");
          if(!item.startDate.isSameMonth(item.endDate)){
            summary.workoutCounts["Sick"] = (summary.workoutCounts["Sick"]?? 0) + item.endDate.day;
          }
          else{
            summary.workoutCounts["Sick"] = (summary.workoutCounts["Sick"]?? 0) + item.endDate.difference(item.startDate).inDays + 1;
          }
        }
        else{
          summary.uniqueWorkouts.add("Sick");
          if(!item.startDate.isSameMonth(item.endDate)){
            summary.workoutCounts["Sick"] = (summary.workoutCounts["Sick"]?? 0) + item.endDate.day;
          }
          else{
            summary.workoutCounts["Sick"] = (summary.workoutCounts["Sick"]?? 0) + item.endDate.difference(item.startDate).inDays + 1;
          }
        }
        if(!item.startDate.isSameMonth(item.endDate)){
          cachedSickDates.addAll(item.startDate.getDatesBetween(item.endDate, onlySameMonth: false));
        }
        final dates = item.endDate.getDatesBetween(item.startDate, onlySameMonth: true);
        summary.differentDaysWithWorkoutOrSick["Sick"]?.addAll(dates);
      }
    }
    if(summary != null){
      tempMonthSummaries[summary.date] = summary;
    }
    monthSummaries = tempMonthSummaries;

    opened = workoutsAndSickDays.map((e) => false).toList();

    // double pos = scrollController.position.pixels;
    refresh();
    // scrollController.jumpTo(pos);
  }

  void saveLastScrollIndex(){
    lastScrollIndex = itemPositionsListener.itemPositions.value.sorted((a, b) => a.index.compareTo(b.index)).firstOrNull?.index?? 0;
  }

  void refresh(){
    notifyListeners();
  }
}

class MonthSummary{
  MonthSummary(this.date);
  DateTime date;
  Set<String> uniqueWorkouts = {};
  Map<String, int> workoutCounts = {};

  Map<String, Set<DateTime>> differentDaysWithWorkoutOrSick = {
    "Sick": {},
    "Workouts": {}
  };
}