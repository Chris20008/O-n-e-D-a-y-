import 'package:fitness_app/screens/screen_statistics/screen_statistics.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Averages extends StatefulWidget {
  const Averages({super.key});

  @override
  State<Averages> createState() => _AveragesState();
}

class _AveragesState extends State<Averages> {
  late CnScreenStatistics cnScreenStatistics  = Provider.of<CnScreenStatistics>(context, listen: false);

  // final PageController _controller = PageController(viewportFraction: 0.33);
  late final ScrollController _scrollController;
  final double buttonWidth = 180;
  late final width = MediaQuery.of(context).size.width;
  late final leftRightBoxesWidth = (width-buttonWidth)/2;
  bool scrollControllerIsInitialized = false;

  // @override
  // void initState() {
  //   // Future.delayed(const Duration(milliseconds: 0), (){
  //   //   late final newPos = buttonWidth * List.from(cnScreenStatistics.intervalSelectorMap.keys).indexOf(cnScreenStatistics.currentlySelectedIntervalAsText) - width/2 + buttonWidth/2 +leftRightBoxesWidth;
  //   //   // _scrollController.animateTo(newPos, duration: const Duration(milliseconds: 50), curve: Curves.easeInOut);
  //   //   _scrollController.jumpTo(newPos);
  //   //   _scrollController = ScrollController(initialScrollOffset: newPos);
  //   // });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    if(!scrollControllerIsInitialized){
      late final newPos = buttonWidth * List.from(cnScreenStatistics.intervalSelectorMap.keys).indexOf(cnScreenStatistics.currentlySelectedIntervalAsText) - width/2 + buttonWidth/2 +leftRightBoxesWidth;
      _scrollController = ScrollController(initialScrollOffset: newPos);
      scrollControllerIsInitialized = true;
    }

    return SizedBox(
      // margin: const EdgeInsets.symmetric(vertical: 20),
      height: 30,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          // separatorBuilder: (BuildContext context, int index) {return SizedBox(width: 5,);},
          itemCount: cnScreenStatistics.intervalSelectorMap.length,
          itemBuilder: (BuildContext context, int index) {
            final text = List.from(cnScreenStatistics.intervalSelectorMap.keys)[index];
            Widget? child = SizedBox(
              width: buttonWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      // shadowColor: Colors.transparent,
                      backgroundColor: cnScreenStatistics.currentlySelectedIntervalAsText == text? Colors.amber[800] : Colors.transparent,
                      // fixedSize: size,
                      padding: const EdgeInsets.all(0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: (){
                      cnScreenStatistics.currentlySelectedIntervalAsText = text;
                      setState(() {
                        double newPos = buttonWidth * index - width/2 + buttonWidth/2 +leftRightBoxesWidth;
                        _scrollController.animateTo(newPos, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
                      });
                    },
                    child: Text(text)
                ),
              ),
            );
            if(index == 0){
              return Row(
                children: [
                  SizedBox(width: leftRightBoxesWidth),
                  child
                ],
              );
            }
            else if(index == cnScreenStatistics.intervalSelectorMap.length-1){
              return Row(
                children: [
                  child,
                  SizedBox(width: leftRightBoxesWidth)
                ],
              );
            }
            return child;
          },
      ),
    );

    // return SizedBox(
    //   height: 100, // Card height
    //   child: PageView.builder(
    //     pageSnapping: false,
    //     physics: const PageOverscrollPhysics(velocityPerOverscroll: 500),
    //     itemCount: 50,
    //     controller: _controller,
    //     itemBuilder: (context, index) {
    //       return ListenableBuilder(
    //         listenable: _controller,
    //         builder: (context, child) {
    //           double factor = 1;
    //           if (_controller.position.hasContentDimensions) {
    //             factor = 1 - (_controller.page! - index).abs();
    //           }
    //
    //           return Center(
    //             child: SizedBox(
    //               height: 70 + (factor * 20),
    //               child: Card(
    //                 elevation: 4,
    //                 child: Center(child: Text('Card $index')),
    //               ),
    //             ),
    //           );
    //         },
    //       );
    //     },
    //   ),
    // );

    // return Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 30),
    //   child: SafeArea(
    //     child: Container(
    //       padding: const EdgeInsets.all(20),
    //       height: 300,
    //       decoration: BoxDecoration(
    //           color: Colors.black26,
    //           borderRadius: BorderRadius.circular(15)
    //       ),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           const Text("Averages", textScaler: TextScaler.linear(1.5),),
    //           Expanded(
    //             child: RotatedBox(
    //               quarterTurns: 1,
    //               child: BarChart(
    //                 BarChartData(
    //                   barTouchData: barTouchData,
    //                   titlesData: titlesData,
    //                   borderData: borderData,
    //                   barGroups: barGroups,
    //                   gridData: const FlGridData(show: false),
    //                   alignment: BarChartAlignment.spaceAround,
    //                   maxY: 20,
    //                 ),
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }

  BarTouchData get barTouchData => BarTouchData(
    enabled: false,
    touchTooltipData: BarTouchTooltipData(
      rotateAngle: 270,
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
    const style = TextStyle(
      color: Colors.white, // AppColors.contentColorBlue.darken(20),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    // String text = cnScreenStatistics.workoutsSorted[2024][value]["name"];
    String text = "";
    switch (value.toInt()) {
      case 0:
        text = cnScreenStatistics.workoutsSorted[2024]['3/18/2024']["name"];
        break;
      case 1:
        text = cnScreenStatistics.workoutsSorted[2024]['3/25/2024']["name"];
        break;
      case 2:
        text = cnScreenStatistics.workoutsSorted[2024]['4/1/2024']["name"];
        break;
      case 3:
        text = cnScreenStatistics.workoutsSorted[2024]['4/8/2024']["name"];
        break;
      default:
        text = '';
        break;
    }
    return RotatedBox(
      quarterTurns: -1,
      child: SideTitleWidget(
        // angle: -1.55,
        // angle: 15/360,
        axisSide: meta.axisSide,
        space: 0,
        child: Text(text, style: style),
      ),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 50,
        getTitlesWidget: getTitles,
      ),
    ),
    leftTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: const AxisTitles(
      sideTitles: SideTitles(
        showTitles: false,
      ),
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
          borderRadius: BorderRadius.circular(4),
          width: 15,
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
          borderRadius: BorderRadius.circular(4),
          width: 15,
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
          borderRadius: BorderRadius.circular(4),
          width: 15,
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
          borderRadius: BorderRadius.circular(4),
          width: 15,
          toY: cnScreenStatistics.workoutsSorted[2024]['4/8/2024']['counter']*1.0,
          gradient: _barsGradient,
        )
      ],
      showingTooltipIndicators: [0],
    )
  ];
}


