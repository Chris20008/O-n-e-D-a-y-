import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/screen_running_workout.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/stopwatch.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/widgets/spotify_bar.dart';
import 'package:fitness_app/widgets/standard_popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import '../../../main.dart';
import '../../../objects/exercise.dart';
import '../../../util/constants.dart';
import '../../../widgets/bottom_menu.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AnimatedColumn extends StatefulWidget {
  const AnimatedColumn({super.key});

  @override
  State<AnimatedColumn> createState() => _AnimatedColumnState();
}

class _AnimatedColumnState extends State<AnimatedColumn> {

  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  late CnStopwatchWidget cnStopwatchWidget = Provider.of<CnStopwatchWidget>(context, listen: false);
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnConfig cnConfig = Provider.of<CnConfig>(context);
  late CnNewExercisePanel cnNewExercise = Provider.of<CnNewExercisePanel>(context);
  late CnAnimatedColumn cnAnimatedColumn;
  final TextEditingController _textController = TextEditingController();
  bool canConfirm = true;
  late bool showSpotify = cnConfig.useSpotify;
  final double _iconSize = 25;
  final _style = const TextStyle(color: Colors.white, fontSize: 18);
  UniqueKey newExerciseKey = UniqueKey();
  UniqueKey linkNameKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    cnAnimatedColumn = Provider.of<CnAnimatedColumn>(context);
    showSpotify = cnConfig.useSpotify;

    return SafeArea(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [

          /// Stopwatch/Timer
          AnimatedContainer(
              duration: Duration(milliseconds: cnStopwatchWidget.animationTimeStopwatch),
              transform: Matrix4.translationValues(
                  ///x
                  0,
                  ///y
                  getYPositionStopwatch(),
                  ///z
                  0),
              child: const StopwatchWidget()
          ),

          /// Add Exercise
          AnimatedContainer(
            duration: Duration(milliseconds: cnStopwatchWidget.animationTimeStopwatch),
            transform: Matrix4.translationValues(
              ///x
                0,
                ///y
                getYPositionAddExercise(),
                ///z
                0),
            child: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: SizedBox(
                width: 54,
                height: 54,
                child: IconButton(
                    iconSize: 30,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      cnAnimatedColumn.newEx = Exercise(blockLink: true);
                      showAddExercise(context);
                    },
                    icon: Icon(
                      Icons.add,
                      color: Colors.amber[800],
                    )
                ),
              ),
            ),
          ),

