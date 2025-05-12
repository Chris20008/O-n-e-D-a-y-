import 'dart:ui';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/other_screens/screen_running_workout/screen_running_workout.dart';
import 'block_swipe_back.dart';

class BannerRunningWorkout extends StatefulWidget {
  const BannerRunningWorkout({super.key});

  @override
  State<BannerRunningWorkout> createState() => _BannerRunningWorkoutState();
}

class _BannerRunningWorkoutState extends State<BannerRunningWorkout> {

  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnBannerRunningWorkout cnBannerRunningWorkout = Provider.of<CnBannerRunningWorkout>(context, listen: false);
  final double _height = 50;

  @override
  Widget build(BuildContext context) {

    return Hero(
      transitionOnUserGestures: true,
      tag: "Banner",
      child: Selector<CnBannerRunningWorkout, bool>(
          selector: (_, cn) => cn.showBanner,
          builder: (_, showBanner, __){
            return AnimatedCrossFade(
                firstChild: const SizedBox(width: double.maxFinite),
                secondChild: ClipRRect(
                  child: BlockSwipeBack(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaX: 10.0,
                          sigmaY: 10.0,
                          tileMode: TileMode.mirror
                      ),
                      child: Container(
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Selector<CnBannerRunningWorkout, bool>(
                              selector: (_, cn) => cn.canOpenWorkout,
                              builder: (_, canOpenWorkout, __){
                                return CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    if(canOpenWorkout){
                                      cnRunningWorkout.reopenRunningWorkout(context);
                                      cnBannerRunningWorkout.onlyShow();
                                    }
                                  },
                                  child: Container(
                                    height: _height,
                                    width: double.maxFinite,
                                    color: Colors.black.withValues(alpha: 0.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Spacer(),
                                        Expanded(
                                          flex: 4,
                                          child: Center(
                                            child: OverflowSafeText(
                                                cnRunningWorkout.workout.name,
                                                style: Theme.of(context).textTheme.titleMedium,
                                                maxLines: 1,
                                                minFontSize: 27
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                  ),
                                );
                              }
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                crossFadeState: !showBanner
                    ?CrossFadeState.showFirst
                    :CrossFadeState.showSecond,
                duration: const Duration(
                    milliseconds: 250
                )
            );
          }
      ),
    );
  }
}

class CnBannerRunningWorkout extends ChangeNotifier {
  bool showBanner = false;
  bool canOpenWorkout = false;

  void reset(){
    showBanner = false;
    canOpenWorkout = false;
    refresh();
  }

  void onlyShow(){
    showBanner = true;
    canOpenWorkout = false;
    refresh();
  }

  void activateButton(){
    showBanner = true;
    canOpenWorkout = true;
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}