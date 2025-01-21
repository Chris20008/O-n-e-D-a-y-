import 'dart:collection';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/selector_exercises_per_link.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/selector_exercises_to_update.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/setRow.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/stopwatch.dart';
import 'package:fitness_app/util/backup_functions.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/widgets/banner_running_workout.dart';
import 'package:fitness_app/widgets/initial_animated_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../main.dart';
import '../../../objects/exercise.dart';
import '../../../objects/workout.dart';
import '../../../util/constants.dart';
import '../../../widgets/bottom_menu.dart';
import '../../../widgets/spotify_bar.dart';
import '../../../widgets/standard_popup.dart';
import '../../main_screens/screen_workouts/screen_workouts.dart';
import 'animated_column.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fitness_app/assets/custom_icons/my_icons_icons.dart';

class ScreenRunningWorkout extends StatefulWidget {
  const ScreenRunningWorkout({
    super.key,
  });

  @override
  State<ScreenRunningWorkout> createState() => _ScreenRunningWorkoutState();
}

class _ScreenRunningWorkoutState extends State<ScreenRunningWorkout> {
  // late final AnimationController _controllerSelectorExUpdate = AnimationController(
  //   duration: const Duration(milliseconds: 200),
  //   vsync: this,
  // );
  // late final Animation<double> _animationSelectorExUpdate = CurvedAnimation(
  //   parent: _controllerSelectorExUpdate,
  //   curve: Curves.decelerate,
  //     // curve: Curves.easeOutBack
  // );
  // late final AnimationController _controllerSelectorExPerLink = AnimationController(
  //   duration: const Duration(milliseconds: 200),
  //   vsync: this,
  // );
  // late final Animation<double> _animationSelectorExPerLink = CurvedAnimation(
  //   parent: _controllerSelectorExPerLink,
  //   curve: Curves.decelerate,
  //     // curve: Curves.easeOutBack
  // );

  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  late CnStopwatchWidget cnStopwatchWidget = Provider.of<CnStopwatchWidget>(context, listen: false);
  late CnConfig cnConfig  = Provider.of<CnConfig>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context);
  /// listen to bottomMenu for height changes
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context);
  final double _iconSize = 20;
  final double _heightOfSetRow = 30;
  final double _widthOfTextField = 55;
  final double _setPadding = 5;
  Key selectorExerciseToUpdateKey = UniqueKey();
  Key selectorExercisePerLinkKey = UniqueKey();
  double viewInsetsBottom = 0;
  bool isAlreadyCheckingKeyboard = false;
  bool isAlreadyCheckingKeyboardPermanent = false;
  // bool showSelectorExerciseToUpdate = false;
  // bool showSelectorExercisePerLink = false;
  bool isSavingData = false;
  final _style = const TextStyle(color: Colors.white, fontSize: 15);
  String descendantNameExerciseToUpdate = "ScreenRunningWorkout";
  PanelController controllerSelectorExerciseToUpdate = PanelController();
  PanelController controllerSelectorExercisePerLink = PanelController();
  String? currentDraggingKey;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    cnRunningWorkout.scrollController = ScrollController(initialScrollOffset: cnRunningWorkout.lastScrollPosition);

    return PopScope(
      canPop: !isSavingData,
      onPopInvoked: (doPop){
        if(cnRunningWorkout.isVisible){
          cnRunningWorkout.lastScrollPosition = cnRunningWorkout.scrollController.offset;
          cnRunningWorkout.isVisible = false;
          cnWorkouts.refresh();
          cnRunningWorkout.cache();
        }
        if(cnStandardPopUp.isVisible){
          cnStandardPopUp.clear();
        }
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xffc26a0e),
                    Color(0xbb110a02)
                  ]
              )
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InitialAnimatedScreen(
                backDropEnabled: true,
                animationControllerName: "ScreenRunningWorkout",
                child: Scaffold(
                  extendBody: true,
                  bottomNavigationBar: viewInsetsBottom < 50? ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaX: 10.0,
                          sigmaY: 10.0,
                          tileMode: TileMode.mirror
                      ),
                      child: GestureDetector(
                        onTap: openPopUpFinishWorkout,
                        child: Container(
                          height: cnBottomMenu.height,
                          color: Colors.black.withOpacity(0.5),
                          child: Center(child: Text(AppLocalizations.of(context)!.finish, style: TextStyle(color: Colors.amber[800]), textScaler: const TextScaler.linear(1.4),)),
                        ),
                      ),
                    ),
                  ): const SizedBox(),
                  body: GestureDetector(
                    onTap: (){
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Stack(
                      children: [
                        SafeArea(
                          top: false,
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.only(top:0,bottom: 0,left: 20, right: 20),
                            child: Column(
                              children: [

                                Expanded(

                                  /// Each EXERCISE
                                  child: ReorderableListView.builder(
                                    scrollController: cnRunningWorkout.scrollController,
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    onReorderStart: (index){
                                      currentDraggingKey = cnRunningWorkout.groupedExercises.entries.toList()[index].key.split("_").firstOrNull;
                                    },
                                    onReorder: (int oldIndex, int newIndex) {
                                      if (oldIndex < newIndex) {
                                        newIndex -= 1;
                                      }
                                      dynamic movingItem = cnRunningWorkout.groupedExercises[cnRunningWorkout.groupedExercises.keys.toList()[oldIndex]];
                                      dynamic newIndexItem = cnRunningWorkout.groupedExercises[cnRunningWorkout.groupedExercises.keys.toList()[newIndex]];

                                      if(movingItem is GroupedSet && newIndexItem is GroupedSet){
                                        String linkNameOld = cnRunningWorkout.groupedExercises.keys.toList()[oldIndex].split("_").first;
                                        String linkNameNew = cnRunningWorkout.groupedExercises.keys.toList()[newIndex].split("_").first;
                                        if(linkNameOld != linkNameNew){
                                          return;
                                        }
                                        Exercise exOld = (cnRunningWorkout.groupedExercises[linkNameOld] as GroupedExercise).getExercise(cnRunningWorkout.selectedIndexes[linkNameOld]!)!;
                                        Exercise exNew = (cnRunningWorkout.groupedExercises[linkNameNew] as GroupedExercise).getExercise(cnRunningWorkout.selectedIndexes[linkNameNew]!)!;
                                        movingItem = movingItem.getSet(exOld.name);
                                        newIndexItem = newIndexItem.getSet(exNew.name);
                                      }

                                      if(movingItem is NamedSet && newIndexItem is NamedSet && movingItem.name == newIndexItem.name){
                                        NamedSet? setToMove = cnRunningWorkout.removeSpecificSetFromExercise(movingItem);

                                        if(setToMove == null){
                                          return;
                                        }
                                        setToMove.index = newIndexItem.index;

                                        if (oldIndex < newIndex) {
                                          setToMove.index += 1;
                                        }
                                        cnRunningWorkout.addSpecificSetToExercise(setToMove);
                                        setState(() {});

                                      }
                                    },
                                    proxyDecorator: (Widget child, int index, Animation<double> animation) {
                                      return AnimatedBuilder(
                                        animation: animation,
                                        builder: (BuildContext context, Widget? child) {
                                          final double animValue = Curves.easeInOut.transform(animation.value);
                                          final double scale = lerpDouble(1, 1.06, animValue)!;
                                          return Transform.scale(
                                            scale: scale,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Material(
                                                  child: Container(
                                                      padding: const EdgeInsets.only(left: 2),
                                                      color: Colors.grey.withOpacity(0.1),
                                                      child: child
                                                  )
                                              ),
                                            ),
                                          );
                                        },
                                        child: child,
                                      );
                                    },
                                    // separatorBuilder: (BuildContext context, int index) {
                                    //   if (index == 0){
                                    //     return const SizedBox();
                                    //   }
                                    //   dynamic item = cnRunningWorkout.groupedExercises.entries.toList()[index+1].value;
                                    //   if (item is Exercise || item is GroupedExercise){
                                    //     return mySeparator();
                                    //   }
                                    //   return const SizedBox();
                                    // },
                                    // cacheExtent: 1000000,
                                    itemCount: cnRunningWorkout.groupedExercises.length,
                                    itemBuilder: (BuildContext context, int indexExercise) {
                                      Widget? child;
                                      String groupedExerciseKey = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].key;
                                      dynamic mapValue = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value;
                                      dynamic item = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value;

                                      if(mapValue.toString().contains("Separator")){
                                        dynamic previousItem = cnRunningWorkout.groupedExercises.entries.toList()[indexExercise-1].value;
                                        late Exercise ex;
                                        if(previousItem is NamedSet){
                                          ex = previousItem.ex;
                                        }
                                        else{
                                          previousItem = previousItem as GroupedSet;
                                          String linkName = groupedExerciseKey.split("_").first;
                                          ex = (cnRunningWorkout.groupedExercises[linkName] as GroupedExercise).getExercise(cnRunningWorkout.selectedIndexes[linkName]!)!;
                                        }

                                        Exercise? templateEx = cnRunningWorkout.workoutTemplateModifiable.exercises.where((e) => e.name == ex.name).firstOrNull;

                                        child = GestureDetector(
                                          /// Empty long press to prevent dragging
                                          onLongPress: (){},
                                          child: Column(
                                            children: [
                                              getAddSetButton(ex, templateEx!),
                                              mySeparator(),
                                            ],
                                          ),
                                        );
                                      }

                                      else if(item is Exercise || item is GroupedExercise){

                                        Exercise? newEx = item is Exercise ? item : (mapValue as GroupedExercise).getExercise(cnRunningWorkout.selectedIndexes[groupedExerciseKey]!);

                                        if(newEx == null){
                                          return const SizedBox();
                                        }

                                        child = GestureDetector(
                                          /// Empty long press to prevent dragging
                                          onLongPress: (){},
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (item is !Exercise)
                                                Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: OverflowSafeText(
                                                    groupedExerciseKey,
                                                    textAlign: TextAlign.center,
                                                    // fontSize: 12,
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.white70
                                                    ),
                                                    minFontSize: 12,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              Row(
                                                children: [
                                                  item is Exercise
                                                  /// Single Exercise
                                                      ? Expanded(
                                                    child: ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                          maxWidth: MediaQuery.of(context).size.width-80
                                                      ),
                                                      child: OverflowSafeText(
                                                        newEx.name,
                                                        maxLines: 1,
                                                        style: const TextStyle(color: Colors.white, fontSize: 20),
                                                      ),
                                                    ),
                                                  )
                                                  /// Exercise Selector
                                                      : PullDownButton(
                                                    onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
                                                    buttonAnchor: PullDownMenuAnchor.start,
                                                    routeTheme: const PullDownMenuRouteTheme(backgroundColor: CupertinoColors.secondaryLabel),
                                                    itemBuilder: (context) {
                                                      final children = item.exercises.map<PullDownMenuItem>((Exercise value) {
                                                        return PullDownMenuItem.selectable(
                                                          title: value.name,
                                                          selected: value.name == (mapValue as GroupedExercise).getExercise(cnRunningWorkout.selectedIndexes[groupedExerciseKey]!)?.name,
                                                          // selected: false,
                                                          onTap: () {
                                                            FocusManager.instance.primaryFocus?.unfocus();
                                                            HapticFeedback.selectionClick();
                                                            Future.delayed(const Duration(milliseconds: 200), (){
                                                              setState(() {
                                                                final exercises = mapValue.exercises;
                                                                final t = exercises.indexWhere((ex) => ex.name == value.name);

                                                                cnRunningWorkout.selectedIndexes[groupedExerciseKey] = t;
                                                              });
                                                              cnRunningWorkout.cache();
                                                            });
                                                          },
                                                        );
                                                      }).toList();
                                                      return children;
                                                    },
                                                    buttonBuilder: (context, showMenu) => CupertinoButton(
                                                        onPressed: (){
                                                          HapticFeedback.selectionClick();
                                                          showMenu();
                                                        },
                                                        padding: EdgeInsets.zero,
                                                        child: Row(
                                                          children: [
                                                            ConstrainedBox(
                                                              constraints: BoxConstraints(
                                                                  maxWidth: MediaQuery.of(context).size.width-120
                                                              ),
                                                              child: OverflowSafeText(
                                                                  (mapValue as GroupedExercise).exercises[cnRunningWorkout.selectedIndexes[groupedExerciseKey]!].name,
                                                                  style: const TextStyle(color: Colors.white, fontSize: 20),
                                                                  maxLines: 1
                                                              ),
                                                            ),
                                                            const SizedBox(width: 10,),
                                                            trailingChoice(size: 15, color: Colors.white)
                                                          ],
                                                        )
                                                    ),
                                                  ),

                                                  cnRunningWorkout.groupedExercises.entries.toList()[indexExercise].value is Exercise
                                                      ? const SizedBox()
                                                      : const Spacer(),

                                                  // if(cnRunningWorkout.newExNames.contains(key))
                                                  //   SizedBox(
                                                  //     width:40,
                                                  //     child: myIconButton(
                                                  //       icon:const Icon(Icons.delete_forever),
                                                  //       onPressed: (){
                                                  //         showCupertinoModalPopup<void>(
                                                  //           context: context,
                                                  //           builder: (BuildContext context) => CupertinoActionSheet(
                                                  //             cancelButton: getActionSheetCancelButton(context),
                                                  //             message: Text(AppLocalizations.of(context)!.runningWorkoutDeleteExercise),
                                                  //             actions: <Widget>[
                                                  //               CupertinoActionSheetAction(
                                                  //                 /// This parameter indicates the action would perform
                                                  //                 /// a destructive action such as delete or exit and turns
                                                  //                 /// the action's text color to red.
                                                  //                 isDestructiveAction: true,
                                                  //                 onPressed: () {
                                                  //                   // cnRunningWorkout.deleteExercise(item is Exercise? item : item._exercises[0]);
                                                  //                   Navigator.pop(context);
                                                  //                 },
                                                  //                 child: Text(AppLocalizations.of(context)!.delete),
                                                  //               ),
                                                  //             ],
                                                  //           ),
                                                  //         );
                                                  //       },
                                                  //     ),
                                                  //   ),
                                                ],
                                              ),

                                              const SizedBox(height: 5),

                                              Row(
                                                // mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(width: 100, child: getSeatLevelSelector(newEx)),
                                                  Icon(MyIcons.tags, size: _iconSize-3, color: Colors.amber[900]!.withOpacity(0.6),),
                                                  const SizedBox(width: 8,),
                                                  Text(newEx.getCategoryName())
                                                ]
                                              ),

                                              /// Rest in Seconds Row and Selector
                                              getRestInSecondsSelector(newEx),

                                              const SizedBox(height: 15),

                                              /// Text for Set, Template, Weight and Amount
                                              Row(
                                                children: [
                                                  SizedBox(
                                                      width: _widthOfTextField,
                                                      child: OverflowSafeText(
                                                        AppLocalizations.of(context)!.set,
                                                        textAlign: TextAlign.center,
                                                        // fontSize: 12,
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            color: Colors.white70
                                                        ),
                                                        minFontSize: 12,
                                                        maxLines: 1,
                                                      )
                                                  ),
                                                  Expanded(
                                                      flex: 2,
                                                      child: OverflowSafeText(
                                                          AppLocalizations.of(context)!.template,
                                                          textAlign: TextAlign.center,
                                                          // fontSize: 12,
                                                          style: const TextStyle(
                                                              fontSize: 13,
                                                              color: Colors.white70
                                                          ),
                                                          minFontSize: 12,
                                                          maxLines: 1
                                                      )
                                                  ),
                                                  /// TextField Headers
                                                  Expanded(
                                                      flex: 2,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          SizedBox(
                                                              width: _widthOfTextField+10,
                                                              child: OverflowSafeText(
                                                                // AppLocalizations.of(context)!.weight,
                                                                  newEx.getLeftTitle(context),
                                                                  textAlign: TextAlign.center,
                                                                  // fontSize: 12,
                                                                  style: const TextStyle(
                                                                      fontSize: 13,
                                                                      color: Colors.white70
                                                                  ),
                                                                  minFontSize: 12,
                                                                  maxLines: 1
                                                              )
                                                          ),
                                                          const SizedBox(width: 4,),
                                                          SizedBox(
                                                              width: _widthOfTextField+10,
                                                              child: OverflowSafeText(
                                                                // AppLocalizations.of(context)!.amount,
                                                                  newEx.getRightTitle(context),
                                                                  textAlign: TextAlign.center,
                                                                  // fontSize: 12,
                                                                  style: const TextStyle(
                                                                      fontSize: 13,
                                                                      color: Colors.white70
                                                                  ),
                                                                  minFontSize: 12,
                                                                  maxLines: 1
                                                              )
                                                          )
                                                        ],
                                                      )
                                                  )
                                                ],
                                              ),

                                              const SizedBox(height: 5),
                                            ],
                                          ),
                                        );
                                      }

                                      /// Single Set Row
                                      if(item is NamedSet || item is GroupedSet){
                                        child = SetRow(
                                            cnRunningWorkout: cnRunningWorkout,
                                            i: item,
                                            groupedExerciseKey: groupedExerciseKey,
                                        );
                                      }

                                      /// Top Spacer
                                      if (indexExercise == 0){
                                        child = Column(
                                          children: [
                                            const SizedBox(height: 80,),
                                            child?? const SizedBox()
                                          ],
                                        );
                                      }

                                      /// Bottom Spacer
                                      if (indexExercise == cnRunningWorkout.groupedExercises.length-1){
                                        child = Column(
                                          children: [
                                            child?? const SizedBox(),
                                            AnimatedContainer(
                                                duration: const Duration(milliseconds: 250),
                                                height: cnStopwatchWidget.isOpened
                                                    ? 70 + cnStopwatchWidget.heightOfTimer
                                                    : 70
                                            ),
                                          ],
                                        );
                                      }

                                      return Container(
                                          // key: (item is NamedSet || item is GroupedSet)
                                          //     && currentDraggingKey != null
                                          //     && groupedExerciseKey.contains(currentDraggingKey!)
                                          //     ? ValueKey(groupedExerciseKey)
                                          //     : UniqueKey(),
                                          key: ValueKey(groupedExerciseKey),
                                          child: child?? const SizedBox());
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        /// do not make const, should be updated by rebuild
                        Hero(
                            transitionOnUserGestures: true,
                            tag: "Banner",
                            child: BannerRunningWorkout()
                        ),
                        AnimatedCrossFade(
                            layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
                              return Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Positioned(
                                    key: bottomChildKey,
                                    // bottom: 0,
                                    // left: 0,
                                    child: bottomChild,
                                  ),
                                  Positioned(
                                    key: topChildKey,
                                    child: topChild,
                                  ),
                                ],
                              );
                            },
                            firstChild: const AnimatedColumn(),
                            secondChild: const Align(
                              alignment: Alignment.bottomRight,
                                child: SizedBox(width: double.maxFinite)
                            ),
                            crossFadeState: viewInsetsBottom < 50
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                            duration: Duration(milliseconds: viewInsetsBottom < 50? cnSpotifyBar.animationTimeSpotifyBar~/2 : 0)
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if(cnRunningWorkout.dismissedSets.isNotEmpty)
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: undoDismiss,
                        icon: Icon(
                          Icons.undo,
                          color: Colors.amber[800],
                        )
                    ),
                  ),
                ),
              const StandardPopUp(),
              // AnimatedCrossFade(
              //   firstChild: Container(
              //     color: Colors.black54,
              //   ),
              //   secondChild: const SizedBox(),
              //   crossFadeState: showSelectorExerciseToUpdate || showSelectorExercisePerLink
              //       ? CrossFadeState.showFirst
              //       : CrossFadeState.showSecond,
              //   duration: const Duration(milliseconds: 200),
              //   layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
              //     return Stack(
              //       clipBehavior: Clip.none,
              //       alignment: Alignment.center,
              //       children: <Widget>[
              //         Positioned(
              //           key: bottomChildKey,
              //           child: bottomChild,
              //         ),
              //         Positioned(
              //           key: topChildKey,
              //           child: topChild,
              //         ),
              //       ],
              //     );
              //   },
              // ),
              SelectorExercisesPerLink(
                controller: controllerSelectorExercisePerLink,
                key: selectorExercisePerLinkKey,
                groupedExercises: cnRunningWorkout.groupedExercises,
                relevantLinkNames: cnRunningWorkout.linkWithMultipleExercisesStarted,
                onConfirm: confirmSelectorExPerLink,
                onCancel: (){
                  controllerSelectorExercisePerLink.close();
                },
              ),
              SelectorExercisesToUpdate(
                key: selectorExerciseToUpdateKey,
                controller: controllerSelectorExerciseToUpdate,
                descendantAnimationControllerName: descendantNameExerciseToUpdate,
                workout: Workout.clone(cnRunningWorkout.workout),
                workoutTemplate: Workout.clone(cnRunningWorkout.workoutTemplateNotModifiable),
                onConfirm: finishWorkout,
                onCancel: (){
                  // controllerSelectorExerciseToUpdate.close().then((value) => controllerSelectorExercisePerLink.close());
                  controllerSelectorExerciseToUpdate.close();
                },
              ),
              if (isSavingData)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CupertinoActivityIndicator(
                        radius: 20.0,
                        color: Colors.amber[800]
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  // Widget getButtonInsertTemplatesData({
  //   required SingleSet newSet,
  //   required SingleSet? templateSet,
  //   required Exercise? templateEx,
  //   required int indexSet,
  //   required TextEditingController? weightController,
  //   required TextEditingController? amountController
  // }){
  //
  //   String getText(){
  //     if(templateEx == null || templateSet == null){
  //       return "";
  //     }
  //     switch (templateEx.category){
  //       case 1:
  //         return templateSet.weight != null && templateSet.amount != null? "${templateSet.weightAsTrimmedDouble?? ""} kg x ${templateSet.amount?? ""}" : "";
  //       case 2:
  //         return templateSet.weight != null && templateSet.amount != null? "${templateSet.weightAsTrimmedDouble?? ""} km in ${templateSet.amountAsTime?? ""}" : "";
  //       case 3:
  //         return templateSet.weight != null && templateSet.amount != null? "${templateSet.weightAsTrimmedDouble?? ""} kg for ${templateSet.amountAsTime?? ""}" : "";
  //       default:
  //         return "";
  //     }
  //   }
  //
  //   final weightTextIsEmpty = weightController?.text.isEmpty?? false;
  //   final amountTextIsEmpty = amountController?.text.isEmpty?? false;
  //
  //   return Expanded(
  //       flex: 2,
  //       child: IgnorePointer(
  //         ignoring: !(weightTextIsEmpty &&
  //             amountTextIsEmpty &&
  //             templateSet?.weight != null &&
  //             templateSet?.amount != null),
  //         child: SizedBox(
  //           height: _heightOfSetRow,
  //           child: ElevatedButton(
  //             style: ButtonStyle(
  //                 shadowColor: MaterialStateProperty.all(Colors.transparent),
  //                 surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
  //                 backgroundColor: MaterialStateProperty.all(Colors.transparent),
  //                 shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
  //             ),
  //             onPressed: (){
  //               if(templateSet == null || templateEx == null){
  //                 return;
  //               }
  //               if(templateSet.weight != null &&
  //                   templateSet.amount != null &&
  //                   weightTextIsEmpty &&
  //                   amountTextIsEmpty
  //               ){
  //                 vibrateConfirm();
  //                 weightController?.text = (templateSet.weightAsTrimmedDouble?? "").toString();
  //                 newSet.weight = templateSet.weight;
  //                 if(templateEx.categoryIsReps()){
  //                   amountController?.text = templateSet.amount!.toString();
  //                 }
  //                 else{
  //                   amountController?.text = templateSet.amountAsTime.toString();
  //                 }
  //                 newSet.amount = templateSet.amount;
  //                 cnRunningWorkout.refresh();
  //                 cnRunningWorkout.cache();
  //               } else{
  //                 setState(() {
  //                   FocusManager.instance.primaryFocus?.unfocus();
  //                 });
  //               }
  //             },
  //             child: Center(
  //               child: OverflowSafeText(
  //                 maxLines: 1,
  //                 getText(),
  //                 style: TextStyle(
  //                     color: (weightTextIsEmpty &&
  //                         amountTextIsEmpty)
  //                         ?Colors.white
  //                         : Colors.white.withOpacity(0.2)
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       )
  //   );
  // }

  void confirmSelectorExPerLink({List<String>? exToRemove, int? delay}){
    cnRunningWorkout.exercisesToRemove = exToRemove?? [];
    if(canUpdateTemplate()){
      Future.delayed(Duration(milliseconds: delay?? cnStandardPopUp.animationTime), (){
        setState(() {
          selectorExerciseToUpdateKey = UniqueKey();
          controllerSelectorExerciseToUpdate = PanelController();
        });
        Future.delayed(const Duration(milliseconds: (100)), (){
          FocusManager.instance.primaryFocus?.unfocus();
          controllerSelectorExerciseToUpdate.open();
        });
      });
    }
    else{
      finishWorkout();
    }
  }

  void addSet(Exercise ex, Exercise lastEx){
    int newIndex = ex.sets.length;
    ex.addSet();
    lastEx.addSet();
    SingleSet newSet = ex.sets[newIndex];
    NamedSet newNamedSet = NamedSet(
        set: newSet,
        name: ex.name,
        index: newIndex,
        ex: ex,
        weightController: TextEditingController(text: (newSet.weightAsTrimmedDouble?? "").toString()),
        amountController: TextEditingController(text: (newSet.getAmountAsText(ex.category)?? "").toString())
    );
    if(ex.linkName == null){
      cnRunningWorkout.groupedExercises[getSetKeyName(ex.name, newIndex)] = newNamedSet;
    } else{
      final String newSetKey = getSetKeyName(ex.linkName!, newIndex);
      if(cnRunningWorkout.groupedExercises.containsKey(newSetKey)){
        (cnRunningWorkout.groupedExercises[getSetKeyName(ex.linkName!, newIndex)] as GroupedSet).add(newNamedSet);
      } else{
        cnRunningWorkout.groupedExercises[getSetKeyName(ex.linkName!, newIndex)] = GroupedSet(set: newNamedSet);
      }
    }
    cnRunningWorkout.slideableKeys[ex.name]?.add(UniqueKey());
    final newControllerPos = cnRunningWorkout.scrollController.position.pixels+_heightOfSetRow + _setPadding*2;
    // if(newControllerPos >= 0 && cnRunningWorkout.scrollController.position.maxScrollExtent >= newControllerPos){
    cnRunningWorkout.scrollController.jumpTo(newControllerPos);
    // }
    cnRunningWorkout.refresh();
    // setState();
  }

  // void dismiss(Exercise ex, Exercise templateEx, NamedSet set){
  //   setState(() {
  //     // final dismissedSet = ex.sets.removeAt(set.index);
  //     // final dismissedTemplateSet = lastEx.sets.removeAt(set.index);
  //     // final dismissedControllers = cnRunningWorkout.textControllers[ex.name]?.removeAt(index);
  //     // cnRunningWorkout.slideableKeys[ex.name]?.removeAt(index);
  //
  //     // print("KEY NAME ${getSetKeyName(ex.name, set.index)}");
  //     // print(cnRunningWorkout.groupedExercises.keys);
  //     // print("Länge vorher");
  //     // print(cnRunningWorkout.groupedExercises.length);
  //
  //     final oldSetsAmount = ex.sets.length;
  //     // print("Old Sets Amount = $oldSetsAmount");
  //     ex.sets.removeAt(set.index);
  //     templateEx.sets.removeAt(set.index);
  //     if(ex.linkName == null){
  //       // print("Is Single Exercise");
  //       for(int i = set.index; i <= (oldSetsAmount-1); i++){
  //         if(i == oldSetsAmount-1){
  //           // print("Delete Set at index $i");
  //           cnRunningWorkout.groupedExercises.remove(getSetKeyName(ex.name, i));
  //           break;
  //         }
  //         // print("replace Set at index $i");
  //         NamedSet nextNamedSet = cnRunningWorkout.groupedExercises[getSetKeyName(ex.name, i+1)];
  //         nextNamedSet.index -= 1;
  //         cnRunningWorkout.groupedExercises[getSetKeyName(ex.name, i)] = nextNamedSet;
  //       }
  //       // print("");
  //     }
  //     else {
  //       // print("Is Grouped Exercise");
  //       for(int i = set.index; i <= (oldSetsAmount-1); i++){
  //         // cnRunningWorkout.groupedExercises.keys.forEach((element) {print(element);});
  //         if(i == oldSetsAmount-1){
  //           // print("Delete Set at index $i");
  //           // print(getSetKeyName(ex.linkName!, i));
  //           // print(cnRunningWorkout.groupedExercises[getSetKeyName(ex.linkName!, i)]);
  //           cnRunningWorkout.groupedExercises[getSetKeyName(ex.linkName!, i)].remove(ex.name);
  //           if(cnRunningWorkout.groupedExercises[getSetKeyName(ex.linkName!, i)].isEmpty()){
  //             // print("Delete whole GroupeedSet");
  //             cnRunningWorkout.groupedExercises.remove(getSetKeyName(ex.linkName!, i));
  //           }
  //           break;
  //         }
  //         // print("replace Set at index $i");
  //         NamedSet nextNamedSet = cnRunningWorkout.groupedExercises[getSetKeyName(ex.linkName!, i+1)].getSet(ex.name);
  //         nextNamedSet.index -= 1;
  //         cnRunningWorkout.groupedExercises[getSetKeyName(ex.linkName!, i)].set(nextNamedSet);
  //       }
  //       // print("");
  //     }
  //
  //
  //
  //     // cnRunningWorkout.groupedExercises.remove(getSetKeyName(ex.name, set.index));
  //     // String name = ex.linkName ?? ex.name;
  //     // cnRunningWorkout.groupedExercises.map((key, value) {
  //     //   if(key.split("_").first == name){
  //     //     if(value is NamedSet && value.index > set.index){
  //     //       print("Dismiss in single Exercise");
  //     //       value.index -= 1;
  //     //     }
  //     //     /// ToDo: not working properly
  //     //     else if(value is GroupedSet){
  //     //       NamedSet s = value._sets.firstWhere((set) => set.name == ex.name);
  //     //       if(s.index > set.index){
  //     //         print("Dismiss in grouped Exercise");
  //     //         s.index -= 1;
  //     //       }
  //     //     }
  //     //   }
  //     //   return MapEntry(key, value);
  //     // });
  //     // print("Länge nachher");
  //     // print(cnRunningWorkout.groupedExercises.length);
  //     //
  //     // final dismissedSet = ex.sets.removeAt(set.index);
  //     // final dismissedTemplateSet = lastEx.sets.removeAt(set.index);
  //
  //     // cnRunningWorkout.dismissedSets.add(
  //     //     DismissedSingleSet(
  //     //         linkName: ex.linkName,
  //     //         exName: ex.name,
  //     //         index: set.index,
  //     //         dismissedSet: dismissedSet,
  //     //         dismissedTemplateSet: dismissedTemplateSet,
  //     //         dismissedControllers: [set.weightController, set.amountController]
  //     //     )
  //     // );
  //   });
  //   cnRunningWorkout.cache();
  // }

  void undoDismiss(){
    // if(cnRunningWorkout.dismissedSets.isEmpty){
    //   return;
    // }
    // setState(() {
    //   final setsToInsert = cnRunningWorkout.dismissedSets.removeLast();
    //   final templateEx = cnRunningWorkout.workoutTemplateModifiable.exercises.where((element) => element.name == setsToInsert.exName).first;
    //   late Exercise newEx;
    //   if(setsToInsert.linkName != null){
    //     newEx = cnRunningWorkout.groupedExercises[setsToInsert.linkName].where((ex) => ex.name == setsToInsert.exName).first;
    //   } else{
    //     newEx = cnRunningWorkout.groupedExercises[setsToInsert.exName];
    //   }
    //   templateEx.sets.insert(setsToInsert.index, setsToInsert.dismissedTemplateSet);
    //   newEx.sets.insert(setsToInsert.index, setsToInsert.dismissedSet);
    //   if(setsToInsert.dismissedControllers != null){
    //     cnRunningWorkout.textControllers[setsToInsert.exName]?.insert(setsToInsert.index, setsToInsert.dismissedControllers!);
    //   } else{
    //     cnRunningWorkout.textControllers[setsToInsert.exName]?.insert(setsToInsert.index, [TextEditingController(), TextEditingController()]);
    //   }
    //   cnRunningWorkout.slideableKeys[setsToInsert.exName]?.insert(setsToInsert.index, UniqueKey());
    // });
    // cnRunningWorkout.cache();
  }

  /// Find the first indication of whether or not an Exercise has changed.
  ///
  /// Can be through:
  ///   - amount of sets
  ///   - weight
  ///   - amount
  ///   - rest in seconds
  ///   - seat level
  ///   - new Exercise added
  bool canUpdateTemplate(){
    Workout tempWo = Workout.clone(cnRunningWorkout.workout);
    tempWo.removeEmptyExercises();

    if(tempWo.exercises.isEmpty){
      return false;
    }

    /// Get exercises names of true template
    List<String> templateWorkoutExerciseNames = cnRunningWorkout.workoutTemplateNotModifiable.exercises.map((e) => e.name).toList();

    /// Iterate over every exercise in the current running (new) one
    for(Exercise ex in tempWo.exercises){
      /// Exercise name does not exist in true template yet => new exercise has been added => can update Template
      if(!templateWorkoutExerciseNames.contains(ex.name)){
        return true;
      }
      /// When the exercise name already exists, we check if the exercise of the true template and the current running one are truly the same
      Exercise tempTemplateEx = cnRunningWorkout.workoutTemplateNotModifiable.exercises.firstWhere((e) => e.name == ex.name);
      if(!tempTemplateEx.equals(ex)){
        return true;
      }
    }
    return false;
  }

  bool hasStartedWorkout(){
    Workout tempWo = Workout.clone(cnRunningWorkout.workout);
    tempWo.removeEmptyExercises();
    if(tempWo.exercises.isEmpty){
      return false;
    }
    return true;
  }

  void openPopUpFinishWorkout(){
    final bool canFinish = hasStartedWorkout();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        cancelButton: getActionSheetCancelButton(context, text: "Workout Fortsetzen"),
        title: Text(AppLocalizations.of(context)!.runningWorkoutFinishWorkout),
        actions: <Widget>[
          CupertinoActionSheetAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as delete or exit and turns
            /// the action's text color to red.
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              Future.delayed(const Duration(milliseconds: 250), (){
                openPopUpConfirmCancelWorkout();
              });
            },
            child: Text(AppLocalizations.of(context)!.runningWorkoutStopWorkout),
          ),
          if(canFinish)
            CupertinoActionSheetAction(
              /// This parameter indicates the action would perform
              /// a destructive action such as delete or exit and turns
              /// the action's text color to red.
              isDestructiveAction: false,
              onPressed: () {
                Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime), (){
                  setState(() {
                    cnRunningWorkout.checkMultipleExercisesPerLink();
                    if(cnRunningWorkout.linkWithMultipleExercisesStarted.isNotEmpty){
                      descendantNameExerciseToUpdate = "SelectorExercisePerLink";
                      selectorExercisePerLinkKey = UniqueKey();
                      controllerSelectorExercisePerLink = PanelController();
                      Future.delayed(const Duration(milliseconds: 100), (){
                        FocusManager.instance.primaryFocus?.unfocus();
                        controllerSelectorExercisePerLink.open();
                      });
                    } else{
                      descendantNameExerciseToUpdate = "ScreenRunningWorkout";
                      confirmSelectorExPerLink(delay: 0);
                    }
                  });
                });
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.finish),
            ),
        ],
      ),
    );
  }

  Widget getAddSetButton(Exercise newEx, Exercise templateEx){
    return Row(
      children: [
        Expanded(
          child: IconButton(
              alignment: Alignment.center,
              color: Colors.amber[800],
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(20)))
              ),
              onPressed: () {
                addSet(newEx, templateEx);
              },
              icon: const Icon(
                Icons.add,
                size: 20,
              )
          ),
        ),
      ],
    );
  }

  void openPopUpConfirmCancelWorkout() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        cancelButton: getActionSheetCancelButton(context, text: "Workout Fortsetzen"),
        title: Text(AppLocalizations.of(context)!.runningWorkoutStopWorkout),
        message: Text(AppLocalizations.of(context)!.runningWorkoutConfirmCancelWorkout),
        actions: <Widget>[
          CupertinoActionSheetAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as delete or exit and turns
            /// the action's text color to red.
            isDestructiveAction: true,
            onPressed: () {
              stopWorkout();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.runningWorkoutStopWorkout),
          ),
        ],
      ),
    );
  }

  Future stopWorkout({int? time})async{
    time = time?? cnStandardPopUp.animationTime;
    if(cnStandardPopUp.isVisible){
      cnStandardPopUp.clear();
    }
    await Future.delayed(Duration(milliseconds: time), ()async{
      cnRunningWorkout.isVisible = false;
      cnRunningWorkout.isRunning = false;
      cnHomepage.refresh();
      cnWorkouts.refresh();
      await Future.delayed(const Duration(milliseconds: 50), ()async{
        Navigator.of(context).pop();
        /// delayed that the pop context is finished, if to short, the user
        /// will se a blank page which is not wanted
        await Future.delayed(const Duration(milliseconds: 500), (){
          cnRunningWorkout.clear();
          if(cnStopwatchWidget.isRunning){
            cnStopwatchWidget.cancelTimer();
          }
        });
      });
    });
  }

  Future finishWorkout() async{
    int time = 0;

    setState(() {
      isSavingData = true;
    });


    await Future.delayed(const Duration(milliseconds: 300));
    if(controllerSelectorExerciseToUpdate.panelPosition > 0){
      await controllerSelectorExerciseToUpdate.close();
      time = 100;
    }
    if(controllerSelectorExercisePerLink.panelPosition > 0){
      await Future.delayed(Duration(milliseconds: time));
      await controllerSelectorExercisePerLink.close();
    }

    /// delay that the popup is closed
    await Future.delayed(const Duration(milliseconds: 100), ()async{
      cnRunningWorkout.workout.refreshDate();
      cnRunningWorkout.removeNotRelevantExercises();
      cnRunningWorkout.workout.removeEmptyExercises();
      if(cnRunningWorkout.workout.exercises.isNotEmpty){
        cnRunningWorkout.workout.saveToDatabase();
        cnWorkouts.refreshAllWorkouts();
      }
      if(cnStopwatchWidget.isRunning){
        cnStopwatchWidget.cancelTimer();
      }

      if(cnConfig.automaticBackups){
        await saveBackup(withCloud: cnConfig.saveBackupCloud, cnConfig: cnConfig) != null;
      }

      await saveCurrentData(cnConfig) != null;

      Fluttertoast.showToast(
          msg: "Workout erfolgreich abgeschlossen 🎉",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[800]?.withOpacity(0.9),
          textColor: Colors.white,
          fontSize: 16.0
      );
      vibrateSuccess();
      await stopWorkout(time: 0);
      isSavingData = false;
    });
  }

  Widget getSeatLevelSelector(Exercise newEx) {
    return SizedBox(
      height: 30,
      child: getSelectSeatLevel(
          currentSeatLevel: newEx.seatLevel,
          child: SizedBox(
            width: 100,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 100,
                height: 30,
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.airline_seat_recline_normal, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
                    const SizedBox(width: 2,),
                    if (newEx.seatLevel == null)
                      Text("-", style: _style,)
                    else
                      Text(newEx.seatLevel.toString(), style: _style,)
                  ],
                ),
              ),
            ),
          ),
          onConfirm: (dynamic value){
            if(value is int){
              newEx.seatLevel = value;
              cnRunningWorkout.refresh();
            }
            else if(value == AppLocalizations.of(context)!.clear){
              newEx.seatLevel = null;
              cnRunningWorkout.refresh();
            }
          },
        context: context
      ),
    );
  }

  getRestInSecondsSelector(Exercise newEx) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          getSelectRestInSeconds(
              currentTime: newEx.restInSeconds,
              context: context,
              child: SizedBox(
                width: 100,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(Icons.timer, size: _iconSize, color: Colors.amber[900]!.withOpacity(0.6),),
                      const SizedBox(width: 2,),
                      Text(mapRestInSecondsToString(restInSeconds: newEx.restInSeconds), style: _style),
                      const SizedBox(width: 10,)
                    ],
                  ),
                ),
              ),
              onConfirm: (dynamic value){
                if(value is int){
                  newEx.restInSeconds = value;
                  cnRunningWorkout.refresh();
                }
                else if(value == AppLocalizations.of(context)!.clear){
                  newEx.restInSeconds = 0;
                  cnRunningWorkout.refresh();
                }
                else{
                  showDialogMinuteSecondPicker(
                    context: context,
                    initialTimeDuration: Duration(minutes: newEx.restInSeconds~/60, seconds: newEx.restInSeconds%60),
                    onConfirm: (Duration newDuration){
                      newEx.restInSeconds = newDuration.inSeconds;
                    }
                  ).then((value) => setState(() {}));
                }
              }
          ),
          const Spacer()
        ],
      ),
    );
  }
}

