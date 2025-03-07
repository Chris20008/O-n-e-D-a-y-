import 'dart:ui';
import 'dart:io';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/widgets/standard_popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fitness_app/assets/custom_icons/my_icons_icons.dart';

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
      setState(() {
        cnBottomMenu.setBottomMenuHeight(context);
        /// Refresh running workout if its visible since the bottom bar depends on bottom menu height
        if(cnRunningWorkout.isVisible){
          cnRunningWorkout.refresh();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    cnBottomMenu = Provider.of<CnBottomMenu>(context);

    if(cnBottomMenu.height <= 0){
      cnBottomMenu.setBottomMenuHeight(context);
    }

    if(!cnBottomMenu.isVisible){
      return const SizedBox();
    }

    return AnimatedContainer(
      key: cnBottomMenu.bottomMenuKey,
      duration: const Duration(milliseconds: 0),
      transform: Matrix4.translationValues(0, cnBottomMenu.positionYAxis, 0),
      curve: Curves.easeInOut,
      height: cnBottomMenu.height,
      decoration: BoxDecoration(
        // color: Colors.black.withOpacity(0.4),
        color: cnNewWorkout.minPanelHeight > 0 && cnBottomMenu.index != 2? Theme.of(context).primaryColor : Colors.black.withOpacity(0.4),
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
                  icon: Icon(Icons.history, size: cnBottomMenu.iconSize!),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(MyIcons.dumbbell, size: cnBottomMenu.iconSize!-5),
                  label: 'Templates',
                ),
                BottomNavigationBarItem(
                  icon: Icon(MyIcons.chart_line, size: cnBottomMenu.iconSize!-5),
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
    final lastIndex = cnBottomMenu.index;
    cnBottomMenu._changeIndex(index);
    if(cnStandardPopUp.isVisible){
      cnStandardPopUp.cancel();
    }
    if(index == 0) {
      cnWorkoutHistory.refreshAllWorkouts();
      cnNewWorkout.refreshAllWorkoutDays();
      if(lastIndex == 0){
        cnWorkoutHistory.scrollController.scrollTo(
            index: 0,
            alignment: 0.05,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut
        );
      }
    }
    else if(index == 1) {
      cnWorkouts.refreshAllWorkouts();
    }
    else if(index == 2) {
      cnScreenStatistics.refreshData(context);
      if(lastIndex == 2){
        cnScreenStatistics.resetGraph(withKeyReset: false);
        cnScreenStatistics.refresh();
      }
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
  double height = 0;
  final GlobalKey _bottomMenuKey = GlobalKey();
  double? iconSize;
  late Orientation orientation;

  GlobalKey get bottomMenuKey => _bottomMenuKey;

  // CnBottomMenu(BuildContext context){
  //   setBottomMenuHeight(context);
  // }

  void _changeIndex(int index) {
    _selectedIndex = index;
    refresh();
  }

  void setBottomMenuHeight(BuildContext context){
    orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? (Platform.isAndroid? 60 : 50)   /// When Portrait higher
        : (Platform.isAndroid? 40 : 35);  /// Reduced height when landscape*
    final double paddingBottom = MediaQuery.of(context).padding.bottom;
    this.height = paddingBottom + height;
    iconSize = orientation == Orientation.portrait? 25 : 15;
  }

  void showBottomMenuAnimated(){
    positionYAxis = positionYAxis * 0.92;
    if(positionYAxis < 1){
      positionYAxis = 0;
    }
    refresh();
    Future.delayed(const Duration(milliseconds: 10), (){
      if(positionYAxis > 0){
        showBottomMenuAnimated();
      }
    });
  }

  /// value between 0-1
  ///
  /// 0 = scrolled Down
  ///
  /// 1 = completely Visible
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