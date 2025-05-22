import 'dart:math';

import 'package:fitness_app/main.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/widgets/charts/exercise_line_chart/statistics_overlay.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:fitness_app/util/objectbox/ob_sick_days.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/widgets/charts/sz_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../util/constants.dart';
import '../../../../../../widgets/scroll_listener.dart';
import '../../../screen_statistics.dart';
import '../sz_wrapper.dart';

class ExerciseLineChart extends StatefulWidget {
  const ExerciseLineChart({super.key});

  @override
  State<ExerciseLineChart> createState() => _ExerciseLineChartState();
}

class _ExerciseLineChartState extends State<ExerciseLineChart> {
  late CnScreenStatistics cnScreenStatistics;
  final double widthAxisTitles = 50;

  late SZController szController = cnScreenStatistics.szController?? SZController(
      widthAxisTitles: widthAxisTitles,
      totalScreenWidth: MediaQuery.of(context).size.width,
      minDate: cnScreenStatistics.minDate.toDate(),
      maxDate: cnScreenStatistics.maxDate.toDate()
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
    cnScreenStatistics.szController = szController;
  }

  double minWeight = 0;
  double maxWeight = 0;

  double minTotalWeight = 0;
  double maxTotalWeight = 0;

  double minY = 0;
  double maxY = 0;

  double minPercent = 1;
  double maxPercent = 1;

  int verticalStepSize = 0;

  late List<ObSickDays> allSickDays;

  Map<DateTime, double>? maxWeights;
  Map<DateTime, double>? avgWeights;
  Map<DateTime, double>? oneRepMaxPerDate;

  List<FlSpot> spotsMaxWeight = [];
  List<FlSpot> spotsAvgWeightPerSet = [];
  List<FlSpot> spotsOneRepMax = [];
  List<FlSpot> sickDaysSpots = [];