class CnRunningWorkout extends ChangeNotifier {
  Workout workout = Workout();
  /// Modifiable Workout template
  /// Exercises can be delete
  Workout workoutTemplateModifiable = Workout();
  /// NOT Modifiable Workout template - for comparison what have changed
  Workout workoutTemplateNotModifiable = Workout();
  bool isRunning = false;
  bool isVisible = false;
  ScrollController scrollController = ScrollController();
  List<String> newExNames = [];
  late Map<String, List<Key>> slideableKeys = {
    for (var e in workout.exercises)
      e.name :
      e.generateKeyForEachSet()
  };
  // late Map<String, List<List<TextEditingController>>> textControllers = {
  //   for (var e in workout.exercises)
  //     e.name :
  //     e.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList()
  // };
  /// Contains all Exercises - linked and non linked ones - as a Map
  /// linked exercises are saved as another Map with key = linkName
  /// non linked Exercises are saved as the exercise itself with the ex.name as the key
  SplayTreeMap<String, dynamic> groupedExercises = SplayTreeMap();
  /// Contains for each linked exercise the currently selected index for getting the right one
  /// from the groupedExercises Map
  Map<String, int> selectedIndexes = {};
  late CnConfig cnConfig;
  List<String> linkWithMultipleExercisesStarted = [];
  List<String> exercisesToRemove = [];
  List<DismissedSingleSet> dismissedSets = [];
  double lastScrollPosition = 0;
  List<String> exerciseOrder = [];

