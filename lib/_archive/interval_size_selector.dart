// import 'package:fitness_app/util/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../screen_statistics.dart';
//
// class IntervalSizeSelector extends StatefulWidget {
//   const IntervalSizeSelector({super.key});
//
//   @override
//   State<IntervalSizeSelector> createState() => _IntervalSizeSelectorState();
// }
//
// class _IntervalSizeSelectorState extends State<IntervalSizeSelector> {
//   late CnScreenStatistics cnScreenStatistics  = Provider.of<CnScreenStatistics>(context);
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 30,
//       child: Row(
//         children: intervalButtons,
//       ),
//     );
//   }
//
//   List<Widget> get intervalButtons => [
//     for(TimeInterval ti in TimeInterval.values)
//       Expanded(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 5),
//           child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 foregroundColor: Colors.white,
//                 // shadowColor: Colors.transparent,
//                 backgroundColor: cnScreenStatistics.selectedIntervalSize == ti? Colors.amber[800] : Colors.transparent,
//                 // fixedSize: size,
//                 padding: const EdgeInsets.all(0),
//                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//               ),
//               onPressed: (){
//                 if(cnScreenStatistics.selectedIntervalSize != ti){
//                   cnScreenStatistics.reset();
//                   cnScreenStatistics.refresh();
//                   cnScreenStatistics.selectedIntervalSize = ti;
//                   cnScreenStatistics.refreshIntervalSelectorMap();
//                   cnScreenStatistics.calculateCurrentData();
//                   cnScreenStatistics.refresh();
//                 }
//               },
//               child: Text(ti.value)
//           ),
//         ),
//       ),
//   ];
// }
