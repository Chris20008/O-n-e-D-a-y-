import 'dart:ui';

import 'package:fitness_app/widgets/spotify_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'animated_column.dart';

class StopwatchWidget extends StatefulWidget {
  const StopwatchWidget({super.key});

  @override
  State<StopwatchWidget> createState() => _StopwatchWidgetState();
}

class _StopwatchWidgetState extends State<StopwatchWidget> {
  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  late CnStopwatchWidget cnStopwatchWidget;

  double paddingLeftRight = 5;
  final width = WidgetsBinding.instance.window.physicalSize.width;

  @override
  Widget build(BuildContext context) {
    cnStopwatchWidget = Provider.of<CnStopwatchWidget>(context);

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
          padding: EdgeInsets.only(left:paddingLeftRight, right: paddingLeftRight, bottom: 3),
          child: AnimatedCrossFade(
            // secondCurve: cnSpotifyBar.isConnected? Curves.easeInOutQuint : Curves.easeInExpo,
            // secondCurve: Curves.fastOutSlowIn,
            // secondCurve: Curves.fastLinearToSlowEaseIn,
            //   sizeCurve: Curves.easeInOutBack,
            sizeCurve: Curves.easeInOut,
            firstChild: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5.0,
                  sigmaY: 5.0,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  height: cnStopwatchWidget.heightOfTimer,
                  width: width - paddingLeftRight*2,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: SizedBox(
                              width: double.maxFinite,
                              height: 70,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedCrossFade(
                                      layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
                                        return Stack(
                                          clipBehavior: Clip.none,
                                          alignment: Alignment.center,
                                          children: <Widget>[
                                            Positioned(
                                              key: bottomChildKey,
                                              top: 0.0,
                                              child: bottomChild,
                                            ),
                                            Positioned(
                                              key: topChildKey,
                                              child: topChild,
                                            ),
                                          ],
                                        );
                                      },
                                      firstChild: Row(
                                        children: [
                                          const SizedBox(
                                            width: 70,
                                          ),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(35),
                                            child: Material(
                                              color: const Color(0xff333333),
                                              child: InkWell(
                                                onTap: cnStopwatchWidget.cancelTimer,
                                                child: const SizedBox(
                                                  height: 70,
                                                  width: 70,
                                                  child: Center(
                                                    child: Text(
                                                      "Löschen",
                                                      style: TextStyle(color: Color(
                                                          0xfffdfdfd)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 70,
                                          ),
                                        ],
                                      ),
                                      secondChild: const SizedBox(width: 70, height: 70,),
                                      crossFadeState: cnStopwatchWidget.isRunning?
                                      CrossFadeState.showFirst:
                                      CrossFadeState.showSecond,
                                      duration: Duration(milliseconds: (cnStopwatchWidget.animationTimeStopwatch/2).round())
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(35),
                                    child: Material(
                                      color: cnStopwatchWidget.isPaused? const Color(0xff0b2912) :const Color(
                                          0xff330e0b),
                                      child: SizedBox(
                                        height: 70,
                                        width: 70,
                                        child: InkWell(
                                          onTap: cnStopwatchWidget.isPaused? cnStopwatchWidget.startTimer : cnStopwatchWidget.pauseTimer,
                                          child: Center(
                                            child: Text(
                                              cnStopwatchWidget.isPaused? "Start" : "Stopp",
                                              style: TextStyle(
                                                color: cnStopwatchWidget.isPaused? const Color(0x9627eb15) : const Color(
                                                    0xfffd443a)
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 70,
                                  ),
                                  // const Spacer(flex: 4,),
                                ],
                              ),
                            ),
                          )
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            // "00:00",
                            cnStopwatchWidget.isRunning?
                              getTimeString() :
                              "00:00,00",
                            style: TextStyle(
                              fontSize: 60,
                              color: Colors.white54,
                              fontFamily: GoogleFonts.robotoMono().fontFamily
                            )
                          ),
                        )
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            iconSize: 25,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.transparent),
                              // shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                            ),
                            onPressed: () async{
                              cnStopwatchWidget.close();
                            },
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.amber[800],
                            )
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            secondChild: SizedBox(
              height: cnSpotifyBar.height,
              width: cnSpotifyBar.height,
              child: IconButton(
                  iconSize: 28,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  onPressed: () async{
                    cnStopwatchWidget.open();
                  },
                  icon: Icon(
                    Icons.timer,
                    color: Colors.amber[800],
                  )
              ),
            ),
            crossFadeState: cnStopwatchWidget.isOpened?
            CrossFadeState.showFirst :
            CrossFadeState.showSecond,
            duration: Duration(milliseconds: cnStopwatchWidget.animationTimeStopwatch),
            layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned(
                    key: bottomChildKey,
                    top: 0.0,
                    child: bottomChild,
                  ),
                  Positioned(
                    key: topChildKey,
                    child: topChild,
                  ),
                ],
              );
            },
          )
      ),
    );
  }

  String getTimeString() {
    String minutes = (cnStopwatchWidget.stopwatch.elapsed.inMinutes%60).toString();
    minutes = minutes.length==1? "0$minutes" : minutes;

    String seconds = (cnStopwatchWidget.stopwatch.elapsed.inSeconds%60).toString();
    seconds = seconds.length==1? "0$seconds" : seconds;

    String milliseconds = (cnStopwatchWidget.stopwatch.elapsed.inMilliseconds%1000).toString();
    milliseconds = milliseconds.length==1? "0$milliseconds" : milliseconds;
    milliseconds = milliseconds.length==2? "0$milliseconds" : milliseconds;
    milliseconds = milliseconds.substring(0,  milliseconds.length>=2 ? 2 : milliseconds.length);
    milliseconds = milliseconds.length==1? "0$milliseconds" : milliseconds;

    return "$minutes:$seconds,$milliseconds";
  }
}



class CnStopwatchWidget extends ChangeNotifier {
  bool isOpened = false;
  bool isRunning = false;
  bool isPaused = true;
  int animationTimeStopwatch = 300;
  double heightOfTimer = 250;
  late CnAnimatedColumn cnAnimatedColumn;
  final Stopwatch stopwatch = Stopwatch();

  CnStopwatchWidget(BuildContext context){
    cnAnimatedColumn = Provider.of<CnAnimatedColumn>(context, listen: false);
  }

  void open(){
    isOpened = true;
    refresh();
    Future.delayed(Duration(milliseconds: animationTimeStopwatch), (){
      cnAnimatedColumn.refresh();
    });
  }

  void close(){
    isOpened = false;
    refresh();
    Future.delayed(Duration(milliseconds: animationTimeStopwatch), (){
      cnAnimatedColumn.refresh();
    });
  }

  void startTimer(){
    stopwatch.start();
    isRunning = true;
    isPaused = false;
    refresh();
    intervallRefresh();
  }

  void pauseTimer(){
    stopwatch.stop();
    isRunning = true;
    isPaused = true;
    refresh();
  }

  void cancelTimer(){
    stopwatch.reset();
    isRunning = false;
    isPaused = true;
    refresh();
  }

  void intervallRefresh(){
    Future.delayed(const Duration(milliseconds: 1), (){
      if(isRunning){
        if(isOpened){
          refresh();
        }
        intervallRefresh();
      }
    });
  }

  void refresh()async{
    notifyListeners();
  }
}