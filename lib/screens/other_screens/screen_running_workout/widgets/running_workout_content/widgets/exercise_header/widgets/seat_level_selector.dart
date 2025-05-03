import 'package:flutter/material.dart';
import '../../../../../../../../assets/custom_icons/my_icons_icons.dart';
import '../../../../../../../../objects/exercise.dart';
import '../../../../../../../../util/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SeatLevelSelectorRunningWorkout extends StatefulWidget {
  final Exercise exercise;
  final double iconSize;
  final TextStyle? style;

  const SeatLevelSelectorRunningWorkout({
    super.key,
    required this.exercise,
    required this.iconSize,
    required this.style
  });

  @override
  State<SeatLevelSelectorRunningWorkout> createState() => _SeatLevelSelectorRunningWorkoutState();
}

class _SeatLevelSelectorRunningWorkoutState extends State<SeatLevelSelectorRunningWorkout> {
  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: SizedBox(
                height: 30,
                child: getSelectSeatLevel(
                    currentSeatLevel: widget.exercise.seatLevel,
                    child: SizedBox(
                      width: 100,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 100,
                          height: 30,
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.airline_seat_recline_normal, size: widget.iconSize),
                              const SizedBox(width: 2,),
                              if (widget.exercise.seatLevel == null)
                                Text("-", style: widget.style,)
                              else
                                Text(widget.exercise.seatLevel.toString(), style: widget.style,)
                            ],
                          ),
                        ),
                      ),
                    ),
                    onConfirm: (dynamic value){
                      if(value is int){
                        widget.exercise.seatLevel = value;
                        // cnRunningWorkout.refresh();
                      }
                      else if(value == AppLocalizations.of(context)!.clear){
                        widget.exercise.seatLevel = null;
                        // cnRunningWorkout.refresh();
                      }
                      setState(() {});
                    },
                    context: context
                ),
              )
          ),
          Icon(MyIcons.tags, size: widget.iconSize-3),
          const SizedBox(width: 8,),
          Text(widget.exercise.getCategoryName())
        ]
    );
  }
}
