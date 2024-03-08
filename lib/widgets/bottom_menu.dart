import 'package:fitness_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/screen_workout_history/screen_workout_history.dart';
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
  late CnBottomMenu cnBottomMenu;

  @override
  Widget build(BuildContext context) {
    cnBottomMenu = Provider.of<CnBottomMenu>(context);

    if(!cnBottomMenu.isVisible){
      return const SizedBox();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 0), // Animationsdauer
      transform: Matrix4.translationValues(0, cnBottomMenu.heightOfBottomMenu, 0),
      curve: Curves.easeInOut,
      child: Container(
        // height: cnBottomMenu.heightOfBottomMenu,
        height: cnBottomMenu.maxHeightBottomMenu,
        // decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //         begin: Alignment.bottomCenter,
        //         end: Alignment.topCenter,
        //         colors: [
        //           Colors.black.withOpacity(0.6),
        //           Colors.amber[500]!.withOpacity(0.0),
        //         ]
        //     )
        // ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.amber[800]!.withOpacity(0.25),
            // focusColor: Colors.transparent,
            // hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
                // backgroundColor: Color(0xffffff),
            backgroundColor: Color(0xFF151515),
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
  final double maxHeightBottomMenu = 60;

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