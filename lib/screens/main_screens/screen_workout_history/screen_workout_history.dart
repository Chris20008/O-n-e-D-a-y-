import 'package:fitness_app/main.dart';
import 'package:fitness_app/objectbox.g.dart';
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

                  Widget child = Container();
                  DateTime? dateOfWorkout;
                  final DateTime? dateOfNewerWorkout = index > 0
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
                    dateOfWorkout = cnWorkoutHistory.workoutsAndSickDays[index].startDate;
                    child = sickDayWidget(cnWorkoutHistory.workoutsAndSickDays[index]);
                  }

                  final double heightOfSpacer = dateOfNewerWorkout == null? 0 : 40;

                  /// check if date is not null
                  if (dateOfWorkout != null) {

                    /// Future
                    if(dateOfWorkout.isInFuture()){
                      if(dateOfNewerWorkout == null){
                        return getChildWithTimeHeader(
                            child: child,
                            headerText: AppLocalizations.of(context)!.historyFuture,
                            heightSpacer: heightOfSpacer,
                            textScaler: 1.8
                        );
                      }
                    }

                    /// Today
                    else if(dateOfWorkout.isToday()){
                      if(dateOfNewerWorkout == null || !dateOfNewerWorkout.isToday()){
                        return getChildWithTimeHeader(
                          child: child,
                          headerText: AppLocalizations.of(context)!.historyToday,
                          heightSpacer: dateOfNewerWorkout == null? 0 : 40,
                          textScaler: 1.8,
                          /// with week header
                          dateForWeekDecoration: dateOfNewerWorkout == null || !dateOfWorkout.isSameWeek(dateOfNewerWorkout)? dateOfWorkout : null
                        );
                      }
                    }

                    /// Yesterday
                    else if(dateOfWorkout.isYesterday()){
                      if(dateOfNewerWorkout == null || !dateOfNewerWorkout.isYesterday()){
                        return getChildWithTimeHeader(
                            child: child,
                            headerText: AppLocalizations.of(context)!.historyYesterday,
                            heightSpacer: heightOfSpacer,
                            textScaler: 1.7,
                            /// with week header
                            dateForWeekDecoration: dateOfNewerWorkout == null || !dateOfWorkout.isSameWeek(dateOfNewerWorkout)? dateOfWorkout : null
                        );
                      }
                    }

                    /// Last 7 days
                    else if(dateOfWorkout.isInLastSevenDays()){
                      if(dateOfNewerWorkout == null
                          || dateOfNewerWorkout.isToday()
                          || dateOfNewerWorkout.isYesterday()
                          || dateOfNewerWorkout.isInFuture() ){
                        return getChildWithTimeHeader(
                            child: child,
                            headerText: AppLocalizations.of(context)!.historyLast7Days,
                            heightSpacer: heightOfSpacer,
                            textScaler: 1.7,
                            /// with week header
                            dateForWeekDecoration: dateOfNewerWorkout == null || !dateOfWorkout.isSameWeek(dateOfNewerWorkout)? dateOfWorkout : null
                        );
                      }
                    }

                    /// Month Header
                    else if(dateOfNewerWorkout == null
                        || dateOfNewerWorkout.isInLastSevenDays()
                        || dateOfNewerWorkout.isInFuture()
                        || !dateOfNewerWorkout.isSameMonth(dateOfWorkout)
                    ){
                      return getChildWithTimeHeader(
                          child: child,
                          headerText: DateFormat('MMMM y', Localizations.localeOf(context).languageCode).format(dateOfWorkout),
                          heightSpacer: heightOfSpacer,
                          textScaler: 1.7,
                          /// with week header
                          dateForWeekDecoration: dateOfNewerWorkout == null || !dateOfWorkout.isSameWeek(dateOfNewerWorkout)? dateOfWorkout : null
                      );
                    }
                    /// Week Header
                    else if(!dateOfWorkout.isSameWeek(dateOfNewerWorkout)){
                      return Column(
                        children: [
                          const SizedBox(height: 15,),
                          getWeekDecoration(Jiffy.parseFromDateTime(dateOfWorkout).weekOfYear.toString()),
                          const SizedBox(height: 5),
                          child
                        ],
                      );
                    }
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
                          String key = "${values.first?.year}${values.first?.month}${values.first?.day}";
                          if(cnWorkoutHistory.indexOfWorkout.keys.contains(key)){
                            index = cnWorkoutHistory.indexOfWorkout[key];
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
    DateTime? dateForWeekDecoration
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
                  textScaler: const TextScaler.linear(0.8),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w200
                  ),
                ),
                Text(
                  DateFormat('EEEE d. MMMM', Localizations.localeOf(context).languageCode).format(sickDay.startDate),
                  textScaler: const TextScaler.linear(0.8),
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

  Future refreshAllWorkouts() async{
    List<Workout> tempWorkouts = [];
    Map<String, int> tempindexOfWorkout = {};
    List<ObSickDays> tempSickDays = [];
    List tempWorkoutsAndSickDays = [];
    // workouts.clear();
    // indexOfWorkout.clear();
    // sickDays.clear();
    // workoutsAndSickDays.clear();

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

      final key = "${w.date.year}${w.date.month}${w.date.day}";
      if(!tempindexOfWorkout.containsKey(key)){
        tempindexOfWorkout[key] = index;
      }
      index += 1;
    }

    workouts = tempWorkouts;
    indexOfWorkout = tempindexOfWorkout;
    sickDays = tempSickDays;
    workoutsAndSickDays = tempWorkoutsAndSickDays;

    opened = workoutsAndSickDays.map((e) => false).toList();

    // double pos = scrollController.position.pixels;
    refresh();
    // scrollController.jumpTo(pos);
  }

  void refresh(){
    notifyListeners();
  }
}