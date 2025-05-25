import 'package:fitness_app/main.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/objects/exercise.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/screens/other_screens/all_exercises_panel/screens/all_exercises/all_exercises.dart';
import 'package:fitness_app/screens/other_screens/all_exercises_panel/screens/new_exercise/new_exercise.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:fitness_app/widgets/slide_up_panel/my_slide_up_panel.dart';
import'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../util/objectbox/ob_exercise.dart';

class AllExercisesPanel extends StatefulWidget {
  const AllExercisesPanel({super.key});

  @override
  State<AllExercisesPanel> createState() => _AllExercisesPanelState();
}

class _AllExercisesPanelState extends State<AllExercisesPanel> {

  late CnAllExercisesPanel cnAllExercisesPanel;
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  late CnNewWorkOutPanel cnNewWorkOutPanel = Provider.of<CnNewWorkOutPanel>(context, listen: false);
  GlobalKey keyTopLetter = GlobalKey();

  @override
  Widget build(BuildContext context) {
    cnAllExercisesPanel = context.read<CnAllExercisesPanel>();
    bool panelIsClosed = context.select<CnAllExercisesPanel, bool>((cn) => cn.panelController.isAttached && cn.panelController.panelPosition == 0);

    pr("Rebuild All Exercises panel");

    return PopScope(
        child: Stack(
          children: [
            GestureDetector(
              onTap: (){
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: MySlideUpPanel(
                bounce: false,
                controller: cnAllExercisesPanel.panelController,
                onPanelSlide: onPanelSlide,
                animationControllerName: "AllExercisesPanel",
                descendantAnimationControllerName: "NewWorkoutPanel",
                panelBuilder: (context, listView){

                  if(panelIsClosed){
                    return const SizedBox();
                  }

                  return Navigator(
                    key: cnAllExercisesPanel.navigatorKey,
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
                  );
                },
              ),
            ),
          ],
        )
    );
  }

  void onPanelSlide(value){
    if(value == 0){
      cnAllExercisesPanel.refresh();
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
  final PanelController panelController = PanelController();
  List<Exercise> exercises = [];
  List<TileItem> filteredExercises = [];
  ScrollController scrollController = ScrollController();
  final int animationTime = 500;
  GlobalKey keySideBar = GlobalKey();
  List<TileItem> characters = [];
  GlobalKey keyFirstListTile = GlobalKey();
  TextEditingController textController = TextEditingController();
  double sizeListTile = 0;
  GlobalKey<NavigatorState>? navigatorKey = GlobalKey();
  Function callBackRefreshAllExercisesList = (){};

  /// padding Side Bar that it scrolls up and down like the panel while sliding
  ValueNotifier<double> verticalPaddingSideBar = ValueNotifier(0);

  CnAllExercisesPanel() {
    initExercises();
  }

  Future initExercises()async{
    exercises.clear();
    final tempExercisesAdded = [];

    final builder = objectbox.exerciseBox.query();
    builder.backlinkMany(ObWorkout_.exercises, ObWorkout_.isTemplate.equals(true));
    final obExercises = await builder.order(ObExercise_.id, flags: Order.descending).build().findAsync();

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

  void jumpToLetter(dynamic details, double heightSideBar){
    if(!scrollController.hasClients){
      return;
    }

    /// initSize of one ListTile
    /// happens only once
    initSize();

    /// calculate local position in SideBar
    RenderBox box = keySideBar.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(details.position);

    /// Transform local position to letter
    final int index = (localPosition.dy ~/ (heightSideBar/characters.length)).clamp(0, characters.length-1);
    final String letter = characters[index].name;

    /// Get Index of first item from list which starts with this letter
    final allExercisesIndex = filteredExercises.indexWhere((element) => element.name[0].toUpperCase() == letter);

    /// calculate jump position and jump
    double position = (allExercisesIndex * sizeListTile + (allExercisesIndex * 0.25) + 15).clamp(0, scrollController.position.maxScrollExtent);
    scrollController.jumpTo(position);
  }

  void initSize(){
    if(sizeListTile == 0){
      sizeListTile = getWidgetSize(keyFirstListTile).height;
    }
  }

  Future openPanel() async{
    reset();
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
    /// Wait 300 ms that the first build is fully done
    await Future.delayed(const Duration(milliseconds: 100));
    // WidgetsBinding.instance.addPostFrameCallback((_) {
      panelController.animatePanelToPosition(
          1,
          duration: Duration(milliseconds: animationTime),
          curve: Curves.fastEaseInToSlowEaseOut
      );
    // });
    return;
  }

  Future closePanel() async{
    await panelController.animatePanelToPosition(
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