import 'package:collection/collection.dart';
import 'package:fitness_app/screens/main_screens/screen_workout_history/screen_workout_history.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MonthSummaryChart extends StatefulWidget {
  final MonthSummary summary;

  const MonthSummaryChart({
    super.key,
    required this.summary
  });

  @override
  State<MonthSummaryChart> createState() => _MonthSummaryChartState();
}

class _MonthSummaryChartState extends State<MonthSummaryChart> {
  int touchedIndex = -1;
  late final names = widget.summary.uniqueWorkouts.toList();

  List<Color> colorsShades = [
    Colors.black45,
    Colors.black26,
    Colors.black38,
    // Colors.black12,
    Colors.black54,
  ];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // if(touchedIndex >= 0)
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            firstChild: Container(
              width: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${(widget.summary.workoutCounts.values.sum - (widget.summary.workoutCounts["Krank"]?? 0)).toString()} Workouts"),
                  if(widget.summary.workoutCounts.keys.contains("Krank"))
                    Text("${widget.summary.workoutCounts["Krank"]!.toString()} Krank"),
                  Text("${widget.summary.date.numOfDaysOfMonth() - widget.summary.workoutCounts.values.sum} Restdays")
                ],
              ),
            ),
            secondChild: Container(
              width: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(touchedIndex > -1)
                    Text(widget.summary.workoutCounts[names[touchedIndex]].toString()),
                ],
              ),
            ),
            crossFadeState: touchedIndex == -1? CrossFadeState.showFirst : CrossFadeState.showSecond,
            layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned(
                    key: bottomChildKey,
                    // bottom: 0,
                    // left: 0,
                    child: bottomChild,
                  ),
                  Positioned(
                    key: topChildKey,
                    child: topChild,
                  ),
                ],
              );
            },
          ),
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      // touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse
                        .touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(
                show: false,
              ),
              sectionsSpace: 0,
              centerSpaceRadius: 70,
              sections: showingSections(),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    final totalCount = widget.summary.workoutCounts.values.sum;
    return List.generate(names.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = touchedIndex < 0 || isTouched ? 17.0 : 12.0;
      final radius = touchedIndex < 0 || isTouched ? 45.0 : 35.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      return PieChartSectionData(
        color: colorsShades[i < colorsShades.length ?  i % colorsShades.length : (i+1) % colorsShades.length],
        value: (widget.summary.workoutCounts[names[i]]! / totalCount) * 360,
        title: names[i],
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          // color: AppColors.mainTextColor1,
          shadows: shadows,
        ),
      );
    });
  }
}