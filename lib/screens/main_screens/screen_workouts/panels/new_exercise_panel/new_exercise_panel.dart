import 'package:fitness_app/assets/custom_icons/my_icons_icons.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/header/new_exercise_header.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/widgets/set_list_view/set_list_view.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/widgets/slide_up_panel/my_slide_up_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../../../objects/exercise.dart';
import '../../../../../util/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../widgets/bottom_menu.dart';
import '../../../../../widgets/exercise_context_id.dart';
import '../../../../../widgets/slide_up_panel/animation_controller_name.dart';

class NewExercisePanel extends StatefulWidget {
  final String id;

  const NewExercisePanel({
    super.key,
    required this.id
  });

  @override
  State<NewExercisePanel> createState() => _NewExercisePanelState();
}

class _NewExercisePanelState extends State<NewExercisePanel> with TickerProviderStateMixin{
  late CnNewExercisePanel cnNewExercise;
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  late CnNewWorkOutPanel cnNewWorkOutPanel = Provider.of<CnNewWorkOutPanel>(context, listen: false);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cnNewExercise.initVsync(this);
    });
  }

  @override
  void dispose() {
    cnNewExercise.onDispose(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // cnNewExercise = Provider.of<CnNewExercisePanel>(context);
    cnNewExercise = context.read<CnNewExercisePanel>();
    bool panelIsClosed = context.select<CnNewExercisePanel, bool>((cn) => !cn.panelController.isAttached || cn.panelController.panelPosition == 0);

    pr("Exercise Panel");

    return GlobalKeyContext(
      ids: {KeyContextId.newExercisePanel: widget.id},
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (doPop, res){
          if (cnNewExercise.panelController.isPanelOpen){
            cnNewExercise.closePanel(doClear: false, context: context);
          }
        },
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: MySlideUpPanel(
            key: cnNewExercise.key,
            onPanelSlide: onPanelSlide,
            controller: cnNewExercise.panelController,
            backdropOpacity: 0.25,
            color: Theme.of(context).primaryColor,
            animationControllerName: AnimationControllerName.newExercisePanel,
            descendantAnimationControllerName: cnBottomMenu.index == 2
                ? AnimationControllerName.screenStatistics
                : AnimationControllerName.newWorkoutPanel,
            panelBuilder: (context, listView) {

              if(panelIsClosed){
                return const SizedBox();
              }

              return Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: const SetListView(),
                  ),

                  const NewExerciseHeader()
                ],
              );
            }
          )
        ),
      ),
    );
  }

  void onPanelSlide(value){
    if(value == 0){
      cnNewExercise.refresh();
    }

    if(cnNewWorkOutPanel.panelController.panelPosition < 0.1){
      cnBottomMenu.adjustHeight(value);
    }
  }
}

class CnNewExercisePanel extends ChangeNotifier {
  final PanelController panelController = PanelController();

  final GlobalKey keyHeader = GlobalKey();
  final GlobalKey keyExerciseName = GlobalKey();
  final GlobalKey keySetRow = GlobalKey();
  final GlobalKey keySaveButton = GlobalKey();
  final GlobalKey keyAddSet = GlobalKey();
  // final formKey = GlobalKey<FormState>();
  final Map<String, GlobalKey<FormState>> _formKeys = {};
  final Map<String, ScrollController> _scrollControllers = {};

  static const String defaultContextId = "panel";

  final FocusNode focusNodeTextFieldExerciseName = FocusNode();
  Key key = UniqueKey();
  Exercise exercise = Exercise();
  TextEditingController exerciseNameController = TextEditingController();
  // ScrollController scrollController = ScrollController();
  late List<Key> slidableKeys = exercise.generateKeyForEachSet();
  Function(Exercise ex)? onConfirm;
  ExerciseNameValidator? exerciseNameFieldValidator;
  final int animationTime = 500;
  late TickerProvider vsync;
  double iconSize = 25;
  double heightHeader = 140.0;
  double widthSetWeightAmount = 55;
  double heightSetWeightAmount = 35;
  final TextStyle _style = const TextStyle(color: Colors.white, fontSize: 18);
  int currentIndexFocus = 0;
  int currentIndexWeightOrAmount = 0;
  List<String> linkedExercises = [];

