// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import '../../../../../../../util/constants.dart';
// import '../bottom_spacer.dart';
// import 'dart:io';
// import 'dart:ui';
// import 'package:fitness_app/screens/other_screens/screen_running_workout/stopwatch.dart';
// import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/running_workout_content/widgets/bottom_spacer.dart';
// import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/running_workout_content/widgets/list_view_item/list_view_item.dart';
// import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/running_workout_content/widgets/rest_in_seconds_selector.dart';
// import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/running_workout_content/widgets/seat_level_selector.dart';
// import 'package:fitness_app/screens/other_screens/screen_running_workout/widgets/running_workout_content/widgets/set_header_row.dart';
// import 'package:fitness_app/widgets/spotify_bar.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:provider/provider.dart';
// import 'package:pull_down_button/pull_down_button.dart';
//
// class ListViewItem extends StatelessWidget {
//   const ListViewItem({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     Widget? child;
//     String groupedExerciseKey = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].key;
//     dynamic mapValue = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value;
//     dynamic item = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value;
//
//     if(mapValue.toString().contains("Separator")){
//       dynamic previousItem = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise-1].value;
//       late Exercise ex;
//       if(previousItem is NamedSet){
//         ex = previousItem.ex;
//       }
//       else{
//         previousItem = previousItem as GroupedSet;
//         String linkName = groupedExerciseKey.split("_").first;
//         ex = (cnRunningWorkout.groupedExercises[linkName] as GroupedExercise).getExercise(cnRunningWorkout.selectedIndexes[linkName]!)!;
//       }
//
//       Exercise? templateEx = cnRunningWorkout.workoutTemplateModifiable.exercises.where((e) => e.name == ex.name).firstOrNull;
//
//       child = GestureDetector(
//         /// Empty long press to prevent dragging
//         onLongPress: (){},
//         child: Column(
//           children: [
//             const SizedBox(height: 10,),
//             getRowButton(
//                 context: context,
//                 minusWidth: 10,
//                 height: 35,
//                 onPressed: (){
//                   cnRunningWorkout.addSet(ex: ex, lastEx: templateEx!);
//                 }
//             ),
//             if(indexExercise < cnRunningWorkout.groupedExercises.length-1)
//               mySeparator(),
//           ],
//         ),
//       );
//     }
//
//     else if(item is Exercise || item is GroupedExercise){
//
//       Exercise? newEx = item is Exercise ? item : (mapValue as GroupedExercise).getExercise(cnRunningWorkout.selectedIndexes[groupedExerciseKey]!);
//
//       if(newEx == null){
//         return const SizedBox();
//       }
//
//       child = GestureDetector(
//         /// Empty long press to prevent dragging
//         onLongPress: (){},
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (item is !Exercise)
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: OverflowSafeText(
//                   groupedExerciseKey,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                       fontSize: 13,
//                       color: Colors.white70
//                   ),
//                   minFontSize: 12,
//                   maxLines: 1,
//                 ),
//               ),
//             Row(
//               children: [
//                 item is Exercise
//                 /// Single Exercise
//                     ? Expanded(
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                         maxWidth: MediaQuery.of(context).size.width-80
//                     ),
//                     child: OverflowSafeText(
//                       newEx.name,
//                       maxLines: 1,
//                       style: const TextStyle(color: Colors.white, fontSize: 20),
//                     ),
//                   ),
//                 )
//                 /// Exercise Selector
//                     : PullDownButton(
//                   onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
//                   buttonAnchor: PullDownMenuAnchor.start,
//                   routeTheme: const PullDownMenuRouteTheme(backgroundColor: CupertinoColors.secondaryLabel),
//                   itemBuilder: (context) {
//                     final children = item.exercises.map<PullDownMenuItem>((Exercise value) {
//                       return PullDownMenuItem.selectable(
//                         title: value.name,
//                         selected: value.name == (mapValue as GroupedExercise).getExercise(cnRunningWorkout.selectedIndexes[groupedExerciseKey]!)?.name,
//                         onTap: () {
//                           FocusManager.instance.primaryFocus?.unfocus();
//                           HapticFeedback.selectionClick();
//                           Future.delayed(const Duration(milliseconds: 200), (){
//                             setState(() {
//                               final exercises = mapValue.exercises;
//                               final t = exercises.indexWhere((ex) => ex.name == value.name);
//
//                               cnRunningWorkout.selectedIndexes[groupedExerciseKey] = t;
//                             });
//                             cnRunningWorkout.cache();
//                           });
//                         },
//                       );
//                     }).toList();
//                     return children;
//                   },
//                   buttonBuilder: (context, showMenu) => CupertinoButton(
//                       onPressed: (){
//                         HapticFeedback.selectionClick();
//                         showMenu();
//                       },
//                       padding: EdgeInsets.zero,
//                       child: Row(
//                         children: [
//                           ConstrainedBox(
//                             constraints: BoxConstraints(
//                                 maxWidth: MediaQuery.of(context).size.width-120
//                             ),
//                             child: OverflowSafeText(
//                                 (mapValue as GroupedExercise).exercises[cnRunningWorkout.selectedIndexes[groupedExerciseKey]!].name,
//                                 style: const TextStyle(color: Colors.white, fontSize: 20),
//                                 maxLines: 1
//                             ),
//                           ),
//                           const SizedBox(width: 10,),
//                           trailingChoice(size: 15, color: Colors.white)
//                         ],
//                       )
//                   ),
//                 ),
//
//                 cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value is Exercise
//                     ? const SizedBox()
//                     : const Spacer(),
//
//                 // if(cnRunningWorkout.newExNames.contains(key))
//                 //   SizedBox(
//                 //     width:40,
//                 //     child: myIconButton(
//                 //       icon:const Icon(Icons.delete_forever),
//                 //       onPressed: (){
//                 //         showCupertinoModalPopup<void>(
//                 //           context: context,
//                 //           builder: (BuildContext context) => CupertinoActionSheet(
//                 //             cancelButton: getActionSheetCancelButton(context),
//                 //             message: Text(AppLocalizations.of(context)!.runningWorkoutDeleteExercise),
//                 //             actions: <Widget>[
//                 //               CupertinoActionSheetAction(
//                 //                 /// This parameter indicates the action would perform
//                 //                 /// a destructive action such as delete or exit and turns
//                 //                 /// the action's text color to red.
//                 //                 isDestructiveAction: true,
//                 //                 onPressed: () {
//                 //                   // cnRunningWorkout.deleteExercise(item is Exercise? item : item._exercises[0]);
//                 //                   Navigator.pop(context);
//                 //                 },
//                 //                 child: Text(AppLocalizations.of(context)!.delete),
//                 //               ),
//                 //             ],
//                 //           ),
//                 //         );
//                 //       },
//                 //     ),
//                 //   ),
//               ],
//             ),
//
//             const SizedBox(height: 5),
//
//             SeatLevelSelectorRunningWorkout(
//                 exercise: newEx,
//                 iconSize: iconSize,
//                 style: style
//             ),
//
//             /// Rest in Seconds Row and Selector
//             // getRestInSecondsSelector(newEx),
//             RestInSecondsSelectorRunningWorkout(
//                 exercise: newEx,
//                 iconSize: iconSize,
//                 style: style
//             ),
//
//             const SizedBox(height: 15),
//
//             /// Text for Set, Template, Weight and Amount
//             SetHeaderRow(exercise: newEx),
//
//             const SizedBox(height: 5),
//           ],
//         ),
//       );
//     }
//
//     /// Single Set Row
//     if(item is NamedSet || item is GroupedSet){
//       child = SetRow(
//           cnRunningWorkout: cnRunningWorkout,
//           item: item,
//           groupedExerciseKey: groupedExerciseKey,
//           index: indexExercise
//       );
//     }
//
//     /// Top Spacer
//     if (indexExercise == 0){
//       child = Column(
//         children: [
//           SizedBox(height: Platform.isAndroid? 80 : 120),
//           child?? const SizedBox()
//         ],
//       );
//     }
//
//     /// Bottom Spacer
//     if (indexExercise == cnRunningWorkout.groupedExercises.length-1){
//       child = Column(
//         children: [
//           child?? const SizedBox(),
//           const BottomSpacerRunningWorkout(),
//         ],
//       );
//     }
//
//     return Container(
//         key: currentDraggingKey == null ||
//             ((item is NamedSet || item is GroupedSet)
//                 && groupedExerciseKey.contains(currentDraggingKey!))
//             ? ValueKey(groupedExerciseKey)
//             : UniqueKey(),
//         // key: key,
//         // key: ValueKey(groupedExerciseKey),
//         child: child?? const SizedBox());
//   }
// }
