import 'package:fitness_app/util/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';

import '../screen_statistics.dart';

class LineChartExerciseWeightProgress extends StatefulWidget {
  const LineChartExerciseWeightProgress({super.key});

  @override
  State<LineChartExerciseWeightProgress> createState() => _LineChartExerciseWeightProgressState();
}

class _LineChartExerciseWeightProgressState extends State<LineChartExerciseWeightProgress> {
  late CnScreenStatistics cnScreenStatistics = Provider.of<CnScreenStatistics>(context);
  List<Color> gradientColors = [
    Colors.amber[200]!,
    Colors.amber[800]!,
  ];

  bool showAvg = false;
  int minWeight = 0;
  int maxWeight = 0;
  int maxX = 0;
  late DateTime minDate;
  List<FlSpot> spots = [];

  @override
  Widget build(BuildContext context) {

    final minMaxWeights = cnScreenStatistics.getMinMaxWeights();
    final Map<DateTime, int>? maxWeights = cnScreenStatistics.getMaxWeightsPerDate();

    if(minMaxWeights == null || maxWeights == null){
      if(cnScreenStatistics.isCalculatingData){
        return const SizedBox(
            height: 100,
            width: 100,
            child: Center(child: CircularProgressIndicator())
        );
      } else {
        return const SizedBox();
      }
    }

    minWeight = minMaxWeights[0]!;
    maxWeight = minMaxWeights[1]!;
    minDate = cnScreenStatistics.intervalSelectorMap[cnScreenStatistics.currentlySelectedIntervalAsText]!["minDate"]!;
    
    if(cnScreenStatistics.selectedIntervalSize == TimeInterval.monthly){
      spots.clear();
      maxWeights.forEach((date, weight) {
        spots.add(FlSpot(date.day.toDouble(), weight.toDouble()));
      });
      maxX = cnScreenStatistics.getMaxDaysOfMonths(minDate);
    }
    else if(cnScreenStatistics.selectedIntervalSize == TimeInterval.quarterly){
      spots.clear();
      maxWeights.forEach((date, weight) {
        final distanceToFirstMonthOfQuarter = (date.month-1)%3;
        print("DAYS TO ADD: $distanceToFirstMonthOfQuarter");
        int daysToAdd = 0;
        DateTime tempDate = date.copyWith();
        for(final i in range(0, distanceToFirstMonthOfQuarter)){
          tempDate = tempDate.copyWith(month: tempDate.month - 1);
          daysToAdd = daysToAdd + cnScreenStatistics.getMaxDaysOfMonths(tempDate);
        }
        print("DAYS TO ADD: $daysToAdd");
        spots.add(FlSpot((date.day + daysToAdd).toDouble(), weight.toDouble()));
      });
      maxX = cnScreenStatistics.getMaxDaysOfMonths(minDate)
          + cnScreenStatistics.getMaxDaysOfMonths(DateTime(minDate.year,minDate.month+1))
          + cnScreenStatistics.getMaxDaysOfMonths(DateTime(minDate.year,minDate.month+2));
    }
    

    print("MIN WEIGHT: $minWeight");
    print("MAX WEIGHT: $maxWeight");
    print("SPOTS: $spots");
    print("MAX X: $maxX");
    print(cnScreenStatistics.intervalSelectorMap[cnScreenStatistics.currentlySelectedIntervalAsText]);

    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
                mainData()
              // showAvg ? avgData() : mainData(),
            ),
          ),
        ),
        // SizedBox(
        //   width: 60,
        //   height: 34,
        //   child: TextButton(
        //     onPressed: () {
        //       setState(() {
        //         showAvg = !showAvg;
        //       });
        //     },
        //     child: Text(
        //       'avg',
        //       style: TextStyle(
        //         fontSize: 12,
        //         color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    if(cnScreenStatistics.selectedIntervalSize == TimeInterval.monthly){
      switch (value.toInt()) {
        case 1:
          text = const Text('1', style: style);
          break;
        case 5:
          text = const Text('5', style: style);
          break;
        case 10:
          text = const Text('10', style: style);
          break;
        case 15:
          text = const Text('15', style: style);
          break;
        case 20:
          text = const Text('20', style: style);
          break;
        case 25:
          text = const Text('25', style: style);
          break;
        case 30:
          text = const Text('30', style: style);
          break;
        default:
          text = const Text('', style: style);
          break;
      }
    }
    else if(cnScreenStatistics.selectedIntervalSize == TimeInterval.quarterly){
      switch (value.toInt()) {
        case 15:
          text = Text(DateFormat('MMM').format(minDate), style: style);
          break;
        case 45:
          text = Text(DateFormat('MMM').format(minDate.copyWith(month: minDate.month+1)), style: style);
          break;
        case 75:
          text = Text(DateFormat('MMM').format(minDate.copyWith(month: minDate.month+2)), style: style);
          break;
        default:
          text = const Text('', style: style);
          break;
      }
    }
    else{
      text = const Text('', style: style);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 10:
        text = '10 KG';
        break;
      case 30:
        text = '30 kg';
        break;
      case 50:
        text = '50 kg';
        break;
      case 70:
        text = '70 kg';
        break;
      case 90:
        text = '90 kg';
        break;
      case 110:
        text = '110 kg';
        break;
      case 130:
        text = '130 kg';
        break;
      case 150:
        text = '150 kg';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      // lineTouchData: LineTouchData(
      //   enabled: false
      // ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 5,
        verticalInterval: 5,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.grey,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.grey,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff5e5e5e)),
      ),
      minX: 0,
      maxX: maxX.toDouble(),
      minY: minWeight-10 < 0? 0 : minWeight-10,
      maxY: maxWeight+10,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  // LineChartData avgData() {
  //   return LineChartData(
  //     lineTouchData: const LineTouchData(enabled: false),
  //     gridData: FlGridData(
  //       show: true,
  //       drawHorizontalLine: true,
  //       verticalInterval: 1,
  //       horizontalInterval: 1,
  //       getDrawingVerticalLine: (value) {
  //         return const FlLine(
  //           color: Color(0xff37434d),
  //           strokeWidth: 1,
  //         );
  //       },
  //       getDrawingHorizontalLine: (value) {
  //         return const FlLine(
  //           color: Color(0xff37434d),
  //           strokeWidth: 1,
  //         );
  //       },
  //     ),
  //     titlesData: FlTitlesData(
  //       show: true,
  //       bottomTitles: AxisTitles(
  //         sideTitles: SideTitles(
  //           showTitles: true,
  //           reservedSize: 30,
  //           getTitlesWidget: bottomTitleWidgets,
  //           interval: 1,
  //         ),
  //       ),
  //       leftTitles: AxisTitles(
  //         sideTitles: SideTitles(
  //           showTitles: true,
  //           getTitlesWidget: leftTitleWidgets,
  //           reservedSize: 42,
  //           interval: 1,
  //         ),
  //       ),
  //       topTitles: const AxisTitles(
  //         sideTitles: SideTitles(showTitles: false),
  //       ),
  //       rightTitles: const AxisTitles(
  //         sideTitles: SideTitles(showTitles: false),
  //       ),
  //     ),
  //     borderData: FlBorderData(
  //       show: true,
  //       border: Border.all(color: const Color(0xff37434d)),
  //     ),
  //     minX: 0,
  //     maxX: 11,
  //     minY: 0,
  //     maxY: 6,
  //     lineBarsData: [
  //       LineChartBarData(
  //         spots: const [
  //           FlSpot(0, 3.44),
  //           FlSpot(2.6, 3.44),
  //           FlSpot(4.9, 3.44),
  //           FlSpot(6.8, 3.44),
  //           FlSpot(8, 3.44),
  //           FlSpot(9.5, 3.44),
  //           FlSpot(11, 3.44),
  //         ],
  //         isCurved: true,
  //         gradient: LinearGradient(
  //           colors: [
  //             ColorTween(begin: gradientColors[0], end: gradientColors[1])
  //                 .lerp(0.2)!,
  //             ColorTween(begin: gradientColors[0], end: gradientColors[1])
  //                 .lerp(0.2)!,
  //           ],
  //         ),
  //         barWidth: 5,
  //         isStrokeCapRound: true,
  //         dotData: const FlDotData(
  //           show: false,
  //         ),
  //         belowBarData: BarAreaData(
  //           show: true,
  //           gradient: LinearGradient(
  //             colors: [
  //               ColorTween(begin: gradientColors[0], end: gradientColors[1])
  //                   .lerp(0.2)!
  //                   .withOpacity(0.1),
  //               ColorTween(begin: gradientColors[0], end: gradientColors[1])
  //                   .lerp(0.2)!
  //                   .withOpacity(0.1),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}