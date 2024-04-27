import 'package:fitness_app/widgets/spotify_bar.dart';
import 'package:fitness_app/widgets/stopwatch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'bottom_menu.dart';

class AnimatedColumn extends StatefulWidget {
  const AnimatedColumn({super.key});

  @override
  State<AnimatedColumn> createState() => _AnimatedColumnState();
}

class _AnimatedColumnState extends State<AnimatedColumn> {


  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  late CnStopwatchWidget cnStopwatchWidget = Provider.of<CnStopwatchWidget>(context, listen: false);
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  late CnAnimatedColumn cnAnimatedColumn;

  @override
  Widget build(BuildContext context) {
    cnAnimatedColumn = Provider.of<CnAnimatedColumn>(context);

    return SafeArea(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Padding(
          //   padding: EdgeInsets.only(bottom: cnSpotifyBar.height*2),
          //   child: AnimatedContainer(
          //     duration: Duration(milliseconds: cnStopwatchWidget.animationTimeStopwatch),
          //     transform: Matrix4.translationValues(0, cnStopwatchWidget.isOpened? -cnStopwatchWidget.heightOfTimer+cnSpotifyBar.height : -10, 0),
          //     width: cnSpotifyBar.height,
          //     height: cnSpotifyBar.height,
          //     padding: const EdgeInsets.only(right: 10),
          //     child: IconButton(
          //         iconSize: 28,
          //         style: ButtonStyle(
          //           backgroundColor: MaterialStateProperty.all(Colors.transparent),
          //         ),
          //         onPressed: () {
          //           Navigator.of(context).pop();
          //           cnHomepage.refresh(refreshSpotifyBar: true);
          //         },
          //         icon: Icon(
          //           Icons.fullscreen_exit,
          //           color: Colors.amber[800],
          //         )
          //     ),
          //   ),
          // ),
          AnimatedContainer(
              duration: Duration(milliseconds: cnStopwatchWidget.animationTimeStopwatch),
              transform: Matrix4.translationValues(
                  ///x
                  0,
                  ///y
                  cnStopwatchWidget.isOpened && !cnSpotifyBar.isConnected?
                  0 :
                  cnStopwatchWidget.isOpened && cnSpotifyBar.isConnected?
                  -cnSpotifyBar.height - 5:
                  -cnSpotifyBar.height -5,
                  ///z
                  0),
              child: const StopwatchWidget()
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: cnStopwatchWidget.animationTimeStopwatch),
            transform: Matrix4.translationValues(0, cnStopwatchWidget.isOpened && !cnSpotifyBar.isConnected? -cnStopwatchWidget.heightOfTimer-5: 0, 0),
            child: const Hero(
                transitionOnUserGestures: true,
                tag: "SpotifyBar",
                child: SpotifyBar()
            ),
          ),
        ],
      ),
    );
  }
}

class CnAnimatedColumn extends ChangeNotifier {
  bool isOpened = false;
  bool isRunning = false;
  bool isPaused = false;
  int animationTimeStopwatch = 300;
  // double heightOfTimer = 250;

  void refresh()async{
    notifyListeners();
  }
}