import 'package:fitness_app/widgets/spotify_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Stopwatch extends StatefulWidget {
  const Stopwatch({super.key});

  @override
  State<Stopwatch> createState() => _StopwatchState();
}

class _StopwatchState extends State<Stopwatch> {
  double paddingLeftRight = 5;
  final width = WidgetsBinding.instance.window.physicalSize.width;
  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: cnSpotifyBar.height),
      child: SafeArea(
        child: Align(
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
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                    height: cnSpotifyBar.height,
                    // width: constraints.maxWidth,
                    // width: size.width - paddingLeftRight*2,
                    width: width - paddingLeftRight*2,
                    child: Container(),
                  ),
                ),
                secondChild: SizedBox(
                  height: cnSpotifyBar.height,
                  width: cnSpotifyBar.height,
                  child: IconButton(
                      iconSize: 25,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.transparent),
                        // shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                      ),
                      onPressed: () async{
                        // cnSpotifyBar.connectToSpotify();
                      },
                      icon: Icon(
                        Icons.timer,
                        color: Colors.amber[800],
                      )
                  ),
                ),
                crossFadeState: true?
                CrossFadeState.showFirst :
                CrossFadeState.showSecond,
                duration: Duration(milliseconds: cnSpotifyBar.animationTimeSpotifyBar),
                layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
                  return Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: <Widget>[
                      Positioned(
                        key: bottomChildKey,
                        // left: 0.0,
                        // top: 0.0,
                        // right: 0.0,
                        bottom: 0,
                        child: bottomChild,
                      ),
                      Positioned(
                        key: topChildKey,
                        // left: 0.0,
                        // top: 0.0,
                        // right: 0.0,
                        // bottom: 0,
                        // right: 0,
                        child: topChild,
                      ),
                    ],
                  );
                },
              )
          ),
        ),
      ),
    );
  }
}



class CnStopwatch extends ChangeNotifier {
  bool isOpened = false;
  double animationTimeStopwatch = 300;

  void refresh()async{
    notifyListeners();
  }
}