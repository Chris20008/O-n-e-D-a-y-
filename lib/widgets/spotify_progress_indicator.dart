import 'package:fitness_app/widgets/spotify_bar.dart';
import 'package:fitness_app/widgets/stopwatch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class SpotifyProgressIndicator extends StatefulWidget {
  final PlayerState? data;
  const SpotifyProgressIndicator({super.key, this.data});
  // const SpotifyProgressIndicator({super.key});

  @override
  State<SpotifyProgressIndicator> createState() => _SpotifyProgressIndicatorState();
}

class _SpotifyProgressIndicatorState extends State<SpotifyProgressIndicator> {
  bool doRefresh = true;
  double? currentWidthPercent;
  int? remainingDuration;
  late CnStopwatchWidget cnStopwatchWidget = Provider.of<CnStopwatchWidget>(context, listen: false);
  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  int delayStartPeriodicRefreshing = 250;
  final double height = 2;


  @override
  void initState() {
    try{
      if(widget.data != null){
        currentWidthPercent = (widget.data!.playbackPosition / widget.data!.track!.duration);
      }
      if (cnStopwatchWidget.isOpened){
        delayStartPeriodicRefreshing = delayStartPeriodicRefreshing + cnStopwatchWidget.animationTimeStopwatch;
      }
    }
    on Exception catch (_) {}
    Future.delayed(Duration(milliseconds: delayStartPeriodicRefreshing), (){
      periodicRefresh();
    });
    super.initState();
  }

  void periodicRefresh() async{
    Future.delayed(const Duration(milliseconds: 500), ()async{
      if(doRefresh && cnSpotifyBar.isConnected){
        try{
          final data = await SpotifySdk.getPlayerState();
          /// check if doRefresh is still true, cause it could have changed to false during 'await'
          if (doRefresh && data != null && !data.isPaused){
            setState(() {
              currentWidthPercent = data.playbackPosition / data.track!.duration;
              periodicRefresh();
            });
          }
        } on Exception catch (_) {
          periodicRefresh();
        }
      }
    });
  }

  @override
  void dispose() {
    doRefresh = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
        builder: (context, constraints){

          return Container(
            height: height,
            width: constraints.maxWidth,
            color: Colors.grey[350],
            child: Align(
              alignment: Alignment.centerLeft,
              child: currentWidthPercent != null
                ?Container(
                  height: 1.5,
                  width: constraints.maxWidth * currentWidthPercent!,
                  color: Colors.amber[800])
                :const SizedBox(),
            ),
          );
        }
    );
  }
}