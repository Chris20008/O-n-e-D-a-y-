import 'package:fitness_app/screens/other_screens/screen_running_workout/screen_running_workout.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../util/constants.dart';
import '../../../widgets/banner_running_workout.dart';

class WrapperScreenRunningWorkout extends StatefulWidget {
  const WrapperScreenRunningWorkout({
    super.key,
  });

  @override
  State<WrapperScreenRunningWorkout> createState() => _WrapperScreenRunningWorkout();
}

class _WrapperScreenRunningWorkout extends State<WrapperScreenRunningWorkout> {

  late CnRunningWorkout cnRunningWorkout = context.read<CnRunningWorkout>();
  late CnBannerRunningWorkout cnBannerRunningWorkout = context.read<CnBannerRunningWorkout>();

  @override
  Widget build(BuildContext context) {
    final isSavingData = context.select<CnRunningWorkout, bool>((cn) => cn.isSavingData);

    pr("Wrapper Running Workout");

    return PopScope(
      canPop: !isSavingData,
      onPopInvokedWithResult: (doPop, res) {
        if (cnRunningWorkout.isVisible) {
          cnRunningWorkout.lastScrollPosition = cnRunningWorkout.scrollController.offset;
          cnRunningWorkout.isVisible = false;
          cnRunningWorkout.cache();
          cnBannerRunningWorkout.activateButton();
        }
        else {
          cnBannerRunningWorkout.reset();
        }
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: const ScreenRunningWorkout()
    );
  }
}