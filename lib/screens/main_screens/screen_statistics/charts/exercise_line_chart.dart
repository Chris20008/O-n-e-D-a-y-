import 'dart:math';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:fitness_app/util/objectbox/ob_sick_days.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../screen_statistics.dart';

class ExerciseLineChart extends StatefulWidget {
  const ExerciseLineChart({super.key});

  @override
  State<ExerciseLineChart> createState() => _ExerciseLineChartState();
}

class _ExerciseLineChartState extends State<ExerciseLineChart> {
  late CnScreenStatistics cnScreenStatistics = Provider.of<CnScreenStatistics>(context);
  List<Color> gradientColors = [
    Colors.amber[200]!,
    Colors.amber[800]!,
  ];

  List<Color> gradientColors2 = [
    const Color(0xffb3b3b3),
    const Color(0xff3e3e3e),
  ];

  List<Color> gradientColors3 = [
    const Color(0xff147e88),
    const Color(0xff147e88),
  ];

  double minWeight = 0;
  double maxWeight = 0;
  double minTotalWeight = 0;
  double maxTotalWeight = 0;
  // final double maxVisibleDays = 1900;
  double minY = 0;
  double maxY = 0;
  double minPercent = 1;
  double maxPercent = 1;
  final double _widthAxisTitles = 50;
  int verticalStepSize = 0;
  late DateTime minDate;
  late DateTime maxDate;
  double width = 0;
  List<FlSpot> spotsMaxWeight = [];
  List<FlSpot> spotsAvgWeightPerSet = [];
  List<FlSpot> sickDaysSpots = [];
  Offset? pointerA;
  Offset? pointerAPreviousPos;
  Offset? pointerB;
  int? pointerAIdentifier;
  int? pointerBIdentifier;
  double lastPointerDistance = 0;
  double focalPointPercent = 0;
  final int _leftPadding = 5;
  late final int _totalPadding = _leftPadding * 2;
  Map<DateTime, double>? maxWeights;
  Map<DateTime, double>? avgWeights;
  int animationTime = 500;
  bool firstLoad = true;
  int countSteps = 0;
  double percent = 0.7;

