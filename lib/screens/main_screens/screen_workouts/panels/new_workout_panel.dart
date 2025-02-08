import 'dart:io';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/util/backup_functions.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:fitness_app/util/objectbox/ob_sick_days.dart';
import 'package:fitness_app/widgets/my_slide_up_panel.dart';
import 'package:fitness_app/widgets/spacer_list_view.dart';
import 'package:fitness_app/widgets/tutorials/tutorial_add_exercise.dart';
import 'package:fitness_app/widgets/tutorials/tutorial_explain_exercise_drag_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
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

class _NewWorkOutPanelState extends State<NewWorkOutPanel> with TickerProviderStateMixin{
  late CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context);
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  late CnNewExercisePanel cnNewExercisePanel = Provider.of<CnNewExercisePanel>(context, listen: false);
  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnWorkoutHistory cnWorkoutHistory = Provider.of<CnWorkoutHistory>(context, listen: false);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  late CnConfig cnConfig = Provider.of<CnConfig>(context, listen: false);
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  final _formKey = GlobalKey<FormState>();
  final double _heightBottomColoredBox = Platform.isAndroid? 15 : 25;
  final double _totalHeightBottomBox = Platform.isAndroid? 70 : 80;
  // late final _color = Theme.of(context).primaryColor;
  // final _color = const Color(0xff120a01);
  // final _color = const Color(0xff221b14);
  // final _color = const Color(0xff231b13);
  // Color _color = const Color(0xff663a0b);
  // final _color = const Color(0xff1c1001);
  late final _color = Theme.of(context).primaryColor;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cnNewWorkout.initVsync(this);
      cnNewWorkout.scrollController.addListener(() {
        // print("Call Listener");
        for (SlidableExerciseOrLink item in cnNewWorkout.exercisesAndLinks) {
          SlidableController controller = item.slidableController;
          if(controller.animation.value > 0 && !controller.closing){
            controller.close();
          }
        }
      });
    });
  }

  void checkTutorialState(){
    if(tutorialIsRunning && MediaQuery.of(context).viewInsets.bottom == 0){
      if(currentTutorialStep == 1
          && cnNewWorkout.workout.name.isNotEmpty
          && cnNewExercisePanel.panelController.isPanelClosed
          && cnNewWorkout.workout.exercises.isEmpty
      ){
        currentTutorialStep = 2;
        initTutorialAddExercise(context);
        showTutorialAddExercise(context);
      }
      if(currentTutorialStep == 3 && cnNewWorkout.workout.exercises.isNotEmpty){
        currentTutorialStep = 4;
        Future.delayed(const Duration(milliseconds: 500), (){
          initTutorialExplainExerciseDragOptions(context);
          showTutorialExplainExerciseDragOptions(context);
        });

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    checkTutorialState();

    return PopScope(
      canPop: false,
      onPopInvoked: (doPop){
        if (cnNewWorkout.panelController.isPanelOpen && !cnNewExercisePanel.panelController.isPanelOpen && !tutorialIsRunning){
          cnNewWorkout.panelController.close();
        }
      },
      child: MySlideUpPanel(
        controller: cnNewWorkout.panelController,
        minHeight: cnNewWorkout.minPanelHeight,
        backdropEnabled: false,
        animationControllerName: "NewWorkoutPanel",
        descendantAnimationControllerName: "ScreenWorkouts",
        // reduceSizeWorkoutsScreen: true,
        color: _color,
        onPanelSlide: onPanelSlide,
        /// Use panelBuilder in Order to get a ScrollController which enables closing the panel
        /// when swiping down in  ListView
        // panelBuilder: (sc){
        //   // cnNewWorkout.scrollController = sc;
        //   return
        // },
        panelBuilder: (context, listView){
          return ClipRRect(
            borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
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
                    height: double.maxFinite,
                    width: double.maxFinite,
                    child: Stack(
                      children: [
                        SlidableAutoCloseBehavior(
                          child: listView(
                            controller: cnNewWorkout.scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 0, right: 20.0, left: 20.0),
                            shrinkWrap: true,
                            children: [
                              // SizedBox(height: cnNewWorkout.workout.isTemplate? 220 : 240),
                              SizedBox(height: cnNewWorkout.workout.isTemplate? 140 : 190),
                              /// Exercises and Links
                              ReorderableListView(
                                  // scrollController: cnNewWorkout.scrollController,
                                  physics: const NeverScrollableScrollPhysics(),
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
                                      if(cnNewWorkout.exercisesAndLinks[index].isExercise)
                                        getExerciseWithSlideActions(index)
                                      else if(cnNewWorkout.exercisesAndLinks[index].isLink)
                                        getLinkWithSlideActions(index),
                                  ]
                              ),
                              if(!cnNewWorkout.isSickDays)
                                getAddExerciseButton()
                            ],
                          ),
                        ),
                        getHeader(),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(onPressed: onCancel, child: const Text("Abbrechen")),
                      CupertinoButton(
                          onPressed: (){
                            if(!hasChangedNames()){
                              onConfirm();
                            }
                            else{
                              openConfirmNameChangePopUp();
                            }
                          },
                          child: const Text("Speichern")
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }
      )
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
            color: _color,
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
                        cnNewWorkout.workout.isTemplate && cnNewWorkout.workout.isEmpty()
                            ?getWorkoutOrSickDaysPicker()
                            :Text(
                            cnNewWorkout.workout.isTemplate
                                ? AppLocalizations.of(context)!.panelWoWorkoutTemplate
                                : cnNewWorkout.isSickDays
                                  ? "Krank"
                                  : AppLocalizations.of(context)!.panelWoWorkoutFinished,
                            textScaler: const TextScaler.linear(1.5)),
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
                if (!cnNewWorkout.isSickDays)
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
                              bool first = workoutNameExistsInTemplates(workoutName: cnNewWorkout.workout.name);
                              bool second = cnNewWorkout.workout.isTemplate;
                              bool third = cnNewWorkout.workout.name.toLowerCase() != cnNewWorkout.originalWorkout.name.toLowerCase();
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!.panelWoEnterName;
                              }
                              /// Check if the workout name already exists, but only when the current name is different from the
                              /// initializing name. Otherwise editing an existing workout could lead to error
                              else if(first   &&                                                       /// only check if template
                                      second && /// Name is not equal to initial name when opening editing
                                      third                          /// Name exists in database
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
                  )
                else if(cnNewWorkout.isSickDays)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Dauer", textScaler: TextScaler.linear(1.3),),
                            const Spacer(),
                            buildCalendarDialogButton(
                                context: context,
                                cnNewWorkout: cnNewWorkout,
                                calendarType: CalendarDatePicker2Type.range,
                                dateValues: [cnNewWorkout.sickDays.startDate, cnNewWorkout.sickDays.endDate],
                                onConfirm: (List<DateTime?>? values){
                                  if(values != null) {
                                    cnNewWorkout.sickDays.startDate = values.firstOrNull?? cnNewWorkout.sickDays.startDate;
                                    cnNewWorkout.sickDays.endDate =  values.lastOrNull?? cnNewWorkout.sickDays.endDate;
                                    if (cnNewWorkout.sickDays.startDate.isAfter(cnNewWorkout.sickDays.endDate)) {
                                      cnNewWorkout.sickDays.endDate = cnNewWorkout.sickDays.startDate;
                                    }
                                  }
                                }
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                if(!cnNewWorkout.workout.isTemplate && !cnNewWorkout.isSickDays)
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
                              dateValues: [cnNewWorkout.workout.date?? DateTime.now()],
                              cnNewWorkout: cnNewWorkout,
                              onConfirm: (List<DateTime?>? values){
                                cnNewWorkout.workout.date = values?[0]?? cnNewWorkout.workout.date;
                              }
                          )
                      ],
                    ),
                  )
                // else
                //   const SizedBox(height: 25,),
                // if(!cnNewWorkout.isSickDays)
                //   Column(
                //     children: [
                //       Container(
                //         height: 1,
                //         decoration: BoxDecoration(
                //             color: Colors.white.withOpacity(0.5),
                //             borderRadius: BorderRadius.circular(2)
                //         ),
                //       ),
                //       Container(height: 15,),
                //       Text(AppLocalizations.of(context)!.panelWoExercises, textScaler: const TextScaler.linear(1.2)),
                //       Container(height: 16,),
                //     ],
                //   )

              ],
            ),
          ),
          if(!cnNewWorkout.isSickDays)
            Container(
              height: 25,
              decoration: BoxDecoration(
                  gradient:  LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        // Colors.transparent,
                        // Color(0xff0a0604),
                        _color.withOpacity(0.0),
                        _color
                      ]
                  )
              ),
            ),
        ],
      ),
    );
  }

  Widget getWorkoutOrSickDaysPicker() {
    return SizedBox(
      height: 30,
      child: PullDownButton(
        onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
        routeTheme: routeTheme,
        itemBuilder: (context) {
          return [
            PullDownMenuItem(
              title: "Workout",
              onTap: () {
                cnNewWorkout.isSickDays = false;
                cnNewWorkout.minPanelHeight = cnNewWorkout.keepShowingPanelHeight;
                cnWorkouts.refresh();
                cnHomepage.refresh();
              },
            ),
            PullDownMenuItem(
              title: "Krank",
              onTap: () {
                cnNewWorkout.isSickDays = true;
                cnNewWorkout.minPanelHeight = cnNewWorkout.keepShowingPanelHeightSickDays;
                cnWorkouts.refresh();
                cnHomepage.refresh();
              },
            ),
          ];
        },
        buttonBuilder: (context, showMenu) => CupertinoButton(
          onPressed: (){
            HapticFeedback.selectionClick();
            showMenu();
          },
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OverflowSafeText(
                  minFontSize: 22,
                  maxLines: 1,
                  cnNewWorkout.isSickDays
                      ?"Krank"
                      :cnNewWorkout.workout.isTemplate? AppLocalizations.of(context)!.panelWoWorkoutTemplate : AppLocalizations.of(context)!.panelWoWorkoutFinished,
                  style: const TextStyle(color: Colors.white)
              ),
              const SizedBox(width: 10),
              trailingChoice()
            ],
          ),
        ),
      ),
    );
  }

  Widget getLinkWithSlideActions(int index){
    bool withSpacer = cnNewWorkout.exercisesAndLinks.length-1 == index || cnNewWorkout.exercisesAndLinks[index+1].linkName != cnNewWorkout.exercisesAndLinks[index].linkName;
    return Column(
      key: ValueKey(cnNewWorkout.exercisesAndLinks[index].linkName),
      children: [
        Slidable(
            controller: cnNewWorkout.exercisesAndLinks[index].slidableController,
            closeOnScroll: false,
            groupTag: 1,
            key: cnNewWorkout.exercisesAndLinks[index].key,
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              dismissible: DismissiblePane(
                  onDismissed: () {dismissLink(cnNewWorkout.exercisesAndLinks[index]);
                  }),
              children: [
                SlidableAction(
                  onPressed: (BuildContext context){
                    dismissLink(cnNewWorkout.exercisesAndLinks[index]);
                  },
                  backgroundColor: const Color(0xFFA12D2C),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                ),
              ],
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: withSpacer? BorderRadius.circular(8) : BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))
              ),
              child: Row(
                key: UniqueKey(),
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                    child: OverflowSafeText(
                      cnNewWorkout.exercisesAndLinks[index].linkName!,
                      textAlign: TextAlign.center,
                      // fontSize: 12,
                      // style: style,
                      minFontSize: 12,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            )
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: withSpacer? 8 : 0,
        )
      ],
    );
  }

  Widget getExerciseWithSlideActions(int index){
    final bool hasLink = (cnNewWorkout.exercisesAndLinks[index].exercise as Exercise).linkName != null;
    Exercise? nextExercise =  cnNewWorkout.exercisesAndLinks.length > index+1
        && cnNewWorkout.exercisesAndLinks[index+1].isExercise
          ? cnNewWorkout.exercisesAndLinks[index+1].exercise!
          : null;
    bool withSpacer = nextExercise?.linkName != cnNewWorkout.exercisesAndLinks[index].linkName
        || (nextExercise?.blockLink?? false)
        || (nextExercise?.linkName == null);
    return Column(
      key: index == 0 && tutorialIsRunning? cnNewWorkout.keyFirstExercise : ValueKey(cnNewWorkout.exercisesAndLinks[index].exercise!.name),
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasLink)
          SpaceFixerHorizontalLine(
            // key: UniqueKey(),
            context: context,
            overflowHeight: 2,
            width: MediaQuery.of(context).size.width - 40,
            overflowColor: Theme.of(context).cardColor,
          ),
        Slidable(
            key: cnNewWorkout.exercisesAndLinks[index].key,
            controller: cnNewWorkout.exercisesAndLinks[index].slidableController,
            closeOnScroll: false,
            groupTag: 1,
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              dismissible: DismissiblePane(
                  onDismissed: () {dismissExercise(cnNewWorkout.exercisesAndLinks[index]);
                  }),
              children: [
                SlidableAction(
                  // flex:32,
                  onPressed: (BuildContext context){
                    dismissExercise(cnNewWorkout.exercisesAndLinks[index]);
                  },
                  // borderRadius: BorderRadius.circular(15),
                  backgroundColor: const Color(0xFFA12D2C),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                ),
              ],
            ),

            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  padding: const EdgeInsets.all(0),
                  onPressed: (BuildContext context){
                    if(cnNewWorkout.exercisesAndLinks[index].exercise!.blockLink){
                      cnNewWorkout.exercisesAndLinks[index].exercise!.linkName = null;
                      cnNewWorkout.exercisesAndLinks[index].exercise!.blockLink = false;
                      cnNewWorkout.updateExercisesLinks();
                    }
                    else{
                      cnNewWorkout.exercisesAndLinks[index].exercise!.linkName = null;
                      cnNewWorkout.exercisesAndLinks[index].exercise!.blockLink = true;
                      cnNewWorkout.orderExercises();
                    }
                    setState(() {});
                  },
                  backgroundColor: const Color(0xFF5F9561),
                  // backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  icon: cnNewWorkout.exercisesAndLinks[index].exercise!.blockLink? Icons.link : Icons.link_off,
                ),
                SlidableAction(
                  padding: const EdgeInsets.all(0),
                  onPressed: (BuildContext context){
                    openExercise(cnNewWorkout.exercisesAndLinks[index].exercise!, copied: true);
                  },
                  backgroundColor: const Color(0xFF617EB1),
                  foregroundColor: Colors.white,
                  icon: Icons.copy,
                ),
                SlidableAction(
                  padding: const EdgeInsets.all(0),
                  onPressed: (BuildContext context){
                    openExercise(cnNewWorkout.exercisesAndLinks[index].exercise!);
                  },
                  backgroundColor: const Color(0xFFAE7B32),
                  // backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                ),
              ],
            ),
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: hasLink? 70 : 75,
                child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ExerciseRow(
                        exercise: cnNewWorkout.exercisesAndLinks[index].exercise!,
                        // padding: EdgeInsets.only(left: hasLink? 30 : 10, right: 10, bottom: 5, top: 5),
                        padding: EdgeInsets.only(left: hasLink? 30 : 10, right: 10, bottom: 6, top: 3),
                        margin: hasLink? const EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 0) : null,
                        style: hasLink
                            ? const TextStyle(
                            fontSize: 13,
                            color: Colors.white70
                        )
                            : null,
                        borderRadius: hasLink
                            ? (nextExercise?.linkName != cnNewWorkout.exercisesAndLinks[index].linkName || nextExercise == null
                            ? const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8))
                            : BorderRadius.zero)
                            : null,
                      ),
                      if(cnNewWorkout.exercisesAndLinks[index].exercise!.blockLink)
                        const Positioned(
                          top: 5,
                          right: 5,
                          child: Icon(
                            Icons.link_off,
                            size: 10,
                            color: Color(0xFF5F9561),
                          ),
                        )
                    ]
                )
            )
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: withSpacer? 8 : 0,
        )
        // if(withSpacer)
        //   const SizedBox(height: 8,)
      ],
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

  void dismissExercise(SlidableExerciseOrLink ex){
    // final index = cnNewWorkout.exercisesAndLinks.indexOf(ex);
    // final controller = cnNewWorkout.slidableControllers.removeAt(index);
    // Future.delayed(const Duration(milliseconds: 1000), (){
    //   ex.slidableController.dispose();
    // });
    // ex.slidableController.ratio = 0.0;

    cnNewWorkout.workout.exercises.remove(ex.exercise);
    cnNewWorkout.updateExercisesAndLinksList();
    cnNewWorkout.refresh();
  }

  void dismissLink(SlidableExerciseOrLink linkName){
    // final index = cnNewWorkout.exercisesAndLinks.indexOf(linkName);
    // final controller = cnNewWorkout.slidableControllers.removeAt(index);
    // Future.delayed(const Duration(milliseconds: 100), (){
    //   controller.dispose();
    // });
    // controller.dispose();

    cnNewWorkout.workout.linkedExercises.remove(linkName.linkName);
    cnNewWorkout.updateExercisesAndLinksList();
    cnNewWorkout.updateExercisesLinks();
    cnNewWorkout.refresh();
  }

  void addExercise(){
    if(!tutorialIsRunning && cnNewWorkout.panelController.panelPosition > 0.99){
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
    if(cnNewWorkout.panelController.panelPosition < 0.05){
      cnBottomMenu.refresh();
    }
  }

  void onDelete(){
    if(cnNewWorkout.isSickDays){
      cnNewWorkout.sickDays.delete();
    }
    else{
      cnNewWorkout.workout.deleteFromDatabase();
      cnWorkouts.refreshAllWorkouts();
    }
    cnWorkoutHistory.refreshAllWorkouts();
    cnNewWorkout.closePanel(doClear: true);
    cnNewExercisePanel.clear();
    saveCurrentData(cnConfig);
  }

  void onConfirm() async{
    if(cnNewWorkout.isSickDays){
      vibrateConfirm();
      cnNewWorkout.sickDays.save();
      cnNewWorkout.closePanel(doClear: true);
      cnNewExercisePanel.clear();
      _formKey.currentState?.reset();
      saveCurrentData(cnConfig);
      if(cnBottomMenu.index == 0){
        Future.delayed(const Duration(milliseconds: 100), (){
          cnWorkoutHistory.refreshAllWorkouts();
          cnWorkoutHistory.refresh();
        });
      }
    }
    else if (_formKey.currentState!.validate()){
      vibrateConfirm();
      _formKey.currentState?.reset();
      cnNewWorkout.updateExercisesOrderInWorkoutObject();
      if(!cnNewWorkout.isUpdating){
        cnNewWorkout.workout.isTemplate = true;
      }
      cnNewWorkout.workout.removeEmptyLinksFromWorkout();
      cnNewWorkout.workout.saveToDatabase();
      if(cnNewWorkout.applyNameChanges){
        changeSameNameWorkouts();
      }
      cnWorkouts.refreshAllWorkouts();
      await cnWorkoutHistory.refreshAllWorkouts();
      if(cnBottomMenu.index == 0){
        int? index;
        String key = "${cnNewWorkout.workout.date?.year}${cnNewWorkout.workout.date?.month}${cnNewWorkout.workout.date?.day}";
        if(cnWorkoutHistory.indexOfWorkout.keys.contains(key)){
          index = cnWorkoutHistory.indexOfWorkout[key];
          if(index != null){
            Future.delayed(const Duration(milliseconds: 0), (){
              cnWorkoutHistory.scrollController.jumpTo(
                  index: index!,
                  // duration: const Duration(milliseconds: 0),
                  alignment: index == 0
                      ? 0.05 : index >= cnWorkoutHistory.indexOfWorkout.keys.length-1
                      ? 0.6 : index >= cnWorkoutHistory.indexOfWorkout.keys.length-2
                      ? 0.5 : index >= cnWorkoutHistory.indexOfWorkout.keys.length-3
                      ? 0.3 :  0.1,
                  // curve: Curves.easeInOut
              );
            });
          }
        }
      }
      cnNewWorkout.closePanel(doClear: true);
      cnNewExercisePanel.clear();
      saveCurrentData(cnConfig);
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
    // cnWorkouts.animationControllerWorkoutsScreen.value = value*0.5;
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

  void askDeleteWorkout() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        cancelButton: getActionSheetCancelButton(context),
        message: Text(AppLocalizations.of(context)!.panelWoDeleteWorkout),
        actions: <Widget>[
          CupertinoActionSheetAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as delete or exit and turns
            /// the action's text color to red.
            isDestructiveAction: true,
            onPressed: () {
              onDelete();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }
}

class CnNewWorkOutPanel extends ChangeNotifier{
  final GlobalKey keyAddLink = GlobalKey();
  final GlobalKey keyAddExercise = GlobalKey();
  final GlobalKey keyTextFieldWorkoutName = GlobalKey();
  final GlobalKey keyFirstExercise = GlobalKey();
  final FocusNode focusNodeTextFieldWorkoutName = FocusNode();
  final PanelController panelController = PanelController();
  ObSickDays sickDays = ObSickDays(startDate: DateTime.now(), endDate: DateTime.now());
  Workout workout = Workout();
  Workout originalWorkout = Workout();
  TextEditingController workoutNameController = TextEditingController();
  TextEditingController linkNameController = TextEditingController();
  bool isUpdating = false;
  ScrollController scrollController = ScrollController();
  List<SlidableExerciseOrLink> exercisesAndLinks = [];
  // List<SlidableController> slidableControllers = [];
  double minPanelHeight = 0;
  bool isCurrentlyRebuilding = false;
  bool applyNameChanges = false;
  bool isSickDays = false;
  double keepShowingPanelHeight = Platform.isAndroid? 180 : 212;
  double keepShowingPanelHeightSickDays = Platform.isAndroid? 210 : 242;
  Map<String, String> exerciseNewNameMapping = {};
  late CnHomepage cnHomepage;
  late CnWorkouts cnWorkouts;
  late CnWorkoutHistory cnWorkoutHistory;
  late Map<DateTime, dynamic> allWorkoutDates = getAllWorkoutDays();
  late TickerProvider vsync;

  void initVsync(TickerProvider vsync){
    this.vsync = vsync;
  }

  Map<DateTime, dynamic> getAllWorkoutDays(){
    Map<DateTime, dynamic> dates = {};

    final workouts  = objectbox.workoutBox.query(ObWorkout_.isTemplate.equals(false)).build().find();
    for(ObWorkout w in workouts){
      bool contains = false;
      DateTime? keyDate;
      workout.date = workout.date?.toDate();

      for(final k in dates.keys){
        if(k.isSameDate(w.date)){
          contains = true;
          keyDate = k;
          break;
        }
      }

      /// Fill map
      if(contains && keyDate != null){
        if(dates[keyDate] is List){
          dates[keyDate].add(w.name);
        }
        else{
          dates[keyDate] = [dates[keyDate], w.name];
        }
      }
      else{
        dates[w.date.toDate()] = w.name;
      }
    }

    final sickDays  = objectbox.sickDaysBox.getAll();
    for(ObSickDays timespan in sickDays){
      final sickDayDates = List.generate(timespan.endDate.difference(timespan.startDate).inDays + 1, (index) => timespan.startDate.add(Duration(days: index, hours: 1)).toDate());
      for(DateTime date in sickDayDates){
        if(dates.keys.contains(date)){
          if(dates[date] is List){
            dates[date].add("Krank");
          }
          else{
            dates[date] = [dates[date], "Krank"];
          }
        }
        else{
          dates[date] = "Krank";
        }
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
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastEaseInToSlowEaseOut
    );
  }

  // void addToExercisesAndLinksList(dynamic item){
  //   exercisesAndLinks.add(item);
  // }
  //
  // void deleteFromExercisesAndLinksList(dynamic item){
  //   exercisesAndLinks.remove(item);
  // }

  void updateExercisesAndLinksList(){
    /// Updates the exercisesAndLinksList which is responsible for showing the exercises and links together in new_workout_panel
    Set<SlidableExerciseOrLink> itemsToRemove = {};
    Set<SlidableExerciseOrLink> itemsToAdd = {};

    for(SlidableExerciseOrLink item in exercisesAndLinks){
      if(item.isExercise && !(workout.exercises.map((e) => e.name).contains(item.exercise?.name))){
        itemsToRemove.add(item);
      }
      else if(item.isLink && !workout.linkedExercises.contains(item.linkName)){
        itemsToRemove.add(item);
      }
    }

    for(Exercise ex in workout.exercises){
      if(!(exercisesAndLinks.where((element) => element.isExercise).map((e) => e.exercise!.name).contains(ex.name))){
        itemsToAdd.add(SlidableExerciseOrLink(
            exercise: ex,
            linkName: ex.linkName,
            slidableController: SlidableController(vsync)
        ));
      }
    }

    for(final linkName in workout.linkedExercises){
      if(!(exercisesAndLinks.where((element) => element.isLink).map((e) => e.linkName).contains(linkName))){
        itemsToAdd.add(SlidableExerciseOrLink(
            exercise: null,
            linkName: linkName,
            slidableController: SlidableController(vsync)
        ));
      }
    }

    for (var element in itemsToRemove) {
      element.slidableController.dispose();
      exercisesAndLinks.remove(element);
    }

    // print("to remove");
    // itemsToRemove.forEach((element) {print(element.exercise?.name?? element.linkName);});
    // print("");
    // print("to add");
    // itemsToAdd.forEach((element) {print(element.exercise?.name?? element.linkName);});
    // print("");

    exercisesAndLinks.addAll(itemsToAdd);
    exercisesAndLinks = List.from(exercisesAndLinks.toSet());

    itemsToRemove.clear();
    itemsToAdd.clear();
  }

  void insertLinksAtPlace(){
    final List<SlidableExerciseOrLink> links = exercisesAndLinks.where((element) => element.isLink).toList();
    for (final link in links){
        exercisesAndLinks.remove(link);
        final index = exercisesAndLinks.indexWhere((element) => element.isExercise && element.linkName == link.linkName);
        if(index >= 0){
          exercisesAndLinks.insert(index, link);
        }
    }
  }

  void refreshExercise(Exercise ex){
    final index = exercisesAndLinks.indexWhere((element) => element.isExercise && (element.name == ex.originalName || element.name == ex.name));
    if(index >= 0){
      final item = exercisesAndLinks.removeAt(index);
      exercisesAndLinks.insert(
          index,
          item
      );
    }
  }

  void updateExercisesOrderInWorkoutObject(){
    List<Exercise> orderedExercises = exercisesAndLinks.where((element) => element.isExercise).map((e) => e.exercise!).toList();
    workout.exercises.clear();
    workout.exercises.addAll(orderedExercises);
  }

  void updateExercisesLinks(){
    /// Gives the exercises their correct linkName, if they need one, otherwise null
    String currentLinkName = "";
    for(SlidableExerciseOrLink item in exercisesAndLinks){
      if(item.isExercise){
        if(currentLinkName.isEmpty){
          item.exercise!.linkName = null;
          continue;
        }
        else if(!(item.exercise!.blockLink)){
          item.exercise!.linkName = currentLinkName;
        }
      }
      else{
        currentLinkName = item.linkName!;
      }
    }
    orderExercises();
  }

  void closePanel({bool doClear = false}){
    minPanelHeight = 0;
    refresh();
    Future.delayed(const Duration(milliseconds: 50), (){
      panelController.animatePanelToPosition(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.decelerate
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

    // for (var element in slidableControllers) {
    //   element.dispose();
    // }
    // slidableControllers.clear();
  }

  // void initSlidableControllers(){
  //   slidableControllers = exercisesAndLinks.map((e) => SlidableController(vsync)).toList();
  // }

  void editWorkout({
    Workout? workout,
    ObSickDays? sickDays
  }){

    if (workout != null){
      isSickDays = false;
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
        // initSlidableControllers();
        insertLinksAtPlace();
        orderExercises();
        openPanelWithRefresh();
      }
    }
    else if(sickDays != null){
      clear(doRefresh: false);
      isSickDays = true;
      isUpdating = true;
      this.sickDays = sickDays;
      openPanelWithRefresh();
      minPanelHeight = keepShowingPanelHeightSickDays;
    }

  }

  void setWorkout(Workout w){
    workout = w;
    refreshAllWorkoutDays();
    originalWorkout = Workout.clone(w);
    workoutNameController = TextEditingController(text: w.name);
  }

  void clear({bool doRefresh = true}){
    isSickDays = false;
    workout = Workout();
    originalWorkout = Workout();
    sickDays = ObSickDays(startDate: DateTime.now(), endDate: DateTime.now());
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

  void orderExercises() {
    exercisesAndLinks.sort(((a, b) {
      // print("A");
      // print(a.isExercise);
      // print(a.exercise?.name);
      // print(a.linkName);
      // print(a.exercise?.blockLink);
      // print("B");
      // print(b.isExercise);
      // print(b.exercise?.name);
      // print(b.linkName);
      // print(b.exercise?.blockLink);

      /// blocked Link
      if(a.isExercise && a.exercise!.blockLink){
        // print((a.linkName??"") + " " + a.isExercise.toString());
        // print((b.linkName??"") + " " + b.isExercise.toString());
        /// b is LinkName so a is after b
        if(b.isLink){
          // print("-1");
          // print("");
          return -1;
        }
        /// b is blockedLink, don't change order
        if(b.isExercise && b.exercise!.blockLink){
          // print("0");
          // print("");
          return 0;
        }
        /// b is Exercise with link, a after b
        // print("1");
        // print("");
        return 1;
      }


      if(a.isLink && b.isExercise){
        // print((a.linkName??"") + " " + a.isExercise.toString());
        // print((b.linkName??"") + " " + b.isExercise.toString());
        if(a.linkName == b.linkName || b.exercise!.blockLink){
          // print("-1");
          // print("");
          return -1;
        }
        // print("1");
        // print("");
        return 1;
      }

      if(a.isLink && b.isLink){
        // print((a.linkName??"") + " " + a.isExercise.toString());
        // print((b.linkName??"") + " " + b.isExercise.toString());
        // print("0");
        // print("");
        return 0;
      }

      if(a.isExercise && b.isLink){
        // print((a.linkName??"") + " " + a.isExercise.toString());
        // print((b.linkName??"") + " " + b.isExercise.toString());
        if(a.linkName == b.linkName){
          // print("1");
          // print("");
          return 1;
        } else{
          // print("-1");
          // print("");
          return -1;
        }
      }

      // print("Else");
      // print("");

      return 0;
    }));
  }
  // void removeLink(int index) {
  //   Exercise ex = exercisesAndLinks.removeAt(index);
  //   String? oldLinkName = ex.linkName;
  //   ex.linkName = null;
  //   ex.blockLink = true;
  //   final newIndex = oldLinkName == null? index : exercisesAndLinks.lastIndexWhere((element) => element is Exercise && element.linkName == oldLinkName)+1;
  //   if(newIndex >= 0){
  //     exercisesAndLinks.insert(newIndex, ex);
  //   }
  // }
}

class SlidableExerciseOrLink{
  final Exercise? exercise;
  final String? _linkName;
  final SlidableController slidableController;
  final key = UniqueKey();

  SlidableExerciseOrLink({
    required this.exercise,
    required linkName,
    required this.slidableController
  }) : _linkName = linkName;

  bool get isExercise => exercise != null;
  bool get isLink => !isExercise;
  String get name => exercise?.name?? "";
  String? get linkName => isLink? _linkName : exercise?.linkName;
}