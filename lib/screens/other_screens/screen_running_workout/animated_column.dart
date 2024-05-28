import 'package:fitness_app/screens/other_screens/screen_running_workout/screen_running_workout.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/stopwatch.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/widgets/spotify_bar.dart';
import 'package:fitness_app/widgets/standard_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  late CnAnimatedColumn cnAnimatedColumn;
  final TextEditingController _textController = TextEditingController();
  bool canConfirm = true;

  @override
  Widget build(BuildContext context) {
    cnAnimatedColumn = Provider.of<CnAnimatedColumn>(context);
    final bool showSpotify = cnConfig.useSpotify;

    return SafeArea(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          AnimatedContainer(
              duration: Duration(milliseconds: cnStopwatchWidget.animationTimeStopwatch),
              transform: Matrix4.translationValues(
                  ///x
                  0,
                  ///y
                  cnStopwatchWidget.isOpened && !cnSpotifyBar.isConnected?
                  0 :
                  cnStopwatchWidget.isOpened && cnSpotifyBar.isConnected?
                  -(showSpotify? cnSpotifyBar.height - 5 : 0.0):
                  -(showSpotify? cnSpotifyBar.height - 5 : 0.0),
                  ///z
                  0),
              child: const StopwatchWidget()
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: cnStopwatchWidget.animationTimeStopwatch),
            transform: Matrix4.translationValues(
                ///x
                0,
                ///y
                cnStopwatchWidget.isOpened
                    ? - cnStopwatchWidget.heightOfTimer - (showSpotify? cnSpotifyBar.height -5 : 0.0)
                    : - cnSpotifyBar.height* (showSpotify? 2 : 1) - (showSpotify? -7 : 0),
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
                      cnStandardPopUp.open(
                          context: context,
                          onCancel: (){
                            Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime), (){
                              FocusScope.of(context).unfocus();
                              _textController.clear();
                            });
                          },
                          child: TextFormField(
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
                          canConfirm: canConfirm,
                          onConfirm: (){
                            if(_textController.text.isNotEmpty &&
                               !exerciseNameExistsInWorkout(workout: cnRunningWorkout.workout, exerciseName: _textController.text)
                            ){
                              cnRunningWorkout.addExercise(Exercise(name: _textController.text));
                            }
                            Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime), (){
                              FocusScope.of(context).unfocus();
                              _textController.clear();
                            });
                        }
                      );
                    },
                    icon: Icon(
                      Icons.add,
                      color: Colors.amber[800],
                    )
                ),
              ),
            ),
          ),

          if(showSpotify)
            AnimatedContainer(
              duration: Duration(milliseconds: cnStopwatchWidget.animationTimeStopwatch),
              transform: Matrix4.translationValues(
                  ///x
                  0,
                  /// y
                  cnStopwatchWidget.isOpened && !cnSpotifyBar.isConnected
                      ? -cnStopwatchWidget.heightOfTimer - 5
                      : 0,
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
}

class CnAnimatedColumn extends ChangeNotifier {
  bool isOpened = false;
  bool isRunning = false;
  bool isPaused = false;
  int animationTimeStopwatch = 300;
  // double heightOfTimer = 250;

  void refresh()async{
    notifyListeners();
  }
}