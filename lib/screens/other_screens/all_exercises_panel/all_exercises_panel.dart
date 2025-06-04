import 'package:fitness_app/main.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/objects/exercise.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/screens/other_screens/all_exercises_panel/screens/all_exercises/all_exercises.dart';
import 'package:fitness_app/screens/other_screens/all_exercises_panel/screens/new_exercise/new_exercise.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:fitness_app/widgets/exercise_context_id.dart';
import 'package:fitness_app/widgets/slide_up_panel/my_slide_up_panel.dart';
import'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../util/objectbox/ob_exercise.dart';
import '../../../widgets/slide_up_panel/animation_controller_name.dart';
import '../../main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';

class AllExercisesPanel extends StatefulWidget {
  final AllExercisePanelIds id;
  final AnimationControllerName descendantAnimationControllerName;

  const AllExercisesPanel({
    super.key,
    required this.id,
    required this.descendantAnimationControllerName
  });

  @override
  State<AllExercisesPanel> createState() => _AllExercisesPanelState();
}

class _AllExercisesPanelState extends State<AllExercisesPanel> {

  late CnAllExercisesPanel cnAllExercisesPanel;
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  late CnNewWorkOutPanel cnNewWorkOutPanel = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  late final PanelController panelController;
  GlobalKey keyTopLetter = GlobalKey();

