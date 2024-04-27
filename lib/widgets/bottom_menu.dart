import 'dart:ui';
import 'dart:io';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/widgets/standard_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/screen_statistics/screen_statistics.dart';
import '../screens/screen_workout_history/screen_workout_history.dart';
import '../screens/screen_workouts/panels/new_workout_panel.dart';
import '../screens/screen_workouts/screen_running_workout.dart';
import '../screens/screen_workouts/screen_workouts.dart';

class BottomMenu extends StatefulWidget {
  const BottomMenu({super.key});

  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnWorkoutHistory cnWorkoutHistory = Provider.of<CnWorkoutHistory>(context, listen: false);
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  late CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnScreenStatistics cnScreenStatistics = Provider.of<CnScreenStatistics>(context, listen: false);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  late CnBottomMenu cnBottomMenu;
  final double height = Platform.isAndroid? 60 : 50;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    cnBottomMenu = Provider.of<CnBottomMenu>(context);

    if(cnBottomMenu.height <= 0){
      final double paddingBottom = MediaQuery.of(context).padding.bottom;
      cnBottomMenu.height = paddingBottom + height;
    }

    if(!cnBottomMenu.isVisible){
      return const SizedBox();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 0),
      transform: Matrix4.translationValues(0, cnBottomMenu.positionYAxis, 0),
      curve: Curves.easeInOut,
      height: cnBottomMenu.height,
      decoration: BoxDecoration(
          color: cnNewWorkout.minPanelHeight > 0 || cnRunningWorkout.isVisible? null: Colors.black.withOpacity(0.5),
          gradient: cnNewWorkout.minPanelHeight > 0 || cnRunningWorkout.isVisible? const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                Color(0xff160d05),
                Color(0xff0a0604),
              ]
          ) : null
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: cnNewWorkout.minPanelHeight > 0 || cnRunningWorkout.isVisible? 0 : 10.0,
              sigmaY: cnNewWorkout.minPanelHeight > 0 || cnRunningWorkout.isVisible? 0 : 10.0,
              tileMode: TileMode.mirror
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.amber[800]!.withOpacity(0.25),
              // focusColor: Colors.transparent,
              // hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sports_martial_arts),
                  label: 'Templates',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.scatter_plot),
                  label: 'Statistics',
                ),
              ],
              currentIndex: cnBottomMenu._selectedIndex,
              selectedItemColor: Colors.amber[800],
              onTap: changeIndex,
            ),
          ),
        ),
      ),
    );
  }

  void changeIndex(int index){
    cnBottomMenu._changeIndex(index);
    if(cnStandardPopUp.isVisible){
      cnStandardPopUp.cancel();
    }
    if(index == 0) {
      cnWorkoutHistory.refreshAllWorkouts();
    }
    else if(index == 1) {
      cnWorkouts.refreshAllWorkouts();
    }
    else if(index == 2) {
      cnScreenStatistics.calculateCurrentData();
      // cnScreenStatistics.refresh();
    }
    cnHomepage.refresh();
  }
}

class CnBottomMenu extends ChangeNotifier {
  int _selectedIndex = 1;
  bool isVisible = true;
  double positionYAxis = 0;
  // final double height = Platform.isAndroid? 60 : 92;
  double height = 0;
  // final t =

  void _changeIndex(int index) {
    _selectedIndex = index;
    refresh();
  }

  int get index => _selectedIndex;

  void setVisibility(bool visible){
    isVisible = visible;
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}