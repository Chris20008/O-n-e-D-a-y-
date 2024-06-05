import 'dart:io';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/util/backup_functions.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:fitness_app/widgets/tutorials/tutorial_add_exercise.dart';
import 'package:fitness_app/widgets/tutorials/tutorial_explain_exercise_drag_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../../main.dart';
import '../../../../objects/exercise.dart';
import '../../../../objects/workout.dart';
import '../../../../util/constants.dart';
import '../../../../util/objectbox/ob_workout.dart';
import '../../../../widgets/bottom_menu.dart';
import '../../../../widgets/exercise_row.dart';
import '../../../../widgets/spotify_bar.dart';
import '../../../../widgets/standard_popup.dart';
import '../../../other_screens/screen_running_workout/screen_running_workout.dart';
import '../../screen_workout_history/screen_workout_history.dart';
import '../screen_workouts.dart';
import 'new_exercise_panel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  late CnConfig cnConfig = Provider.of<CnConfig>(context, listen: false);
  final _formKey = GlobalKey<FormState>();
  final double _heightBottomColoredBox = Platform.isAndroid? 15 : 25;
  final double _totalHeightBottomBox = Platform.isAndroid? 70 : 80;

  void checkTutorialState(){
    if(tutorialIsRunning && MediaQuery.of(context).viewInsets.bottom == 0){
      if(currentTutorialStep == 1
          && cnNewWorkout.workout.name.isNotEmpty
          && cnNewExercisePanel.panelController.isPanelClosed){
        initTutorialAddExercise(context);
        showTutorialAddExercise(context);
        currentTutorialStep = 2;
      }
      if(currentTutorialStep == 3 && cnNewWorkout.workout.exercises.isNotEmpty){
        Future.delayed(const Duration(milliseconds: 500), (){
          initTutorialExplainExerciseDragOptions(context);
          showTutorialExplainExerciseDragOptions(context);
          currentTutorialStep = 4;
        });

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context);

    checkTutorialState();

    return PopScope(
      canPop: false,
      onPopInvoked: (doPop){
        if (cnNewWorkout.panelController.isPanelOpen && !cnNewExercisePanel.panelController.isPanelOpen && !tutorialIsRunning){
          cnNewWorkout.panelController.close();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints){
          return SlidingUpPanel(
            controller: cnNewWorkout.panelController,
            defaultPanelState: PanelState.CLOSED,
            maxHeight: constraints.maxHeight - (Platform.isAndroid? 50 : 70),
            minHeight: cnNewWorkout.minPanelHeight,
            isDraggable: true,
            borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
            // backdropEnabled: true,
            // backdropColor: Colors.black,
            color: const Color(0xff120a01),
            onPanelSlide: onPanelSlide,
            panel: ClipRRect(
              borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  if(cnNewWorkout.panelController.isPanelClosed){
                    HapticFeedback.selectionClick();
                    // cnNewWorkout.openPanelWithRefresh();
                    cnNewWorkout.openPanel();
                  }
                },
                child: Stack(
                  children: [
                    SizedBox(
                      // padding: const EdgeInsets.only(bottom: 0, right: 20.0, left: 20.0, top: 10),
                      height: double.maxFinite,
                      width: double.maxFinite,
                      // color: Colors.transparent,
                      child: Stack(
                        children: [
                          ListView(
                            controller: cnNewWorkout.scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 0, right: 20.0, left: 20.0),
                            shrinkWrap: true,
                            children: [
                              SizedBox(height: cnNewWorkout.workout.isTemplate? 220 : 240),
                              /// Exercises and Links
                              ReorderableListView(
                                  scrollController: ScrollController(),
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.all(0),
                                  shrinkWrap: true,
                                  proxyDecorator: (
                                      Widget child, int index, Animation<double> animation) {
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
                                                  color: Colors.grey.withOpacity(0.05),
                                                  child: child
                                                ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: child,
                                    );
                                  },
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
                        height: _totalHeightBottomBox,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            /// faded container
                            Positioned(
                              bottom: _heightBottomColoredBox - 0.2,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: _totalHeightBottomBox - _heightBottomColoredBox,
                                decoration: BoxDecoration(
                                    gradient:  LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          // Colors.transparent,
                                          // Colors.black,
                                          const Color(0xff120a01).withOpacity(0.0),
                                          const Color(0xff120a01)
                                        ]
                                    )
                                ),
                              ),
                            ),
                            /// just colored container below faded container
                            Container(
                              height: _heightBottomColoredBox,
                              // color: Colors.black,
                              color: const Color(0xff120a01),
                            ),
                            /// bottom row with icons
                            Padding(
                              padding: EdgeInsets.only(bottom: Platform.isAndroid? 20 : 30, left: 30, right: 30),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  myIconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: onCancel
                                  ),
                                  if(cnNewWorkout.isUpdating)
                                    myIconButton(
                                      icon:const Icon(Icons.delete_forever),
                                      onPressed: (){
                                        cnStandardPopUp.open(
                                            context: context,
                                            child: Text(
                                              AppLocalizations.of(context)!.panelWoDeleteWorkout,
                                              textAlign: TextAlign.center,
                                              textScaler: const TextScaler.linear(1.2),
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                            onConfirm: onDelete,
                                            onCancel: (){},
                                            color: const Color(0xff2d2d2d)
                                          // pos: Offset(position.dx + width/2, position.dy + height/2)
                                        );
                                      },
                                    ),
                                  myIconButton(
                                      icon: const Icon(Icons.check),
                                      onPressed: (){
                                        if(!hasChangedNames()){
                                          onConfirm();
                                        }
                                        else{
                                          openConfirmNameChangePopUp();
                                        }
                                      }
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
                key: cnNewWorkout.keyAddExercise,
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

  void openConfirmNameChangePopUp(){
    cnStandardPopUp.open(
        context: context,
        confirmText: AppLocalizations.of(context)!.yes,
        cancelText: AppLocalizations.of(context)!.no,
        maxWidth: MediaQuery.of(context).size.width,
        widthFactor: 0.9,
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.panelWoWorkoutNameChanged,
              textScaler: const TextScaler.linear(1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              AppLocalizations.of(context)!.panelWoWorkoutNameChangedMessage,
              textScaler: const TextScaler.linear(1),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
                constraints: const BoxConstraints(
                    maxHeight: 400
                ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [

                    /// new workout name
                    if(cnNewWorkout.originalWorkout.name != cnNewWorkout.workout.name)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          children: [
                            const SizedBox(height: 20,),
                            Text(AppLocalizations.of(context)!.panelWoWorkoutName, textScaler: const TextScaler.linear(1.2),),
                            const SizedBox(height: 5,),
                            Row(
                              children: [
                                Expanded(child: Align(alignment: Alignment.centerLeft ,child: OverflowSafeText(cnNewWorkout.originalWorkout.name, maxLines: 3, fontSize: 15, minFontSize: 10))),
                                const Expanded(child: Center(child: Icon(Icons.arrow_right_alt))),
                                Expanded(child: Align(alignment: Alignment.centerLeft ,child: OverflowSafeText(cnNewWorkout.workout.name, maxLines: 3, fontSize: 15, minFontSize: 10))),
                                // const Spacer(),
                              ],
                            ),
                          ],
                        ),
                      ),

                    /// New exercises names
                    if(cnNewWorkout.exerciseNewNameMapping.isNotEmpty)
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5, top: 20),
                            child: Text(AppLocalizations.of(context)!.panelWoExerciseNames, textScaler: const TextScaler.linear(1.2),),
                          ),
                          for(MapEntry entry in cnNewWorkout.exerciseNewNameMapping.entries)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(child: Align(alignment: Alignment.centerLeft ,child: OverflowSafeText(entry.key, maxLines: 3, fontSize: 15, minFontSize: 10))),
                                  const Expanded(child: Center(child: Icon(Icons.arrow_right_alt))),
                                  Expanded(child: Align(alignment: Alignment.centerLeft ,child: OverflowSafeText(entry.value, maxLines: 3, fontSize: 15, minFontSize: 10)))
                                ],
                              ),
                            )
                        ],
                      ),
                  ],
                ),
              ),
            )
          ],
        ),
        onConfirm: (){
          cnNewWorkout.applyNameChanges = true;
          onConfirm();
        },
        onCancel: (){
          cnNewWorkout.applyNameChanges = false;
          onConfirm();
        },
        onTapOutside: (){
          cnNewWorkout.applyNameChanges = false;
        },
        color: const Color(0xff2d2d2d)
    );
  }

  Widget getHeader(){
    return ClipRRect(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 0, right: 20.0, left: 20.0, top: 10),
            // color: const Color(0xff0a0604),
            // color: Theme.of(context).primaryColor,
            color: const Color(0xff120a01),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Column(
                      children: [
                        panelTopBar,
                        const SizedBox(height: 15,),
                        Text(cnNewWorkout.workout.isTemplate? AppLocalizations.of(context)!.panelWoWorkoutTemplate : AppLocalizations.of(context)!.panelWoWorkoutFinished, textScaler: const TextScaler.linear(1.5)),
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
                Row(
                  children: [
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          focusNode: cnNewWorkout.focusNodeTextFieldWorkoutName,
                          key: cnNewWorkout.keyTextFieldWorkoutName,
                          keyboardAppearance: Brightness.dark,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            value = value?.trim();
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.panelWoEnterName;
                            }
                            /// Check if the workout name already exists, but only when the current name is different from the
                            /// initializing name. Otherwise editing an existing workout could lead to error
                            else if(cnNewWorkout.workout.isTemplate  &&                                                           /// only check if template
                                    cnNewWorkout.workout.name.toLowerCase() != cnNewWorkout.originalWorkout.name.toLowerCase() && /// Name is not equal to initial name when opening editing
                                    workoutNameExistsInTemplates(workoutName: cnNewWorkout.workout.name)                          /// Name exists in database
                            ){
                              return AppLocalizations.of(context)!.panelWoAlreadyExists;
                            }
                            return null;
                          },
                          onTap: ()async{
                            if(cnNewWorkout.panelController.isPanelClosed){
                              Future.delayed(const Duration(milliseconds: 300), (){
                                HapticFeedback.selectionClick();
                                /// We need to use the panel controllers own open methode because, when we use our open
                                /// panel method, the keyboard gets dismissed (unfocused) by onPanelSlide() cause for some reason
                                /// our methods triggers an exact 0.0 value and the normal panelController.open() methode does not.
                                /// Maybe due to speed of opening the panel
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
                            labelText: AppLocalizations.of(context)!.name,
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
                          key: cnNewWorkout.keyAddLink,
                          icon: const Icon(Icons.add_link, color: Color(0xFF5F9561)),
                          onPressed: ()async{
                            if(cnNewWorkout.panelController.isPanelClosed){
                              HapticFeedback.selectionClick();
                              await cnNewWorkout.openPanel();
                            }
                            cnStandardPopUp.open(
                                context: context,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        keyboardAppearance: Brightness.dark,
                                        maxLength: 15,
                                        keyboardType: TextInputType.text,
                                        controller: cnNewWorkout.linkNameController,
                                        style: const TextStyle(
                                            fontSize: 20
                                        ),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                          isDense: true,
                                          labelText: AppLocalizations.of(context)!.groupName,
                                          counterText: "",
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8 ,vertical: 8.0),
                                          suffixIcon: IconButton(
                                              onPressed: () async{
                                                HapticFeedback.selectionClick();
                                                await showDialog(
                                                    context: context,
                                                    builder: (context){
                                                      return Center(
                                                          child: standardDialog(
                                                              context: context,
                                                              child: getExplainExerciseGroups(context)
                                                          )
                                                      );
                                                    }
                                                );
                                                HapticFeedback.selectionClick();
                                                FocusManager.instance.primaryFocus?.unfocus();
                                              },
                                              icon: const Icon(
                                                  Icons.info_outline_rounded
                                              )
                                          )
                                        ),
                                        onChanged: (value){},
                                      ),
                                    ),
                                  ],
                                ),
                                onConfirm: (){
                                  // bool added = false;
                                  final linkName = cnNewWorkout.linkNameController.text;
                                  if(linkName.isNotEmpty && !cnNewWorkout.workout.linkedExercises.contains(linkName)){
                                    // added = true;
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
                if(!cnNewWorkout.workout.isTemplate)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.panelWoDate, textScaler: const TextScaler.linear(1.3),),
                        const Spacer(),
                        if(cnNewWorkout.workout.date != null)
                        buildCalendarDialogButton(
                            context: context,
                            cnNewWorkout: cnNewWorkout,
                            onConfirm: (List<DateTime?>? values){
                              cnNewWorkout.workout.date = values?[0]?? cnNewWorkout.workout.date;
                            }
                        )
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
                Text(AppLocalizations.of(context)!.panelWoExercises, textScaler: TextScaler.linear(1.2)),
                Container(height: 16,),
              ],
            ),
          ),
          Container(
            height: 25,
            decoration: BoxDecoration(
                gradient:  LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      // Colors.transparent,
                      // Color(0xff0a0604),
                      const Color(0xff120a01).withOpacity(0.0),
                      const Color(0xff120a01)
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
                    color: (
                        getLinkColor(
                            linkName: cnNewWorkout.exercisesAndLinks[index],
                            workout: cnNewWorkout.workout
                        )?? Colors.grey
                    ).withOpacity(0.6),
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
      key: index == 0 && tutorialIsRunning? cnNewWorkout.keyFirstExercise : UniqueKey(),
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
                        color: (
                            getLinkColor(
                                linkName: (cnNewWorkout.exercisesAndLinks[index] as Exercise).linkName!,
                                workout: cnNewWorkout.workout
                            )?? Colors.grey
                        ).withOpacity(0.6),
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

  bool hasChangedNames(){
    if(!cnNewWorkout.workout.isTemplate){
      return false;
    }

    /// calculate Exercises that have had a name change
    final changedExercises = cnNewWorkout.originalWorkout.exercises.where(
            (exercise) => cnNewWorkout.workout.exercises.any(
                (ex) => ex.id == exercise.id
                && ex.name != exercise.name
        )
    ).toList();

    /// create exercise name mapping oldName: newName
    for(Exercise ex in changedExercises){
      cnNewWorkout.exerciseNewNameMapping[ex.name] = cnNewWorkout.workout.exercises.firstWhere((exercise) => exercise.id == ex.id).name;
    }

    if((cnNewWorkout.originalWorkout.name != cnNewWorkout.workout.name && cnNewWorkout.originalWorkout.name.isNotEmpty)
        || cnNewWorkout.exerciseNewNameMapping.isNotEmpty){
      return true;
    }

    return false;
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
    if(!tutorialIsRunning && cnNewWorkout.panelController.isPanelOpen){
        cnNewExercisePanel.openPanel(workout: cnNewWorkout.workout, onConfirm: cnNewWorkout.confirmAddExercise);
    }
    else if(tutorialIsRunning && cnNewWorkout.panelController.isPanelOpen){
      if(currentTutorialStep < 2){
        FocusScope.of(context).unfocus();
      }
      else{
        cnNewExercisePanel.openPanel(workout: cnNewWorkout.workout, onConfirm: cnNewWorkout.confirmAddExercise);
      }
    }

  }

  void addLink(String linkName){
    // if (cnNewWorkout.workout.linkedExercises.contains(linkName)) {
    //   linkName = "Curls";
    // }
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
    Exercise exToEdit;
    if(copied){
      exToEdit = Exercise.copy(ex);
    } else{
      exToEdit = Exercise.clone(ex);
    }

    if(copied) {
      /// If copied means a copy of the original exercise is made to create a completely new exercise
      exToEdit.name = "";
    } else {
      /// Otherwise the user is editing the exercise so we keep track of the origina name in case
      /// the user changes the exercises name
      exToEdit.originalName = ex.name;
    }

    if(cnNewWorkout.panelController.isPanelOpen){
      // cnNewExercisePanel.setExercise(exToEdit);
      cnNewExercisePanel.openPanel(workout: cnNewWorkout.workout, exercise: exToEdit, onConfirm: cnNewWorkout.confirmAddExercise);
      cnNewExercisePanel.refresh();
    }
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
    if(cnConfig.syncWithCloud){
      saveBackup(
          withCloud: true,
          cnConfig: cnConfig,
          currentDataCloud: true
      );
    }
  }

  void onConfirm() async{
    if (_formKey.currentState!.validate()){
      vibrateConfirm();
      cnNewWorkout.updateExercisesOrderInWorkoutObject();
      if(!cnNewWorkout.isUpdating){
        cnNewWorkout.workout.isTemplate = true;
      }
      cnNewWorkout.removeEmptyLinksFromWorkout();
      cnNewWorkout.workout.saveToDatabase();
      if(cnNewWorkout.applyNameChanges){
        changeSameNameWorkouts();
      }
      cnWorkouts.refreshAllWorkouts();
      cnWorkoutHistory.refreshAllWorkouts();
      cnNewWorkout.closePanel(doClear: true);
      cnNewExercisePanel.clear();
      _formKey.currentState?.reset();
      if(cnConfig.syncWithCloud){
        saveBackup(
            withCloud: true,
            cnConfig: cnConfig,
            currentDataCloud: true
        );
      }
    }
  }

  void changeSameNameWorkouts(){
    final currentObWorkouts = objectbox.workoutBox.query(ObWorkout_.name.equals(cnNewWorkout.originalWorkout.name)).build().find();

    for(ObWorkout wo in currentObWorkouts){
      wo.name = cnNewWorkout.workout.name;
      for(MapEntry mapping in cnNewWorkout.exerciseNewNameMapping.entries){
        if(wo.exercises.map((e) => e.name).contains(mapping.key)){
          wo.exercises.firstWhere((e) => e.name == mapping.key).name = mapping.value;
        }
      }
      wo.save();
    }
  }

  void onPanelSlide(value){
    cnWorkouts.animationControllerWorkoutPanel.value = value*0.5;
    if(value == 0){
      FocusScope.of(context).unfocus();
      cnNewWorkout.refresh();
    }
    else if(value == 1){
      cnNewWorkout.refresh();
    }
    cnBottomMenu.adjustHeight(value);
    // cnBottomMenu.positionYAxis = cnBottomMenu.height * value;
    // cnBottomMenu.refresh();
  }

}

class CnNewWorkOutPanel extends ChangeNotifier {
  final GlobalKey keyAddLink = GlobalKey();
  final GlobalKey keyAddExercise = GlobalKey();
  final GlobalKey keyTextFieldWorkoutName = GlobalKey();
  final GlobalKey keyFirstExercise = GlobalKey();
  final FocusNode focusNodeTextFieldWorkoutName = FocusNode();
  final PanelController panelController = PanelController();
  Workout workout = Workout();
  Workout originalWorkout = Workout();
  TextEditingController workoutNameController = TextEditingController();
  TextEditingController linkNameController = TextEditingController();
  bool isUpdating = false;
  ScrollController scrollController = ScrollController();
  List<dynamic> exercisesAndLinks = [];
  double minPanelHeight = 0;
  bool isCurrentlyRebuilding = false;
  bool applyNameChanges = false;
  double keepShowingPanelHeight = Platform.isAndroid? 180 : 212;
  Map<String, String> exerciseNewNameMapping = {};
  late CnHomepage cnHomepage;
  late CnWorkouts cnWorkouts;
  late CnWorkoutHistory cnWorkoutHistory;
  late Map<DateTime, dynamic> allWorkoutDates = getAllWorkoutDays();

  Map<DateTime, dynamic> getAllWorkoutDays(){
    Map<DateTime, dynamic> dates = {};
    final workouts  = objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(false)).build().find();
    for(ObWorkout w in workouts){
      bool contains = false;
      DateTime? keyDate;

      for(final k in dates.keys){
        if(k.isSameDate(w.date)){
          contains = true;
          keyDate = k;
          break;
        }
      }

      /// if date exists
      if(contains && keyDate != null){
        if(dates[keyDate] is List){
          dates[keyDate].add(w.name);
        }
        else{
          dates[keyDate] = [dates[keyDate], w.name];
        }
      }
      else{
        dates[w.date] = w.name;
      }
    }
    return dates;
  }

  void refreshAllWorkoutDays(){
    allWorkoutDates = getAllWorkoutDays();
  }

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

  void confirmAddExercise(Exercise ex){

    workout.addOrUpdateExercise(ex);
    refreshExercise(ex);
    updateExercisesAndLinksList();
    updateExercisesLinks();
    refresh();
  }

  void openPanelAsTemplate(){
    if(isUpdating){
      clear();
    }
    workout.isTemplate = true;
    openPanelWithRefresh();
  }

  void openPanelWithRefresh() async{
    HapticFeedback.selectionClick();
    minPanelHeight = keepShowingPanelHeight;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    refresh();
    await openPanel();
    /// is needed to move spotifyBar higher when panel is opened
    cnHomepage.refresh();
    /// is needed to move addWorkout button higher when panel is opened
    cnWorkouts.refresh();
    // cnWorkoutHistory.refresh();
  }

  Future<void> openPanel() async{
    await panelController.animatePanelToPosition(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.decelerate
    );
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
    /// When same workout
    if(isUpdating && this.workout.id == w.id){
      openPanelWithRefresh();
    }
    /// When different workout
    else{
      clear(doRefresh: false);
      isUpdating = true;
      setWorkout(w);
      updateExercisesAndLinksList();
      initializeCorrectOrder();
      openPanelWithRefresh();
    }
  }

  void setWorkout(Workout w){
    workout = w;
    refreshAllWorkoutDays();
    originalWorkout = Workout.clone(w);
    workoutNameController = TextEditingController(text: w.name);
  }

  void clear({bool doRefresh = true}){
    workout = Workout();
    originalWorkout = Workout();
    exerciseNewNameMapping.clear();
    applyNameChanges = false;
    refreshAllWorkoutDays();
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