  @override
  void initState() {
    super.initState();
    cnAllExercisesPanel = context.read<CnAllExercisesPanel>();
    panelController = cnAllExercisesPanel.getPanelControllerById(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    cnAllExercisesPanel = context.read<CnAllExercisesPanel>();

    return ValueListenableBuilder(
        valueListenable: cnAllExercisesPanel.showContent,
        builder: (context, showContent, _){
          if(!showContent){
            return const SizedBox();
          }

          pr("Rebuild All Exercises panel");

          return PopScope(
            // canPop: false,
            // onPopInvokedWithResult: (_, __){
            //   cnAllExercisesPanel.closePanel(id: widget.id);
            // },
            child: GlobalKeyContext(
              ids: {
                KeyContextId.allExercisePanel: widget.id.toString(),
                KeyContextId.newExercisePanel: "${widget.id}_newExercise"
              },
              child: GestureDetector(
                onTap: (){
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: MySlideUpPanel(
                  bounce: false,
                  controller: panelController,
                  onPanelSlide: onPanelSlide,
                  animationControllerName: AnimationControllerName.allExercisesPanel,
                  descendantAnimationControllerName: widget.descendantAnimationControllerName,
                  panelBuilder: (context, listView){

                    return PopScope(
                      canPop: false,
                      child: Navigator(
                        key: cnAllExercisesPanel.getNavigatorKey(context),
                        initialRoute: '/allExercises',
                        onGenerateRoute: (RouteSettings settings) {
                          final routes = <String, WidgetBuilder>{
                            '/allExercises': (_) => const AllExercises(),
                            '/singleExercise': (_) => const NewExercise(),
                          };

                          final builder = routes[settings.name];
                          if (builder != null) {
                            return MaterialPageRoute(builder: builder, settings: settings);
                          }
                          return null;
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }
    );
  }

  void onPanelSlide(value){
    if(value == 0){
      cnAllExercisesPanel.showContent.value = false;
    }
    if(value == 1){
      cnAllExercisesPanel.refresh();
    }
    if(cnNewWorkOutPanel.panelController.isAttached && cnNewWorkOutPanel.panelController.panelPosition == 0){
      cnBottomMenu.adjustHeight(value);
    }
  }
}

class CnAllExercisesPanel extends ChangeNotifier {
  ValueNotifier<bool> showContent = ValueNotifier(false);
  List<Exercise> exercises = [];
  List<TileItem> filteredExercises = [];
  List<TileItem> characters = [];
  ValueNotifier<String> lastJumpedLetter = ValueNotifier("");

  final int animationTime = 500;

  TextEditingController textController = TextEditingController();
  double sizeListTile = 0;
  StateSetter callBackRefreshAllExercisesList = (_){};
  AllExercisePanelConfig config = AllExercisePanelConfig(
    validator: null,
    onConfirm: (_){}
  );

  final Map<String, GlobalKey> _keysSideBar = {};
  final Map<String, GlobalKey<NavigatorState>?> _keysNavigator = {};
  final Map<String, GlobalKey> _keysFirstListTile = {};
  final Map<String, ScrollController> _scrollControllers = {};
  final Map<String, PanelController> _panelControllers = {};

  CnAllExercisesPanel() {
    refreshExercises();
  }

  GlobalKey getSideBarKey(BuildContext context) {
    final id = GlobalKeyContext.of(context, KeyContextId.allExercisePanel);
    return _keysSideBar.putIfAbsent(id, () => GlobalKey());
  }

  GlobalKey<NavigatorState>? getNavigatorKey(BuildContext context) {
    final id = GlobalKeyContext.of(context, KeyContextId.allExercisePanel);
    return _keysNavigator.putIfAbsent(id, () => GlobalKey());
  }

  GlobalKey getKeyFirstListTile(BuildContext context) {
    final id = GlobalKeyContext.of(context, KeyContextId.allExercisePanel);
    return _keysFirstListTile.putIfAbsent(id, () => GlobalKey());
  }

  ScrollController getScrollController(BuildContext context) {
    final id = GlobalKeyContext.of(context, KeyContextId.allExercisePanel);
    return _scrollControllers.putIfAbsent(id, () => ScrollController());
  }

  // ScrollController getScrollControllerById(String id) {
  //   return _scrollControllers.putIfAbsent(id, () => ScrollController());
  // }

  PanelController getPanelController(BuildContext context) {
    final id = GlobalKeyContext.of(context, KeyContextId.allExercisePanel);
    return _panelControllers.putIfAbsent(id, () => PanelController());
  }

  PanelController getPanelControllerById(AllExercisePanelIds id) {
    return _panelControllers.putIfAbsent(id.toString(), () => PanelController());
  }

  Future refreshExercises()async{
    exercises.clear();
    final tempExercisesAdded = [];

    final builder = objectbox.exerciseBox.query();
    builder.backlinkMany(ObWorkout_.exercises, ObWorkout_.isTemplate.equals(true));
    final obExercises = builder.order(ObExercise_.id, flags: Order.descending).build().find();

    for(ObExercise ex in obExercises){
      if(tempExercisesAdded.contains(ex.name)){
        continue;
      }
      exercises.add(Exercise.fromObExercise(ex));
      tempExercisesAdded.add(ex.name);
    }

    exercises.sort(sortExerciseNames);

    filteredExercises = List.from(exercises.map((e) => TileItem(name: e.name, exercise: e)));
    addCharactersToTileItemList();
  }

  void addCharactersToTileItemList(){
    Set chars = Set.from(filteredExercises.map((e) => e.name[0].startsWithLatinLetter() ? e.name[0].normalizeGermanUmlauts(trimmed: true).toUpperCase() : '#'));

    characters = chars.map((c) => TileItem(name: c)).toList();
    filteredExercises.addAll(characters);

    filteredExercises.sort(sortTileItemElements);
  }

  int sortTileItemElements(TileItem a, TileItem b){
      if(a.exercise == null || b.exercise == null){
        final an = a.name.normalizeGermanUmlauts().toLowerCase();
        final bn = b.name.normalizeGermanUmlauts().toLowerCase();
        if(an == bn){
          if(a.exercise == null){
            return -1;
          }
          return 1;
        }
        if(an.startsWithLatinLetter() && !bn.startsWithLatinLetter()){
          return -1;
        }
        if(!an.startsWithLatinLetter() && bn.startsWithLatinLetter()){
          return 1;
        }
        return an.compareTo(bn);
      }

      return sortExerciseNames(a.exercise!, b.exercise!);
  }

  int sortExerciseNames(Exercise a, Exercise b) {
    final aLatin = a.name.startsWithLatinLetter();
    final bLatin = b.name.startsWithLatinLetter();

    if(aLatin && bLatin){
      if(a.name.toLowerCase() != b.name.toLowerCase()){
        return a.name.normalizeGermanUmlauts().toLowerCase().compareTo(b.name.normalizeGermanUmlauts().toLowerCase());
      }
      return 0;
    }
    else if(aLatin && !bLatin){
      return -1;
    }
    else if(!aLatin && bLatin){
      return 1;
    }
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  void filterExercises(String value) {
    value = value.replaceAll("-", " ").replaceAll("z", "c");
    final tempFiltExs = List.from(exercises.where((ex) => ex.name.toLowerCase().replaceAll("-", " ").replaceAll("z", "c").contains(value.toLowerCase())));
    filteredExercises = List.from(tempFiltExs.map((e) => TileItem(name: e.name, exercise: e)));
    addCharactersToTileItemList();
    refresh();
  }

  void jumpToLetter({
    required dynamic details,
    required double heightSideBar,
    required BuildContext context
  }){
    final sc = getScrollController(context);
    if(!sc.hasClients){
      return;
    }

    /// initSize of one ListTile
    /// happens only once
    initSize(context);

    /// calculate local position in SideBar
    RenderBox box = getSideBarKey(context).currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(details.position);

    /// Transform local position to letter
    final int index = (localPosition.dy ~/ (heightSideBar/characters.length)).clamp(0, characters.length-1);
    final String letter = characters[index].name;
    if(letter == lastJumpedLetter.value){
      return;
    }

    /// Get Index of first item from list which starts with this letter
    final allExercisesIndex = filteredExercises.indexWhere((element) => element.name[0].toUpperCase() == letter);

    /// calculate jump position and jump
    double position = (allExercisesIndex * sizeListTile + (allExercisesIndex * 0.25) + 15).clamp(0, sc.position.maxScrollExtent);
    HapticFeedback.selectionClick();
    sc.jumpTo(position);
    lastJumpedLetter.value = letter;
  }

  void initSize(BuildContext context){
    if(sizeListTile == 0){
      sizeListTile = getWidgetSize(getKeyFirstListTile(context)).height;
    }
  }

  Future openPanel({
    required AllExercisePanelConfig config,
    required AllExercisePanelIds id,
    required BuildContext context
  }) async{
    OverlayEntry ov = blockUserInput(context, duration: null)!;
    await refreshExercises();
    reset();
    this.config = config;
    showContent.value = true;
    await waitForNextFrame();
    final pc = getPanelControllerById(id);
    if(!pc.isAttached){
      return;
    }
    /// jump to minimal position to make initial build
    /// so that the slide up is smooth
    /// also allow the Panel to build it's content since it's a SizedBox()
    /// when closed
    await pc.animatePanelToPosition(
        0.001,
        duration: const Duration(milliseconds: 0)
    );
    /// Trigger Rebuild only for
    /// bool panelIsClosed = context.select<CnAllExercisesPanel, bool>((cn) => cn.panelController.isAttached && cn.panelController.panelPosition == 0);
    refresh();
    /// Wait 100 ms that the first build is fully done
    await Future.delayed(const Duration(milliseconds: 100));
    await pc.animatePanelToPosition(
        1,
        duration: Duration(milliseconds: animationTime),
        curve: Curves.fastEaseInToSlowEaseOut
    );
    ov.remove();
    return;
  }

  Future closePanel({required AllExercisePanelIds id}) async{
    final pc = getPanelControllerById(id);
    if(!pc.isAttached){
      return;
    }
    await pc.animatePanelToPosition(
        0,
        duration: Duration(milliseconds: animationTime-150),
        curve: Curves.decelerate
    );
    reset();
    refresh();
    return;
  }

  void reset(){
    textController.clear();
    filteredExercises = List.from(exercises.map((e) => TileItem(name: e.name, exercise: e)));
    addCharactersToTileItemList();
  }

  void refresh(){
    notifyListeners();
  }
}

class TileItem{
  Exercise? exercise;
  String name;

  TileItem({
    required this.name,
    this.exercise
  });
}

class AllExercisePanelConfig{
  ExerciseNameValidator? validator;
  Function(Exercise) onConfirm;
  List<String> linkedExercises = [];

  AllExercisePanelConfig({
    required this.validator,
    required this.onConfirm,
    this.linkedExercises = const []
  });
}

enum AllExercisePanelIds{
  mainAllExercisesPanel,
  runningWorkoutAllExercisesPanel,
}