  @override
  Widget build(BuildContext context) {
    List<FlSpot> tempSpotsMaxWeight = [];
    List<FlSpot> tempSpotsAvgWeightPerSet = [];
    List<FlSpot> tempSickDaysSpots = [];

    final t = objectbox.exerciseBox.query((ObExercise_.name.equals(cnScreenStatistics.selectedExerciseName??"").and(ObExercise_.category.equals(1)))).build().findFirst();
    if(t == null && cnScreenStatistics.selectedExerciseName != null){
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "The Category of this Exercise is currently not supported for statistics",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    width = MediaQuery.of(context).size.width;
    minDate = cnScreenStatistics.minDate.toDate();
    maxDate = cnScreenStatistics.maxDate.toDate();

    final tempMaxX = maxDate.difference(minDate).inDays + _totalPadding - cnScreenStatistics.offsetMaxX;
    if(tempMaxX > cnScreenStatistics.maxVisibleDays){
      final rest = tempMaxX - cnScreenStatistics.maxVisibleDays;
      if(cnScreenStatistics.currentVisibleDays <= 0){
        cnScreenStatistics.offsetMinX += rest;
      }
      cnScreenStatistics.offsetMaxX += rest - _totalPadding;
      cnScreenStatistics.currentVisibleDays = cnScreenStatistics.maxVisibleDays;
    } else{
      cnScreenStatistics.currentVisibleDays = tempMaxX;
    }

    maxWeights = cnScreenStatistics.getMaxWeightsPerDate();
    avgWeights = cnScreenStatistics.getAvgMovedWeightPerSet();

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

    minDate = cnScreenStatistics.minDate.toDate();
    maxDate = cnScreenStatistics.maxDate.toDate();

    /// Set Spots Max Weight
    maxWeights?.forEach((date, weight) {
      final xCoordinate = date.toDate().difference(minDate.toDate()).inDays.toDouble() - cnScreenStatistics.offsetMinX + _leftPadding;
      tempSpotsMaxWeight.add(FlSpot(xCoordinate, weight.toDouble()));
    });

    /// Set Spots Total Moved Weight
    avgWeights?.forEach((date, totalWeight) {
      double percent = (totalWeight*1.1) / maxTotalWeight;
      final xCoordinate = date.toDate().difference(minDate.toDate()).inDays.toDouble() - cnScreenStatistics.offsetMinX + _leftPadding;
      if(percent.isNaN){
        percent = totalWeight / (maxTotalWeight.isNaN? 1 : maxTotalWeight);
        if(percent.isNaN){
          tempSpotsAvgWeightPerSet.add(FlSpot(xCoordinate, 0));
          return;
        }
      }
      if(percent < minPercent){
        minPercent = percent;
      }
      if(percent > maxPercent){
        maxPercent = percent;
      }
      tempSpotsAvgWeightPerSet.add(FlSpot(xCoordinate, maxWeight * percent));
    });

    minY = maxWeight * minPercent - 10 < 0? 0 : maxWeight * minPercent - 5;
    minY = minY.isNaN? -4 : minY;
    maxY = maxWeight*maxPercent + 5;
    print("MINY");
    print(percent);
    print(minY);
    if(minY == maxY){
      maxY += 50;
    }
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

    for (ObSickDays sickDay in cnScreenStatistics.allSickDays){
      double xCoordinate = sickDay.startDate.toDate().difference(minDate.toDate()).inDays.toDouble() - cnScreenStatistics.offsetMinX + _leftPadding;
      double percent = 5;
      double factor = maxWeight > 0? maxWeight : 4;
      tempSickDaysSpots.add(FlSpot(xCoordinate, -5));
      tempSickDaysSpots.add(FlSpot(xCoordinate, factor * percent));
      xCoordinate = sickDay.endDate.toDate().difference(minDate.toDate()).inDays.toDouble() - cnScreenStatistics.offsetMinX + _leftPadding;
      tempSickDaysSpots.add(FlSpot(xCoordinate, factor * percent));
      tempSickDaysSpots.add(FlSpot(xCoordinate, -5));
    }

    if(firstLoad){
      tempSpotsMaxWeight = List.generate(tempSpotsMaxWeight.length, (index) => FlSpot(tempSpotsMaxWeight[index].x, minY));
      tempSpotsAvgWeightPerSet = List.generate(tempSpotsAvgWeightPerSet.length, (index) => FlSpot(tempSpotsAvgWeightPerSet[index].x, minY));
      Future.delayed(const Duration(milliseconds: 100), (){
        setState(() {
          firstLoad = false;
        });
      });
    }

    if(!cnScreenStatistics.showAvgWeightPerSetLine){
      tempSpotsAvgWeightPerSet = List.generate(tempSpotsAvgWeightPerSet.length, (index) => FlSpot(tempSpotsAvgWeightPerSet[index].x, minY-5));
      // tempSpotsAvgWeightPerSet = List.generate(tempSpotsAvgWeightPerSet.length, (index) => FlSpot(tempSpotsAvgWeightPerSet[index].x, -5));
    } else{
      tempSpotsAvgWeightPerSet = List.generate(tempSpotsAvgWeightPerSet.length, (index) => FlSpot(tempSpotsAvgWeightPerSet[index].x, tempSpotsAvgWeightPerSet[index].y));
    }

    if(!cnScreenStatistics.showSickDays){
      tempSickDaysSpots = List.generate(tempSickDaysSpots.length, (index) => FlSpot(tempSickDaysSpots[index].x, -5));
    } else{
      tempSickDaysSpots = List.generate(tempSickDaysSpots.length, (index) => FlSpot(tempSickDaysSpots[index].x, tempSickDaysSpots[index].y));
    }

    spotsMaxWeight = tempSpotsMaxWeight;
    spotsAvgWeightPerSet = tempSpotsAvgWeightPerSet;
    sickDaysSpots = tempSickDaysSpots;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context)!.statisticsMaxWeight, textScaler: const TextScaler.linear(1.2), style: TextStyle(color: gradientColors[0]),),
            const Spacer(),
            IconButton(
                onPressed: (){
                  HapticFeedback.selectionClick();
                  setState(() {
                    cnScreenStatistics.graphLocked = !cnScreenStatistics.graphLocked;
                  });
                },
                icon: cnScreenStatistics.graphLocked? const Icon(Icons.lock_outlined) : const Icon(Icons.lock_open),
            )
          ],
        ),
        const SizedBox(height: 10,),
        LayoutBuilder(
          builder: (context, constraints) {
            return Listener(
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
                  /// the middle point between the two pointer in percent
                  focalPointPercent = (lastPointerDistance/2 + minPos - _widthAxisTitles) / width;
                }
              },
              onPointerMove: (PointerMoveEvent details){
                if(cnScreenStatistics.graphLocked){
                  return;
                }
                if(details.pointer == pointerAIdentifier){
                  pointerA = details.position;
                }
                else if(details.pointer == pointerBIdentifier){
                  pointerB = details.position;
                }

                /// ZOOM
                if(pointerA != null && pointerB != null){
                  double sensibility = ((cnScreenStatistics.currentVisibleDays) / (1500 / sqrt(cnScreenStatistics.currentVisibleDays)));
                  final maxDays = maxDate.toDate().difference(minDate.toDate()).inDays;
                  final currentPointerDistance = (pointerB!.dx - pointerA!.dx).abs();
                  final difference = (lastPointerDistance - currentPointerDistance) * sensibility;
                  lastPointerDistance = currentPointerDistance;

                  setState(() {
                    double newOffsetMaxX;
                    double newOffsetMinX;

                    newOffsetMaxX = (cnScreenStatistics.offsetMaxX - difference);
                    newOffsetMaxX = newOffsetMaxX >= 0? newOffsetMaxX : 0;
                    newOffsetMinX = (cnScreenStatistics.offsetMinX - difference * focalPointPercent);
                    newOffsetMinX = newOffsetMinX >= 0? newOffsetMinX : 0;

                    if(newOffsetMaxX + 5 < maxDays && maxDate.toDate().difference(minDate.toDate()).inDays + _totalPadding - newOffsetMaxX <= cnScreenStatistics.maxVisibleDays){
                      cnScreenStatistics.offsetMinX = newOffsetMinX;
                      cnScreenStatistics.offsetMaxX = newOffsetMaxX;
                    }
                  });
                }

                /// SCROLL
                else if(pointerA != null && pointerB == null && pointerAPreviousPos != null){
                  final totalRange = maxDate.toDate().difference(minDate.toDate()).inDays;
                  final maxValueOffsetMinX = totalRange - cnScreenStatistics.currentVisibleDays + _totalPadding;
                  // double sensibility = 1/ (currentVisibleDays / 280); /// maybe 300 or calculate with screen width
                  double sensibility = 1/ (cnScreenStatistics.currentVisibleDays / (constraints.maxWidth-_widthAxisTitles));
                  sensibility = sensibility < 0.1? 0.1 : sensibility > 500? 500 : sensibility;
                  final currentPointerDistance = (pointerAPreviousPos!.dx - pointerA!.dx) / sensibility;

                  double newOffsetMinX;

                  newOffsetMinX = cnScreenStatistics.offsetMinX + currentPointerDistance;
                  if(newOffsetMinX >= 0 && newOffsetMinX != cnScreenStatistics.offsetMinX && (newOffsetMinX <= maxValueOffsetMinX || newOffsetMinX <= cnScreenStatistics.offsetMinX)){
                    setState(() {
                      cnScreenStatistics.offsetMinX = newOffsetMinX;
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
                // }
                // else if(details.pointer == pointerBIdentifier){
                  pointerB = null;
                  pointerBIdentifier = null;
                // }
                Future.delayed(const Duration(milliseconds: 500), (){
                  if(pointerA == null && pointerB == null){
                    animationTime = 500;
                  }
                });
                // pointerA = null;
                // pointerAPreviousPos = null;
                // pointerAIdentifier = null;
                // pointerB = null;
                // pointerBIdentifier = null;
                // Future.delayed(const Duration(milliseconds: 500), (){
                //   if(pointerA == null && pointerB == null){
                //     animationTime = 500;
                //   }
                // });
              },
              child: Stack(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: cnScreenStatistics.width / (cnScreenStatistics.height * (cnScreenStatistics.orientation == Orientation.portrait? 0.6 : 0.7)),
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: LineChart(
                          duration: Duration(milliseconds: animationTime),
                          curve: Curves.easeInOut,
                          mainData()
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
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

    value += cnScreenStatistics.offsetMinX;

    if(cnScreenStatistics.currentVisibleDays < 200 && value % 1.0 > 0.1){
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
    if(cnScreenStatistics.currentVisibleDays < 20){
      doLabel = date.day % 5 == 0;
      format = 'd. MMM';
    } else if(cnScreenStatistics.currentVisibleDays < 40){
      doLabel = date.day % 10 == 0;
      format = 'd. MMM';
    } else if(cnScreenStatistics.currentVisibleDays < 80){
      doLabel = date.day % 15 == 0 || (date.day == 28 && date.month == 2);
      format = 'd. MMM';
    } else if(cnScreenStatistics.currentVisibleDays < 200){
      doLabel = date.day == 1;
      format = 'MMM yy';
    } else if(cnScreenStatistics.currentVisibleDays < 400){
      doLabel = date.day == 1 && date.month % 2 == 0;
      format = 'MMM yy';
    }else if (cnScreenStatistics.currentVisibleDays < 700){
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
    print("AXIS VALUE");
    print(value);
    if(value.toInt() % verticalStepSize == 0 && value == value.toInt()){
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
      clipData: const FlClipData.all(),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          // showOnTopOfTheChartBoxArea: true,
          fitInsideVertically: true,
          fitInsideHorizontally: true,
          getTooltipItems: (List<LineBarSpot> spots){
            return spots.asMap().entries.map((e) {
              int index = e.value.barIndex;
              if (index == 2 || (!cnScreenStatistics.showAvgWeightPerSetLine && index == 1)) {
                return null;
              }
              LineBarSpot spot = e.value;
              return LineTooltipItem(
                  textAlign: TextAlign.left,
                  getSpotData(spot),
                  TextStyle(
                      fontSize: 14,
                      color: spot.barIndex == 0? gradientColors[0] : gradientColors2[0]
                  )
              );
            }).toList();
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
            interval: cnScreenStatistics.currentVisibleDays < 200? 0.1 : 1,
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
      maxX: cnScreenStatistics.currentVisibleDays.toDouble(),
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          isCurved: false,
          // curveSmoothness: 0.1,
          spots: spotsMaxWeight,
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
        // if(cnScreenStatistics.showAvgWeightPerSetLine)
          LineChartBarData(
            isCurved: false,
            curveSmoothness: 0.1,
            spots: spotsAvgWeightPerSet,
            gradient: LinearGradient(
              colors: gradientColors2,
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(
              show: true,
            ),
          ),
        if(cnScreenStatistics.showSickDays)
          LineChartBarData(
            isCurved: false,
            curveSmoothness: 0.1,
            spots: sickDaysSpots,
            gradient: LinearGradient(
              colors: gradientColors3,
            ),
            barWidth: 1,
            isStrokeCapRound: true,
            // dotData: const FlDotData(
            //   show: true,
            // ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: gradientColors3
                    .map((color) => color.withOpacity(0.3))
                    .toList(),
              ),
            ),
          )
      ],
    );
  }

  String getSpotData(LineBarSpot spot){
    Map<DateTime, double> data;
    if(spot.barIndex == 0){
      data = maxWeights!;
    } else if(spot.barIndex == 1){
      data = avgWeights!;
    }
    else{
      return "Krank";
    }
    return "${DateFormat("d.MMM").format(data.keys.toList()[spot.spotIndex])} ${data.values.toList()[spot.spotIndex].toInt()} kg";
  }
}