  CnRunningWorkout(BuildContext context){
    cnConfig = Provider.of<CnConfig>(context, listen: false);
  }
  
  void addExercise(Exercise ex){
    workoutTemplateModifiable.exercises.add(Exercise.copy(ex));
    workout.exercises.add(ex);
    newExNames.add(ex.name);
    slideableKeys[ex.name] = ex.generateKeyForEachSet();
    SingleSet newSet = ex.sets.first;
    NamedSet newNamedSet = NamedSet(
        set: newSet,
        name: ex.name,
        index: 0,
        ex: ex,
        weightController: TextEditingController(text: (newSet.weightAsTrimmedDouble?? "").toString()),
        amountController: TextEditingController(text: (newSet.getAmountAsText(ex.category)?? "").toString())
    );
    if(ex.linkName == null){
      exerciseOrder.add(ex.name);
      groupedExercises[ex.name] = ex;
      groupedExercises[getSetKeyName(ex.name, 0)] = newNamedSet;
    }
    cache();
    refresh();
  }

  void deleteExercise(Exercise ex){
    workoutTemplateModifiable.exercises.removeWhere((e) => e.name == ex.name);
    dismissedSets.removeWhere((e) => e.exName == ex.name);
    workout.exercises.removeWhere((e) => e.name == ex.name);
    newExNames.removeWhere((e) => e == ex.name);
    slideableKeys.remove(ex.name);
    groupedExercises.remove(ex.name);
    refresh();
  }

