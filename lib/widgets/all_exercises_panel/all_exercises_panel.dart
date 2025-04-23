import 'dart:convert';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/objectbox.g.dart';
import 'package:fitness_app/objects/exercise.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/widgets/all_exercises_panel/top_header_letter.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:fitness_app/widgets/slide_up_panel/my_slide_up_panel.dart';
import 'package:flutter/cupertino.dart';
import'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class AllExercisesPanel extends StatefulWidget {
  const AllExercisesPanel({super.key});

  @override
  State<AllExercisesPanel> createState() => _AllExercisesPanelState();
}

class _AllExercisesPanelState extends State<AllExercisesPanel> {

  late CnAllExercisesPanel cnAllExercisesPanel;
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  double sizeListTile = 0;
  double verticalPaddingSideBar = 0;
  GlobalKey keyTopLetter = GlobalKey();

  @override
  Widget build(BuildContext context) {
    cnAllExercisesPanel = Provider.of<CnAllExercisesPanel>(context);
    final List<TileItem> exs = cnAllExercisesPanel.filteredExercises;

    return PopScope(
        child: Stack(
          children: [
            GestureDetector(
              onTap: (){
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: MySlideUpPanel(
                controller: cnAllExercisesPanel.panelController,
                onPanelSlide: onPanelSlide,
                animationControllerName: "AllExercisesPanel",
                descendantAnimationControllerName: "ScreenWorkouts",
                panelBuilder: (context, listView){
                  return Stack(
                    children: [
                      listView(
                        controller: cnAllExercisesPanel.scrollController,
                        padding: const EdgeInsets.only(left: 10, right: 25),
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: exs.length,
                        separatorBuilder: (context, index){
                          return Container(
                            height: 0.25,
                            margin: const EdgeInsets.only(left: 20),
                            color: CupertinoColors.systemGrey,
                          );
                        },
                        itemBuilder: (context, index){
                          EdgeInsets padding = exs[index].exercise == null? EdgeInsets.only(top: 21, left: 20, bottom: 5) : EdgeInsets.only(top: 13, left: 20, bottom: 13);

                          return Padding(
                            padding: EdgeInsets.only(bottom: index == exs.length-1 ? 80 + MediaQuery.of(context).viewInsets.bottom : 0),
                            child: CupertinoButton(
                              key: index == 0 ? cnAllExercisesPanel.keyFirstListTile : null,
                              pressedOpacity: MediaQuery.of(context).viewInsets.bottom <= 0? 0.4 : 1,
                              padding: EdgeInsets.zero,
                              child: CupertinoListTile(
                                padding: padding,
                                  title: Text(exs[index].name, style: TextStyle(color: exs[index].exercise == null? Colors.grey : Colors.white),
                                  )
                              ),
                              onPressed: (){
                                if(MediaQuery.of(context).viewInsets.bottom <= 0){
                                  return;
                                } else{
                                  FocusScope.of(context).unfocus();
                                }
                              },
                            ),
                          );
                        },
                      ),

                      const TopHeaderLetter(),

                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        child: Container(
                          height: 60,
                          width: double.maxFinite,
                          color: CupertinoTheme.of(context).scaffoldBackgroundColor,
                          padding: const EdgeInsets.all(10),
                          child: CupertinoSearchTextField(
                            controller: cnAllExercisesPanel.textController,
                            style: const TextStyle(color: Colors.white),
                            backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
                            onChanged: (value){
                              cnAllExercisesPanel.scrollController.jumpTo(0);
                              cnAllExercisesPanel.filterExercises(value);
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            if(cnAllExercisesPanel.panelController.isAttached
                && cnAllExercisesPanel.panelController.panelPosition > 0
                && cnAllExercisesPanel.textController.text.isEmpty
            )
              Positioned(
                bottom: 90 - verticalPaddingSideBar + MediaQuery.of(context).viewInsets.bottom,
                right: 0,
                child: Listener(
                  onPointerDown: (details) {
                    jumpToLetter(details);
                  },
                  onPointerMove: (details){
                    jumpToLetter(details);
                  },
                  onPointerUp: (details){
                    jumpToLetter(details);
                  },
                  child: Container(
                      key: cnAllExercisesPanel.keySideBar,
                      color: Colors.red.withValues(alpha: 0.0),
                      height: 572 - MediaQuery.of(context).viewInsets.bottom*0.8,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: cnAllExercisesPanel.characters.map((letter) {
                          return Text(
                              letter.name,
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).viewInsets.bottom >= 20? 8 : 13,
                                  fontWeight: FontWeight.bold,
                                  color: buttonTextColor
                              )
                          );
                        }).toList(),
                      )
                  ),
                ),
              ),
          ],
        )
    );
  }

  void jumpToLetter(dynamic details){
    initSize();

    RenderBox box = cnAllExercisesPanel.keySideBar.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(details.position);
    final int index = (localPosition.dy ~/ ((572 - MediaQuery.of(context).viewInsets.bottom*0.8)/26)).clamp(0, cnAllExercisesPanel.characters.length-1);
    final String letter = cnAllExercisesPanel.characters[index].name;
    final allExercisesIndex = cnAllExercisesPanel.filteredExercises.indexWhere((element) => element.name[0].toUpperCase() == letter);
    double position = (allExercisesIndex * sizeListTile + (allExercisesIndex * 0.25) + 15).clamp(0, cnAllExercisesPanel.scrollController.position.maxScrollExtent);
    // position = position > cnAllExercisesPanel.scrollController.position.maxScrollExtent? cnAllExercisesPanel.scrollController.position.maxScrollExtent : position;
    cnAllExercisesPanel.scrollController.jumpTo(position);
  }

  void initSize(){
    if(sizeListTile == 0){
      sizeListTile = getWidgetSize(cnAllExercisesPanel.keyFirstListTile).height;
    }
  }

  void onPanelSlide(value){
    if(value == 0){
      cnAllExercisesPanel.reset();
      cnAllExercisesPanel.refresh();
    }
    else if(value == 1){
      cnAllExercisesPanel.refresh();
    }
    setState(() {
      verticalPaddingSideBar = MediaQuery.of(context).size.height * (1-value);
    });
    cnBottomMenu.adjustHeight(value);
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

  CnAllExercisesPanel() {
    initExercises();
  }

  Future initExercises()async{
    /// Read the file
    final resultString = await rootBundle.loadString("lib/assets/exercises/filtered_exercises.json");
    List<dynamic> dataMap = jsonDecode(resultString);
    exercises = dataMap.map(
            (ex) => Exercise(
            name: ex["name"],
            description: (ex["instructions"] as List).firstOrNull?? ""
        )
    ).toList();
    List<String> allExTemplateNames = exercises.map((e) => e.name).toList();

    final builder = objectbox.exerciseBox.query();
    final query = builder.build().property(ObExercise_.name);
    query.distinct = true;
    final List<String> createdExNames = query.find();


    exercises.addAll(createdExNames
        .whereNot(
            (e) => allExTemplateNames.contains(e))
        .map(
            (e) => Exercise(name: e))
    );

    exercises.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    filteredExercises = List.from(exercises.map((e) => TileItem(name: e.name, exercise: e)));
    fillFilteredList();
  }

  void fillFilteredList(){
    Set chars = Set.from(filteredExercises.map((e) => e.name[0].toUpperCase()));
    characters = chars.map((c) => TileItem(name: c)).toList();
    filteredExercises.addAll(characters);
    filteredExercises.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future openPanel() async{
    await panelController.animatePanelToPosition(
        1,
        duration: Duration(milliseconds: animationTime),
        curve: Curves.fastEaseInToSlowEaseOut
    );
    return;
  }

  Future closePanel() async{
    await panelController.animatePanelToPosition(
        0,
        duration: Duration(milliseconds: animationTime-150),
        curve: Curves.decelerate
    );
    reset();
    return;
  }

  void filterExercises(String value) {
    value = value.replaceAll("-", " ").replaceAll("z", "c");
    final tempFiltExs = List.from(exercises.where((ex) => ex.name.toLowerCase().replaceAll("-", " ").replaceAll("z", "c").contains(value.toLowerCase())));
    filteredExercises = List.from(tempFiltExs.map((e) => TileItem(name: e.name, exercise: e)));
    fillFilteredList();
    refresh();
  }

  void reset(){
    filteredExercises = List.from(exercises.map((e) => TileItem(name: e.name, exercise: e)));
    fillFilteredList();
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