// class PageOverscrollPhysics extends ScrollPhysics {
//   ///The logical pixels per second until a page is overscrolled.
//   ///A satisfying value can be determined by experimentation.
//   ///
//   ///Example:
//   ///If the user scroll velocity is 3500 pixel/second and [velocityPerOverscroll]=
//   ///1000, then 3.5 pages will be overscrolled/skipped.
//   final double velocityPerOverscroll;
//
//   const PageOverscrollPhysics({
//     ScrollPhysics? parent,
//     this.velocityPerOverscroll = 1000,
//   }) : super(parent: parent);
//
//   @override
//   PageOverscrollPhysics applyTo(ScrollPhysics? ancestor) {
//     return PageOverscrollPhysics(
//       parent: buildParent(ancestor)!,
//     );
//   }
//
//   double _getTargetPixels(ScrollMetrics position, double velocity) {
//     double page = position.pixels / position.viewportDimension;
//     page += velocity / velocityPerOverscroll;
//     double pixels = page.roundToDouble() * position.viewportDimension;
//     return pixels;
//   }
//
//   @override
//   Simulation? createBallisticSimulation(
//       ScrollMetrics position, double velocity) {
//     // If we're out of range and not headed back in range, defer to the parent
//     // ballistics, which should put us back in range at a page boundary.
//     if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
//         (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
//       return super.createBallisticSimulation(position, velocity);
//     }
//     final double target = _getTargetPixels(position, velocity);
//     if (target != position.pixels) {
//       return ScrollSpringSimulation(spring, position.pixels, target, velocity,
//           tolerance: tolerance);
//     }
//     return null;
//   }
//
//   @override
//   bool get allowImplicitScrolling => false;
// }