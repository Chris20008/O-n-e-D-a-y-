import 'package:fitness_app/screens/screen_statistics/screen_statistics.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GeneralOverview extends StatefulWidget {
  const GeneralOverview({super.key});

  @override
  State<GeneralOverview> createState() => _GeneralOverviewState();
}

class _GeneralOverviewState extends State<GeneralOverview> {
  late CnScreenStatistics cnScreenStatistics  = Provider.of<CnScreenStatistics>(context, listen: false);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SafeArea(
        child: BarChart(
          BarChartData(
            barTouchData: barTouchData,
            titlesData: titlesData,
            borderData: borderData,
            barGroups: barGroups,
            gridData: const FlGridData(show: false),
            alignment: BarChartAlignment.spaceAround,
            maxY: 20,
          ),
        ),
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
    enabled: false,
    touchTooltipData: BarTouchTooltipData(
      getTooltipColor: (group) => Colors.transparent,
      tooltipPadding: EdgeInsets.zero,
      tooltipMargin: 8,
      getTooltipItem: (
          BarChartGroupData group,
          int groupIndex,
          BarChartRodData rod,
          int rodIndex,
          ) {
        return BarTooltipItem(
          rod.toY.round().toString(),
          const TextStyle(
            color: Colors.white,// AppColors.contentColorCyan,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    ),
  );

  Widget getTitles(double value, TitleMeta meta) {
    final style = const TextStyle(
      color: Colors.white, // AppColors.contentColorBlue.darken(20),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text = cnScreenStatistics.workoutsSorted[2024][value]["name"];
    // switch (value.toInt()) {
    //   case 0:
    //     text = cnScreenStatistics.workoutsSorted[2024]['3/18/2024']["name"];
    //     break;
    //   case 1:
    //     text = cnScreenStatistics.workoutsSorted[2024]['3/25/2024']["name"];
    //     break;
    //   case 2:
    //     text = cnScreenStatistics.workoutsSorted[2024]['4/1/2024']["name"];
    //     break;
    //   case 3:
    //     text = cnScreenStatistics.workoutsSorted[2024]['4/8/2024']["name"];
    //     break;
    //   default:
    //     text = '';
    //     break;
    // }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        getTitlesWidget: getTitles,
      ),
    ),
    leftTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    rightTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
  );

  FlBorderData get borderData => FlBorderData(
    show: false,
  );

  LinearGradient get _barsGradient => LinearGradient(
    colors: [
      Colors.amber[800]!,
      Colors.amber[800]!
      // Colors.red
      // AppColors.contentColorBlue.darken(20),
      // AppColors.contentColorCyan,
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  List<BarChartGroupData> get barGroups => [
    BarChartGroupData(
      x: 1,
      barRods: [
        BarChartRodData(
          toY: cnScreenStatistics.workoutsSorted[2024]['3/18/2024']['counter']*1.0,
          gradient: _barsGradient,
        )
      ],
      showingTooltipIndicators: [0],
    ),
    BarChartGroupData(
      x: 1,
      barRods: [
        BarChartRodData(
          toY: cnScreenStatistics.workoutsSorted[2024]['3/25/2024']['counter']*1.0,
          gradient: _barsGradient,
        )
      ],
      showingTooltipIndicators: [0],
    ),
    BarChartGroupData(
      x: 2,
      barRods: [
        BarChartRodData(
          toY: cnScreenStatistics.workoutsSorted[2024]['4/1/2024']['counter']*1.0,
          gradient: _barsGradient,
        )
      ],
      showingTooltipIndicators: [0],
    ),
    BarChartGroupData(
      x: 3,
      barRods: [
        BarChartRodData(
          toY: cnScreenStatistics.workoutsSorted[2024]['4/8/2024']['counter']*1.0,
          gradient: _barsGradient,
        )
      ],
      showingTooltipIndicators: [0],
    )
  ];
}
