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

  List<Color> gradientColors2 = [
    const Color(0xffb3b3b3),
    const Color(0xff3e3e3e),
  ];

  bool showAvg = false;
  double minWeight = 0;
  double maxWeight = 0;
  double minTotalWeight = 0;
  double maxTotalWeight = 0;
  int maxX = 0;
  double minY = 0;
  double maxY = 0;
  double minPercent = 1;
  double maxPercent = 1;
  int verticalStepSize = 0;
  late DateTime minDate;
  List<FlSpot> spotsMaxWeight = [];
  List<FlSpot> spotsTotalMovedWeight = [];
  Map<DateTime, double>? maxWeights;
  Map<DateTime, double>? totalWeights;

  @override
  Widget build(BuildContext context) {

    // final minMaxWeights = cnScreenStatistics.getMinMaxWeights();
    maxWeights = cnScreenStatistics.getMaxWeightsPerDate();
    totalWeights = cnScreenStatistics.getTotalMovedWeight();

    if(/*minMaxWeights == null ||*/ maxWeights == null || totalWeights == null){
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

    minWeight = 10000;
    maxWeight = 0;
    maxWeights?.forEach((key, value) {
      minWeight = minWeight < value? minWeight : value;
      maxWeight = maxWeight < value? value : maxWeight;
    });
    minPercent = minWeight / maxWeight;
    maxPercent = 1;

    minTotalWeight = 10000;
    maxTotalWeight = 0;
    totalWeights?.forEach((key, value) {
      minTotalWeight = minTotalWeight < value? minTotalWeight : value;
      maxTotalWeight = maxTotalWeight < value? value : maxTotalWeight;
    });

    minDate = cnScreenStatistics.intervalSelectorMap[cnScreenStatistics.currentlySelectedIntervalAsText]!["minDate"]!;
    
    // if(cnScreenStatistics.selectedIntervalSize == TimeInterval.monthly){
    /// Set Spots Max Weight
      spotsMaxWeight.clear();
      maxWeights?.forEach((date, weight) {
        spotsMaxWeight.add(FlSpot(date.day.toDouble(), weight.toDouble()));
      });
      maxX = cnScreenStatistics.getMaxDaysOfMonths(minDate);

    /// Set Spots Total Moved Weight
      spotsTotalMovedWeight.clear();
      totalWeights?.forEach((date, totalWeight) {
        double percent = (totalWeight*1.1) / maxTotalWeight;
        if(percent.isNaN){
          percent = totalWeight / maxTotalWeight;
          if(percent.isNaN){
            spotsTotalMovedWeight.add(FlSpot(date.day.toDouble(), 0));
            return;
          }
        }
        if(percent < minPercent){
          minPercent = percent;
        }
        if(percent > maxPercent){
          maxPercent = percent;
        }
        spotsTotalMovedWeight.add(FlSpot(date.day.toDouble(), maxWeight * percent));
      });
    // }
    // else
    if(cnScreenStatistics.selectedIntervalSize == TimeInterval.quarterly){
      final List<int> daysToAddList = [];
      maxWeights?.forEach((date, weight) {
        final distanceToFirstMonthOfQuarter = (date.month-1)%3;
        int daysToAdd = 0;
        DateTime tempDate = date.copyWith();
        for(final _ in range(0, distanceToFirstMonthOfQuarter)){
          tempDate = tempDate.copyWith(month: tempDate.month - 1);
          daysToAdd = daysToAdd + cnScreenStatistics.getMaxDaysOfMonths(tempDate);
        }
        daysToAddList.add(daysToAdd);
      });

      spotsMaxWeight = spotsMaxWeight.map((spot) => FlSpot(spot.x + daysToAddList[spotsMaxWeight.indexOf(spot)], spot.y)).toList();
      spotsTotalMovedWeight = spotsTotalMovedWeight.map((spot) => FlSpot(spot.x + daysToAddList[spotsTotalMovedWeight.indexOf(spot)], spot.y)).toList();

      maxX = cnScreenStatistics.getMaxDaysOfMonths(minDate)
          + cnScreenStatistics.getMaxDaysOfMonths(DateTime(minDate.year,minDate.month+1))
          + cnScreenStatistics.getMaxDaysOfMonths(DateTime(minDate.year,minDate.month+2));
    }
    else if(cnScreenStatistics.selectedIntervalSize == TimeInterval.yearly){
      final List<int> daysToAddList = [];
      maxWeights?.forEach((date, weight) {
        final distanceToFirstMonth = date.month-1;
        int daysToAdd = 0;
        DateTime tempDate = date.copyWith();
        for(final _ in range(0, distanceToFirstMonth)){
          tempDate = tempDate.copyWith(month: tempDate.month - 1);
          daysToAdd = daysToAdd + cnScreenStatistics.getMaxDaysOfMonths(tempDate);
        }
        daysToAddList.add(daysToAdd);
      });
      spotsMaxWeight = spotsMaxWeight.map((spot) => FlSpot(spot.x + daysToAddList[spotsMaxWeight.indexOf(spot)], spot.y)).toList();
      spotsTotalMovedWeight = spotsTotalMovedWeight.map((spot) => FlSpot(spot.x + daysToAddList[spotsTotalMovedWeight.indexOf(spot)], spot.y)).toList();
      maxX = 365;
    }

    if(spotsMaxWeight.isEmpty){
      return const SizedBox();
    }

    minY = maxWeight * minPercent - 10 < 0? 0 : maxWeight * minPercent - 5;
    maxY = maxWeight*maxPercent + 5;
    final weightRange = maxY - minY;
    if(weightRange < 25){
      verticalStepSize = 2;
    } else if (weightRange < 60){
      verticalStepSize = 5;
    } else if(weightRange < 100){
      verticalStepSize = 10;
    } else {
      verticalStepSize = 20;
    }



    // spotsTotalMovedWeight = spotsMaxWeight.map((e) => FlSpot(e.x, e.y+10)).toList();
    

    // print("MIN WEIGHT: $minWeight");
    // print("MAX WEIGHT: $maxWeight");
    // print("SPOTS: $spotsMaxWeight");
    // print("SPOTS: $spotsTotalMovedWeight");
    // print("MAX X: $maxX");
    // print("MAX PERCENT: $maxPercent");
    // print(cnScreenStatistics.intervalSelectorMap[cnScreenStatistics.currentlySelectedIntervalAsText]);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Max Weight", textScaler: const TextScaler.linear(1.2), style: TextStyle(color: gradientColors[0]),),
            Text("Total Moved Weight", textScaler: const TextScaler.linear(1.2), style: TextStyle(color: gradientColors2[0]),),
          ],
        ),
        const SizedBox(height: 10,),
        Stack(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.2,
              child: Padding(
                padding: EdgeInsets.zero,
                // padding: const EdgeInsets.only(
                //   right: 18,
                //   left: 12,
                //   top: 24,
                //   bottom: 12,
                // ),
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
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: cnScreenStatistics.selectedIntervalSize == TimeInterval.yearly? 10 : 16,
    );
    Widget text;

    /// Monthly
    if(cnScreenStatistics.selectedIntervalSize == TimeInterval.monthly){
      if(value.toInt() % 5 == 0){
        text = Text(value.toInt().toString(), style: style);
      }
      else{
        text = Text('', style: style);
      }
    }
    /// Quarterly
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
          text = Text('', style: style);
          break;
      }
    }
    /// Yearly
    else{
      if((value.toInt()-15) % 30 == 0){
        text = Text(DateFormat('MMM').format(minDate.copyWith(month: minDate.month+(value.toInt() ~/ 30))), style: style);
      }
      else{
        text = Text('', style: style);
      }
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: gradientColors[0]
    );
    String text;
    if(value.toInt() % verticalStepSize == 0 && value.toInt() != 0 && value == value.toInt()){
      text = '${value.toInt()} KG';
    } else{
      return Container();
    }
    return Text(text, style: style, textAlign: TextAlign.left);
  }

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
        color: gradientColors2[0]
    );
    String text;
    if(value.toInt() % verticalStepSize == 0 && value.toInt() != 0 && value == value.toInt()){
      text = '${(((value.toInt() / ((maxWeight*maxPercent))) * (maxTotalWeight) + 5) / 1000).toStringAsFixed(2)} t';
      // text = '${(((value.toInt() / ((maxWeight*(maxPercent/1.1))+5)) * (maxTotalWeight)) / 1000).toStringAsFixed(2)} t';
    } else{
      return Container();
    }
    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> spots){
            final List<LineTooltipItem> result = spots.map((spot) => LineTooltipItem(
                textAlign: TextAlign.left,
                "${getSpotData(spot)} kg",
                TextStyle(
                  fontSize: 16,
                  color: spot.barIndex == 0? gradientColors[0] : gradientColors2[0]
                ))
            ).toList();
            return result;
          }
        )
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: verticalStepSize.toDouble(),
        verticalInterval: cnScreenStatistics.selectedIntervalSize == TimeInterval.yearly? 30 : 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[700]!.withOpacity(0.7),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey[700]!.withOpacity(0.7),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        // rightTitles: const AxisTitles(
        //   sideTitles: SideTitles(showTitles: false),
        // ),
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
            interval: verticalStepSize.toDouble(),
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
        rightTitles: AxisTitles(
          // axisNameWidget: RotatedBox(quarterTurns:1, child: Text("Test")),
          sideTitles: SideTitles(
            showTitles: true,
            interval: verticalStepSize.toDouble(),
            getTitlesWidget: rightTitleWidgets,
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
      // minY: minWeight-10 < 0? 0 : minWeight-10,
      minY: minY,
      // maxY: maxWeight*maxPercent +10,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          curveSmoothness: 0.1,
          spots: spotsMaxWeight,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: cnScreenStatistics.selectedIntervalSize == TimeInterval.yearly? 3 : 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
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
        LineChartBarData(
          curveSmoothness: 0.1,
          spots: spotsTotalMovedWeight,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors2,
          ),
          barWidth: cnScreenStatistics.selectedIntervalSize == TimeInterval.yearly? 3 : 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors2
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  String getSpotData(LineBarSpot spot){
    Map<DateTime, double> data;
    if(spot.barIndex == 0){
      data = maxWeights!;
    } else{
      data = totalWeights!;
    }
    return "${DateFormat("d.MMM").format(data.keys.toList()[spot.spotIndex])} ${data.values.toList()[spot.spotIndex]}";
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