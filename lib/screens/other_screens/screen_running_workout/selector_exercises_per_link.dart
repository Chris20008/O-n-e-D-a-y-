// import 'package:fitness_app/screens/other_screens/screen_running_workout/screen_running_workout.dart';
// import 'package:fitness_app/widgets/bottom_menu.dart';
// import 'package:fitness_app/widgets/cupertino_button_text.dart';
// import 'package:fitness_app/widgets/slide_up_panel/my_slide_up_panel.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:sliding_up_panel/sliding_up_panel.dart';
// import '../../../objects/exercise.dart';
// import '../../../util/constants.dart';
// import '../../../widgets/multiple_exercise_row.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'dart:io';
//
// class SelectorExercisesPerLink extends StatefulWidget {
//
//   const SelectorExercisesPerLink({
//     super.key,
//   });
//
//   @override
//   State<SelectorExercisesPerLink> createState() => _SelectorExercisesPerLinkState();
// }
//
// class _SelectorExercisesPerLinkState extends State<SelectorExercisesPerLink> {
//
//   /// listen to bottomMenu for height changes
//   late CnBottomMenu cnBottomMenu;
//   late CnRunningWorkout cnRunningWorkout;
//   late CnSelectorExercisePerLink cnSelectorExercisePerLink;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     cnBottomMenu = Provider.of<CnBottomMenu>(context);
//     cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen:false);
//     cnSelectorExercisePerLink = Provider.of<CnSelectorExercisePerLink>(context, listen:true);
//
//     print("Selector Exercises Per Link");
//
//     final linkNames = cnSelectorExercisePerLink.groupedExercises.keys.toList();
//     Map groupedExercises = cnSelectorExercisePerLink.groupedExercises;
//     List<List<bool>> isCheckedList = cnSelectorExercisePerLink.isCheckedList;
//
//     return MySlideUpPanel(
//       key: widget.key,
//       animationControllerName: "SelectorExercisePerLink",
//       descendantAnimationControllerName: "ScreenRunningWorkout",
//       backdropEnabled: false,
//       controller: cnSelectorExercisePerLink.panelController,
//       panelBuilder: (context, listView){
//         return SafeArea(
//           top: false,
//           bottom: false,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Stack(
//               children: [
//                 Container(
//                   margin: const EdgeInsets.only(bottom: 2),
//                   color: Theme.of(context).primaryColor,
//                   child: listView(
//                       controller: cnSelectorExercisePerLink.sc,
//                       physics: const BouncingScrollPhysics(),
//                       padding: EdgeInsets.only(bottom: cnBottomMenu.height+10, top: 100),
//                       shrinkWrap: true,
//                       separatorBuilder: (context, index){
//                         return Padding(
//                           padding: const EdgeInsets.only(left: 15, right: 15),
//                           child: mySeparator(heightBottom: 15, heightTop: 15),
//                         );
//                       },
//                       itemCount: groupedExercises.keys.length,
//                       itemBuilder: (context, index){
//                         return Padding(
//                           padding: const EdgeInsets.only(left: 15),
//                           child: Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Center(
//                                       child: OverflowSafeText(
//                                           "${AppLocalizations.of(context)!.runningWorkoutGroup}: ${linkNames[index]}",
//                                           minFontSize: 20,
//                                           maxLines: 1
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 15,),
//                               for(Exercise ex in groupedExercises[linkNames[index]])
//                               /// show only exercises that actually to have filled sets
//                               /// In a Group with 3 or more Exercises it is likely to happen
//                               /// that the user fills two exercises. However the not filled
//                               /// exercises are still in the group. Here we filter for only those
//                               /// that actually have filled sets
//                                 if(ex.sets.isNotEmpty)
//                                   GestureDetector(
//                                     onTap: (){
//                                       setState(() {
//                                         final currentState = isCheckedList[index][groupedExercises[linkNames[index]].indexOf(ex)];
//                                         isCheckedList[index][groupedExercises[linkNames[index]].indexOf(ex)] = !currentState;
//                                         if(!currentState){
//                                           vibrateConfirm();
//                                         } else{
//                                           vibrateCancel();
//                                         }
//                                       });
//                                     },
//                                     child: Row(
//                                       children: [
//                                         Expanded(
//                                           child: MultipleExerciseRow(
//                                             exercises: [ex],
//                                             fontSize: 15,
//                                             colorFade: Theme.of(context).primaryColor,
//                                           ),
//                                         ),
//                                         Transform.scale(
//                                           scale: 1.4,
//                                           child: Checkbox(
//                                             checkColor: Colors.white,
//                                             value: isCheckedList[index][groupedExercises[linkNames[index]].indexOf(ex)],
//                                             shape: const CircleBorder(),
//                                             onChanged: (bool? value) {
//                                               setState(() {
//                                                 isCheckedList[index][groupedExercises[linkNames[index]].indexOf(ex)] = value?? false;
//                                                 if(value?? false){
//                                                   vibrateConfirm();
//                                                 } else{
//                                                   vibrateCancel();
//                                                 }
//                                               });
//                                             },
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   )
//                             ],
//                           ),
//                         );
//                       }
//                   ),
//                 ),
//                 /// top text
//                 Container(
//                   height: 84,
//                   // padding: const EdgeInsets.all(10),
//                   color: Theme.of(context).primaryColor,
//                   child: Column(
//                     children: [
//                       // Padding(
//                       //     padding: const EdgeInsets.only(top:10, bottom: 10),
//                       //     child: panelTopBar
//                       // ),
//                       const SizedBox(height: 20,),
//                       Center(
//                           child: OverflowSafeText(
//                             AppLocalizations.of(context)!.runningWorkoutSelectGroup,
//                             textAlign: TextAlign.center,
//                             fontSize: 22,
//                           )
//                       ),
//                     ],
//                   ),
//                 ),
//                 /// top faded box
//                 Positioned(
//                   top: 83.8,
//                   left: 0,
//                   right: 0,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient:  LinearGradient(
//                           begin: Alignment.bottomCenter,
//                           end: Alignment.topCenter,
//                           colors: [
//                             Theme.of(context).primaryColor.withValues(alpha: 0.0),
//                             Theme.of(context).primaryColor,
//                           ]
//                       ),
//                     ),
//                     height: 30,
//                   ),
//                 ),
//                 /// bottom colored box
//                 Positioned(
//                     bottom: 0,
//                     left: 0,
//                     right: 0,
//                     child: Container(
//                       color: Theme.of(context).primaryColor,
//                       height: cnBottomMenu.height,
//                     )
//                 ),
//                 /// bottom faded box
//                 Positioned(
//                   bottom: cnBottomMenu.height - 0.5,
//                   left: 0,
//                   right: 0,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient:  LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             Theme.of(context).primaryColor.withValues(alpha: 0.0),
//                             Theme.of(context).primaryColor,
//                           ]
//                       ),
//                     ),
//                     height: 30,
//                   ),
//                 ),
//                 /// bottom buttons
//                 Positioned(
//                     bottom: Platform.isAndroid? 10 : -5,
//                     left: 0,
//                     right: 0,
//                     child: SafeArea(
//                       top: false,
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: CupertinoButtonText(
//                               text: AppLocalizations.of(context)!.cancel,
//                               onPressed: () {
//                                 HapticFeedback.selectionClick();
//                                 cnSelectorExercisePerLink.panelController.close();
//                               },
//                             ),
//                           ),
//
//                           const Spacer(),
//
//                           Expanded(
//                             child: CupertinoButtonText(
//                               text: AppLocalizations.of(context)!.confirm,
//                               onPressed: () {
//                                 List<String> exToRemove = [];
//                                 int index = 0;
//                                 int indexJ = 0;
//                                 for(List<bool> checks in isCheckedList){
//                                   for(bool check in checks){
//                                     if(check){
//                                       indexJ += 1;
//                                       continue;
//                                     }
//                                     exToRemove.add(groupedExercises[linkNames[index]][indexJ].name);
//                                     indexJ += 1;
//                                   }
//                                   indexJ = 0;
//                                   index += 1;
//                                 }
//                                 HapticFeedback.selectionClick();
//                                 cnRunningWorkout.confirmSelectorExPerLink(exToRemove: exToRemove, context: context);
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class CnSelectorExercisePerLink extends ChangeNotifier {
//   Map groupedExercises = {};
//   Function onConfirm = (){};
//   Function onCancel = (){};
//   PanelController panelController = PanelController();
//   List<List<bool>> isCheckedList = [];
//   ScrollController sc = ScrollController();
//
//   CnSelectorExercisePerLink();
//
//   void reset(){
//     groupedExercises.clear();
//     isCheckedList.clear();
//     sc = ScrollController();
//     onConfirm = (){};
//     onCancel = (){};
//   }
//
//   void initData({
//     required Map groupedExercises,
//     required List<String> relevantLinkNames,
//     bool withRefresh = true
//   }){
//     final Map groupedExs = {};
//     for(MapEntry e in groupedExercises.entries){
//       if(relevantLinkNames.contains(e.key) && e.value is GroupedExercise){
//         groupedExs[e.key] = e.value.exercises.map((ex) => Exercise.copy(ex)).toList();
//         for(Exercise ex in groupedExs[e.key]){
//           ex.removeEmptySets();
//         }
//       }
//     }
//     isCheckedList = groupedExs.entries.map((e) => List<bool>.generate(e.value.length, (index) => true)).toList();
//     this.groupedExercises = groupedExs;
//     if(withRefresh){
//       refresh();
//     }
//   }
//
//   Future openPanel() async{
//     await panelController.animatePanelToPosition(
//         1,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.fastEaseInToSlowEaseOut
//     );
//   }
//
//   bool get isOpened => panelController.panelPosition > 0;
//
//   void refresh(){
//     notifyListeners();
//   }
// }