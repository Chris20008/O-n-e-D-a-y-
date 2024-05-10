// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../screens/main_screens/screen_statistics/screen_statistics.dart';
//
// class GeneralOverviewBarChart extends StatefulWidget {
//   const GeneralOverviewBarChart({super.key});
//
//   @override
//   State<GeneralOverviewBarChart> createState() => _GeneralOverviewBarChartState();
// }
//
// class _GeneralOverviewBarChartState extends State<GeneralOverviewBarChart> {
//   late CnScreenStatistics cnScreenStatistics  = Provider.of<CnScreenStatistics>(context, listen: false);
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 30),
//       child: SafeArea(
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           height: 200,
//           decoration: BoxDecoration(
//             color: Colors.black26,
//             borderRadius: BorderRadius.circular(15)
//           ),
//           child: BarChart(
//             BarChartData(
//               barTouchData: barTouchData,
//               titlesData: titlesData,
//               borderData: borderData,
//               barGroups: barGroups,
//               gridData: const FlGridData(show: false),
//               alignment: BarChartAlignment.spaceAround,
//               maxY: 20,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   BarTouchData get barTouchData => BarTouchData(
//     enabled: false,
//     touchTooltipData: BarTouchTooltipData(
//       getTooltipColor: (group) => Colors.transparent,
//       tooltipPadding: EdgeInsets.zero,
//       tooltipMargin: 8,
//       getTooltipItem: (
//           BarChartGroupData group,
//           int groupIndex,
//           BarChartRodData rod,
//           int rodIndex,
//           ) {
//         return BarTooltipItem(
//           rod.toY.round().toString(),
//           const TextStyle(
//             color: Colors.white,// AppColors.contentColorCyan,
//             fontWeight: FontWeight.bold,
//           ),
//         );
//       },
//     ),
//   );
//
//   Widget getTitles(double value, TitleMeta meta) {
//     final style = const TextStyle(
//       color: Colors.white, // AppColors.contentColorBlue.darken(20),
//       fontWeight: FontWeight.bold,
//       fontSize: 14,
//     );
//     // String text = cnScreenStatistics.workoutsSorted[2024][value]["name"];
//     String text = "";
//     switch (value.toInt()) {
//       case 0:
//         text = cnScreenStatistics.workoutsSorted[2024]['3/18/2024']["name"];
//         break;
//       case 1:
//         text = cnScreenStatistics.workoutsSorted[2024]['3/25/2024']["name"];
//         break;
//       case 2:
//         text = cnScreenStatistics.workoutsSorted[2024]['4/1/2024']["name"];
//         break;
//       case 3:
//         text = cnScreenStatistics.workoutsSorted[2024]['4/8/2024']["name"];
//         break;
//       default:
//         text = '';
//         break;
//     }
//     return SideTitleWidget(
//       axisSide: meta.axisSide,
//       space: 4,
//       child: Text(text, style: style),
//     );
//   }
//
//   FlTitlesData get titlesData => FlTitlesData(
//     show: true,
//     bottomTitles: AxisTitles(
//       sideTitles: SideTitles(
//         showTitles: true,
//         reservedSize: 30,
//         getTitlesWidget: getTitles,
//       ),
//     ),
//     leftTitles: const AxisTitles(
//       sideTitles: SideTitles(showTitles: false),
//     ),
//     topTitles: const AxisTitles(
//       sideTitles: SideTitles(showTitles: false),
//     ),
//     rightTitles: const AxisTitles(
//       sideTitles: SideTitles(showTitles: false),
//     ),
//   );
//
//   FlBorderData get borderData => FlBorderData(
//     show: false,
//   );
//
//   LinearGradient get _barsGradient => LinearGradient(
//     colors: [
//       Colors.amber[800]!,
//       Colors.amber[800]!
//       // Colors.red
//       // AppColors.contentColorBlue.darken(20),
//       // AppColors.contentColorCyan,
//     ],
//     begin: Alignment.bottomCenter,
//     end: Alignment.topCenter,
//   );
//
//   List<BarChartGroupData> get barGroups => [
//     BarChartGroupData(
//       x: 1,
//       barRods: [
//         BarChartRodData(
//           borderRadius: BorderRadius.circular(4),
//           width: 15,
//           toY: cnScreenStatistics.workoutsSorted[2024]['3/18/2024']['counter']*1.0,
//           gradient: _barsGradient,
//         )
//       ],
//       showingTooltipIndicators: [0],
//     ),
//     BarChartGroupData(
//       x: 1,
//       barRods: [
//         BarChartRodData(
//           borderRadius: BorderRadius.circular(4),
//           width: 15,
//           toY: cnScreenStatistics.workoutsSorted[2024]['3/25/2024']['counter']*1.0,
//           gradient: _barsGradient,
//         )
//       ],
//       showingTooltipIndicators: [0],
//     ),
//     BarChartGroupData(
//       x: 2,
//       barRods: [
//         BarChartRodData(
//           borderRadius: BorderRadius.circular(4),
//           width: 15,
//           toY: cnScreenStatistics.workoutsSorted[2024]['4/1/2024']['counter']*1.0,
//           gradient: _barsGradient,
//         )
//       ],
//       showingTooltipIndicators: [0],
//     ),
//     BarChartGroupData(
//       x: 3,
//       barRods: [
//         BarChartRodData(
//           borderRadius: BorderRadius.circular(4),
//           width: 15,
//           toY: cnScreenStatistics.workoutsSorted[2024]['4/8/2024']['counter']*1.0,
//           gradient: _barsGradient,
//         )
//       ],
//       showingTooltipIndicators: [0],
//     )
//   ];
// }