  late List<List<TextEditingController>> controllers = exercise.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList();
  // late List<List<GlobalKey>> ensureVisibleKeys = exercise.sets.map((e) => ([GlobalKey(), GlobalKey()])).toList();
  late List<List<FocusNode>> focusNodes = exercise.sets.map((e) => ([FocusNode(), FocusNode()])).toList();

  GlobalKey<FormState> getFormKey(BuildContext context) {
    final id = GlobalKeyContext.of(context, KeyContextId.newExercisePanel);
    return _formKeys.putIfAbsent(id, () => GlobalKey<FormState>());
  }

  ScrollController getScrollController(BuildContext context) {
    final id = GlobalKeyContext.of(context, KeyContextId.newExercisePanel);
    return _scrollControllers.putIfAbsent(id, () => ScrollController());
  }

  GlobalKey? getKeySaveButton(BuildContext context) {
    return isDefaultContext(context)? keySaveButton : null;
  }

  GlobalKey? getKeyExerciseName(BuildContext context) {
    return isDefaultContext(context)? keyExerciseName : null;
  }

  GlobalKey? getKeyHeader(BuildContext context) {
    return isDefaultContext(context)? keyHeader : null;
  }

  GlobalKey? getKeyAddSet(BuildContext context) {
    return isDefaultContext(context)? keyAddSet : null;
  }

  bool isDefaultContext(context){
    return GlobalKeyContext.of(context, KeyContextId.newExercisePanel) == defaultContextId;
  }

  void onDispose(BuildContext context){
    final sc = getScrollController(context);
    sc.dispose();
    _scrollControllers.remove(sc);
  }

  CnNewExercisePanel(){
    clear();
  }

  void initVsync(TickerProvider vsync){
    this.vsync = vsync;
  }

  void onCancel(BuildContext context){
    closePanel(doClear: true, context: context);
    getFormKey(context).currentState?.reset();
    vibrateCancel();
  }

  void dismissSet(int index){
    exercise.sets.removeAt(index);
    slidableKeys.removeAt(index);
    controllers.removeAt(index);
    // ensureVisibleKeys.removeAt(index);
    focusNodes.removeAt(index);
    refresh();
  }

