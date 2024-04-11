import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitness_app/screens/screen_workouts/panels/new_exercise_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../main.dart';
import '../../../objects/exercise.dart';
import '../../../objects/workout.dart';
import '../../../widgets/bottom_menu.dart';

import '../../../widgets/exercise_row.dart';
import '../../../widgets/standard_popup.dart';
import '../../screen_workout_history/screen_workout_history.dart';
import '../screen_running_workout.dart';
import '../screen_workouts.dart';

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
  final deleteWorkoutKey = GlobalKey();
  final addLinkKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context);
    print("REBUILD NEW WOKROUT PANEL");

    return PopScope(
      canPop: false,
      onPopInvoked: (doPop){
        if (cnNewWorkout.panelController.isPanelOpen && !cnNewExercisePanel.panelController.isPanelOpen){
          cnNewWorkout.panelController.close();
        }
      },
      // onWillPop: () async{
      //   if (cnNewWorkout.panelController.isPanelOpen && !cnNewExercisePanel.panelController.isPanelOpen){
      //     cnNewWorkout.panelController.close();
      //     return false;
      //   }
      //   return true;
      // },
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
                      cnNewWorkout.panelController.open();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 30.0, right: 30.0, left: 30.0, top: 10),
                    height: double.maxFinite,
                    width: double.maxFinite,
                    color: Colors.transparent,
                    child: Column(
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
                                const Text("Workout", textScaleFactor: 1.5),
                                const SizedBox(height: 10,),
                              ],
                            ),
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
                              child: SizedBox(
                                height: 50,
                                child: TextField(
                                  onTap: ()async{
                                    if(cnNewWorkout.panelController.isPanelClosed){
                                      Future.delayed(const Duration(milliseconds: 300), (){
                                        cnNewWorkout.panelController.open();
                                      });
                                    }
                                  },
                                  controller: cnNewWorkout.workoutNameController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    labelText: 'Name',
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
                                  key: addLinkKey,
                                  onPressed: ()async{
                                    if(cnNewWorkout.panelController.isPanelClosed){
                                      await cnNewWorkout.panelController.open();
                                    }
                                    cnStandardPopUp.open(
                                      child: TextField(
                                        maxLength: 15,
                                        textAlignVertical: TextAlignVertical.center,
                                        keyboardType: TextInputType.text,
                                        controller: cnNewWorkout.linkNameController,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                          isDense: true,
                                          labelText: 'Group Name',
                                          counterText: "",
                                        ),
                                        onChanged: (value){

                                        },
                                      ),
                                      onConfirm: (){
                                        final linkName = cnNewWorkout.linkNameController.text;
                                        if(linkName.isNotEmpty && !cnNewWorkout.workout.linkedExercises.contains(linkName)){
                                          cnNewWorkout.workout.linkedExercises.add(linkName);
                                          cnNewWorkout.updateExercisesAndLinksList();
                                          cnNewWorkout.updateExercisesLinks();
                                          cnNewWorkout.refresh();
                                        }
                                        cnNewWorkout.linkNameController.clear();
                                      },
                                      onCancel: cnNewWorkout.linkNameController.clear,
                                      animationKey: addLinkKey,
                                      color: Color(0xff2d2d2d)
                                    );
                                  },
                                  icon: const Icon(Icons.add_link, color: Color(0xFF5F9561)),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
                                    shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(10))),
                                  ),
                                ),
                              )
                          ],
                        ),
                        const SizedBox(height: 25,),
                        Container(width: double.maxFinite, height: 1, color: Colors.grey[400],),
                        const SizedBox(height: 15,),
                        const Text("Exercises", textScaleFactor: 1.2),
                        const SizedBox(height: 15,),

                        Expanded(
                            child: ListView(
                              controller: ScrollController(),
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.all(0),
                              shrinkWrap: true,
                              children: [
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
                                          Slidable(
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
                                                  backgroundColor: Color(0xFFA12D2C),
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
                                              dismissible: DismissiblePane(
                                                  confirmDismiss: ()async {
                                                    openExercise(cnNewWorkout.exercisesAndLinks[index]);
                                                    return false;
                                                  },
                                                  onDismissed: () {}),
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
                                                  backgroundColor: Color(0xFF617EB1),
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
                                                    textScaleFactor: 1.3,
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
                                          )
                                        else if(cnNewWorkout.exercisesAndLinks[index] is String)
                                          Slidable(
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
                                                    backgroundColor: Color(0xFFA12D2C),
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
                                          )
                                    ]
                                ),
                                Column(
                                  children: [
                                    const SizedBox(height: 15,),

                                    Row(
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
                                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom-50 > 0? MediaQuery.of(context).viewInsets.bottom-50 : 0)
                                  ],
                                )
                              ],
                            )
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: onCancel,
                                icon: const Icon(Icons.close)
                            ),
                            if(cnNewWorkout.isUpdating)
                              Listener(
                                onPointerUp: (PointerUpEvent details){
                                },
                                child: IconButton(
                                    key: deleteWorkoutKey,
                                    onPressed: (){
                                      cnStandardPopUp.open(
                                          child: const Text(
                                            "Do you really want to Delete this workout?",
                                            textAlign: TextAlign.center,
                                            textScaleFactor: 1.2,
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          onConfirm: onDelete,
                                          onCancel: (){},
                                          animationKey: deleteWorkoutKey,
                                          color: Color(0xff2d2d2d)
                                          // pos: Offset(position.dx + width/2, position.dy + height/2)
                                      );
                                    },
                                    icon: const Icon(Icons.delete_forever)
                                ),
                              ),
                            IconButton(
                                onPressed: onConfirm,
                                icon: const Icon(Icons.check)
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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
      cnNewExercisePanel.openPanel();
    }
  }

  // void openLinkPopUp(){
  //
  // }

  void addLink(String linkName){
    print("add link");
    if (cnNewWorkout.workout.linkedExercises.contains(linkName)) {
      linkName = "Curls";
    }
    if (cnNewWorkout.workout.linkedExercises.contains(linkName)){
      print("Return");
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
      cnNewExercisePanel.setExercise(clonedEx);
      cnNewExercisePanel.openPanel();
      cnNewExercisePanel.refresh();
    }
  }

  void onCancel(){
    cnNewWorkout.closePanel(doClear: true);
    cnNewExercisePanel.clear();
  }

  void onDelete(){
    cnNewWorkout.workout.deleteFromDatabase();
    cnWorkouts.refreshAllWorkouts();
    cnWorkoutHistory.refreshAllWorkouts();
    cnNewWorkout.closePanel(doClear: true);
    cnNewExercisePanel.clear();
  }

  void onConfirm(){
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
  }

  void onPanelSlide(value){
    cnBottomMenu.heightOfBottomMenu = cnBottomMenu.maxHeightBottomMenu * value;
    // if(value >= 0.99 || value <= 0.01){
    //
    //   cnNewWorkout.refresh();
    // }
    // if(value == 0.0){
    //   cnNewWorkout.refresh();
    // }
    if(value < 0.05 && !cnBottomMenu.isVisible){
      SystemChrome.setPreferredOrientations([]);
      // cnBottomMenu.setVisibility(true);
    }
    else if(value > 0.05 && cnBottomMenu.isVisible){
      // cnBottomMenu.setVisibility(false);
    }
    if(value == 0 || value == 1){
      cnNewWorkout.refresh();
    }
    cnBottomMenu.refresh();
    // cnNewWorkout.delayedRefresh();
  }

}

