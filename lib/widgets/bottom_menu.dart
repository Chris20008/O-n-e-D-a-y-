import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomMenu extends StatefulWidget {
  const BottomMenu({super.key});

  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  late CnBottomMenu cnBottomMenu;

  @override
  Widget build(BuildContext context) {
    cnBottomMenu = Provider.of<CnBottomMenu>(context);

    if(!cnBottomMenu.isVisible){
      return const SizedBox();
    }

    return Container(
      height: 60,
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
              backgroundColor: Color(0xffffff),
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
              onTap: cnBottomMenu._changeIndex,
        ),
      ),
    );

    // return Column(
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.only(left: 20, right: 20),
    //         child: Container(
    //           width: double.maxFinite,
    //           height: 1,
    //           color: Colors.grey[600],
    //         ),
    //       ),
    //       BottomNavigationBar(
    //         showSelectedLabels: true,
    //         showUnselectedLabels: false,
    //         items: const <BottomNavigationBarItem>[
    //           BottomNavigationBarItem(
    //             icon: Icon(Icons.history),
    //             label: 'History',
    //           ),
    //           BottomNavigationBarItem(
    //             icon: Icon(Icons.sports_martial_arts),
    //             label: 'Workouts',
    //           ),
    //           BottomNavigationBarItem(
    //             icon: Icon(Icons.scatter_plot),
    //             label: 'Statistics',
    //           ),
    //         ],
    //         currentIndex: cnBottomMenu._selectedIndex,
    //         selectedItemColor: Colors.amber[800],
    //         onTap: cnBottomMenu._changeIndex,
    //       ),
    //     ],
    // );
  }
}

class CnBottomMenu extends ChangeNotifier {
  int _selectedIndex = 0;
  bool isVisible = true;

  void _changeIndex(int index) {
    _selectedIndex = index;
    refresh();
  }

  void setVisibility(bool visible){
    isVisible = visible;
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}