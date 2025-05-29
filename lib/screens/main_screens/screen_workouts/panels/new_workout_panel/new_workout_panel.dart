import 'dart:io';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/exercise_and_link_list_view/exercise_and_link_list_view.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/slidable_exercise_or_link.dart';
import 'package:fitness_app/util/backup_helper/backup_functions.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:fitness_app/util/objectbox/ob_exercise.dart';
import 'package:fitness_app/util/objectbox/ob_sick_days.dart';
import 'package:fitness_app/widgets/slide_up_panel/my_slide_up_panel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../../../main.dart';
import '../../../../../objects/exercise.dart';
import '../../../../../objects/workout.dart';
import '../../../../../util/constants.dart';
import '../../../../../util/objectbox/ob_workout.dart';
import '../../../../../widgets/bottom_menu.dart';
import '../../../../../widgets/slide_up_panel/animation_controller_name.dart';
import '../../../../../widgets/standard_popup.dart';
import '../../../screen_workout_history/screen_workout_history.dart';
import '../../screen_workouts.dart';
import '../new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/widgets/header/header.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewWorkOutPanel extends StatefulWidget {
  const NewWorkOutPanel({super.key});

  @override
  State<NewWorkOutPanel> createState() => _NewWorkOutPanelState();
}

class _NewWorkOutPanelState extends State<NewWorkOutPanel> with TickerProviderStateMixin{
  late CnNewWorkOutPanel cnNewWorkout;
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  late CnNewExercisePanel cnNewExercisePanel = Provider.of<CnNewExercisePanel>(context, listen: false);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cnNewWorkout.initVsync(this);
      cnNewWorkout.scrollController.addListener(_listener);
    });
  }

  void _listener(){
    for (SlidableExerciseOrLink item in cnNewWorkout.exercisesAndLinks) {
      SlidableController controller = item.slidableController;
      if(controller.animation.value > 0 && !controller.closing){
        controller.close();
      }
    }
  }

  @override
  void dispose() {
    cnNewWorkout.scrollController.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    cnNewWorkout = context.read<CnNewWorkOutPanel>();

    return ValueListenableBuilder(
        valueListenable: cnNewWorkout.showContent,
        builder: (context, showContent, _){

          if(!showContent){
            return const SizedBox();
          }

          bool blockUi = context.select<CnNewWorkOutPanel, bool>((cn) => cn.blockUi);
          double minPanelHeight = context.select<CnNewWorkOutPanel, double>((cn) => cn.minPanelHeight);

          pr("Workout Panel");

          return PopScope(
              canPop: false,
              onPopInvokedWithResult: (doPop, res){
                if (cnNewWorkout.panelController.isPanelOpen
                    && !cnNewExercisePanel.panelController.isPanelOpen
                    && !tutorialIsRunning
                    && !cnNewWorkout.blockUi
                ){
                  cnNewWorkout.panelController.close();
                }
              },
              child: AbsorbPointer(
                absorbing: blockUi,
                child: MySlideUpPanel(
                    controller: cnNewWorkout.panelController,
                    minHeight: minPanelHeight,
                    backdropEnabled: false,
                    animationControllerName: AnimationControllerName.newWorkoutPanel,
                    descendantAnimationControllerName: AnimationControllerName.screenWorkouts,
                    color: Theme.of(context).primaryColor,
                    onPanelSlide: onPanelSlide,
                    panelBuilder: (context, listView){

                      return GestureDetector(
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
                                      cnNewWorkout.lastPointerPosition = details.position;
                                    },
                                    child: ExerciseAndLinkListView(listView: listView),
                                  ),
                                  NewWorkoutHeader(
                                      tutorialIsRunning: tutorialIsRunning,
                                      currentTutorialStep: currentTutorialStep
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                ),
              )
          );
        }
    );
  }

  void onPanelSlide(value){
    if(value == 0 && cnNewWorkout.minPanelHeight == 0){
      cnNewWorkout.showContent.value = false;
    }
    else if(value == 1){
      cnNewWorkout.panelHasFullyOpened = true;
      cnNewWorkout.refresh();
    }
    cnBottomMenu.adjustHeight(value);
  }
}

