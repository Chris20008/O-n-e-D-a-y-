import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/set_list_view/functions/on_reorder.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/set_list_view/widgets/footer.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/set_list_view/widgets/slidable_single_set_proxy_decorator.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/set_list_view/widgets/exercise_options_selectors.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/set_list_view/widgets/slidable_single_set/slidable_single_set.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/screen_workouts.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/screen_running_workout.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/widgets/slide_up_panel/my_slide_up_panel.dart';
import 'package:fitness_app/widgets/standard_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../../widgets/exercise_context_id.dart';

class SetListView extends StatefulWidget {
  // final ScrollController? controller;

  const SetListView({
    super.key,
    // this.controller
  });

  @override
  State<SetListView> createState() => _SetListViewState();
}

class _SetListViewState extends State<SetListView> {

  late CnNewExercisePanel cnNewExercise;
  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  late final String contextId; // = GlobalKeyContext.of(context, KeyContextId.newExercisePanel);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      contextId = GlobalKeyContext.of(context, KeyContextId.newExercisePanel);
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      cnNewExercise.disposeScrollController(contextId);
    });
  }

  @override
  Widget build(BuildContext context) {

    cnNewExercise = context.read<CnNewExercisePanel>();
    double insetsBottom = MediaQuery.of(context).viewInsets.bottom;
    double screenHeight = MediaQuery.of(context).size.height;

    return SlidableAutoCloseBehavior(
      child: ListViewScope.of(context).listView(
        padding: EdgeInsets.only(top: cnNewExercise.heightHeader - 10),
        controller: cnNewExercise.getScrollController(context),
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        children: [

          const ExerciseOptionsSelectors(),

          const SizedBox(height: 15,),

          Selector<CnNewExercisePanel, int>(
              selector: (_, cn) => cn.exercise.category,
              builder: (_, __, ___){
              return Row(
                children: [
                  Expanded(child: Center(child: OverflowSafeText(AppLocalizations.of(context)!.set, maxLines: 1))),
                  Expanded(child: Center(child: OverflowSafeText(cnNewExercise.exercise.getLeftTitle(context), maxLines: 1))),
                  Expanded(child: Center(child: OverflowSafeText(cnNewExercise.exercise.getRightTitle(context), maxLines: 1))),
                ],
              );
            }
          ),

          Selector<CnNewExercisePanel, int>(
              selector: (_, cn) => cn.exercise.sets.length,
              builder: (_, length, ___){
              return ReorderableListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 10),
                shrinkWrap: true,
                itemCount: length,
                itemBuilder: (BuildContext context, int index) {
                  return SlidableSingleSet(
                      key: tutorialIsRunning && index == 0 && cnNewExercise.isDefaultContext(context)? cnNewExercise.keySetRow : cnNewExercise.slidableKeys[index],
                      index: index,
                      insetsBottom: insetsBottom,
                      screenHeight: screenHeight,
                      cnHomepage: cnHomepage,
                      cnNewExercise: cnNewExercise
                  );
                },
                proxyDecorator: (Widget child, int index, Animation<double> animation) =>
                    SlidableSingleSetProxyDecorator(
                        index: index,
                        animation: animation,
                        child: child
                    ),
                onReorder: (int oldIndex, int newIndex) => onReorder(oldIndex, newIndex, setState, cnNewExercise),
              );
            }
          ),

          const Footer()
        ],
      ),
    );
  }
}