  void addSet({
    required double insetsBottom,
    required double screenHeight,
    required BuildContext context
  }){
    final previousSet = exercise.sets.last;
    exercise.addSet(weight: previousSet.weight, amount: previousSet.amount);
    slidableKeys.add(UniqueKey());
    controllers.add([
      TextEditingController(text: controllers.last[0].text),
      TextEditingController(text: controllers.last[1].text)
    ]);
    // ensureVisibleKeys.add([GlobalKey(), GlobalKey()]);
    focusNodes.add([FocusNode(), FocusNode()]);
    final RenderObject? renderObject = getKeyAddSet(context)?.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final Offset widgetPosition = renderObject.localToGlobal(Offset.zero);
      final Size widgetSize = renderObject.size;
      final isVisible = widgetPosition.dy + widgetSize.height * 80 > 0 && widgetPosition.dy + 80 + insetsBottom < screenHeight;
      if(!isVisible){
        final sc = getScrollController(context);
        if(sc.hasClients){
          sc.jumpTo(sc.position.pixels+41);
        }
      }
    }
    refresh();
  }

  void setExercise(Exercise ex){
    exercise = ex;
    slidableKeys = exercise.generateKeyForEachSet();
    controllers = exercise.sets.map((set) => ([TextEditingController(text: "${set.weightAsTrimmedDouble}"), TextEditingController(text: "${exercise.categoryIsReps()? (set.amount) : parseTextControllerAmountToTime(set.amount)[1]}")])).toList();
    // ensureVisibleKeys = exercise.sets.map((e) => ([GlobalKey(), GlobalKey()])).toList();
    focusNodes = exercise.sets.map((e) => ([FocusNode(), FocusNode()])).toList();
    exerciseNameController = TextEditingController(text: exercise.name);
  }

  void clearTextControllers(){
    for (var element in controllers) {
      element[0].text = "";
      element[1].text = "";
    }
    for (SingleSet set in exercise.sets) {
      set.weight = null;
      set.amount = null;
    }
  }

  void closePanelAndSaveExercise(BuildContext context) async{
    if (getFormKey(context).currentState!.validate() && exercise.name.isNotEmpty) {
      final copy = Exercise.copy(exercise);
      copy.removeEmptySets();

      if(copy.sets.isNotEmpty){
        await closePanel(doClear: true, context: context);
        exercise.removeEmptySets();
        if(onConfirm != null){
          onConfirm!(exercise);
        }
      }
      else{
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.panelWoAddAtLeastOneSet,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.SNACKBAR,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[800]?.withValues(alpha: 0.9),
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }
  }

  /// SELECTORS
  Widget getRestInSecondsSelector({
    required BuildContext context,
    // required Exercise exercise,
    // required Function refresh
  }) {
    return getSelectRestInSeconds(
        currentTime: exercise.restInSeconds,
        context: context,
        child: CupertinoListTile(
          leading: Icon(CupertinoIcons.timer, size: iconSize),
          title: Row(
            children: [
              Text(AppLocalizations.of(context)!.restTime, style: _style),
              const Spacer(),
              Text(mapRestInSecondsToString(restInSeconds: exercise.restInSeconds), style: _style),
              const SizedBox(width: 10),
            ],
          ),
          trailing: trailingChoice(),
        ),
        onConfirm: (dynamic value){
          if(value is int){
            exercise.restInSeconds = value;
            refresh();
          }
          else if (value == AppLocalizations.of(context)!.custom){
            showDialogMinuteSecondPicker(
                context: context,
                initialTimeDuration: Duration(minutes: exercise.restInSeconds~/60, seconds: exercise.restInSeconds%60),
                onConfirm: (Duration newDuration){
                  exercise.restInSeconds = newDuration.inSeconds;
                }
            ).then((value) => refresh());
          }
          else{
            exercise.restInSeconds = 0;
            refresh();
          }
        }
    );
  }

  Widget getSeatLevelSelector({
    required BuildContext context,
    // required Exercise exercise,
    // required Function refresh
  }) {
    return getSelectSeatLevel(
        currentSeatLevel: exercise.seatLevel,
        context: context,
        onConfirm: (dynamic value){
          if(value is int){
            exercise.seatLevel = value;
            refresh();
          }
          else if(value == AppLocalizations.of(context)!.clear){
            exercise.seatLevel = null;
            refresh();
          }
        },
        child: CupertinoListTile(
          leading: Icon(Icons.airline_seat_recline_normal, size: iconSize),
          trailing: trailingChoice(),
          title: Row(
            children: [
              Text(AppLocalizations.of(context)!.seatLevel, style: _style),
              const Spacer(),
              Text(exercise.seatLevel == null? "-" : exercise.seatLevel.toString(), style: _style),
              const SizedBox(width: 10)
            ],
          ),
        )
    );
  }

  Widget getExerciseCategorySelector({
    required BuildContext context,
    required bool isTemplate,
    // required Exercise exercise,
    // required Function refresh
  }) {
    Widget child = CupertinoListTile(
        leading: Icon(MyIcons.tags, size: iconSize-3),
        title: Row(
          children: [
            Text(AppLocalizations.of(context)!.category, style: _style),
            const Spacer(),
            Text(exercise.getCategoryName(), style: _style),
            const SizedBox(width: 10)
          ],
        ),
        trailing: isTemplate? trailingChoice() : null
    );

    if(isTemplate){
      return getSelectCategory(
          context: context,
          currentCategory: exercise.category,
          onConfirm: (int category){
            exercise.category = category;
            refresh();
            clearTextControllers();
          },
          child: child
      );
    }

    return CupertinoButton(
        onPressed: (){
          // HapticFeedback.selectionClick();
          notificationPopUp(
              context: context,
              title: AppLocalizations.of(context)!.panelExChangeCategoryHeader,
              message: AppLocalizations.of(context)!.panelExChangeCategoryText
          );
        },
        padding: EdgeInsets.zero,
        child: child
    );
  }

  Widget getBodyWeightPercentSelector({
    required BuildContext context,
    required bool isTemplate,
    // required Exercise exercise,
    required Function refresh
  }) {
    Widget child = CupertinoListTile(
        leading: Icon(MyIcons.weight, size: iconSize-4),
        title: Row(
          children: [
            Text(AppLocalizations.of(context)!.bodyweight, style: _style),
            const Spacer(),
            Text("${(exercise.bodyWeightPercent * 100).toInt()} %", style: _style),
            const SizedBox(width: 10),
          ],
        ),
        trailing: isTemplate? trailingChoice() : null
    );

    if(isTemplate){
      return getSelectBodyWeightPercent(
          context: context,
          currentBodyWeightPercent: exercise.bodyWeightPercent,
          onConfirm: (int bodyWeight){
            exercise.bodyWeightPercent = bodyWeight/100;
            refresh();
          },
          child: child
      );
    }

    return CupertinoButton(
        onPressed: (){
          // HapticFeedback.selectionClick();
          notificationPopUp(
              context: context,
              title: AppLocalizations.of(context)!.panelExChangeBodyWeightHeader,
              message: AppLocalizations.of(context)!.panelExChangeBodyWeightText
          );
        },
        padding: EdgeInsets.zero,
        child: child
    );
  }

  Widget getSelectLink({
    Key? key,
    // required BuildContext context,
  }) {
    return PullDownButton(
      key: key,
      buttonAnchor: PullDownMenuAnchor.start,
      routeTheme: routeTheme,
      itemBuilder: (context) {
        List linkNames = ["-"] + linkedExercises;
        List<PullDownMenuItem> linkNameWidgets = List.generate(linkNames.length, (index) => PullDownMenuItem.selectable(
            selected: exercise.linkName == linkNames[index] || index == 0 && exercise.linkName == null,
            title: linkNames[index],
            onTap: () {
              HapticFeedback.selectionClick();
              FocusManager.instance.primaryFocus?.unfocus();
              Future.delayed(const Duration(milliseconds: 200), (){
                exercise.linkName = linkNames[index] == "-"? null : linkNames[index];
                exercise.blockLink = linkNames[index] == "-";
                refresh();
                // onConfirm(linkNames[index]);
              });
            })
        );
        return linkNameWidgets;
      },
      onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
      buttonBuilder: (context, showMenu) => CupertinoButton(
          onPressed: (){
            HapticFeedback.selectionClick();
            showMenu();
          },
          padding: EdgeInsets.zero,
          child: CupertinoListTile(
            leading: const Icon(Icons.link, size: 22),
            title: Row(
              children: [
                Text(AppLocalizations.of(context)!.runningWorkoutGroup, style: _style),
                const Spacer(),
                Text(exercise.linkName?? "-", style: _style),
                const SizedBox(width: 10),
              ],
            ),
            trailing: trailingChoice(),
          )
      ),
    );
  }

  Future openPanel({
    Exercise? exercise,
    Function(Exercise ex)? onConfirm,
    ExerciseNameValidator? validator
  })async{
    clear();
    if(exercise != null){
      setExercise(exercise);
    }

    exerciseNameFieldValidator = validator;
    this.onConfirm = onConfirm;
    // HapticFeedback.selectionClick();
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
    await panelController.animatePanelToPosition(
        1,
        duration: Duration(milliseconds: animationTime),
        curve: Curves.fastEaseInToSlowEaseOut
    );
    return;
  }

  Future closePanel({bool doClear = false, required BuildContext context}) async {
    if(MediaQuery.of(context).viewInsets.bottom > 0){
      FocusManager.instance.primaryFocus?.unfocus();
      await Future.delayed(const Duration(milliseconds: 300));
    }
    await panelController.animatePanelToPosition(
        0,
        duration: Duration(milliseconds: animationTime-150),
        curve: Curves.decelerate
    );
    return;
  }

  void clear({bool withRefresh = true}){
    exerciseNameFieldValidator = null;
    linkedExercises = [];
    exercise = Exercise();
    for(MapEntry<String, GlobalKey<FormState>> e in _formKeys.entries){
      e.value.currentState?.reset();
    }
    controllers = exercise.sets.map((e) => ([TextEditingController(), TextEditingController()])).toList();
    exerciseNameController = TextEditingController();
    focusNodes = exercise.sets.map((e) => ([FocusNode(), FocusNode()])).toList();
    if(withRefresh){
      refresh();
    }
  }

  void refresh(){
    notifyListeners();
  }
}

typedef ExerciseNameValidator = String? Function({
  required BuildContext context,
  required String? value,
  required CnNewExercisePanel cnNewExercise,
});