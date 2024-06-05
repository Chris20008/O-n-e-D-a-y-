import 'package:fitness_app/main.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:flutter/material.dart';
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

    return SizedBox(
      height: size.height,
      child: Stack(
        children: [
          ScrollablePositionedList.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 70, left: 20, right: 20, bottom: 0),
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 10);
              },
              addAutomaticKeepAlives: true,
              physics: const BouncingScrollPhysics(),
              key: cnWorkoutHistory.key,
              itemScrollController: cnWorkoutHistory.scrollController,
              itemCount: cnWorkoutHistory.workouts.length+1,
              itemBuilder: (BuildContext context, int index) {
                if (index == cnWorkoutHistory.workouts.length){
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
                final dateOfWorkout = cnWorkoutHistory.workouts[index].date;
                final DateTime? dateOfNewerWorkout = index > 0 ? cnWorkoutHistory.workouts[index-1].date : null;
                Widget child = WorkoutExpansionTile(
                    // key: UniqueKey(),
                    workout: cnWorkoutHistory.workouts[index],
                    // padding: EdgeInsets.only(top: index == 0? cnRunningWorkout.isRunning? 20:70 : 10, left: 20, right: 20, bottom: 0),
                    padding: EdgeInsets.zero,
                    onExpansionChange: (bool isOpen) => cnWorkoutHistory.opened[index] = isOpen,
                    initiallyExpanded: cnWorkoutHistory.opened[index]
                );

                /// check if date is not null
                if (dateOfWorkout != null) {

                  /// Future
                  if(dateOfWorkout.isInFuture()){
                    if(dateOfNewerWorkout == null){
                      return getChildWithTimeHeader(
                          child: child,
                          headerText: AppLocalizations.of(context)!.historyFuture,
                          heightSpacer: dateOfNewerWorkout == null? 0 : 40,
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
                          heightSpacer: dateOfNewerWorkout == null? 0 : 40,
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
                          heightSpacer: dateOfNewerWorkout == null? 0 : 40,
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
                        heightSpacer: dateOfNewerWorkout == null? 0 : 40,
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
    double heightSpacer = 40,
    double textScaler = 1.7,
    DateTime? dateForWeekDecoration}){
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
}

class CnWorkoutHistory extends ChangeNotifier {
  List<Workout> workouts = [];
  Key key = UniqueKey();
  List<bool> opened = [];
  ItemScrollController scrollController = ItemScrollController();
  Map<String, int> indexOfWorkout = {};

  void refreshAllWorkouts() async{
    workouts.clear();
    indexOfWorkout.clear();
    final builder = objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(false)).order(ObWorkout_.date, flags: Order.descending).build();
    List<ObWorkout> obWorkouts = await builder.findAsync();
    int index = 0;
    for (ObWorkout w in obWorkouts) {
      workouts.add(Workout.fromObWorkout(w));
      final key = "${w.date.year}${w.date.month}${w.date.day}";
      if(!indexOfWorkout.containsKey(key)){
        indexOfWorkout[key] = index;
      }
      index += 1;
    }
    opened = workouts.map((e) => false).toList();

    // double pos = scrollController.position.pixels;
    refresh();
    // scrollController.jumpTo(pos);
  }

  void refresh(){
    notifyListeners();
  }
}