          /// Spotify
          if(showSpotify)
            AnimatedContainer(
              duration: Duration(milliseconds: cnStopwatchWidget.animationTimeStopwatch),
              transform: Matrix4.translationValues(
                  ///x
                  0,
                  /// y
                  getYPositionSpotifyBar(),
                  /// z
                  0),
              child: const Hero(
                  transitionOnUserGestures: true,
                  tag: "SpotifyBar",
                  child: SpotifyBar()
              ),
            ),
        ],
      ),
    );
  }

  Widget getSelectLink({
    Key? key,
    required Widget child,
    required Function(String category) onConfirm,
    required BuildContext context,
    required String currentLinkName
  }) {
    return PullDownButton(
      key: key,
      buttonAnchor: PullDownMenuAnchor.start,
      routeTheme: routeTheme,
      itemBuilder: (context) {
        List linkNames = ["-"] + cnRunningWorkout.workout.linkedExercises;
        List<PullDownMenuItem> linkNameWidgets = List.generate(linkNames.length, (index) => PullDownMenuItem.selectable(
            selected: currentLinkName == linkNames[index],
            title: linkNames[index],
            onTap: () {
              HapticFeedback.selectionClick();
              FocusManager.instance.primaryFocus?.unfocus();
              Future.delayed(const Duration(milliseconds: 200), (){
                onConfirm(linkNames[index]);
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
          child: child
      ),
    );
  }

  double getYPositionStopwatch(){
    final heightSpotifyBar = showSpotify? cnSpotifyBar.height + 1 : 0.0;
    if(cnStopwatchWidget.isOpened && !cnSpotifyBar.isConnected){
      return 0;
    }
    else if(cnStopwatchWidget.isOpened){
      return - heightSpotifyBar - 1;
    }
    return - heightSpotifyBar;
  }

  double getYPositionAddExercise(){
    if(!cnStopwatchWidget.isOpened){
      return getYPositionStopwatch() - cnSpotifyBar.height;
    }

    if(cnSpotifyBar.isConnected){
      return getYPositionStopwatch() - cnStopwatchWidget.heightOfTimer - 6;
    }
    else if(showSpotify){
      return getYPositionSpotifyBar() - cnSpotifyBar.height - 3;
    }
    return getYPositionStopwatch() - cnStopwatchWidget.heightOfTimer-6;
  }

  double getYPositionSpotifyBar(){
    if(cnStopwatchWidget.isOpened && !cnSpotifyBar.isConnected){
      return -cnStopwatchWidget.heightOfTimer - 5;
    }
    return 0;
  }

  Future showAddExercise(BuildContext context) async{
    await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context){
          return StatefulBuilder(
            builder: (context, setModalState) {
              return PopScope(
                canPop: MediaQuery.of(context).viewInsets.bottom == 0,
                onPopInvoked: (doPop){
                  if(doPop){
                    _textController.clear();
                  }
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.45 + 50 + MediaQuery.of(context).viewInsets.bottom,
                      maxWidth:MediaQuery.of(context).size.width,
                    ),
                    child: Scaffold(
                      resizeToAvoidBottomInset: false,
                      body: Container(
                        color: Theme.of(context).primaryColor,
                        child: SafeArea(
                          top: false,
                          left: false,
                          right: false,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        flex: 10,
                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: CupertinoButton(
                                                onPressed: (){
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(AppLocalizations.of(context)!.cancel, textAlign: TextAlign.left)
                                            )
                                        )
                                    ),
                                    Expanded(
                                        flex: 13,
                                        child: Center(
                                          child: Text(
                                            AppLocalizations.of(context)!.exercise,
                                            textScaler: const TextScaler.linear(1.3),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                    ),
                                    Expanded(
                                        flex: 10,
                                        child: Align(
                                            alignment: Alignment.centerRight,
                                            child: CupertinoButton(
                                                onPressed: () {
                                                  if(_textController.text.isNotEmpty &&
                                                      !exerciseNameExistsInWorkout(workout: cnRunningWorkout.workout, exerciseName: _textController.text)
                                                  ){
                                                    cnAnimatedColumn.newEx.name = _textController.text;
                                                    double additionalScrollPosition = (cnStopwatchWidget.isOpened? cnStopwatchWidget.heightOfTimer : 0)
                                                        + (cnSpotifyBar.isConnected && !cnSpotifyBar.justClosed? cnSpotifyBar.height : 0)
                                                        + cnBottomMenu.height + 20;
                                                    cnRunningWorkout.addExercise(cnAnimatedColumn.newEx, context, additionalScrollPosition: additionalScrollPosition);
                                                    Navigator.of(context).pop();
                                                    Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime), (){
                                                      FocusScope.of(context).unfocus();
                                                    });
                                                  }
                                                },
                                                child: Text(AppLocalizations.of(context)!.save, textAlign: TextAlign.right)
                                            )
                                        )
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      onTapOutside: (event){
                                        FocusManager.instance.primaryFocus?.unfocus();
                                      },
                                      keyboardAppearance: Brightness.dark,
                                      controller: _textController,
                                      maxLength: 40,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      validator: (value) {
                                        value = value?.trim();
                                        if(exerciseNameExistsInWorkout(workout: cnRunningWorkout.workout, exerciseName: _textController.text)){
                                          canConfirm = false;
                                          return AppLocalizations.of(context)!.runningWorkoutAlreadyExists;
                                        }
                                        canConfirm = true;
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        labelText: AppLocalizations.of(context)!.newExerciseName,
                                        counterText: "",
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 8 ,vertical: 0.0),
                                      ),
                                      style: const TextStyle(
                                          fontSize: 18
                                      ),
                                      textAlign: TextAlign.center,
                                      onChanged: (value){},
                                    ),
                                    Stack(
                                      children: [
                                        CupertinoListSection.insetGrouped(
                                          margin: const EdgeInsets.only(top: 15),
                                          decoration: BoxDecoration(
                                              color: Theme.of(context).cardColor
                                          ),
                                          backgroundColor: Colors.transparent,
                                          children: [
                                            cnNewExercise.getRestInSecondsSelector(
                                                context: context,
                                                exercise: cnAnimatedColumn.newEx,
                                                refresh: (){
                                                  setModalState(() {});
                                                }
                                            ),
                                            cnNewExercise.getSeatLevelSelector(
                                                context: context,
                                                exercise: cnAnimatedColumn.newEx,
                                                refresh: (){
                                                  setModalState(() {});
                                                }
                                            ),
                                            cnNewExercise.getExerciseCategorySelector(
                                                context: context,
                                                isTemplate: true,
                                                exercise: cnAnimatedColumn.newEx,
                                                refresh: (){
                                                  setModalState(() {});
                                                }
                                            ),
                                            cnNewExercise.getBodyWeightPercentSelector(
                                                context: context,
                                                isTemplate: true,
                                                exercise: cnAnimatedColumn.newEx,
                                                refresh: (){
                                                  setModalState(() {});
                                                }
                                            ),
                                            getSelectLink(
                                                key: linkNameKey,
                                                onConfirm: (String linkName){
                                                  cnAnimatedColumn.newEx.linkName = linkName == "-"? null : linkName;
                                                  cnAnimatedColumn.newEx.blockLink = linkName == "-";
                                                  setModalState(() {});
                                                },
                                                currentLinkName: cnAnimatedColumn.newEx.linkName?? "-",
                                                context: context,
                                                child: CupertinoListTile(
                                                  leading: Icon(Icons.link, size: _iconSize-3, color: Colors.amber[900]!.withOpacity(0.6),),
                                                  title: Row(
                                                    children: [
                                                      Text(AppLocalizations.of(context)!.runningWorkoutGroup, style: _style),
                                                      const Spacer(),
                                                      Text(cnAnimatedColumn.newEx.linkName?? "-", style: _style),
                                                      const SizedBox(width: 10),
                                                    ],
                                                  ),
                                                  trailing: trailingChoice(),
                                                )
                                            ),
                                          ],
                                        ),
                                        if(MediaQuery.of(context).viewInsets.bottom > 0)
                                          Align(
                                            alignment: Alignment.topCenter,
                                            child: Container(
                                              color: Colors.transparent,
                                              height: 200,
                                              width: double.maxFinite,
                                            ),
                                          )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          );
        }
    );
  }

}

class CnAnimatedColumn extends ChangeNotifier {
  bool isOpened = false;
  bool isRunning = false;
  bool isPaused = false;
  int animationTimeStopwatch = 300;
  Exercise newEx = Exercise();
  Widget popUpChild = Container();

  void setPopUpChild(Widget child){
    popUpChild = child;
  }

  void refresh()async{
    notifyListeners();
  }
}