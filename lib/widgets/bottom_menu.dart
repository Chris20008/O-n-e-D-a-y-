import 'dart:ui';
import 'dart:io';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/widgets/standard_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../screens/main_screens/screen_statistics/screen_statistics.dart';
import '../screens/other_screens/screen_running_workout/screen_running_workout.dart';
import '../screens/main_screens/screen_workout_history/screen_workout_history.dart';
import '../screens/main_screens/screen_workouts/panels/new_workout_panel.dart';
import '../screens/main_screens/screen_workouts/screen_workouts.dart';
import '../util/config.dart';

class BottomMenu extends StatefulWidget {
  const BottomMenu({super.key});

  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> with WidgetsBindingObserver {
  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnWorkoutHistory cnWorkoutHistory = Provider.of<CnWorkoutHistory>(context, listen: false);
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  late CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnScreenStatistics cnScreenStatistics = Provider.of<CnScreenStatistics>(context, listen: false);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  late CnConfig cnConfig = Provider.of<CnConfig>(context, listen: false);
  late CnBottomMenu cnBottomMenu;
  late Orientation orientation = MediaQuery.of(context).orientation;
  double _height = 40;
  double? _iconSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
      setBottomMenuHeight();
    });
  }

  void setBottomMenuHeight({bool withRefresh = true}){
    orientation = MediaQuery.of(context).orientation;
    _height = orientation == Orientation.portrait? (Platform.isAndroid? 60 : 50) : (Platform.isAndroid? 40 : 35);
    final double paddingBottom = MediaQuery.of(context).padding.bottom;
    cnBottomMenu.height = paddingBottom + _height;
    _iconSize = orientation == Orientation.portrait? null : 15;
    cnBottomMenu.refresh();
  }

  @override
  Widget build(BuildContext context) {
    cnBottomMenu = Provider.of<CnBottomMenu>(context);

    if(cnBottomMenu.height <= 0){
      setBottomMenuHeight(withRefresh: false);
      // final double paddingBottom = MediaQuery.of(context).padding.bottom;
      // cnBottomMenu.height = paddingBottom + _height;
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
        // color: Colors.black.withOpacity(0.4),
        color: cnNewWorkout.minPanelHeight > 0 && cnBottomMenu.index != 2? const Color(0xff120a01) /*Color(0xff0a0604)*/ : Colors.black.withOpacity(0.4),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
              // sigmaX: 10.0,
              // sigmaY: 10.0,
              sigmaX: cnNewWorkout.minPanelHeight > 0 && cnBottomMenu.index != 2? 0 : 10.0,
              sigmaY: cnNewWorkout.minPanelHeight > 0 && cnBottomMenu.index != 2? 0 : 10.0,
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
              selectedFontSize: orientation == Orientation.landscape ? 10 :14,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.history, size: _iconSize),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sports_martial_arts, size: _iconSize),
                  label: 'Templates',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.scatter_plot, size: _iconSize),
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
      cnNewWorkout.refreshAllWorkoutDays();
    }
    else if(index == 1) {
      cnWorkouts.refreshAllWorkouts();

      // only for testing changing language
      // MyApp.of(context)?.setLocale(language: LANGUAGES.en, config: cnConfig);
    }
    else if(index == 2) {
      // cnScreenStatistics.calcMinMaxDates();
      cnScreenStatistics.refreshData();
    }
    if(cnNewWorkout.minPanelHeight > 0 && index != 2){
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else{
      SystemChrome.setPreferredOrientations([]);
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

  void adjustHeight(double value){
    positionYAxis = height * value;
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