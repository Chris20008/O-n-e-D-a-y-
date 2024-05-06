import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../../main.dart';
import '../../../../objects/exercise.dart';
import '../../../../objects/workout.dart';
import '../../../../util/constants.dart';
import '../../../../widgets/bottom_menu.dart';
import '../../../../widgets/exercise_row.dart';
import '../../../../widgets/spotify_bar.dart';
import '../../../../widgets/standard_popup.dart';
import '../../screen_workout_history/screen_workout_history.dart';
import '../../../screen_running_workout/screen_running_workout.dart';
import '../screen_workouts.dart';
import 'new_exercise_panel.dart';

class NewWorkOutPanel extends StatefulWidget {
  const NewWorkOutPanel({super.key});

  @override
  State<NewWorkOutPanel> createState() => _NewWorkOutPanelState();
}

class _NewWorkOutPanelState extends State<NewWorkOutPanel> {
  late CnNewWorkOutPanel cnNewWorkout;
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  late CnNewExercisePanel cnNewExercisePanel = Provider.of<CnNewExercisePanel>(context, listen: false);
  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnWorkoutHistory cnWorkoutHistory = Provider.of<CnWorkoutHistory>(context, listen: false);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  final _formKey = GlobalKey<FormState>();
  final deleteWorkoutKey = GlobalKey();
  final addLinkKey = GlobalKey();

