import 'package:fitness_app/screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IntervalSizeSelector extends StatefulWidget {
  const IntervalSizeSelector({super.key});

  @override
  State<IntervalSizeSelector> createState() => _IntervalSizeSelectorState();
}

class _IntervalSizeSelectorState extends State<IntervalSizeSelector> {
  late CnScreenStatistics cnScreenStatistics  = Provider.of<CnScreenStatistics>(context);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        children: intervalButtons,
      ),
    );
  }

  List<Widget> get intervalButtons => [
    for(TimeInterval ti in TimeInterval.values)
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                // shadowColor: Colors.transparent,
                backgroundColor: cnScreenStatistics.selectedIntervalSize == ti? Colors.amber[800] : Colors.transparent,
                // fixedSize: size,
                padding: const EdgeInsets.all(0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: (){
                if(cnScreenStatistics.selectedIntervalSize != ti){
                  cnScreenStatistics.selectedWorkout = null;
                  cnScreenStatistics.selectedExercise = null;
                  cnScreenStatistics.selectedIntervalSize = ti;
                  cnScreenStatistics.refreshIntervalSelectorMap();
                  cnScreenStatistics.refresh();
                }
              },
              child: Text(ti.value)
          ),
        ),
      ),
  ];

  // List<Widget> getIntervalButtons(){
  //   List<Widget> buttons = [];
  //   for(TimeInterval ti in TimeInterval.values){
  //     buttons.add(
  //       ElevatedButton(
  //           style: ElevatedButton.styleFrom(
  //             foregroundColor: Colors.white,
  //             // shadowColor: Colors.transparent,
  //             backgroundColor: cnScreenStatistics.selectedIntervalSize == ti? Colors.amber[800] : Colors.transparent,
  //             // fixedSize: size,
  //             padding: const EdgeInsets.all(0),
  //             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //           ),
  //           onPressed: (){
  //             // setState(() {
  //             //   cnScreenStatistics.currentlySelectedIntervalAsText = text;
  //             //   double newPos = buttonWidth * index - width/2 + buttonWidth/2 +leftRightBoxesWidth;
  //             //   _scrollController.animateTo(newPos, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  //             // });
  //             cnScreenStatistics.refresh();
  //           },
  //           child: Text(ti.name)
  //       ),
  //     );
  //   }
  //   return buttons;
  // }
}