class CnNewWorkOutPanel extends ChangeNotifier{
  ValueNotifier<bool> showContent = ValueNotifier(false);
  final GlobalKey keyAddLink = GlobalKey();
  final GlobalKey keyAddExercise = GlobalKey();
  final GlobalKey keyTextFieldWorkoutName = GlobalKey();
  final GlobalKey keyFirstExercise = GlobalKey();
  final FocusNode focusNodeTextFieldWorkoutName = FocusNode();
  final PanelController panelController = PanelController();
  final formKey = GlobalKey<FormState>();
  ObSickDays sickDays = ObSickDays(startDate: DateTime.now(), endDate: DateTime.now());
  Workout workout = Workout();
  Workout originalWorkout = Workout();
  TextEditingController workoutNameController = TextEditingController();
  TextEditingController linkNameController = TextEditingController();
  bool isUpdating = false;
  ScrollController scrollController = ScrollController();
  List<SlidableExerciseOrLink> exercisesAndLinks = [];
  double minPanelHeight = 0;
  double heightSpacerExerciseRow = 8;
  bool isCurrentlyRebuilding = false;
  bool applyNameChanges = false;
  bool isSickDays = false;
  bool allowAnimateFirstExerciseSlide = true;
  bool allowAnimateFirstExerciseDrag = true;
  bool blockUi = false;
  bool panelHasFullyOpened = false;
  double keepShowingPanelHeight = Platform.isAndroid? 180 : 212;
  double keepShowingPanelHeightSickDays = Platform.isAndroid? 210 : 242;
  Offset lastPointerPosition = const Offset(0, 0);
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

  Future openPanelAsTemplate() async{
    if(isUpdating){
      clear();
    }
    workout.isTemplate = true;
    await openPanelWithRefresh();
  }

  void openExercise(Exercise ex, {bool copied = false, required CnNewExercisePanel cnNewExercisePanel}){
    // CnNewExercisePanel cnNewExercisePanel = Provider.of<CnNewExercisePanel>(context, listen: false);

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

    if(panelController.isPanelOpen){
      cnNewExercisePanel.openPanel(
          exercise: exToEdit,
          onConfirm: confirmAddExercise,
          validator: exerciseNameFieldValidator
      );
    }
  }