  void initCachedData(Map data){
    if(
      data.containsKey("workout") &&
      data.containsKey("workoutTemplateModifiable") &&
      data.containsKey("workoutTemplateNotModifiable") &&
      data.containsKey("isRunning") &&
      data.containsKey("isVisible") &&
      // data.containsKey("testControllerValues") &&
      data.containsKey("selectedIndexes") &&
      data.containsKey("newExNames")
    ){
      isRunning = data["isRunning"];
      isVisible = data["isVisible"];
      newExNames = List<String>.from(data["newExNames"]);
      for(MapEntry entry in data["selectedIndexes"].entries){
        selectedIndexes[entry.key] = entry.value;
      }
      workout = Workout().fromMap(data["workout"]) ?? Workout();
      workoutTemplateModifiable = Workout().fromMap(data["workoutTemplateModifiable"]) ?? Workout();
      workoutTemplateNotModifiable = Workout().fromMap(data["workoutTemplateNotModifiable"]) ?? Workout();
      initSlideableKeys();
      initGroupedExercises();
      // initTextControllers();
      // setTextControllerValues(data["testControllerValues"]);
    }
  }

  void openRunningWorkout(BuildContext context, Workout w){
    setWorkoutTemplate(w);
    isRunning = true;
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => const ScreenRunningWorkout()
        ));
    isVisible = true;
    cache();
  }

  void reopenRunningWorkout(BuildContext context) async{
    HapticFeedback.selectionClick();
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => const ScreenRunningWorkout()
        ));

    // while(true){
    //   await Future.delayed(const Duration(milliseconds: 5), (){});
    //   if(scrollController.hasClients){
    //     print(scrollController.position.pixels);
    //     scrollController.jumpTo(lastScrollPosition);
    //     break;
    //   }
    // }
    isVisible = true;
    cache();
  }

  void removeNotRelevantExercises(){
    workout.exercises.removeWhere((ex) => exercisesToRemove.contains(ex.name));
  }

  void setWorkoutTemplate(Workout w){
    workoutTemplateModifiable = w;
    workout = Workout.copy(w);
    workoutTemplateNotModifiable = Workout.copy(w);
    workout.resetAllExercisesSets(keepSetType: true);
    initSlideableKeys();
    initSelectedIndexes();
    initGroupedExercises();
    // initTextControllers();
  }

  void initSlideableKeys(){
    slideableKeys = {
      for (var e in workout.exercises)
        e.name :
        e.generateKeyForEachSet()
    };
  }

  void initSelectedIndexes(){
    selectedIndexes = {
      for (String link in workout.linkedExercises)
        link:
        0
    };
  }

  void initGroupedExercises(){
    groupedExercises.clear();
    exerciseOrder.clear();

    for (Exercise ex in workout.exercises){

      /// single exercise
      if (ex.linkName == null){
        groupedExercises[ex.name] = ex;
        for(var i = 0; i < ex.sets.length; i++){
          groupedExercises[getSetKeyName(ex.name, i)] = NamedSet(
              set: ex.sets[i],
              name: ex.name,
              index: i,
              ex: ex,
              weightController: TextEditingController(text: (ex.sets[i].weightAsTrimmedDouble?? "").toString()),
              amountController: TextEditingController(text: (ex.sets[i].getAmountAsText(ex.category)?? "").toString())
          );
        }
        if(!exerciseOrder.contains(ex.name)){
          exerciseOrder.add(ex.name);
        }
      }

      /// linked exercise
      else{
        if(!groupedExercises.containsKey(ex.linkName)){
          groupedExercises[ex.linkName!] = GroupedExercise(ex: ex);
        }
        else{
          (groupedExercises[ex.linkName] as GroupedExercise).add(ex);
        }
        for(var i = 0; i < ex.sets.length; i++){
          NamedSet namedSet = NamedSet(
              set: ex.sets[i],
              name: ex.name,
              index: i,
              ex: ex,
              weightController: TextEditingController(text: (ex.sets[i].weightAsTrimmedDouble?? "").toString()),
              amountController: TextEditingController(text: (ex.sets[i].getAmountAsText(ex.category)?? "").toString())
          );
          final String keyName = getSetKeyName(ex.linkName??"", i);
          if(groupedExercises.containsKey(keyName)){
            (groupedExercises[keyName] as GroupedSet).add(namedSet);
          } else{
            groupedExercises[keyName] = GroupedSet(set: namedSet);
          }
        }
        if(!exerciseOrder.contains(ex.linkName)){
          exerciseOrder.add(ex.linkName!);
        }
      }

      if(exerciseOrder.last.split("_").last != "Separator"){
        exerciseOrder.add("${ex.linkName?? ex.name}_Separator");
        groupedExercises["${ex.linkName?? ex.name}_Separator"] = "Separator";
      }
    }

    int customComparator(String a, String b) {
      String aFirst = a.split("_").first;
      String bFirst = b.split("_").first;
      String aLast = a.split("_").last;
      String bLast = b.split("_").last;
      // print("");
      // print("AB");
      // print(a +""+ b);
      // print(aFirst);
      // print(bFirst);
      final indexA = exerciseOrder.indexOf(aFirst);
      final indexB = exerciseOrder.indexOf(bFirst);
      // print("INDEX");
      // print(indexA);
      // print(indexB);
      if(indexA == indexB){
        // print("EQUAL");
        // print(aLast);
        // print(bLast);
        // print(aLast.compareTo(bLast));
        if(aFirst == aLast && bFirst != bLast){
          // print("SMALLER");
          return -1;
        } else if(aFirst != aLast && bFirst == bLast){
          // print("BIGGER");
          return 1;
        }
        return aLast.compareTo(bLast);
      } else if(indexA > indexB){
        // print("BIGGER");
        return 1;
      } else{
        // print("SMALLER");
        return -1;
      }
    }
    SplayTreeMap<String, dynamic> rightOrderedGroupedExercises = SplayTreeMap<String, dynamic>(customComparator)..addAll(groupedExercises);
    groupedExercises = rightOrderedGroupedExercises;

    // for(MapEntry val in groupedExercises.entries){
    //   final t = val.value;
    //   print(val.key);
    //   if(t is GroupedExercise){
    //     print((t as GroupedExercise)._exercises);
    //   }
    //   else if(t is GroupedSet){
    //     print((t as GroupedSet)._sets.toString());
    //   } else{
    //     print(t.toString());
    //   }
    // }

    // groupedExercises.

    // for(MapEntry entry in groupedExercises.entries){
      // if(entry.value is List){
      //   (entry.value as List).sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      // }
    // }
  }

  // void initTextControllers(){
  //   textControllers = {
  //     for (var e in workout.exercises)
  //       e.name :
  //       e.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList()
  //   };
  // }

  Future<void> cache() async{
    Map data = {
      "workout": workout.asMap(),
      "workoutTemplateModifiable": workoutTemplateModifiable.asMap(),
      "workoutTemplateNotModifiable": workoutTemplateNotModifiable.asMap(),
      "isRunning": isRunning,
      "isVisible": isVisible,
      // "testControllerValues": getTextControllerValues(),
      "selectedIndexes": selectedIndexes,
      "newExNames": newExNames
    };
    cnConfig.config.cnRunningWorkout = data;
    await cnConfig.config.save();
  }

  // Map<String, List<dynamic>> getTextControllerValues(){
  //   return {
  //     for (MapEntry entry in textControllers.entries)
  //       entry.key :
  //       entry.value.map((controllers) => [controllers[0].text, controllers[1].text]).toList()
  //   };
  // }

  // void setTextControllerValues(Map<String, dynamic> textControllersValues){
  //   for (MapEntry entry in textControllersValues.entries){
  //     // textControllers[entry.key] = entry.value.map((e) => [TextEditingController(text: e[0]), TextEditingController(text: e[0])]).toList();
  //     textControllers[entry.key] = List<List<TextEditingController>>.from(entry.value.map((e) => [TextEditingController(text: e[0]), TextEditingController(text: e[1])]));
  //   }
  // }

  NamedSet? removeSpecificSetFromExercise(NamedSet set){
    NamedSet? removedSet;
    Exercise ex = set.ex;
    final oldSetsAmount = ex.sets.length;

    set.ex.sets.removeAt(set.index);
    Exercise? templateEx = workoutTemplateModifiable.exercises.where((exercise) => exercise.name == set.ex.name).firstOrNull;
    SingleSet? removedTemplateSet = templateEx?.sets.removeAt(set.index);

    if(ex.linkName == null){
      removedSet = groupedExercises[getSetKeyName(ex.name, set.index)];
      for(int i = set.index; i <= (oldSetsAmount-1); i++){
        if(i == oldSetsAmount-1){
          groupedExercises.remove(getSetKeyName(ex.name, i));
          break;
        }
        NamedSet nextNamedSet = groupedExercises[getSetKeyName(ex.name, i+1)];
        nextNamedSet.index -= 1;
        groupedExercises[getSetKeyName(ex.name, i)] = nextNamedSet;
      }
    }
    else {
      removedSet = groupedExercises[getSetKeyName(ex.linkName!, set.index)].getSet(ex.name);
      for(int i = set.index; i <= (oldSetsAmount-1); i++){
        if(i == oldSetsAmount-1){
          groupedExercises[getSetKeyName(ex.linkName!, i)].remove(ex.name);
          if(groupedExercises[getSetKeyName(ex.linkName!, i)].isEmpty()){
            groupedExercises.remove(getSetKeyName(ex.linkName!, i));
          }
          break;
        }
        NamedSet nextNamedSet = groupedExercises[getSetKeyName(ex.linkName!, i+1)].getSet(ex.name);
        nextNamedSet.index -= 1;
        groupedExercises[getSetKeyName(ex.linkName!, i)].set(nextNamedSet);
      }
    }
    removedSet?.templateSet = removedTemplateSet;
    return removedSet;
  }

  void addSpecificSetToExercise(NamedSet set){
    Exercise ex = set.ex;
    final oldSetsAmount = ex.sets.length;
    ex.sets.insert(set.index, set.set);

    Exercise? templateEx = workoutTemplateModifiable.exercises.where((exercise) => exercise.name == set.ex.name).firstOrNull;
    templateEx?.sets.insert(set.index, set.templateSet?? SingleSet());

    if(ex.linkName == null){
      for(int i = oldSetsAmount; i >= set.index; i--){
        if(i == set.index){
          groupedExercises[getSetKeyName(ex.name, i)] = set;
          break;
        }
        NamedSet previousNamedSet = groupedExercises[getSetKeyName(ex.name, i-1)];
        previousNamedSet.index += 1;
        groupedExercises[getSetKeyName(ex.name, i)] = previousNamedSet;
      }
    }
    else {
      for(int i = oldSetsAmount; i >= set.index; i--){
        if(i == set.index){
          if(groupedExercises.containsKey(getSetKeyName(ex.linkName!, i))){
            groupedExercises[getSetKeyName(ex.linkName!, i)].set(set);
          } else{
            groupedExercises[getSetKeyName(ex.linkName!, i)] = GroupedSet(set: set);
          }
          break;
        }
        NamedSet previousNamedSet = groupedExercises[getSetKeyName(ex.linkName!, i-1)].getSet(ex.name);
        previousNamedSet.index += 1;
        if(groupedExercises.containsKey(getSetKeyName(ex.linkName!, i))){
          groupedExercises[getSetKeyName(ex.linkName!, i)].set(previousNamedSet);
        } else{
          groupedExercises[getSetKeyName(ex.linkName!, i)] = GroupedSet(set: previousNamedSet);
        }
      }
    }
  }

  void checkMultipleExercisesPerLink(){
    Map<String, int> linkCounter = {};
    Workout tempWo = Workout.clone(workout);
    tempWo.removeEmptyExercises();
    for(Exercise ex in tempWo.exercises){
      if(ex.linkName == null){
        continue;
      }
      if(linkCounter.containsKey(ex.linkName)){
        linkCounter[ex.linkName!] = linkCounter[ex.linkName]! + 1;
      } else{
        linkCounter[ex.linkName!] = 1;
      }
    }
    linkCounter.removeWhere((key, value) => value <= 1);
    linkWithMultipleExercisesStarted = linkCounter.entries.map((e) => e.key).toList();
  }

  void clear(){
    lastScrollPosition = 0;
    workout = Workout();
    // textControllers.clear();
    slideableKeys.clear();
    selectedIndexes.clear();
    groupedExercises.clear();
    exercisesToRemove.clear();
    dismissedSets.clear();
    newExNames.clear();
    linkWithMultipleExercisesStarted.clear();
    scrollController = ScrollController();
    isRunning = false;
    cnConfig.setCnRunningWorkout({});
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}