  // This function displays a CupertinoModalPopup with a reasonable fixed height
  // which hosts CupertinoDatePicker.
  void _showDialog(Widget child) async {
    HapticFeedback.selectionClick();
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system
        // navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (doPop){
        if (cnNewWorkout.panelController.isPanelOpen && !cnNewExercisePanel.panelController.isPanelOpen){
          cnNewWorkout.panelController.close();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints){
          return SlidingUpPanel(
            controller: cnNewWorkout.panelController,
            defaultPanelState: PanelState.CLOSED,
            maxHeight: constraints.maxHeight - 50,
            // maxHeight: constraints.maxHeight,
            minHeight: cnNewWorkout.minPanelHeight,
            isDraggable: true,
            borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
            backdropEnabled: true,
            backdropColor: Colors.black,
            color: Colors.transparent,
            onPanelSlide: onPanelSlide,
            panel: ClipRRect(
              borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
              child: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Color(0xff160d05),
                          Color(0xff0a0604),
                        ]
                    )
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    if(cnNewWorkout.panelController.isPanelClosed){
                      HapticFeedback.selectionClick();
                      cnNewWorkout.panelController.open();
                    }
                  },
                  child: Stack(
                    children: [
                      Container(
                        // padding: const EdgeInsets.only(bottom: 0, right: 20.0, left: 20.0, top: 10),
                        height: double.maxFinite,
                        width: double.maxFinite,
                        color: Colors.transparent,
                        child: Stack(
                          children: [
                            ListView(
                              controller: cnNewWorkout.scrollController,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 0, right: 20.0, left: 20.0),
                              shrinkWrap: true,
                              children: [
                                SizedBox(height: cnNewWorkout.workout.isTemplate? 210 : 150,),
                                /// Exercises and Links
                                ReorderableListView(
                                    scrollController: ScrollController(),
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.all(0),
                                    shrinkWrap: true,
                                    onReorder: (int oldIndex, int newIndex){
                                      setState(() {
                                        if (oldIndex < newIndex) {
                                          newIndex -= 1;
                                        }
                                        final item = cnNewWorkout.exercisesAndLinks.removeAt(oldIndex);
                                        cnNewWorkout.exercisesAndLinks.insert(newIndex, item);
                                        cnNewWorkout.updateExercisesLinks();
                                      });
                                    },
                                    children: [
                                      for(int index = 0; index < cnNewWorkout.exercisesAndLinks.length; index+=1)
                                        if(cnNewWorkout.exercisesAndLinks[index] is Exercise)
                                          getExerciseWithSlideActions(index)
                                        else if(cnNewWorkout.exercisesAndLinks[index] is String)
                                          getLinkWithSlideActions(index)
                                    ]
                                ),
                                getAddExerciseButton()
                              ],
                            ),
                            getHeader(),
                          ],
                        ),
                      ),

                      /// faded box bottom screen
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          height: 70,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Positioned(
                                bottom: 14.8,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 55,
                                  decoration: const BoxDecoration(
                                      gradient:  LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black,
                                          ]
                                      )
                                  ),
                                ),
                              ),
                              Container(
                                height: 15,
                                color: Colors.black,
                              ),
                              /// bottom row with icons
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20, left: 30, right: 30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    myIconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: onCancel
                                    ),
                                    if(cnNewWorkout.isUpdating)
                                      myIconButton(
                                        key: deleteWorkoutKey,
                                        icon:const Icon(Icons.delete_forever),
                                        onPressed: (){
                                          cnStandardPopUp.open(
                                              context: context,
                                              child: const Text(
                                                "Do you really want to delete this workout?",
                                                textAlign: TextAlign.center,
                                                textScaler: TextScaler.linear(1.2),
                                                style: TextStyle(color: Colors.white),
                                              ),
                                              onConfirm: onDelete,
                                              onCancel: (){},
                                              animationKey: deleteWorkoutKey,
                                              color: const Color(0xff2d2d2d)
                                            // pos: Offset(position.dx + width/2, position.dy + height/2)
                                          );
                                        },
                                      ),
                                    myIconButton(
                                        icon: const Icon(Icons.check),
                                        onPressed: onConfirm
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getAddExerciseButton(){
    return Padding(
      padding: EdgeInsets.only(
          top: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom > 0? MediaQuery.of(context).viewInsets.bottom : 80
      ),
      child: Row(
        children: [
          Expanded(
            child: IconButton(
                color: Colors.amber[800],
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(20)))
                ),
                onPressed: () {
                  addExercise();
                },
                icon: const Icon(
                  Icons.add,
                  size: 20,
                )
            ),
          ),
        ],
      ),
    );
  }

  Widget getHeader(){
    return ClipRRect(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 0, right: 20.0, left: 20.0, top: 10),
            color: const Color(0xff0a0604),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Column(
                      children: [
                        Container(
                          height: 2,
                          width: 40,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(2)
                          ),
                        ),
                        const SizedBox(height: 15,),
                        if(cnNewWorkout.workout.isTemplate)
                          const Text("Workout Template", textScaler: TextScaler.linear(1.5)),
                        if(cnNewWorkout.workout.isTemplate)
                          const SizedBox(height: 10,),
                      ],
                    ),
                    /// Button to completely close workout when it is minimized
                    /// currently not working in first build, because panelController is then not attached
                    // if (cnNewWorkout.panelController.isPanelClosed)
                    //   Align(
                    //     alignment: Alignment.centerRight,
                    //     child: IconButton(
                    //         onPressed: onCancel,
                    //         icon: const Icon(Icons.close)
                    //     ),
                    //   )
                  ],
                ),
                if(cnNewWorkout.workout.isTemplate)
                  Row(
                    children: [
                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              value = value?.trim();
                              if (value == null || value.isEmpty) {
                                return 'Enter Workout name';
                              }
                              /// Check if the workout name already exists, but only when the current name is different from the
                              /// initializing name. Otherwise editing an existing workout could lead to error
                              else if(workoutNameExistsInTemplates(workoutName: cnNewWorkout.workout.name) &&
                                        cnNewWorkout.workout.name != cnNewWorkout.originalWorkout.name
                              ){
                                return 'Workout name already exists';
                              }
                              return null;
                            },
                            onTap: (){
                              if(cnNewWorkout.panelController.isPanelClosed){
                                Future.delayed(const Duration(milliseconds: 300), (){
                                  HapticFeedback.selectionClick();
                                  cnNewWorkout.panelController.open();
                                });
                              }
                            },
                            style: const TextStyle(
                              fontSize: 20
                            ),
                            controller: cnNewWorkout.workoutNameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              labelText: 'Name',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8 ,vertical: 0.0),
                            ),
                            onChanged: (value){
                              cnNewWorkout.workout.name = value;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 5,),
                      if(cnNewWorkout.workout.isTemplate)
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: IconButton(
                            icon: const Icon(Icons.add_link, color: Color(0xFF5F9561)),
                            key: addLinkKey,
                            onPressed: ()async{
                              if(cnNewWorkout.panelController.isPanelClosed){
                                HapticFeedback.selectionClick();
                                await cnNewWorkout.panelController.open();
                              }
                              cnStandardPopUp.open(
                                  context: context,
                                  child: TextField(
                                    maxLength: 15,
                                    // textAlignVertical: TextAlignVertical.center,
                                    keyboardType: TextInputType.text,
                                    keyboardAppearance: Brightness.dark,
                                    controller: cnNewWorkout.linkNameController,
                                    style: const TextStyle(
                                        fontSize: 20
                                    ),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      isDense: true,
                                      labelText: 'Group Name',
                                      counterText: "",
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8 ,vertical: 8.0),
                                    ),
                                    onChanged: (value){},
                                  ),
                                  onConfirm: (){
                                    bool added = false;
                                    final linkName = cnNewWorkout.linkNameController.text;
                                    if(linkName.isNotEmpty && !cnNewWorkout.workout.linkedExercises.contains(linkName)){
                                      added = true;
                                      cnNewWorkout.workout.linkedExercises.add(linkName);
                                      cnNewWorkout.updateExercisesAndLinksList();
                                      cnNewWorkout.updateExercisesLinks();
                                      cnNewWorkout.refresh();
                                    }
                                    cnNewWorkout.linkNameController.clear();
                                    Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime*2), (){
                                      FocusScope.of(context).unfocus();
                                      /// Scrolling to maxScrollExtend not working properly, overshoots
                                      // if(added){
                                      //   print("POSITION SCROLL CONTROLLER");
                                      //   print(cnNewWorkout.scrollController.position.pixels);
                                      //   cnNewWorkout.scrollController.animateTo(
                                      //       cnNewWorkout.scrollController.position.maxScrollExtent,
                                      //       duration: const Duration(milliseconds: 500),
                                      //       curve: Curves.easeInOut);
                                      // }
                                    });
                                  },
                                  onCancel: (){
                                    cnNewWorkout.linkNameController.clear();
                                    Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime*2), (){
                                      FocusScope.of(context).unfocus();
                                    });
                                  },
                                  animationKey: addLinkKey,
                                  color: const Color(0xff2d2d2d)
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                        )
                    ],
                  ),
                // else
                //   OverflowSafeText(
                //     cnNewWorkout.workout.name,
                //     maxLines: 1,
                //     fontSize: 25
                //   ),
                if(!cnNewWorkout.workout.isTemplate)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: OverflowSafeText(
                              cnNewWorkout.workout.name,
                              maxLines: 1,
                              fontSize: 25
                          ),
                        ),
                        // const Text('Date', textScaler: TextScaler.linear(1.5),),
                        if(cnNewWorkout.workout.date != null)
                          CupertinoButton(
                            onPressed: () async{
                              if(cnNewWorkout.panelController.isPanelClosed){
                                HapticFeedback.selectionClick();
                                await cnNewWorkout.panelController.open();
                              }
                              _showDialog(
                                CupertinoDatePicker(
                                  initialDateTime: cnNewWorkout.workout.date,
                                  mode: CupertinoDatePickerMode.dateAndTime,
                                  use24hFormat: true,
                                  showDayOfWeek: true,
                                  onDateTimeChanged: (DateTime newDate) {
                                    // cnNewWorkout.workout.date = newDate;
                                    cnNewWorkout.workout.date = newDate;
                                    if(Platform.isAndroid){
                                      HapticFeedback.selectionClick();
                                    }
                                  },
                                ),
                              );
                            },
                            child: Text(
                              DateFormat('EEEE d. MMMM', Localizations.localeOf(context).languageCode).format(cnNewWorkout.workout.date!),
                              // '${cnNewWorkout.workout.date!.month}-${cnNewWorkout.workout.date!.day}-${cnNewWorkout.workout.date!.year}',
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  const SizedBox(height: 25,),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2)
                  ),
                ),
                Container(height: 15,),
                const Text("Exercises", textScaler: TextScaler.linear(1.2)),
                Container(height: 16,),
                // const Text("", textScaler: TextScaler.linear()0.5)
                // Container(height: 0, color: Color(0xff0a0604),),
              ],
            ),
          ),
          Container(
            height: 25,
            decoration: const BoxDecoration(
                gradient:  LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.transparent,
                      Color(0xff0a0604),
                    ]
                )
            ),
          ),
        ],
      ),
    );
  }

  Widget getLinkWithSlideActions(int index){
    return Slidable(
        key: UniqueKey(),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          dismissible: DismissiblePane(
              onDismissed: () {dismissLink(cnNewWorkout.exercisesAndLinks[index]);
              }),
          children: [
            SlidableAction(
              flex:10,
              onPressed: (BuildContext context){
                dismissLink(cnNewWorkout.exercisesAndLinks[index]);
              },
              borderRadius: BorderRadius.circular(15),
              backgroundColor: const Color(0xFFA12D2C),
              foregroundColor: Colors.white,
              icon: Icons.delete,
            ),
            SlidableAction(
              flex: 1,
              onPressed: (BuildContext context){},
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.transparent,
              label: '',
            ),
          ],
        ),
        child: SizedBox(
          width: double.maxFinite,
          height: 30,
          child: Row(
            key: UniqueKey(),
            children: [
              Container(
                height: 25,
                width: 3,
                decoration: BoxDecoration(
                    color: (cnNewWorkout.getLinkColor(cnNewWorkout.exercisesAndLinks[index])?? Colors.grey).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10)
                ),
              ),
              const SizedBox(
                width: 7,
              ),
              Expanded(
                child: SizedBox(
                  // padding: EdgeInsets.all(2),
                  height: 30,
                  child: AutoSizeText(cnNewWorkout.exercisesAndLinks[index], textScaleFactor: 1.7, maxLines: 1,),
                ),
              ),
            ],
          ),
        )
    );
  }

  Widget getExerciseWithSlideActions(int index){
    return Slidable(
      key: UniqueKey(),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(
            onDismissed: () {dismissExercise(cnNewWorkout.exercisesAndLinks[index]);
            }),
        children: [
          SlidableAction(
            flex:10,
            onPressed: (BuildContext context){
              dismissExercise(cnNewWorkout.exercisesAndLinks[index]);
            },
            borderRadius: BorderRadius.circular(15),
            backgroundColor: const Color(0xFFA12D2C),
            foregroundColor: Colors.white,
            icon: Icons.delete,
          ),
          SlidableAction(
            flex: 1,
            onPressed: (BuildContext context){},
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.transparent,
            label: '',
          ),
        ],
      ),

      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        // dismissible: DismissiblePane(
        //     confirmDismiss: ()async {
        //       openExercise(cnNewWorkout.exercisesAndLinks[index]);
        //       return false;
        //     },
        //     onDismissed: () {}
        // ),
        children: [
          SlidableAction(
            flex: 1,
            onPressed: (BuildContext context){},
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.transparent,
            label: '',
          ),
          SlidableAction(
            padding: const EdgeInsets.all(0),
            flex:10,
            onPressed: (BuildContext context){
              openExercise(cnNewWorkout.exercisesAndLinks[index], copied: true);
            },
            borderRadius: BorderRadius.circular(15),
            backgroundColor: const Color(0xFF617EB1),
            // backgroundColor: Colors.white.withOpacity(0.1),
            foregroundColor: Colors.white,
            icon: Icons.copy,
          ),
          SlidableAction(
            flex: 1,
            onPressed: (BuildContext context){},
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.transparent,
            label: '',
          ),
          SlidableAction(
            padding: const EdgeInsets.all(0),
            flex:10,
            onPressed: (BuildContext context){
              openExercise(cnNewWorkout.exercisesAndLinks[index]);
            },
            borderRadius: BorderRadius.circular(15),
            backgroundColor: const Color(0xFFAE7B32),
            // backgroundColor: Colors.white.withOpacity(0.1),
            foregroundColor: Colors.white,
            icon: Icons.edit,
          ),
        ],
      ),
      child: SizedBox(
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ExerciseRow(
              exercise: cnNewWorkout.exercisesAndLinks[index],
              padding: const EdgeInsets.only(left: 20, right: 10, bottom: 5, top: 5),
            ),
            if ((cnNewWorkout.exercisesAndLinks[index] as Exercise).linkName != null)
              Row(
                children: [
                  const SizedBox(width: 10,),
                  Container(
                    width: 3,
                    height: 50,
                    decoration: BoxDecoration(
                        color: (cnNewWorkout.getLinkColor((cnNewWorkout.exercisesAndLinks[index] as Exercise).linkName!)?? Colors.grey).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  void dismissExercise(Exercise ex){
    cnNewWorkout.workout.exercises.remove(ex);
    cnNewWorkout.updateExercisesAndLinksList();
    cnNewWorkout.refresh();
  }

  void dismissLink(String linkName){
    cnNewWorkout.workout.linkedExercises.remove(linkName);
    cnNewWorkout.updateExercisesAndLinksList();
    cnNewWorkout.updateExercisesLinks();
    cnNewWorkout.refresh();
  }

  void addExercise(){
    if(cnNewWorkout.panelController.isPanelOpen){
      cnNewExercisePanel.openPanel(workout: cnNewWorkout.workout, onConfirm: confirmAddExercise);
    }
  }

  void addLink(String linkName){
    if (cnNewWorkout.workout.linkedExercises.contains(linkName)) {
      linkName = "Curls";
    }
    if (cnNewWorkout.workout.linkedExercises.contains(linkName)){
      return;
    }
    cnNewWorkout.workout.linkedExercises.add(linkName);
    cnNewWorkout.updateExercisesAndLinksList();
    cnNewWorkout.updateExercisesLinks();
    cnNewWorkout.refresh();
  }

  void openExercise(Exercise ex, {bool copied = false}){
    /// Clone exercise to prevent directly change settings in original exercise before saving
    /// f.e. when user goes back or just slides down panel
    Exercise clonedEx = Exercise.clone(ex);

    if(copied) {
      /// If copied means a copy of the original exercise is made to create a completely new exercise
      clonedEx.name = "";
    } else {
      /// Otherwise the user is editing the exercise so we keep track of the origina name in case
      /// the user changes the exercises name
      clonedEx.originalName = ex.name;
    }

    if(cnNewWorkout.panelController.isPanelOpen){
      // cnNewExercisePanel.setExercise(clonedEx);
      cnNewExercisePanel.openPanel(workout: cnNewWorkout.workout, exercise: clonedEx, onConfirm: confirmAddExercise);
      cnNewExercisePanel.refresh();
    }
  }

  void confirmAddExercise(Exercise ex){
    cnNewWorkout.workout.addOrUpdateExercise(ex);
    cnNewWorkout.refreshExercise(ex);
    cnNewWorkout.updateExercisesAndLinksList();
    cnNewWorkout.updateExercisesLinks();
    cnNewWorkout.refresh();
  }

  void onCancel(){
    vibrateCancel();
    cnNewWorkout.closePanel(doClear: true);
    cnNewExercisePanel.clear();
    _formKey.currentState?.reset();
  }

  void onDelete(){
    cnNewWorkout.workout.deleteFromDatabase();
    cnWorkouts.refreshAllWorkouts();
    cnWorkoutHistory.refreshAllWorkouts();
    cnNewWorkout.closePanel(doClear: true);
    cnNewExercisePanel.clear();
  }

  void onConfirm(){
    if (_formKey.currentState!.validate()){
      vibrateConfirm();
      cnNewWorkout.updateExercisesOrderInWorkoutObject();
      if(!cnNewWorkout.isUpdating){
        cnNewWorkout.workout.isTemplate = true;
      }
      cnNewWorkout.removeEmptyLinksFromWorkout();
      cnNewWorkout.workout.saveToDatabase();
      cnWorkouts.refreshAllWorkouts();
      cnWorkoutHistory.refreshAllWorkouts();
      cnNewWorkout.closePanel(doClear: true);
      cnNewExercisePanel.clear();
      _formKey.currentState?.reset();
    }
  }

  void onPanelSlide(value){
    cnBottomMenu.positionYAxis = cnBottomMenu.height * value;
    // if(value >= 0.8){
    //   if(cnSpotifyBar.isVisible){
    //     // cnSpotifyBar.setVisibility(false);
    //   }
    // }
    // if(value <= 0.2){
    //   if(!cnSpotifyBar.isVisible){
    //     // cnSpotifyBar.setVisibility(true);
    //   }
    // }
    // if(value < 0.05 && !cnBottomMenu.isVisible){
    //   SystemChrome.setPreferredOrientations([]);
    //
    // }
    // else if(value > 0.05 && cnBottomMenu.isVisible){
    // }
    if(value == 0 || value == 1){
      cnNewWorkout.refresh();
      FocusScope.of(context).unfocus();
    }
    cnBottomMenu.refresh();
  }

}

class CnNewWorkOutPanel extends ChangeNotifier {
  final PanelController panelController = PanelController();
  Workout workout = Workout();
  Workout originalWorkout = Workout();
  TextEditingController workoutNameController = TextEditingController();
  TextEditingController linkNameController = TextEditingController();
  bool isUpdating = false;
  ScrollController scrollController = ScrollController();
  List<dynamic> exercisesAndLinks = [];
  List<Color> linkColors = [
    const Color(0xFF5F9561),
    const Color(0xFFFFEA30),
    const Color(0xFF558FDF),
    const Color(0xFFF48E40),
    const Color(0xFFA349D1),
    const Color(0xFF8AEAC3),
    const Color(0xFF4F8447),
  ];
  double minPanelHeight = 0;
  bool isCurrentlyRebuilding = false;
  double keepShowingPanelHeightTemplate = Platform.isAndroid? 180 : 212; //212;
  double keepShowingPanelHeightNonTemplate = Platform.isAndroid? 130 : 155;
  late CnHomepage cnHomepage;
  late CnWorkouts cnWorkouts;
  late CnWorkoutHistory cnWorkoutHistory;

  CnNewWorkOutPanel(BuildContext context){
    cnHomepage = Provider.of<CnHomepage>(context, listen: false);
    cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
    cnWorkoutHistory = Provider.of<CnWorkoutHistory>(context, listen: false);
  }

  void delayedRefresh() async{
    if (isCurrentlyRebuilding) return;
    isCurrentlyRebuilding = true;
    refresh();
    await Future.delayed(const Duration(milliseconds: 100), () {});
    isCurrentlyRebuilding = false;
  }

  Color? getLinkColor(String linkName){
    int index = workout.linkedExercises.indexOf(linkName);
    if(index >= 0){
      return linkColors[index % linkColors.length];
    }
    return null;
  }

  void openPanel(){
    HapticFeedback.selectionClick();
    minPanelHeight = workout.isTemplate? keepShowingPanelHeightTemplate : keepShowingPanelHeightNonTemplate;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    panelController.animatePanelToPosition(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut
    );
    refresh();
    cnHomepage.refresh();
    cnWorkouts.refresh();
    cnWorkoutHistory.refresh();
  }

  void addToExercisesAndLinksList(dynamic item){
    exercisesAndLinks.add(item);
  }

  void deleteFromExercisesAndLinksList(dynamic item){
    exercisesAndLinks.remove(item);
  }

  void updateExercisesAndLinksList(){
    /// Updates the exercisesAndLinksList which is responsible for showing showing the exercises and links together in new_workout_panel
    Set itemsToRemove = {};
    Set itemsToAdd = {};
    for(dynamic item in exercisesAndLinks){
      if(item is Exercise && !workout.exercises.map((e) => e.name).contains(item.name)){
        itemsToRemove.add(item);
      }
      else if(item is String && !workout.linkedExercises.contains(item)){
        itemsToRemove.add(item);
      }
    }
    for(Exercise ex in workout.exercises){
      if(!exercisesAndLinks.whereType<Exercise>().map((e) => e.name).contains(ex.name)){
        itemsToAdd.add(ex);
      }
    }
    for(final linkName in workout.linkedExercises){
      if(!exercisesAndLinks.contains(linkName)){
        itemsToAdd.add(linkName);
      }
    }
    for (var element in itemsToRemove) {
      exercisesAndLinks.remove(element);
    }
    exercisesAndLinks.addAll(itemsToAdd);
    exercisesAndLinks = List.from(exercisesAndLinks.toSet());
  }

  void initializeCorrectOrder(){
    final List<String> links = exercisesAndLinks.whereType<String>().toList();
    for (final link in links){
      exercisesAndLinks.remove(link);
      final index = exercisesAndLinks.indexWhere((element) => element is Exercise && element.linkName == link);
      if(index >= 0){
        exercisesAndLinks.insert(index, link);
      }
    }
  }

  void refreshExercise(Exercise ex){
    final index = exercisesAndLinks.indexWhere((element) => element is Exercise && (element.name == ex.originalName || element.name == ex.name));
    if(index >= 0){
      exercisesAndLinks.removeAt(index);
      exercisesAndLinks.insert(index, ex);
    }
  }

  void updateExercisesOrderInWorkoutObject(){
    // List tempCopy = List.from(exercisesAndLinks);
    List<Exercise> orderedExercises = exercisesAndLinks.whereType<Exercise>().toList();
    // List<Exercise> orderedExercises = List<Exercise>.from(tempCopy.where((element) => element is Exercise).toList());
    workout.exercises.clear();
    workout.exercises.addAll(orderedExercises);
  }

  void removeEmptyLinksFromWorkout(){
    workout.linkedExercises = workout.linkedExercises.where((linkName) {
      return workout.exercises.any((exercise) => exercise.linkName == linkName);
    }).toList();
  }

  void updateExercisesLinks(){
    /// Gives the exercises their correct linkName, if they need one, otherwise null
    String currentLinkName = "";
    for(dynamic item in exercisesAndLinks){
      if(item is Exercise){
        if(currentLinkName.isEmpty){
          item.linkName = null;
          continue;
        }
        else{
          item.linkName = currentLinkName;
        }
      }
      else{
        currentLinkName = item;
      }
    }
  }

  void closePanel({bool doClear = false}){
    minPanelHeight = 0;
    refresh();
    Future.delayed(const Duration(milliseconds: 50), (){
      panelController.animatePanelToPosition(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut
      ).then((value) => {
        SystemChrome.setPreferredOrientations([]),
        if(doClear){
          clear()
        }
      });
    });
    cnHomepage.refresh();
    cnWorkouts.refresh();
    cnWorkoutHistory.refresh();
  }

  void editWorkout(Workout workout){
    Workout w = Workout.clone(workout);
    if(isUpdating && this.workout.id == w.id){
      openPanel();
    }
    else{
      clear(doRefresh: false);
      isUpdating = true;
      setWorkout(w);
      updateExercisesAndLinksList();
      initializeCorrectOrder();
      openPanel();
    }
  }

  void setWorkout(Workout w){
    workout = w;
    originalWorkout = Workout.clone(w);
    workoutNameController = TextEditingController(text: w.name);
  }

  void clear({bool doRefresh = true}){
    workout = Workout();
    originalWorkout = Workout();
    // workout.isTemplate = true;
    workoutNameController = TextEditingController();
    linkNameController = TextEditingController();
    isUpdating = false;
    exercisesAndLinks = [];
    if(doRefresh){
      refresh();
    }
  }

  void refresh(){
    notifyListeners();
  }
}