  String? exerciseNameFieldValidator ({
    required BuildContext context,
    required String? value,
    required CnNewExercisePanel cnNewExercise
  }) {
    value = value?.trim();
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.panelExEnterName;
    }
    else if(exerciseNameExistsInWorkout(workout: workout, exerciseName: cnNewExercise.exercise.name) &&
        cnNewExercise.exercise.originalName?.toLowerCase() != cnNewExercise.exercise.name.toLowerCase()
    ){
      return AppLocalizations.of(context)!.panelExAlreadyExists;
    }
    return null;
  }

  Future openPanelWithRefresh() async{
    showContent.value = true;
    await waitForNextFrame();
    /// jump to minimal position to make initial build
    /// so that the slide up is smooth
    /// also allow the Panel to build it's content since it's a SizedBox()
    /// when closed
    await panelController.animatePanelToPosition(
        0.001,
        duration: const Duration(milliseconds: 0)
    );
    /// Trigger Rebuild only for
    /// bool panelIsClosed = context.select<CnAllExercisesPanel, bool>((cn) => cn.panelController.isAttached && cn.panelController.panelPosition == 0);
    refresh();
    /// Wait 100 ms that the first build is fully done
    await Future.delayed(const Duration(milliseconds: 100));
    await openPanel();
    minPanelHeight = keepShowingPanelHeight;
    /// is needed to move spotifyBar higher when panel is opened
    cnHomepage.refresh();
    /// is needed to move addWorkout button higher when panel is opened
    cnWorkouts.refresh();
    cnWorkoutHistory.refresh();
  }

  Future<void> openPanel() async{
    await panelController.animatePanelToPosition(
        1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastEaseInToSlowEaseOut
    );
  }

  void dismissExercise(SlidableExerciseOrLink ex){
    workout.exercises.remove(ex.exercise);
    updateExercisesAndLinksList();
    refresh();
  }

  void dismissLink(SlidableExerciseOrLink linkName){
    workout.linkedExercises.remove(linkName.linkName);
    updateExercisesAndLinksList();
    updateExercisesLinks();
    refresh();
  }

  Future onCancel(BuildContext context) async{
    CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
    CnNewExercisePanel cnNewExercisePanel = Provider.of<CnNewExercisePanel>(context, listen: false);
    vibrateCancel();
    await closePanel(doClear: true, context: context);
    cnNewExercisePanel.clear();
    formKey.currentState?.reset();
    if(panelController.panelPosition < 0.05){
      showContent.value = false;
      cnBottomMenu.refresh();
    }
  }

  Future onConfirm(BuildContext context) async{

    CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
    CnNewExercisePanel cnNewExercisePanel = Provider.of<CnNewExercisePanel>(context, listen: false);
    CnConfig cnConfig = Provider.of<CnConfig>(context, listen: false);

    if(isSickDays){
      vibrateConfirm();
      sickDays.save();
      await closePanel(doClear: true, context: context);
      cnNewExercisePanel.clear();
      formKey.currentState?.reset();
      saveCurrentData(cnConfig);
      if(cnBottomMenu.index == 0){
        Future.delayed(const Duration(milliseconds: 100), (){
          cnWorkoutHistory.refreshAllWorkouts();
          cnWorkoutHistory.refresh();
        });
      }
    }
    else if (formKey.currentState!.validate()){
      vibrateConfirm();
      updateExercisesOrderInWorkoutObject();
      if(!isUpdating){
        workout.isTemplate = true;
      }
      workout.removeEmptyLinksFromWorkout();
      if(applyNameChanges){
        changeSameNameWorkouts();
      }
      if(hasChangedBodyWeight()){
        changeSameNameExercisesBodyWeight();
      }
      if(cnBottomMenu.index == 0){
        int? index;
        String key = "${workout.date?.year}${workout.date?.month}${workout.date?.day}";
        if(cnWorkoutHistory.indexOfWorkout.keys.contains(key)){
          index = cnWorkoutHistory.indexOfWorkout[key];
          if(index != null){
            Future.delayed(const Duration(milliseconds: 0), (){
              cnWorkoutHistory.scrollController.jumpTo(
                index: index!,
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
      Workout woToSave = Workout.clone(workout);
      woToSave.saveToDatabase();
      await cnWorkouts.refreshAllWorkouts();
      await cnWorkoutHistory.refreshAllWorkouts();
      await closePanel(doClear: true, context: context);

      cnNewExercisePanel.clear();
      saveCurrentData(cnConfig);
    }
    if(panelController.panelPosition < 0.05){
      cnBottomMenu.refresh();
    }
  }

  bool hasChangedNames(){
    if(!workout.isTemplate){
      return false;
    }
    exerciseNewNameMapping.clear();

    /// calculate Exercises that have had a name change
    final changedExercises = originalWorkout.exercises.where(
            (exercise) => workout.exercises.any(
                (ex) => ex.id == exercise.id
                && ex.name != exercise.name
        )
    ).toList();

    /// create exercise name mapping oldName: newName
    for(Exercise ex in changedExercises){
      exerciseNewNameMapping[ex.name] = workout.exercises.firstWhere((exercise) => exercise.id == ex.id).name;
    }

    if((originalWorkout.name != workout.name && originalWorkout.name.isNotEmpty)
        || exerciseNewNameMapping.isNotEmpty){
      return true;
    }

    return false;
  }

  void changeSameNameExercisesBodyWeight(){
    for(Exercise ex in exerciseNewBodyWeight){
      List<ObExercise> sameNameExercises = objectbox.exerciseBox.query(ObExercise_.name.equals(ex.name)).build().find();
      for(ObExercise obEx in sameNameExercises){
        obEx.bodyWeightPercent = ex.bodyWeightPercent;
        objectbox.exerciseBox.put(obEx);
      }
    }
  }

  void changeSameNameWorkouts(){
    final currentObWorkouts = objectbox.workoutBox.query(ObWorkout_.name.equals(originalWorkout.name)).build().find();

    for(ObWorkout wo in currentObWorkouts){
      wo.name = workout.name;
      for(MapEntry mapping in exerciseNewNameMapping.entries){
        if(wo.exercises.map((e) => e.name).contains(mapping.key)){
          wo.exercises.firstWhere((e) => e.name == mapping.key).name = mapping.value;
        }
      }
      wo.save();
    }
  }

  bool hasChangedBodyWeight(){
    if(!workout.isTemplate){
      return false;
    }

    /// calculate Exercises that have had a bodyWeight change
    final changedExercises = workout.exercises.where(
            (exercise) => originalWorkout.exercises.any(
                (ex) => ex.id == exercise.id
                && ex.bodyWeightPercent != exercise.bodyWeightPercent
        )
    ).toList();

    exerciseNewBodyWeight = changedExercises;

    if(exerciseNewBodyWeight.isNotEmpty){
      return true;
    }

    return false;
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

  /// Takes exercisesAndLinks List as current true order, set the links
  void updateExercisesLinks(){
    /// Gives the exercises their correct linkName, if they need one, otherwise null

    /// Save the most current linkName while iterating through the exercisesAndLinks list
    String currentLinkName = "";

    for(SlidableExerciseOrLink item in exercisesAndLinks){

      if(item.isExercise){
        /// when currentLinkName is empty or blockLink of this exercise is true
        if(currentLinkName.isEmpty || item.exercise!.blockLink){
          item.exercise!.linkName = null;
          continue;
        }
        /// when blockLink is false, this exercise receives the linkName of the
        /// first previous link in exercisesAndLinks
        else if(!(item.exercise!.blockLink)){
          item.exercise!.linkName = currentLinkName;
        }
      }

      /// When the item is a link itself, update the currentLinkName
      else{
        currentLinkName = item.linkName!;
      }
    }

    /// Finally order the exercises and links, to move exercises without link
    /// to their correct place
    orderExercises();
  }

  Future closePanel({bool doClear = false, required BuildContext context})async{
    if(MediaQuery.of(context).viewInsets.bottom > 0){
      FocusManager.instance.primaryFocus?.unfocus();
      await Future.delayed(const Duration(milliseconds: 300));
    }
    minPanelHeight = 0;
    refresh();
    await Future.delayed(const Duration(milliseconds: 50), () async{
      await panelController.animatePanelToPosition(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.decelerate
      ).then((value) => {
        // SystemChrome.setPreferredOrientations([]),
        if(doClear){
          clear()
        }
      });
    });
    cnHomepage.refresh();
    cnWorkouts.refresh();
    cnWorkoutHistory.refresh();
  }

  Future editWorkout({
    Workout? workout,
    ObSickDays? sickDays
  }) async{
    if (workout != null){
      isSickDays = false;
      Workout w = Workout.clone(workout);
      /// When same workout
      if(isUpdating && this.workout.id == w.id){
        await openPanelWithRefresh();
      }
      /// When different workout
      else{
        clear(doRefresh: false);
        isUpdating = true;
        setWorkout(w);
        updateExercisesAndLinksList();
        insertLinksAtPlace();
        orderExercises();
        await openPanelWithRefresh();
      }
    }
    else if(sickDays != null){
      clear(doRefresh: false);
      isSickDays = true;
      isUpdating = true;
      this.sickDays = sickDays;
      await openPanelWithRefresh();
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
    panelHasFullyOpened = false;
    formKey.currentState?.reset();
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
        /// b is LinkName so a is after b
        if(b.isLink){
          return -1;
        }
        /// b is blockedLink, don't change order
        if(b.isExercise && b.linkName == null){
          return 0;
        }
        /// b is Exercise with link, a after b
        return 1;
      }


      if(a.isLink && b.isExercise){
        if(a.linkName == b.linkName || b.exercise!.blockLink){
          return -1;
        }
        return 1;
      }

      if(a.isExercise && b.isLink){
        if(a.linkName == b.linkName){
          return 1;
        } else{
          return -1;
        }
      }

      if(a.isExercise && b.isExercise){
        if(a.linkName == b.linkName){
          return 0;
        }
        else if(a.linkName != b.linkName && !a.exercise!.blockLink && !b.exercise!.blockLink){
          return 1;
        }
      }

      return 0;
    }));
  }
}