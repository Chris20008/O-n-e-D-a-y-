// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../screen_statistics.dart';
//
// class IntervalSelector extends StatefulWidget {
//   const IntervalSelector({super.key});
//
//   @override
//   State<IntervalSelector> createState() => _IntervalSelectorState();
// }
//
// class _IntervalSelectorState extends State<IntervalSelector> {
//   late CnScreenStatistics cnScreenStatistics  = Provider.of<CnScreenStatistics>(context);
//
//   late final ScrollController _scrollController;
//   final double buttonWidth = 180;
//   late final width = MediaQuery.of(context).size.width;
//   late final leftRightBoxesWidth = (width-buttonWidth)/2;
//   bool scrollControllerIsInitialized = false;
//
//   @override
//   Widget build(BuildContext context) {
//     if(!scrollControllerIsInitialized){
//       late final newPos = buttonWidth * List.from(cnScreenStatistics.intervalSelectorMap.keys).indexOf(cnScreenStatistics.currentlySelectedIntervalAsText) - width/2 + buttonWidth/2 +leftRightBoxesWidth;
//       _scrollController = ScrollController(initialScrollOffset: newPos);
//       scrollControllerIsInitialized = true;
//     }
//
//     return SizedBox(
//       // margin: const EdgeInsets.symmetric(vertical: 20),
//       height: 30,
//       child: ListView.builder(
//         physics: const BouncingScrollPhysics(),
//         controller: _scrollController,
//         scrollDirection: Axis.horizontal,
//         // separatorBuilder: (BuildContext context, int index) {return SizedBox(width: 5,);},
//         itemCount: cnScreenStatistics.intervalSelectorMap.length,
//         itemBuilder: (BuildContext context, int index) {
//           final text = List.from(cnScreenStatistics.intervalSelectorMap.keys)[index];
//           Widget? child = SizedBox(
//             width: buttonWidth,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 3),
//               child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white,
//                     // shadowColor: Colors.transparent,
//                     backgroundColor: cnScreenStatistics.currentlySelectedIntervalAsText == text? Colors.amber[800] : Colors.transparent,
//                     // fixedSize: size,
//                     padding: const EdgeInsets.all(0),
//                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   ),
//                   onPressed: (){
//                     // setState(() {
//                     double newPos = buttonWidth * index - width/2 + buttonWidth/2 +leftRightBoxesWidth;
//                     _scrollController.animateTo(newPos, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
//                       if(cnScreenStatistics.currentlySelectedIntervalAsText != text){
//                         cnScreenStatistics.currentlySelectedIntervalAsText = text;
//                         // cnScreenStatistics.setCurrentInterval(text);
//                         cnScreenStatistics.reset();
//                         cnScreenStatistics.refresh();
//                         cnScreenStatistics.calculateCurrentData();
//                         cnScreenStatistics.refresh();
//                       }
//                     // });
//                   },
//                   child: Text(text)
//               ),
//             ),
//           );
//           if(index == 0){
//             return Row(
//               children: [
//                 SizedBox(width: leftRightBoxesWidth),
//                 child
//               ],
//             );
//           }
//           else if(index == cnScreenStatistics.intervalSelectorMap.length-1){
//             return Row(
//               children: [
//                 child,
//                 SizedBox(width: leftRightBoxesWidth)
//               ],
//             );
//           }
//           return child;
//         },
//       ),
//     );
//   }
// }