  @override
  Widget build(BuildContext context) {
    pr("Refresh Line Chart");
    cnScreenStatistics = context.watch<CnScreenStatistics>();
    cnScreenStatistics.szController = cnScreenStatistics.szController?? szController;

    final t = objectbox.exerciseBox.query((ObExercise_.name.equals(cnScreenStatistics.selectedExerciseName??"").and(ObExercise_.category.equals(1)))).build().findFirst();
    if(t == null && cnScreenStatistics.selectedExerciseName != AppLocalizations.of(context)!.statisticsWeight){
      if(cnScreenStatistics.selectedExerciseName != null){
        return SizedBox(
          height: 200,
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.statisticsCurrentlyNotSupported,
              textAlign: TextAlign.center,
            ),
          ),
        );
      } else{
        return SizedBox(
          height: 200,
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.statisticsNoExercise,
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }

    /// init
    maxWeights = cnScreenStatistics.getMaxWeightsPerDate(context);
    avgWeights = cnScreenStatistics.getAvgMovedWeightPerSet();
    oneRepMaxPerDate = cnScreenStatistics.getOneRepMaxPerDate();
    allSickDays = cnScreenStatistics.allSickDays;
    minWeight = 10000;
    maxWeight = 0;
    if(maxWeights != null && maxWeights!.isNotEmpty){
      maxWeights?.forEach((key, value) {
        minWeight = minWeight < value? minWeight : value;
        maxWeight = maxWeight < value? value : maxWeight;
      });
    } else{
      minWeight = 0;
      maxWeight = 100;
    }

    if(cnScreenStatistics.showOneRepMax){
      oneRepMaxPerDate?.forEach((key, value) {
        maxWeight = maxWeight < value? value : maxWeight;
      });
    }
    minPercent = minWeight / maxWeight;
    maxPercent = 1;
    minTotalWeight = 10000;
    maxTotalWeight = 0;
    avgWeights?.forEach((key, value) {
      minTotalWeight = minTotalWeight < value? minTotalWeight : value;
      maxTotalWeight = maxTotalWeight < value? value : maxTotalWeight;
    });

    spotsMaxWeight.clear();
    /// Set Spots Max Weight
    maxWeights?.forEach((date, weight) {
      final xCoordinate = date.toDate().differenceSafe(cnScreenStatistics.minDate.toDate()).inDays.toDouble();
      spotsMaxWeight.add(FlSpot(xCoordinate, weight.toDouble()));
    });

    /// Set Spots Total Moved Weight
    spotsAvgWeightPerSet.clear();
    avgWeights?.forEach((date, totalWeight) {
      double percent = (totalWeight*1.1) / maxTotalWeight;
      final xCoordinate = date.toDate().differenceSafe(cnScreenStatistics.minDate.toDate()).inDays.toDouble();
      if(percent.isNaN){
        percent = totalWeight / (maxTotalWeight.isNaN? 1 : maxTotalWeight);
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
      final yCoordinate = !cnScreenStatistics.showAvgWeightPerSetLine? minY-5 : maxWeight * percent;
      spotsAvgWeightPerSet.add(FlSpot(xCoordinate, yCoordinate));
    });

    calcVerticalStepSize();

    if(!cnScreenStatistics.showAvgWeightPerSetLine){
      minPercent = minWeight / maxWeight;
      maxPercent = 1;
    }

    /// Set Spots One Rep Max
    spotsOneRepMax.clear();
    oneRepMaxPerDate?.forEach((date, weight) {
      final xCoordinate = date.toDate().differenceSafe(cnScreenStatistics.minDate.toDate().toDate()).inDays.toDouble();
      final yCoordinate = !cnScreenStatistics.showOneRepMax? minY-5 : weight.toDouble();
      spotsOneRepMax.add(FlSpot(xCoordinate, yCoordinate));
    });
    
    /// Set Spots Sick Days
    for (ObSickDays sickDay in allSickDays){
      double xCoordinate = sickDay.startDate.toDate().differenceSafe(cnScreenStatistics.minDate.toDate().toDate()).inDays.toDouble();
      double percent = 5;
      double factor = maxWeight > 0? maxWeight : 4;
      sickDaysSpots.add(FlSpot(xCoordinate, -5));
      sickDaysSpots.add(FlSpot(xCoordinate, factor * percent));
      xCoordinate = sickDay.endDate.toDate().differenceSafe(cnScreenStatistics.minDate.toDate().toDate()).inDays.toDouble();
      sickDaysSpots.add(FlSpot(xCoordinate, factor * percent));
      sickDaysSpots.add(FlSpot(xCoordinate, -5));
    }

    if(!cnScreenStatistics.showAvgWeightPerSetLine){
      spotsAvgWeightPerSet = List.generate(spotsAvgWeightPerSet.length, (index) => FlSpot(spotsAvgWeightPerSet[index].x, minY-5));
    }

    if(!cnScreenStatistics.showOneRepMax){
      spotsOneRepMax = List.generate(spotsOneRepMax.length, (index) => FlSpot(spotsOneRepMax[index].x, minY-5));
    }

    if(!cnScreenStatistics.showSickDays){
      sickDaysSpots = List.generate(sickDaysSpots.length, (index) => FlSpot(sickDaysSpots[index].x, -5));
    }

    szController.spotManager.addLine(
      key: "maxWeight",
      value: spotsMaxWeight
    );
    szController.spotManager.addLine(
        key: "oneRepMax",
        value: spotsOneRepMax
    );
    szController.spotManager.addLine(
        key: "spotsAvgWeightPerSet",
        value: spotsAvgWeightPerSet
    );
    szController.spotManager.addLine(
        key: "sickDaysSpots",
        value: sickDaysSpots
    );

    if(cnScreenStatistics.firstAnimationGraph){
      szController.spotManager.doAnimateVertical(minY);
      cnScreenStatistics.firstAnimationGraph = false;
    }

    calcVerticalStepSize();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ScrollListener(
          minValue: cnScreenStatistics.heightExerciseLineChartMin,
          maxValue: cnScreenStatistics.heightExerciseLineChartMax,
          controller: cnScreenStatistics.scrollController.controller,
          withMinValueStop: true,
          curve: Curves.easeOut,
          builder: (context, value, percent) {
            return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: sqrt(percent) * 30,
                    child: AnimatedOpacity(
                      opacity: pow(percent, 3).toDouble(),
                      duration: const Duration(milliseconds: 0),
                      child: Text(AppLocalizations.of(context)!.statisticsMaxWeight, textScaler: const TextScaler.linear(1.2), style: TextStyle(color: cnScreenStatistics.gradientColors[0]),),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  SzWrapper(
                    szController: szController,
                    childBuilder: (context){
                      return AspectRatio(
                        aspectRatio: cnScreenStatistics.width / value,
                        child: Stack(
                          children: [
                            AnimatedOpacity(
                              opacity: pow(percent, 3).toDouble(),
                              duration: const Duration(milliseconds: 0),
                              child: const StatisticsOverlay()
                            ),
                            LineChart(
                                duration: Duration(milliseconds: szController.stateManager.animationTime),
                                curve: Curves.easeInOut,
                                mainData()
                            ),
                          ],
                        ),
                      );
                    },
                  )
                ]
            );
        }
      ),
    );
  }

  void calcVerticalStepSize(){
    minY = maxWeight * minPercent - 10 < 0? 0 : maxWeight * minPercent - 5;
    minY = minY.isNaN? -4 : minY;
    maxY = maxWeight*maxPercent + 5;
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
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    Widget text;

    value += szController.stateManager.current.scrollPosition;

    if(szController.stateManager.current.zoomArea < 50 && value % 1.0 >= 0.1){
      return SideTitleWidget(
          axisSide: meta.axisSide,
          child: const Text('', style: style)
      );
    }

    if(szController.stateManager.current.zoomArea < 100 && value % 1.0 >= 0.25){
      return SideTitleWidget(
          axisSide: meta.axisSide,
          child: const Text('', style: style)
      );
    }

    if(szController.stateManager.current.zoomArea < 200 && value % 1.0 >= 0.5){
      return SideTitleWidget(
          axisSide: meta.axisSide,
          child: const Text('', style: style)
      );
    }

    if(value < szController.leftPaddingGraph || value > szController.totalRange+szController.leftPaddingGraph){
      text = const Text('', style: style);
    }
    else{
      DateTime valuesDate = cnScreenStatistics.minDate.toDate().add(Duration(days: value.toInt()));
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
    date = date.subtract(Duration(days: szController.leftPaddingGraph.toInt()));
    if(szController.stateManager.current.zoomArea < 20){
      doLabel = date.day % 5 == 0;
      format = 'd. MMM';
    } else if(szController.stateManager.current.zoomArea < 40){
      doLabel = date.day % 10 == 0 || (date.day == 1 && date.month == 3);
      format = 'd. MMM';
    } else if(szController.stateManager.current.zoomArea < 80){
      doLabel = date.day % 15 == 0 || (date.day == 28 && date.month == 2);
      format = 'd. MMM';
    } else if(szController.stateManager.current.zoomArea < 200){
      doLabel = date.day == 15;
      format = 'MMM yy';
    } else if(szController.stateManager.current.zoomArea < 450){
      doLabel = date.day == 15 && date.month % 2 == 0;
      format = 'MMM yy';
    }else if (szController.stateManager.current.zoomArea < 700){
      doLabel = date.day == 15 && date.month % 3 == 0;
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
        color: cnScreenStatistics.gradientColors[0]
    );
    String text;
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
        color: cnScreenStatistics.gradientColors2[0]
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
              maxContentWidth: 200,
              showOnTopOfTheChartBoxArea: true,
              fitInsideVertically: true,
              fitInsideHorizontally: true,
              getTooltipItems: (List<LineBarSpot> spots){
                return spots.asMap().entries.map((e) {
                  int index = e.value.barIndex;
                  /// return null when bar index is from sickDays
                  /// or one of the other lines is disabled
                  if (index == 3
                      || (!cnScreenStatistics.showAvgWeightPerSetLine && index == 1)
                      || (!cnScreenStatistics.showOneRepMax && index == 2)
                  ) {
                    return null;
                  }
                  LineBarSpot spot = e.value;
                  late Color color;
                  switch(spot.barIndex){
                    case 0:
                      color = cnScreenStatistics.gradientColors[0];
                    case 1:
                      color = cnScreenStatistics.gradientColors2[0];
                    case 2:
                      color = cnScreenStatistics.gradientColors3[0];
                    default:
                      color = Colors.white;
                  }
                  return LineTooltipItem(
                      textAlign: TextAlign.left,
                      getSpotData(spot),
                      TextStyle(
                          fontSize: 14,
                          color: color
                      )
                  );
                }).toList();
              }
          )
      ),
      gridData: const FlGridData(show: false,),
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
            interval: szController.stateManager.current.zoomArea < 50
                ? 0.1
                : szController.stateManager.current.zoomArea < 100
                ? 0.25
                : szController.stateManager.current.zoomArea < 200
                ? 0.5
                : 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: verticalStepSize.toDouble(),
            getTitlesWidget: leftTitleWidgets,
            reservedSize: widthAxisTitles,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff5e5e5e)),
      ),
      minX: 0,
      maxX: szController.stateManager.current.zoomArea.toDouble(),
      minY: minY,
      maxY: maxY,
      lineBarsData: [

        /// Max weight
        LineChartBarData(
          isCurved: true,
          curveSmoothness: 0.1,
          spots: szController.spotManager.getLine("maxWeight"),
          gradient: LinearGradient(
            colors: cnScreenStatistics.gradientColors,
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: cnScreenStatistics.gradientColors
                  .map((color) => color.withValues(alpha: 0.3))
                  .toList(),
            ),
          ),
        ),

        /// Average Weight per set
        // if(cnScreenStatistics.showAvgWeightPerSetLine)
        LineChartBarData(
          isCurved: true,
          curveSmoothness: 0.1,
          spots: szController.spotManager.getLine("spotsAvgWeightPerSet"),
          gradient: LinearGradient(
            colors: cnScreenStatistics.gradientColors2,
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
        ),

        /// One Rep Max
        LineChartBarData(
          isCurved: true,
          curveSmoothness: 0.1,
          spots: szController.spotManager.getLine("oneRepMax"),
          gradient: LinearGradient(
            colors: cnScreenStatistics.gradientColors3,
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
        ),

        /// Sick Days
        if(cnScreenStatistics.showSickDays)
          LineChartBarData(
            isCurved: false,
            curveSmoothness: 0.1,
            spots: szController.spotManager.getLine("sickDaysSpots"),
            gradient: LinearGradient(
              colors: cnScreenStatistics.gradientColors4,
            ),
            barWidth: 1,
            isStrokeCapRound: true,
            // dotData: const FlDotData(
            //   show: true,
            // ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: cnScreenStatistics.gradientColors4
                    .map((color) => color.withValues(alpha: 0.3))
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
      data = szController.spotManager.getLineFormatted("maxWeight");
    } else if(spot.barIndex == 1){
      data = szController.spotManager.getLineFormatted("spotsAvgWeightPerSet");
    } else if(spot.barIndex == 2){
      data = szController.spotManager.getLineFormatted("oneRepMax");
    }
    else{
      return AppLocalizations.of(context)!.statisticsSick;
    }
    if(szController.spotManager.spotDetailLevel == SpotDetailLevel.weekly){
      return "${data.keys.toList()[spot.spotIndex].formatAsFirstLastDayOfWeek()}  ${formatNumber(data.values.toList()[spot.spotIndex])} kg";
    }
    // return "Test";
    final formattedDate = szController.spotManager.spotDetailLevel == SpotDetailLevel.monthly? DateFormat("MMM yy") : DateFormat("d.MMM");
    return "${formattedDate.format(data.keys.toList()[spot.spotIndex])}  ${formatNumber(data.values.toList()[spot.spotIndex])} kg";
  }
}

String formatNumber(double value) {
  return value % 1 == 0
      ? value.toInt().toString() // Ganze Zahl ohne Nachkommastellen
      : value.toStringAsFixed(value * 10 % 1 == 0 ? 1 : 2); // Eine oder zwei Nachkommastellen
}