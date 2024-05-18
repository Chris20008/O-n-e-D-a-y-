import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  final double maxVisibleDays = 1900;
  double currentVisibleDays = 0;
  double minY = 0;
  double maxY = 0;
  double minPercent = 1;
  double maxPercent = 1;
  final double _widthAxisTitles = 50;
  int verticalStepSize = 0;
  late DateTime minDate;
  late DateTime maxDate;
  // late final width = MediaQuery.of(context).size.width;
  double width = 0;
  List<FlSpot> spotsMaxWeight = [];
  double offsetMinX = 0;
  double offsetMaxX = 0;
  Offset? pointerA;
  Offset? pointerAPreviousPos;
  Offset? pointerB;
  int? pointerAIdentifier;
  int? pointerBIdentifier;
  double lastPointerDistance = 0;
  double focalPointPercent = 0;
  bool isZooming = false;
  final int _leftPadding = 5;
  late final int _totalPadding = _leftPadding * 2;
  List<FlSpot> spotsAvgWeightPerSet = [];
  Map<DateTime, double>? maxWeights;
  Map<DateTime, double>? avgWeights;

  int animationTime = 500;

  @override
  Widget build(BuildContext context) {

    width = MediaQuery.of(context).size.width;
    minDate = cnScreenStatistics.minDate;
    maxDate = cnScreenStatistics.maxDate;

    final tempMaxX = maxDate.difference(minDate).inDays + _totalPadding - offsetMaxX;
    if(tempMaxX > maxVisibleDays){
      final rest = tempMaxX - maxVisibleDays;
      if(currentVisibleDays <= 0){
        offsetMinX += rest;
      }
      offsetMaxX += rest - _totalPadding;
      currentVisibleDays = maxVisibleDays;
    } else{
      currentVisibleDays = tempMaxX;
    }

    // final minMaxWeights = cnScreenStatistics.getMinMaxWeights();
    maxWeights = cnScreenStatistics.getMaxWeightsPerDate();
    avgWeights = cnScreenStatistics.getAvgMovedWeightPerSet();

    // if(/*minMaxWeights == null ||*/ maxWeights == null /*|| avgWeights == null*/){
    //   if(cnScreenStatistics.isCalculatingData){
    //     return const SizedBox(
    //         height: 100,
    //         width: 100,
    //         child: Center(child: CircularProgressIndicator())
    //     );
    //   } else {
    //     return const SizedBox();
    //   }
    // }

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

    avgWeights?.forEach((key, value) {
      minTotalWeight = minTotalWeight < value? minTotalWeight : value;
      maxTotalWeight = maxTotalWeight < value? value : maxTotalWeight;
    });

    minDate = cnScreenStatistics.minDate;
    maxDate = cnScreenStatistics.maxDate;

    // if(cnScreenStatistics.selectedIntervalSize == TimeInterval.monthly){
    /// Set Spots Max Weight
    spotsMaxWeight.clear();
    maxWeights?.forEach((date, weight) {
      // spotsMaxWeight.add(FlSpot(date.day.toDouble(), weight.toDouble()));
      final xCoordinate = date.difference(minDate).inDays.toDouble() - offsetMinX + _leftPadding;
      spotsMaxWeight.add(FlSpot(xCoordinate, weight.toDouble()));
    });
    // maxX = cnScreenStatistics.getMaxDaysOfMonths(minDate);

    /// Set Spots Total Moved Weight
    spotsAvgWeightPerSet.clear();
    avgWeights?.forEach((date, totalWeight) {
      double percent = (totalWeight*1.1) / maxTotalWeight;
      final xCoordinate = date.difference(minDate).inDays.toDouble() - offsetMinX + _leftPadding;
      if(percent.isNaN){
        percent = totalWeight / maxTotalWeight;
        if(percent.isNaN){
          spotsAvgWeightPerSet.add(FlSpot(xCoordinate, 0));
          return;
        }
      }
      if(percent < minPercent){
        minPercent = percent;
      }
      if(percent > maxPercent){
        maxPercent = percent;
      }
      spotsAvgWeightPerSet.add(FlSpot(xCoordinate, maxWeight * percent));
    });
    // print("MAXX: $currentVisibleDays");

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

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Max Weight", textScaler: const TextScaler.linear(1.2), style: TextStyle(color: gradientColors[0]),),
            // Text("Total Moved Weight", textScaler: const TextScaler.linear(1.2), style: TextStyle(color: gradientColors2[0]),),
          ],
        ),
        const SizedBox(height: 10,),
        Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (PointerDownEvent details){
            animationTime = 0;
            if(pointerAIdentifier == null){
              pointerAIdentifier = details.pointer;
              pointerA = details.position;
              pointerAPreviousPos = Offset(pointerA!.dx, pointerA!.dy);
            }
            else if (pointerBIdentifier == null && details.pointer != pointerAIdentifier){
              pointerBIdentifier = details.pointer;
              pointerB = details.position;
              lastPointerDistance = (pointerB!.dx - pointerA!.dx).abs();
              final minPos = pointerB!.dx < pointerA!.dx? pointerB!.dx : pointerA!.dx;
              /// the middle point between the two pointer in percent minus an offset of 0.2
              focalPointPercent = (lastPointerDistance/2 + minPos - _widthAxisTitles) / width;
            }
          },
          onPointerMove: (PointerMoveEvent details){
            if(details.pointer == pointerAIdentifier){
              pointerA = details.position;
            }
            else if(details.pointer == pointerBIdentifier){
              pointerB = details.position;
            }

            /// ZOOM
            if(pointerA != null && pointerB != null && !isZooming){
              isZooming = true;
              // final totalRange = maxDate.difference(minDate).inDays;
              // double sensibility = (currentVisibleDays / 1);
              // sensibility = sensibility > 200? 200 : sensibility;
              // final currentVisibleDays = maxX;
              // double sensibility = ((currentVisibleDays*(currentVisibleDays*0.1)) / (1500);
              double sensibility = ((currentVisibleDays) / (1500 / sqrt(currentVisibleDays)));
              // double sensibility = ((currentVisibleDays/(currentVisibleDays*0.05)) / 10);
              // sensibility = sensibility < 1? 1 : sensibility;
              final maxDays = maxDate.difference(minDate).inDays;
              final currentPointerDistance = (pointerB!.dx - pointerA!.dx).abs();
              final difference = (lastPointerDistance - currentPointerDistance) * sensibility;
              lastPointerDistance = currentPointerDistance;

              setState(() {
                double newOffsetMaxX;
                double newOffsetMinX;

                newOffsetMaxX = (offsetMaxX - difference);
                newOffsetMaxX = newOffsetMaxX >= 0? newOffsetMaxX : 0;
                newOffsetMinX = (offsetMinX - difference * focalPointPercent);
                newOffsetMinX = newOffsetMinX >= 0? newOffsetMinX : 0;

                if(newOffsetMaxX + 5 < maxDays && maxDate.difference(minDate).inDays + _totalPadding - newOffsetMaxX <= maxVisibleDays /*&& currentVisibleDays + (newOffsetMaxX - offsetMaxX) <= maxVisibleDays*/){
                  offsetMinX = newOffsetMinX;
                  offsetMaxX = newOffsetMaxX;
                }
              });
              Future.delayed(const Duration(milliseconds: 30), (){
                isZooming = false;
              });
            }

            /// SCROLL
            else if(pointerA != null && pointerB == null && pointerAPreviousPos != null){
              final totalRange = maxDate.difference(minDate).inDays;
              final maxValueOffsetMinX = totalRange - currentVisibleDays + _totalPadding;
              double sensibility = 1/ (currentVisibleDays / 280); // maybe 300
              sensibility = sensibility < 0.1? 0.1 : sensibility > 500? 500 : sensibility;
              final currentPointerDistance = (pointerAPreviousPos!.dx - pointerA!.dx) / sensibility;

              double newOffsetMinX;

              newOffsetMinX = offsetMinX + currentPointerDistance;
              if(newOffsetMinX >= 0 && newOffsetMinX != offsetMinX && (newOffsetMinX <= maxValueOffsetMinX || newOffsetMinX <= offsetMinX)){
                setState(() {
                  offsetMinX = newOffsetMinX;
                  pointerAPreviousPos = Offset(pointerA!.dx, pointerA!.dy);
                });
              }
              setState(() {});
            }

          },
          onPointerUp: (PointerUpEvent details){
            // if(details.pointer == pointerAIdentifier){
            pointerA = null;
            pointerAPreviousPos = null;
            pointerAIdentifier = null;
            // } else if(details.pointer == pointerBIdentifier){
            pointerB = null;
            pointerBIdentifier = null;
            // }
            isZooming = false;
            Future.delayed(const Duration(milliseconds: 500), (){
              if(pointerA == null && pointerB == null){
                animationTime = 500;
              }
            });
          },
          child: Stack(
            children: <Widget>[
              AspectRatio(
                // aspectRatio: MediaQuery.of(context).orientation == Orientation.portrait ? 1.2 : 3.5,
                aspectRatio: cnScreenStatistics.width / (cnScreenStatistics.height * (cnScreenStatistics.orientation == Orientation.portrait? 0.6 : 0.7)),
                child: Padding(
                  padding: EdgeInsets.zero,
                  // padding: const EdgeInsets.only(
                  //   right: 18,
                  //   left: 12,
                  //   top: 24,
                  //   bottom: 12,
                  // ),
                  child: LineChart(
                      duration: Duration(milliseconds: animationTime),
                      curve: Curves.easeInOut,
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
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    Widget text;

    value += offsetMinX;

    if(currentVisibleDays < 200 && value % 1.0 > 0.1){
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: const Text('', style: style)
      );
    }

    if(value < 5){
      text = const Text('', style: style);
    }
    else{
      value -= _leftPadding;
      DateTime valuesDate = minDate.add(Duration(days: value.toInt()));
      text = generateXAxisText(valuesDate, style);
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget generateXAxisText(DateTime date, TextStyle style){
    bool doLabel;
    String format;
    if(currentVisibleDays < 20){
      doLabel = date.day % 5 == 0;
      format = 'd. MMM';
    } else if(currentVisibleDays < 40){
      doLabel = date.day % 10 == 0;
      format = 'd. MMM';
    } else if(currentVisibleDays < 80){
      doLabel = date.day % 15 == 0 || (date.day == 28 && date.month == 2);
      format = 'd. MMM';
    } else if(currentVisibleDays < 200){
      doLabel = date.day == 1;
      format = 'MMM yy';
    } else if(currentVisibleDays < 400){
      doLabel = date.day == 1 && date.month % 2 == 0;
      format = 'MMM yy';
    }else if (currentVisibleDays < 700){
      doLabel = date.day == 1 && date.month % 3 == 0;
      format = 'MMM yy';
    } else{
      doLabel = date.day == 1 && date.month == 1;
      format = 'y';
    }


    if(doLabel){
      return Text(DateFormat(format, Localizations.localeOf(context).languageCode).format(date), style: style);
    } else{
      return Text('', style: style);
    }
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
                  fontSize: 14,
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
        verticalInterval: 30,
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
            interval: currentVisibleDays < 200? 0.1 : 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: verticalStepSize.toDouble(),
            getTitlesWidget: leftTitleWidgets,
            reservedSize: _widthAxisTitles,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff5e5e5e)),
      ),
      minX: 0,
      maxX: currentVisibleDays.toDouble(),
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          curveSmoothness: 0.1,
          spots: spotsMaxWeight,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 3,
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
        if(cnScreenStatistics.showAvgWeightPerSetLine)
          LineChartBarData(
            curveSmoothness: 0.1,
            spots: spotsAvgWeightPerSet,
            isCurved: true,
            gradient: LinearGradient(
              colors: gradientColors2,
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(
              show: true,
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
      data = avgWeights!;
    }
    return "${DateFormat("d.MMM").format(data.keys.toList()[spot.spotIndex])} ${data.values.toList()[spot.spotIndex].toInt()}";
  }
}