class CnNewWorkOutPanel extends ChangeNotifier {
  final PanelController panelController = PanelController();
  Workout workout = Workout();
  TextEditingController workoutNameController = TextEditingController();
  TextEditingController linkNameController = TextEditingController();
  bool isUpdating = false;
  List<dynamic> exercisesAndLinks = [];
  List<Color> linkColors = [
    const Color(0xFF5F9561),
    const Color(0xFFFFEA30),
    const Color(0xFF558FDF),
    const Color(0xFFF48E40)
  ];
  double minPanelHeight = 0;
  bool isCurrentlyRebuilding = false;
  double keepShowingPanelHeight = 212;
  late CnHomepage cnHomepage;

  CnNewWorkOutPanel(BuildContext context){
    cnHomepage = Provider.of<CnHomepage>(context, listen: false);
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
    minPanelHeight = keepShowingPanelHeight;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    panelController.animatePanelToPosition(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut
    );
    refresh();
    print("open panel ${workout.linkedExercises}");
    cnHomepage.refresh();
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
        print("remove Exercise ${item.name}");
        itemsToRemove.add(item);
      }
      else if(item is String && !workout.linkedExercises.contains(item)){
        print("remove linkname $item");
        itemsToRemove.add(item);
      }
    }
    for(Exercise ex in workout.exercises){
      if(!exercisesAndLinks.whereType<Exercise>().map((e) => e.name).contains(ex.name)){
        print("add Exercise ${ex.name}");
        itemsToAdd.add(ex);
      }
    }
    for(final linkName in workout.linkedExercises){
      if(!exercisesAndLinks.contains(linkName)){
        print("add linkname $linkName");
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
  }

  void editWorkout(Workout workout){
    Workout w = Workout.clone(workout);
    print("WORKOUT ID in history: ${workout.id}");
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
    workoutNameController = TextEditingController(text: w.name);
  }

  void clear({bool doRefresh = true}){
    workout = Workout();
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
