import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/exercise_and_link_list_view/functions/end_action_pane.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/slidable_exercise_or_link.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class LinkWithSlideAction extends StatefulWidget {
  final bool withSpacer;
  final SlidableExerciseOrLink link;
  final Function onDismissed;
  final double heightSpacerExerciseRow;
  final bool withSlideActions;

  const LinkWithSlideAction({
    super.key,
    required this.withSpacer,
    required this.link,
    required this.onDismissed,
    required this.heightSpacerExerciseRow,
    this.withSlideActions = true
  });

  @override
  State<LinkWithSlideAction> createState() => _LinkWithSlideActionState();
}

class _LinkWithSlideActionState extends State<LinkWithSlideAction> {
  late final link = widget.link;

  @override
  Widget build(BuildContext context) {

    if(!widget.withSlideActions){
      return Container(
        decoration: BoxDecoration(
            color: CupertinoTheme.of(context).barBackgroundColor,
            borderRadius: widget.withSpacer? BorderRadius.circular(8) : const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))
        ),
        width: double.maxFinite,
        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
        margin: EdgeInsets.only(bottom: widget.withSpacer? widget.heightSpacerExerciseRow: 0),
        child: OverflowSafeText(
          link.linkName!,
          textAlign: TextAlign.left,
          minFontSize: 12,
          maxLines: 1,
        ),
      );
    }

    return Column(
      children: [
        Slidable(
            controller: link.slidableController,
            closeOnScroll: false,
            groupTag: 1,
            key: link.key,
            endActionPane: buildEndActionPane(onDismissed: widget.onDismissed),
            // child: AnimatedContainer(
            //   key: UniqueKey(),
            //   duration: const Duration(milliseconds: 300),
            //   decoration: BoxDecoration(
            //       color: CupertinoTheme.of(context).barBackgroundColor,
            //       borderRadius: widget.withSpacer? BorderRadius.circular(8) : const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))
            //   ),
            //   width: double.maxFinite,
            //   padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
            //   margin: EdgeInsets.only(bottom: widget.withSpacer? widget.heightSpacerExerciseRow: 0),
            //   child: OverflowSafeText(
            //     link.linkName!,
            //     textAlign: TextAlign.left,
            //     minFontSize: 12,
            //     maxLines: 1,
            //   ),
            // )
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).barBackgroundColor,
                  borderRadius: widget.withSpacer? BorderRadius.circular(8) : const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))
              ),
              child: Row(
                key: UniqueKey(),
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                    child: OverflowSafeText(
                      link.linkName!,
                      textAlign: TextAlign.center,
                      minFontSize: 12,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            )
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: widget.withSpacer? widget.heightSpacerExerciseRow : 0
        )
      ],
    );
  }
}
