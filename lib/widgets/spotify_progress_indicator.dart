import 'package:fitness_app/widgets/spotify_bar.dart';
import 'package:fitness_app/widgets/stopwatch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class SpotifyProgressIndicator extends StatefulWidget {
  final PlayerState? data;
  const SpotifyProgressIndicator({super.key, this.data});

  @override
  State<SpotifyProgressIndicator> createState() => _SpotifyProgressIndicatorState();
}

class _SpotifyProgressIndicatorState extends State<SpotifyProgressIndicator> {
  bool _doRefresh = true;
  double? _currentWidthPercent;
  int _delayStartPeriodicRefreshing = 250;
  final double _height = 2;

  late CnStopwatchWidget cnStopwatchWidget = Provider.of<CnStopwatchWidget>(context, listen: false);
  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);


  @override
  void initState() {
    try{
      if(widget.data != null){
        _currentWidthPercent = (widget.data!.playbackPosition / widget.data!.track!.duration);
      }
      if (cnStopwatchWidget.isOpened){
        _delayStartPeriodicRefreshing = _delayStartPeriodicRefreshing + cnStopwatchWidget.animationTimeStopwatch;
      }
    }
    on Exception catch (_) {}
    Future.delayed(Duration(milliseconds: _delayStartPeriodicRefreshing), (){
      periodicRefresh();
    });
    super.initState();
  }

  void periodicRefresh() async{
    Future.delayed(const Duration(milliseconds: 500), ()async{
      if(_doRefresh && cnSpotifyBar.isConnected){
        try{
          final data = await SpotifySdk.getPlayerState();
          /// check if doRefresh is still true, cause it could have changed to false during 'await'
          if (_doRefresh && data != null && !data.isPaused){
            setState(() {
              _currentWidthPercent = data.playbackPosition / data.track!.duration;
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
    _doRefresh = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
        builder: (context, constraints){

          return Container(
            height: _height,
            width: constraints.maxWidth,
            color: Colors.grey[350],
            child: Align(
              alignment: Alignment.centerLeft,
              child: _currentWidthPercent != null
                ?Container(
                  height: _height,
                  width: constraints.maxWidth * _currentWidthPercent!,
                  color: Colors.amber[800])
                :const SizedBox(),
            ),
          );
        }
    );
  }
}