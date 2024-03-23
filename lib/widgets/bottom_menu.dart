import 'dart:ui';

import 'package:fitness_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  late CnBottomMenu cnBottomMenu;

  @override
  Widget build(BuildContext context) {
    cnBottomMenu = Provider.of<CnBottomMenu>(context);

    if(!cnBottomMenu.isVisible){
      return const SizedBox();
    }

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: cnNewWorkout.minPanelHeight > 0 || cnRunningWorkout.isVisible? 0 : 10.0,
            sigmaY: cnNewWorkout.minPanelHeight > 0 || cnRunningWorkout.isVisible? 0 : 10.0,
            tileMode: TileMode.mirror
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 0), // Animationsdauer
          transform: Matrix4.translationValues(0, cnBottomMenu.heightOfBottomMenu, 0),
          curve: Curves.easeInOut,
          height: cnBottomMenu.maxHeightBottomMenu,
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
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.amber[800]!.withOpacity(0.25),
              // focusColor: Colors.transparent,
              // hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
                  // backgroundColor: Color(0xFF150E0A),
              // backgroundColor: Color(0xFF0D0805),
              // backgroundColor: Color(0xFF110E0C),
              // backgroundColor: cnNewWorkout.minPanelHeight == 0 && cnNewWorkout.panelController.isPanelClosed ? Color(0xffffff) : Color(0xFF151515),
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
                      label: 'Workouts',
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
    print("Index $index");
    if(index == 0) {
      cnWorkoutHistory.refreshAllWorkouts();
    } else if(index == 1) {
      cnWorkouts.refreshAllWorkouts();
      print("REFRESH ALL WORKOUTS");
    }
    cnHomepage.refresh();
  }
}

class CnBottomMenu extends ChangeNotifier {
  int _selectedIndex = 0;
  bool isVisible = true;
  double heightOfBottomMenu = 0;
  final double maxHeightBottomMenu = 92;
  // Color backgroundColor = Colors.transparent;

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