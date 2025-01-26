import 'dart:ui';

import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/widgets/spotify_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../util/config.dart';
import '../../../widgets/standard_popup.dart';
import 'screen_running_workout.dart';
import 'animated_column.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StopwatchWidget extends StatefulWidget {
  const StopwatchWidget({super.key});

  @override
  State<StopwatchWidget> createState() => _StopwatchWidgetState();
}

class _StopwatchWidgetState extends State<StopwatchWidget> {
  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  late CnConfig cnConfig  = Provider.of<CnConfig>(context, listen: false);
  late CnStopwatchWidget cnStopwatchWidget = Provider.of<CnStopwatchWidget>(context);

  double paddingLeftRight = 5;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
          padding: EdgeInsets.only(left:paddingLeftRight, right: paddingLeftRight, bottom: 3),
          child: AnimatedCrossFade(
            sizeCurve: Curves.easeInOut,
            firstChild: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              // child: BackdropFilter(
              //   filter: ImageFilter.blur(
              //       sigmaX: 10.0,
              //       sigmaY: 10.0,
              //       tileMode: TileMode.mirror
              //   ),
                child: Container(
                  color: Colors.black,
                  height: cnStopwatchWidget.heightOfTimer,
                  width: width - paddingLeftRight*2,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [

                    /// Stopwatch controls
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
                                              child: SizedBox(
                                                height: 70,
                                                width: 70,
                                                child: Center(
                                                  child: Text(
                                                    AppLocalizations.of(context)!.delete,
                                                    style: const TextStyle(color: Color(0xfffdfdfd)),
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
                                            cnStopwatchWidget.isPaused? AppLocalizations.of(context)!.start : AppLocalizations.of(context)!.stop,
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

                      /// Stopwatch text
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            cnStopwatchWidget.isRunning || cnStopwatchWidget.countdownTime != null
                                ? getTimeString()
                                // : cnStopwatchWidget.countdownTime != null
                                // ? cnStopwatchWidget.countdownTime.toString()
                                : "00:00",
                            style: TextStyle(
                              fontSize: 80,
                              color: const Color(0xFFA7A7A7),
                              fontFamily: GoogleFonts.robotoMono().fontFamily
                            )
                          ),
                        )
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 2.5),
                          child: IconButton(
                              iconSize: 30,
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                // shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                              ),
                              onPressed: () {
                                cnStopwatchWidget.close(scrollController: cnRunningWorkout.scrollController);
                                cnRunningWorkout.refresh();
                              },
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.amber[800],
                              )
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: getSelectRestInSeconds(
                            currentTime: cnStopwatchWidget.countdownTime?? 0,
                            context: context,
                            onConfirm: (value){
                              if (value is int){
                                cnStopwatchWidget.countdownTime = value;
                                cnStopwatchWidget.cancelTimer();
                                cnConfig.setCountdownTime(cnStopwatchWidget.countdownTime);
                              }
                              else if(value == AppLocalizations.of(context)!.clear){
                                cnStopwatchWidget.countdownTime = null;
                                cnStopwatchWidget.cancelTimer();
                                cnConfig.setCountdownTime(cnStopwatchWidget.countdownTime);
                              }
                              else{
                                showDialogMinuteSecondPicker(
                                    context: context,
                                    initialTimeDuration: Duration(minutes: (cnStopwatchWidget.countdownTime??0)~/60, seconds: (cnStopwatchWidget.countdownTime??0)%60),
                                    onConfirm: (Duration newDuration){
                                      cnStopwatchWidget.countdownTime = newDuration.inSeconds;
                                    }
                                ).then((value) => setState(() {}));
                              }
                            },
                            child: Icon(
                              Icons.timelapse_rounded,
                              color: Colors.amber[800],
                            )
                        ),
                      )
                    ],
                  ),
                ),
              // ),
            ),
            secondChild: SizedBox(
              height: cnSpotifyBar.heightOfButton,
              width: cnSpotifyBar.heightOfButton,
              child: IconButton(
                  iconSize: 28,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  onPressed: () {
                    cnStopwatchWidget.open(scrollController: cnRunningWorkout.scrollController);
                    cnRunningWorkout.refresh();
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
    // String elapsedMinutes = (cnStopwatchWidget.stopwatch.elapsed.inMinutes%60).toString();
    // elapsedMinutes = elapsedMinutes.length==1? "0$elapsedMinutes" : elapsedMinutes;
    //
    // String elapsedSeconds = (cnStopwatchWidget.stopwatch.elapsed.inSeconds%60).toString();
    // elapsedSeconds = elapsedSeconds.length==1? "0$elapsedSeconds" : elapsedSeconds;
    int restCountdownSeconds;
    if(cnStopwatchWidget.countdownTime != null){
      restCountdownSeconds = cnStopwatchWidget.countdownTime! - cnStopwatchWidget.stopwatch.elapsed.inSeconds;
      if(restCountdownSeconds < 0){
        restCountdownSeconds = 0;
        Future.delayed(const Duration(milliseconds: 1000), (){
          cnStopwatchWidget.cancelTimer();
        });
      }
    } else{
      restCountdownSeconds = cnStopwatchWidget.stopwatch.elapsed.inSeconds;
    }

    String elapsedMinutes = (restCountdownSeconds ~/60).toString();
    elapsedMinutes = elapsedMinutes.length==1? "0$elapsedMinutes" : elapsedMinutes;

    String elapsedSeconds = (restCountdownSeconds%60).toString();
    elapsedSeconds = elapsedSeconds.length==1? "0$elapsedSeconds" : elapsedSeconds;

    return "$elapsedMinutes:$elapsedSeconds";
  }

  // String getCountdownAsString(){
  //
  // }
}



class CnStopwatchWidget extends ChangeNotifier {
  bool isOpened = false;
  bool isRunning = false;
  bool isPaused = true;
  int animationTimeStopwatch = 300;
  double heightOfTimer = 200;
  late CnAnimatedColumn cnAnimatedColumn;
  final Stopwatch stopwatch = Stopwatch();
  int? countdownTime;

  CnStopwatchWidget(BuildContext context){
    cnAnimatedColumn = Provider.of<CnAnimatedColumn>(context, listen: false);
  }

  void open({ScrollController? scrollController}){
    isOpened = true;
    refresh();
    if(scrollController != null){
      final currPos = scrollController.position.pixels;
      scrollController.animateTo(
          currPos + heightOfTimer,
          duration: Duration(milliseconds: animationTimeStopwatch),
          curve: Curves.easeInOut
      );
    }
    Future.delayed(Duration(milliseconds: animationTimeStopwatch), (){
      cnAnimatedColumn.refresh();
    });
  }

  void close({ScrollController? scrollController}){
    isOpened = false;
    refresh();
    if(scrollController != null){
      final currPos = scrollController.position.pixels;
      final double newPos = currPos >= heightOfTimer? currPos - heightOfTimer : 0;
      scrollController.animateTo(
          newPos,
          duration: Duration(milliseconds: animationTimeStopwatch),
          curve: Curves.easeInOut
      );
    }
    Future.delayed(Duration(milliseconds: animationTimeStopwatch), (){
      cnAnimatedColumn.refresh();
    });
  }

  void startTimer(){
    stopwatch.start();
    isRunning = true;
    isPaused = false;
    refresh();
    intervalRefresh();
  }

  void pauseTimer(){
    stopwatch.stop();
    isRunning = true;
    isPaused = true;
    refresh();
  }

  void cancelTimer(){
    stopwatch.stop();
    stopwatch.reset();
    isRunning = false;
    isPaused = true;
    refresh();
  }

  void intervalRefresh(){
    Future.delayed(const Duration(milliseconds: 200), (){
      if(isRunning && !isPaused){
        if(isOpened){
          refresh();
        }
        intervalRefresh();
      }
    });
  }

  void refresh()async{
    notifyListeners();
  }
}