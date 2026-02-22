import 'package:flutter/cupertino.dart';
import '../../../../../../../../objects/exercise.dart';
import '../../../../../../../../util/constants.dart';
import 'package:fitness_app/l10n/app_localizations.dart';

class RestInSecondsSelectorRunningWorkout extends StatefulWidget {
  final Exercise exercise;
  final double iconSize;
  final TextStyle? style;

  const RestInSecondsSelectorRunningWorkout({
    super.key,
    required this.exercise,
    required this.iconSize,
    required this.style
  });

  @override
  State<RestInSecondsSelectorRunningWorkout> createState() => _RestInSecondsSelectorRunningWorkoutState();
}

class _RestInSecondsSelectorRunningWorkoutState extends State<RestInSecondsSelectorRunningWorkout> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: 30,
        child: Row(
          children: [
            getSelectRestInSeconds(
                currentTime: widget.exercise.restInSeconds,
                context: context,
                child: SizedBox(
                  width: 100,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(CupertinoIcons.timer, size: widget.iconSize),
                        const SizedBox(width: 2,),
                        Text(mapRestInSecondsToString(restInSeconds: widget.exercise.restInSeconds), style: widget.style),
                        const SizedBox(width: 10,)
                      ],
                    ),
                  ),
                ),
                onConfirm: (dynamic value) async{
                  if(value is int){
                    widget.exercise.restInSeconds = value;
                    // cnRunningWorkout.refresh();
                  }
                  else if(value == AppLocalizations.of(context)!.clear){
                    widget.exercise.restInSeconds = 0;
                    // cnRunningWorkout.refresh();
                  }
                  else{
                    await showDialogMinuteSecondPicker(
                        context: context,
                        initialTimeDuration: Duration(minutes: widget.exercise.restInSeconds~/60, seconds: widget.exercise.restInSeconds%60),
                        onConfirm: (Duration newDuration){
                          widget.exercise.restInSeconds = newDuration.inSeconds;
                        }
                    );
                  }
                  setState(() {});
                }
            ),
            const Spacer()
          ],
        ),
      ),
    );
  }
}