import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../../../../widgets/spotify_bar.dart';
import '../../stopwatch.dart';

class BottomSpacerRunningWorkout extends StatelessWidget {
  const BottomSpacerRunningWorkout({super.key});

  double get _defaultSpacerHeight {
    return Platform.isAndroid ? 80.0 : 100.0;
  }

  @override
  Widget build(BuildContext context) {

    final isOpened = context.select<CnStopwatchWidget, bool>((cn) => cn.isOpened);
    final timerHeight = context.select<CnStopwatchWidget, double>((cn) => cn.heightOfTimer);
    final isConnected = context.select<CnSpotifyBar, bool>((cn) => cn.isConnected);
    final spotifyHeight = context.select<CnSpotifyBar, double>((cn) => cn.height);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: _defaultSpacerHeight
          + (isOpened      ? timerHeight   : 0)
          + (isConnected   ? spotifyHeight : 0),
    );
  }
}