class GroupedExercise{
  List<Exercise> _exercises = [];

   GroupedExercise({required Exercise ex}){
     _exercises.add(ex);
   }

   Exercise? getExercise(int index){
     if(index > _exercises.length-1){
       return null;
     }
     return _exercises[index];
   }

   void add(Exercise ex){
     _exercises.add(ex);
   }

   List<Exercise> get exercises => _exercises;
}

class NamedSet{
  final String name;
  final SingleSet set;
  SingleSet? templateSet;
  int index;
  final Exercise ex;
  final TextEditingController weightController;
  final TextEditingController amountController;
  final UniqueKey key = UniqueKey();

  NamedSet({
    required this.set,
    required this.name,
    required this.index,
    required this.ex,
    required this.weightController,
    required this.amountController,
    this.templateSet
  });

}

class GroupedSet{
  final Map<String, NamedSet> _sets = {};

  GroupedSet({required NamedSet set}){
    _sets[set.name] = set;
  }

  NamedSet? getSet(String exName){
    return _sets[exName];
  }

  void add(NamedSet set){
    _sets[set.name] = set;
  }

  void set(NamedSet set){
    _sets[set.name] = set;
  }

  NamedSet? remove(String key){
    NamedSet? s = _sets.remove(key);
    return s;
  }

  isEmpty(){
    return _sets.isEmpty;
  }
}