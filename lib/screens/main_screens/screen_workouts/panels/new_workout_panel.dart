import 'dart:io';
import 'dart:ui';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:collection/collection.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/util/backup_functions.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:fitness_app/util/objectbox/ob_exercise.dart';
import 'package:fitness_app/util/objectbox/ob_sick_days.dart';
import 'package:fitness_app/widgets/cupertino_button_text.dart';
import 'package:fitness_app/widgets/my_slide_up_panel.dart';
import 'package:fitness_app/widgets/spacer_list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  // late final _color = Theme.of(context).primaryColor;
  // final _color = const Color(0xff120a01);
  // final _color = const Color(0xff221b14);
  // final _color = const Color(0xff231b13);
  // Color _color = const Color(0xff663a0b);
  // final _color = const Color(0xff1c1001);
  late final _color = Theme.of(context).primaryColor;
  bool blockUi = false;
  double heightSpacerExerciseRow = 8;
  Offset lastPointerPosition = const Offset(0, 0);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cnNewWorkout.initVsync(this);
      cnNewWorkout.scrollController.addListener(() {
        for (SlidableExerciseOrLink item in cnNewWorkout.exercisesAndLinks) {
          SlidableController controller = item.slidableController;
          if(controller.animation.value > 0 && !controller.closing){
            controller.close();
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      onPopInvoked: (doPop){
        if (cnNewWorkout.panelController.isPanelOpen
            && !cnNewExercisePanel.panelController.isPanelOpen
            && !tutorialIsRunning
            && !blockUi
        ){
          cnNewWorkout.panelController.close();
        }
      },
      child: AbsorbPointer(
        absorbing: blockUi,
        child: MySlideUpPanel(
          controller: cnNewWorkout.panelController,
          minHeight: cnNewWorkout.minPanelHeight,
          backdropEnabled: false,
          animationControllerName: "NewWorkoutPanel",
          descendantAnimationControllerName: "ScreenWorkouts",
          // reduceSizeWorkoutsScreen: true,
          color: _color,
          onPanelSlide: onPanelSlide,
          panelBuilder: (context, listView){
            return ClipRRect(
              borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  if(cnNewWorkout.panelController.isPanelClosed){
                    HapticFeedback.selectionClick();
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
                          Listener(
                            onPointerDown: (details){
                              lastPointerPosition = details.position;
                            },
                            child: SlidableAutoCloseBehavior(
                              child: listView(
                                controller: cnNewWorkout.scrollController,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.only(bottom: 0, right: 20.0, left: 20.0),
                                shrinkWrap: true,
                                autoScroll: !blockUi,
                                children: [
                                  SizedBox(height: cnNewWorkout.workout.isTemplate? 140 : 190),
                                  /// Exercises and Links
                                  ReorderableListView(
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
                                      children: getReorderableChildren(),
                                  ),
                                  if(!cnNewWorkout.isSickDays)
                                    getAddExerciseButton(),

                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 15,
                                        bottom: MediaQuery.of(context).viewInsets.bottom > 0? MediaQuery.of(context).viewInsets.bottom : 80
                                    ),
                                    child: getRowButton(
                                      context: context,
                                      minusWidth: 0,
                                      onPressed: askDeleteWorkout,
                                      icon: Icons.delete,
                                      color: CupertinoColors.destructiveRed
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          getHeader(),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 10,
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: CupertinoButtonText(
                                      onPressed: onCancel,
                                      text: AppLocalizations.of(context)!.cancel,
                                      textAlign: TextAlign.left
                                  )
                              )
                          ),
                          Expanded(
                            flex: 13,
                            child: Align(
                              alignment: Alignment.center,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: cnNewWorkout.workout.isTemplate && cnNewWorkout.workout.isEmpty()
                                    ?getWorkoutOrSickDaysPicker()
                                    :Text(
                                    cnNewWorkout.workout.isTemplate
                                        ? AppLocalizations.of(context)!.panelWoWorkoutTemplate
                                        : cnNewWorkout.isSickDays
                                        ? AppLocalizations.of(context)!.statisticsSick
                                        : " ", /// Due to Fitted Box the length must be greater than 0 //AppLocalizations.of(context)!.panelWoWorkoutFinished,
                                    textScaler: const TextScaler.linear(1.3),
                                    // style: TextStyle(color: Colors.grey)
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 10,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: CupertinoButtonText(
                                  onPressed: (){
                                    if(!hasChangedNames()){
                                      onConfirm();
                                    }
                                    else{
                                      openConfirmNameChangePopUp();
                                    }
                                  },
                                  text: AppLocalizations.of(context)!.save,
                                  textAlign: TextAlign.right
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        ),
      )
    );
  }

  List<Widget> getReorderableChildren(){
    List <Widget> children = [];
    for(int index = 0; index < cnNewWorkout.exercisesAndLinks.length; index+=1) {
      Widget child = const SizedBox();
      if(cnNewWorkout.exercisesAndLinks[index].isExercise) {
        child = getExerciseWithSlideActions(index);
      }
      else if(cnNewWorkout.exercisesAndLinks[index].isLink) {
        child = getLinkWithSlideActions(index);
      }

      if(index == 0 && tutorialIsRunning){
        child = AnimatedBuilder(
          key: ValueKey(cnNewWorkout.exercisesAndLinks[index].name + index.toString()),
          animation: cnNewWorkout.tutorialAnimationController,
          builder: (context, c){

            double value = cnNewWorkout.tutorialAnimationController.value;

            double factor = (1 + value*0.8).clamp(1, 1.05);
            if(value > 0.9375){
              factor = factor - ((value - 0.9375)*0.8);
            }

            double y = 0;
            double distance = 40;

            if(value <= 0.25){
              y = value * distance;
            }
            else if(value <= 0.5){
              y = (0.25 * distance * 2) - (value * distance);
            }
            else if(value <= 0.75){
              y = -((value-0.5) * distance);
            }
            else{
              y = (0.25 * -distance * 2) +((value-0.5) * distance);
            }

            return Transform(
              transform: Matrix4.translationValues(
                  ///x
                  0,
                  ///y
                  y,
                  ///z
                  0),
              child: Transform.scale(
                scale: factor,
                child: c,
              ),
            );
          },
          child: child,
        );
      }

      children.add(child);
    }
    return children;
  }

  Widget getAddExerciseButton(){
    return Padding(
      padding: EdgeInsets.only(
          top: 10,
          // bottom: MediaQuery.of(context).viewInsets.bottom > 0? MediaQuery.of(context).viewInsets.bottom : 80
      ),
      child: getRowButton(
        key: cnNewWorkout.keyAddExercise,
        context: context,
        minusWidth: 0,
        onPressed: () async{
          if(MediaQuery.of(context).viewInsets.bottom > 0){
            FocusManager.instance.primaryFocus?.unfocus();
            await Future.delayed(const Duration(milliseconds: 300));
          }
          addExercise();
        },
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
    );
  }

  Widget getHeader(){
    return Container(
      padding: const EdgeInsets.only(bottom: 0, right: 20.0, left: 20.0, top: 7),
      color: _color,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height:50),
          if (!cnNewWorkout.isSickDays)
            Row(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      focusNode: cnNewWorkout.focusNodeTextFieldWorkoutName,
                      textInputAction: tutorialIsRunning ? TextInputAction.next : TextInputAction.done,
                      onFieldSubmitted: tutorialIsRunning ? (value){
                        if(tutorialIsRunning && value.isNotEmpty){
                          cnHomepage.tutorial?.next();
                          blockUserInput(context, duration: 1500);
                          FocusManager.instance.primaryFocus?.unfocus();
                        }
                      } : null,
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
                      onTap: () async{
                        if(cnNewWorkout.panelController.isPanelClosed){
                          Future.delayed(const Duration(milliseconds: 300), (){
                            HapticFeedback.selectionClick();
                            /// We need to use the panel controllers own open methode because, when we use our open
                            /// panel method, the keyboard gets dismissed (unfocused) by onPanelSlide() cause for some reason
                            /// our methods triggers an exact 0.0 value and the normal panelController.open() methode does not.
                            /// Maybe due to speed of opening the panel
                            cnNewWorkout.openPanel();
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
                                            await getExplainExerciseGroups(context);
                                            // await showDialog(
                                            //     context: context,
                                            //     builder: (context){
                                            //       return Center(
                                            //           child: standardDialog(
                                            //               context: context,
                                            //               child: getExplainExerciseGroups(context)
                                            //           )
                                            //       );
                                            //     }
                                            // );
                                            HapticFeedback.selectionClick();
                                            FocusManager.instance.primaryFocus?.unfocus();
                                          },
                                          icon: const Icon(
                                            Icons.info_outline_rounded,
                                            color: Colors.white,
                                          )
                                      )
                                    ),
                                    onChanged: (value){},
                                  ),
                                ),
                              ],
                            ),
                            onConfirm: (){
                              cnNewWorkout.addLink(context, cn: cnStandardPopUp);
                            },
                            onCancel: (){
                              cnNewWorkout.linkNameController.clear();
                              Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime*2), (){
                                FocusScope.of(context).unfocus();
                              });
                            },
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
                              cnNewWorkout.refresh();
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
              padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10),
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
                          cnNewWorkout.refresh();
                        }
                    )
                ],
              ),
            ),

          if(cnNewWorkout.workout.isTemplate)
            Container(
              height: 25,
              color: _color
              // decoration: BoxDecoration(
              //     gradient:  LinearGradient(
              //         begin: Alignment.bottomCenter,
              //         end: Alignment.topCenter,
              //         colors: [
              //           // Colors.transparent,
              //           // Color(0xff0a0604),
              //           _color.withOpacity(0.0),
              //           _color
              //         ]
              //     )
              // ),
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
                cnNewWorkout.refresh();
                cnWorkouts.refresh();
                cnHomepage.refresh();
              },
            ),
            PullDownMenuItem(
              title: AppLocalizations.of(context)!.statisticsSick,
              onTap: () {
                cnNewWorkout.isSickDays = true;
                cnNewWorkout.minPanelHeight = cnNewWorkout.keepShowingPanelHeightSickDays;
                cnNewWorkout.refresh();
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
              Text(
                  cnNewWorkout.isSickDays
                  ?AppLocalizations.of(context)!.statisticsSick
                  :cnNewWorkout.workout.isTemplate
                      ? AppLocalizations.of(context)!.panelWoWorkoutTemplate
                      : "",//AppLocalizations.of(context)!.panelWoWorkoutFinished,
                  style: const TextStyle(color: Colors.white),
                  textScaler: TextScaler.linear(1.1),
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
    bool withSpacer = cnNewWorkout.exercisesAndLinks.length-1 == index
        || cnNewWorkout.exercisesAndLinks[index+1].linkName != cnNewWorkout.exercisesAndLinks[index].linkName;
    return Column(
      key: ValueKey(cnNewWorkout.exercisesAndLinks[index].linkName),
      children: [
        Slidable(
            controller: cnNewWorkout.exercisesAndLinks[index].slidableController,
            closeOnScroll: false,
            groupTag: 1,
            key: cnNewWorkout.exercisesAndLinks[index].key,
            endActionPane: ActionPane(
              extentRatio: 0.3,
              motion: const ScrollMotion(),
              dismissible: blockUi? null : DismissiblePane(
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
          height: withSpacer? heightSpacerExerciseRow : 0,
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
              extentRatio: 0.3,
              motion: const ScrollMotion(),
              dismissible: blockUi? null : DismissiblePane(
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
              motion: const StretchMotion(),
              children: [
                SlidableAction(
                  padding: const EdgeInsets.all(0),
                  onPressed: (BuildContext context) async{

                    if(!cnNewWorkout.exercisesAndLinks[index].exercise!.blockLink){
                      if(cnNewWorkout.exercisesAndLinks[index].exercise?.linkName == null   /// has no linkname
                          || cnNewWorkout.exercisesAndLinks[index].exercise!.blockLink      /// link is blocked
                          || cnNewWorkout.exercisesAndLinks.length-1 == index               /// is last item
                          || cnNewWorkout.exercisesAndLinks[index].exercise!.linkName
                              != cnNewWorkout.exercisesAndLinks[index+1].linkName           /// is last item in link group
                      ){
                        Future.delayed(const Duration(milliseconds: 200), (){
                          setState(() {
                            changeBlockLinkState(index);
                          });
                        });
                        return;
                      }

                      final newIndex = cnNewWorkout.exercisesAndLinks.lastIndexWhere((element) => element.linkName == cnNewWorkout.exercisesAndLinks[index].linkName);
                      if(newIndex == -1){
                        return;
                      }

                      double distance = 0;
                      for(int i = index; i < newIndex; i++){
                        distance += getWidgetSize(cnNewWorkout.exercisesAndLinks[index].key).height;
                      }
                      await moveTile(startY: lastPointerPosition.dy, endY: lastPointerPosition.dy + distance);

                      setState(() {
                        changeBlockLinkState(newIndex);
                      });
                    }

                    else{
                      final element = cnNewWorkout.exercisesAndLinks.lastWhereIndexedOrNull((previousIndex, element) => previousIndex < index && element.linkName != null);
                      if(element == null){
                        Future.delayed(const Duration(milliseconds: 200), (){
                          setState(() {
                            changeBlockLinkState(index);
                          });
                        });
                        return;
                      }

                      final newIndex = cnNewWorkout.exercisesAndLinks.indexOf(element);
                      if(index - newIndex == 1){
                        Future.delayed(const Duration(milliseconds: 200), (){
                          setState(() {
                            changeBlockLinkState(index);
                          });
                        });
                        return;
                      }
                      else{
                        final Offset widgetPosition = getWidgetPosition(cnNewWorkout.exercisesAndLinks[index].key);

                        double distance = 0;
                        for(int i = newIndex+1; i < index; i++){
                          final element = cnNewWorkout.exercisesAndLinks[index];
                          distance += getWidgetSize(element.key).height;
                          if(element.isExercise && element.exercise!.blockLink){
                            distance += heightSpacerExerciseRow;
                          }
                        }
                        await moveTile(startY: widgetPosition.dy, endY: widgetPosition.dy - distance);

                        setState(() {
                          changeBlockLinkState(newIndex+1);
                        });
                      }
                    }
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
              ],
            ),
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: hasLink? 70 : 75,
                child: ClipRRect(
                  borderRadius: hasLink
                      ? (nextExercise?.linkName != cnNewWorkout.exercisesAndLinks[index].linkName || nextExercise == null
                      ? const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8))
                      : BorderRadius.zero)
                      : BorderRadius.circular(8),
                  child: Material(
                    color: Theme.of(context).cardColor,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: (){
                        if(MediaQuery.of(context).viewInsets.bottom <= 0){
                          openExercise(cnNewWorkout.exercisesAndLinks[index].exercise!);
                        } else{
                          FocusScope.of(context).unfocus();
                        }
                      },
                      child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ExerciseRow(
                              exercise: cnNewWorkout.exercisesAndLinks[index].exercise!,
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
                      ),
                    ),
                  ),
                )
            )
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: withSpacer? heightSpacerExerciseRow : 0,
        )
        // if(withSpacer)
        //   const SizedBox(height: 8,)
      ],
    );
  }

  Future moveTile({
    required double startY,
    required double endY
  }) async{
    setState(() {
      blockUi = true;
    });

    const int pointer = 1000000;

    GestureBinding.instance.handlePointerEvent(
      PointerDownEvent(position: Offset(100, startY), pointer: pointer),
    );

    await Future.delayed(Duration(milliseconds: 600));

    int steps = 35;
    final delta =  (endY - startY)/steps;
    for (int i = 1; i <= steps; i++) {
      GestureBinding.instance.handlePointerEvent(
        PointerMoveEvent(delta: Offset(0, delta), pointer: pointer),
      );

      await Future.delayed(Duration(milliseconds: 6));
    }

    // 3. Finger loslassen (Drag beenden)
    GestureBinding.instance.handlePointerEvent(
      PointerUpEvent(position: Offset(100, endY), pointer: pointer),
    );

    await Future.delayed(Duration(milliseconds: 300));

    setState(() {
      blockUi = false;
    });
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

  bool hasChangedBodyWeight(){
    if(!cnNewWorkout.workout.isTemplate){
      return false;
    }

    /// calculate Exercises that have had a bodyWeight change
    final changedExercises = cnNewWorkout.workout.exercises.where(
            (exercise) => cnNewWorkout.originalWorkout.exercises.any(
                (ex) => ex.id == exercise.id
                && ex.bodyWeightPercent != exercise.bodyWeightPercent
        )
    ).toList();

    cnNewWorkout.exerciseNewBodyWeight = changedExercises;

    if(cnNewWorkout.exerciseNewBodyWeight.isNotEmpty){
      return true;
    }

    return false;
  }

  void dismissExercise(SlidableExerciseOrLink ex){
    cnNewWorkout.workout.exercises.remove(ex.exercise);
    cnNewWorkout.updateExercisesAndLinksList();
    cnNewWorkout.refresh();
  }

  void dismissLink(SlidableExerciseOrLink linkName){
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
    else{
      cnNewExercisePanel.openPanel(workout: cnNewWorkout.workout, onConfirm: cnNewWorkout.confirmAddExercise);
    }
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
      /// Otherwise the user is editing the exercise so we keep track of the original name in case
      /// the user changes the exercises name
      exToEdit.originalName = ex.name;
    }

    if(cnNewWorkout.panelController.isPanelOpen){
      cnNewExercisePanel.openPanel(workout: cnNewWorkout.workout, exercise: exToEdit, onConfirm: cnNewWorkout.confirmAddExercise);
      cnNewExercisePanel.refresh();
    }
  }

  void onCancel(){
    vibrateCancel();
    cnNewWorkout.closePanel(doClear: true, context: context);
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
    cnNewWorkout.closePanel(doClear: true, context: context);
    cnNewExercisePanel.clear();
    saveCurrentData(cnConfig);
  }

  void onConfirm() async{
    if(cnNewWorkout.isSickDays){
      vibrateConfirm();
      cnNewWorkout.sickDays.save();
      cnNewWorkout.closePanel(doClear: true, context: context);
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
      if(hasChangedBodyWeight()){
        changeSameNameExercisesBodyWeight();
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
      cnNewWorkout.closePanel(doClear: true, context: context);
      cnNewExercisePanel.clear();
      saveCurrentData(cnConfig);
    }
    if(cnNewWorkout.panelController.panelPosition < 0.05){
      cnBottomMenu.refresh();
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

  void changeSameNameExercisesBodyWeight(){
    for(Exercise ex in cnNewWorkout.exerciseNewBodyWeight){
      List<ObExercise> sameNameExercises = objectbox.exerciseBox.query(ObExercise_.name.equals(ex.name)).build().find();
      for(ObExercise obEx in sameNameExercises){
        obEx.bodyWeightPercent = ex.bodyWeightPercent;
        objectbox.exerciseBox.put(obEx);
      }
    }



    // for(ObWorkout wo in currentObWorkouts){
    //   wo.name = cnNewWorkout.workout.name;
    //   for(MapEntry mapping in cnNewWorkout.exerciseNewNameMapping.entries){
    //     if(wo.exercises.map((e) => e.name).contains(mapping.key)){
    //       wo.exercises.firstWhere((e) => e.name == mapping.key).name = mapping.value;
    //     }
    //   }
    //   wo.save();
    // }
  }

  void onPanelSlide(value){
    // cnWorkouts.animationControllerWorkoutsScreen.value = value*0.5;
    if(value == 0){
      // FocusScope.of(context).unfocus();
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

  void changeBlockLinkState(int index) {
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
  bool allowAnimateFirstExerciseSlide = true;
  bool allowAnimateFirstExerciseDrag = true;
  double keepShowingPanelHeight = Platform.isAndroid? 180 : 212;
  double keepShowingPanelHeightSickDays = Platform.isAndroid? 210 : 242;
  Map<String, String> exerciseNewNameMapping = {};
  List<Exercise> exerciseNewBodyWeight = [];
  late CnHomepage cnHomepage;
  late CnWorkouts cnWorkouts;
  late CnWorkoutHistory cnWorkoutHistory;
  late Map<DateTime, dynamic> allWorkoutDates = getAllWorkoutDays();
  late TickerProvider vsync;
  late final AnimationController tutorialAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: vsync
  );

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
            dates[date].add("Sick");
          }
          else{
            dates[date] = [dates[date], "Sick"];
          }
        }
        else{
          dates[date] = "Sick";
        }
      }
    }

    return dates;
  }

  void addLink(BuildContext context, {CnStandardPopUp? cn, String? linkName}){
    final newLinkName = linkName?? linkNameController.text;
    if(newLinkName.isNotEmpty && !workout.linkedExercises.contains(newLinkName)){
      workout.linkedExercises.add(newLinkName);
      updateExercisesAndLinksList();
      updateExercisesLinks();
      refresh();
    }
    linkNameController.clear();
    if(cn != null){
      Future.delayed(Duration(milliseconds: cn.animationTime*2), (){
        FocusManager.instance.primaryFocus?.unfocus();
      });
    } else{
      FocusManager.instance.primaryFocus?.unfocus();
    }
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
      exercisesAndLinks[index].exercise = ex;
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

  void closePanel({bool doClear = false, required BuildContext context})async{
    if(MediaQuery.of(context).viewInsets.bottom > 0){
      FocusManager.instance.primaryFocus?.unfocus();
      await Future.delayed(const Duration(milliseconds: 300));
    }
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
  }

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
    exerciseNewBodyWeight.clear();
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

  // Future hidePanel(BuildContext context) async{
  //   if(minPanelHeight > 50){
  //     minPanelHeight = minPanelHeight * 0.95;
  //     print("Min Panel height: $minPanelHeight");
  //     refresh();
  //     await Future.delayed(const Duration(milliseconds: 16), (){});
  //     await hidePanel(context);
  //     // final maxHeight = MediaQuery.of(context).size.height - (Platform.isAndroid? 50 : 70);
  //     // minPanelHeight = 1;
  //     // await panelController.animatePanelToPosition(keepShowingPanelHeight/maxHeight, duration: Duration(milliseconds: 0));
  //     // refresh();
  //     // await panelController.animatePanelToPosition(0, duration: Duration(milliseconds: 300));
  //   }
  // }
  //
  // Future showHidedPanel(BuildContext context) async{
  //   if(minPanelHeight < keepShowingPanelHeight){
  //     minPanelHeight = minPanelHeight + 5;
  //     print("Min Panel height: $minPanelHeight");
  //     refresh();
  //     await Future.delayed(const Duration(milliseconds: 16), (){});
  //     await showHidedPanel(context);
  //   } else{
  //     minPanelHeight = keepShowingPanelHeight;
  //     refresh();
  //   }
  // }

  Future animateFirstExerciseSlide({int duration = 1500}) async{
    if(allowAnimateFirstExerciseSlide){
      await Future.delayed(Duration(milliseconds: duration), ()async{});
    }
    if(allowAnimateFirstExerciseSlide){
      await exercisesAndLinks.first.slidableController.openStartActionPane(duration: const Duration(milliseconds: 1000), curve: Curves.fastEaseInToSlowEaseOut);
    }
    if(allowAnimateFirstExerciseSlide){
      await Future.delayed(const Duration(milliseconds: 300), ()async{});
    }
    if(allowAnimateFirstExerciseSlide){
      await exercisesAndLinks.first.slidableController.close(duration: const Duration(milliseconds: 1000), curve: Curves.fastEaseInToSlowEaseOut);
    }
    if(allowAnimateFirstExerciseSlide){
      await exercisesAndLinks.first.slidableController.openEndActionPane(duration: const Duration(milliseconds: 1000), curve: Curves.fastEaseInToSlowEaseOut);
    }
    if(allowAnimateFirstExerciseSlide){
      await Future.delayed(const Duration(milliseconds: 300), ()async{});
    }
    if(allowAnimateFirstExerciseSlide){
      await exercisesAndLinks.first.slidableController.close(duration: const Duration(milliseconds: 1000), curve: Curves.fastEaseInToSlowEaseOut);
    }
    if(allowAnimateFirstExerciseSlide){
      animateFirstExerciseSlide(duration: 300);
    }
  }

  Future animateFirstExerciseDrag() async{
    if(allowAnimateFirstExerciseDrag){
      await tutorialAnimationController.forward();
    }
    if(allowAnimateFirstExerciseDrag){
      await Future.delayed(const Duration(milliseconds: 800), () async{});
    }
    if(allowAnimateFirstExerciseDrag){
      await tutorialAnimationController.reverse();
    }
    if(allowAnimateFirstExerciseDrag){
      await Future.delayed(const Duration(milliseconds: 500), (){});
    }
    if(allowAnimateFirstExerciseDrag){
      animateFirstExerciseDrag();
    }
  }


  void refresh(){
    notifyListeners();
  }

  void orderExercises() {
    exercisesAndLinks.sort(((a, b) {

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
        if(b.isExercise && b.linkName == null /*&& b.exercise!.blockLink*/){
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
}

class SlidableExerciseOrLink{
  Exercise? exercise;
  String? _linkName;
  final SlidableController slidableController;
  final key = GlobalKey();

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