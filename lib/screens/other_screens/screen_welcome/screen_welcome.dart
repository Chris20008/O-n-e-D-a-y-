import 'package:fitness_app/assets/custom_icons/my_icons_icons.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/screen_workouts.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/screen_settings.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/screens/backups_screen/widgets/connect_with_cloud.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/screens/initial_settings_screen/widgets/1_general_settings/widgets/switch_health.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/screens/initial_settings_screen/widgets/1_general_settings/widgets/switch_spotify.dart';
import 'package:fitness_app/screens/other_screens/screen_welcome/screens/cloud_connect.dart';
import 'package:fitness_app/screens/other_screens/screen_welcome/screens/connect_health.dart';
import 'package:fitness_app/screens/other_screens/screen_welcome/screens/connect_spotify.dart';
import 'package:fitness_app/screens/other_screens/screen_welcome/screens/language.dart';
import 'package:fitness_app/widgets/cupertino_button_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../util/config.dart';
import '../../../util/constants.dart';
import 'dart:io';

import '../../../widgets/custom_navigator_observer.dart';
import '../../../widgets/slide_up_panel/animation_controller_name.dart';

class ScreenWelcome extends StatefulWidget {
  final Function(bool) onFinish;
  const ScreenWelcome({
    required this.onFinish,
    super.key,
  });

  @override
  State<ScreenWelcome> createState() => _ScreenWelcomeState();
}

class _ScreenWelcomeState extends State<ScreenWelcome> {

  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnSettings cnSettings =context.read<CnSettings>();
  late CnScreenStatistics cnScreenStatistics;
  late CnConfig cnConfig;
  final maxIndex = 4;
  int screenIndex = 0;
  final settingsObserver = CustomNavigatorObserver();
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();


  @override
  void dispose(){
    super.dispose();
    cnSettings.explainBackupPanelDescendantAnimationControllerName = AnimationControllerName.screenSettings;
  }

  void onPopInvoked(_, __){
    if(cnSettings.panelControllerExplainBackups.panelPosition > 0.9){
      cnSettings.panelControllerExplainBackups.close();
    }
    else if(settingsObserver.currentRouteName != '/welcomeLanguage'){
      navigatorKey.currentState?.pop();
    }
    // else if(!cnSettings.showLoadingIndicator){
    //   cnSettings.panelControllerSettings.animatePanelToPosition(
    //       0,
    //       duration: const Duration(milliseconds: 350),
    //       curve: Curves.decelerate
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    cnConfig  = Provider.of<CnConfig>(context);
    cnScreenStatistics = Provider.of<CnScreenStatistics>(context);
    cnSettings.explainBackupPanelDescendantAnimationControllerName = AnimationControllerName.screenWelcome;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvoked,
      child: Navigator(
        key: navigatorKey,
        observers: [settingsObserver],
        initialRoute: '/welcomeLanguage',
        onGenerateRoute: (RouteSettings settings) {
          final routes = <String, WidgetBuilder>{
            '/welcomeLanguage': (_) => const PopScope(
                canPop: false,
                child: ScreenLanguage()
            ),
            '/connectCloud': (_) => const ConnectCloud(),
            '/connectSpotify': (_) => const ConnectSpotify(),
            '/connectHealth': (_) => ConnectHealth(onFinish: widget.onFinish),
          };

          final builder = routes[settings.name];
          if (builder != null) {
            return MaterialPageRoute(builder: builder, settings: settings);
          }
          return null;
        },
      ),
    );
  }

  Widget imprintButton(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: Platform.isAndroid? EdgeInsets.zero : const EdgeInsets.only(bottom: 20),
        child: SizedBox(
          height: 20,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () async{
              HapticFeedback.selectionClick();
              await openUrl("https://chris20008.github.io/O-n-e-D-a-y-Info/imprint");
            },
            child: Text(
              AppLocalizations.of(context)!.settingsImprint,
              style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  decoration: TextDecoration.underline,
                  fontSize: 10
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomBar(){
    return Positioned(
      left: 5,
      right: 5,
      bottom: Platform.isAndroid? 15 : 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              flex: 10,
              child: screenIndex > 0 ? Align(
                  alignment: Alignment.centerLeft,
                  child: CupertinoButtonText(
                      text: AppLocalizations.of(context)!.welcomeBack,
                      onPressed: (){
                        setState(() {
                          screenIndex -= 1;
                          screenIndex = screenIndex <= 0? 0 : screenIndex;
                        });
                      }
                  ),
              ) : const SizedBox()
          ),
          const Spacer(flex: 13),
          Expanded(
            flex: 10,
            child: screenIndex < maxIndex? Align(
              alignment: Alignment.centerRight,
              child: CupertinoButtonText(
                  text: AppLocalizations.of(context)!.welcomeNext,
                  onPressed: (){
                    setState(() {
                      if(screenIndex < maxIndex) {
                        screenIndex += 1;
                      }
                    });
                  }
              ),
            ) : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget nextButton(){
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: CupertinoButtonText(
            text: AppLocalizations.of(context)!.welcomeNext,
            onPressed: (){
              setState(() {
                if(screenIndex < maxIndex) {
                  screenIndex += 1;
                }
              });
            }
        ),
      ),
    );
  }

  Widget backButton(){
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: CupertinoButtonText(
            text: AppLocalizations.of(context)!.welcomeBack,
            onPressed: (){
              setState(() {
                screenIndex -= 1;
                screenIndex = screenIndex <= 0? 0 : screenIndex;
              });
            }
        ),
      ),
    );
  }



  /// Screen Two
  Widget screenTwo(){
    return Stack(
      children: [
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: OverflowSafeText(
                          maxLines: 1,
                          Platform.isAndroid? AppLocalizations.of(context)!.welcomeSyncGoogleDrive : AppLocalizations.of(context)!.welcomeSynciCloud,
                          fontSize: 25,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    OverflowSafeText(
                      maxLines: 1,
                      AppLocalizations.of(context)!.welcomeNoAccount,
                    ),
                    OverflowSafeText(
                      maxLines: 1,
                      AppLocalizations.of(context)!.welcomeNoAccount2,
                    ),
                    const SizedBox(height: 20),
                    OverflowSafeText(
                      maxLines: 1,
                      AppLocalizations.of(context)!.welcomeAwesome,
                    ),
                    const SizedBox(height: 80),
                    OverflowSafeText(
                      maxLines: 2,
                      AppLocalizations.of(context)!.welcomeLocalBackups,
                      textAlign: TextAlign.center
                    ),
                    const SizedBox(height: 20),
                    OverflowSafeText(
                        maxLines: 2,
                        Platform.isAndroid? AppLocalizations.of(context)!.welcomeSyncGoogleDrive2 : AppLocalizations.of(context)!.welcomeSynciCloud2,
                        textAlign: TextAlign.center
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    /// Sync with iCloud
                    const ConnectWithCloud(),

                    GestureDetector(
                      onTap: () async{
                        HapticFeedback.selectionClick();
                        cnSettings.openPanelExplainBackups();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info,
                              size:12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5,),
                            Text(AppLocalizations.of(context)!.settingsBackupMoreInfo, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w300),),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ),
              const SizedBox(height: 20,)
            ],
          ),
        ),
      ],
    );
  }

  /// Screen Three
  Widget screenThree(){
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.welcomeControlMusic,
                    textScaler: const TextScaler.linear(1.8),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.welcomeMusicQuestion,
                    style: const TextStyle(fontSize: 17),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.welcomeMusicSolution,
                    style: const TextStyle(fontSize: 17),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.welcomeMusicExplanation,
                    style: const TextStyle(fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Connect to Spotify
                const CupertinoListTileSwitchSpotify(),
                Container(
                  height: 20,
                  padding: const EdgeInsets.only(left: 30),
                  child: cnConfig.failedSpotifyConnection? Text(AppLocalizations.of(context)!.welcomeSpotifyError, textAlign: TextAlign.left,) : null
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Screen Four
  Widget screenFour(){
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.welcomeHealth,
                  textScaler: const TextScaler.linear(1.8),
                ),
                const SizedBox(width: 10,),
                Stack(
                  children: [
                    Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(6)
                      ) ,
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Icon(
                            MyIcons.heart,
                            color: Colors.red,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.welcomeHealth1,
                  style: const TextStyle(fontSize: 17),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                Text(
                  AppLocalizations.of(context)!.welcomeHealth2,
                  style: const TextStyle(fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                /// Use Health Data
                CupertinoListTileSwitchHealth(),

                SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Screen Five
  Widget screenFive(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100,),
              Center(
                child: Text(
                  AppLocalizations.of(context)!.welcomeSetupCompleted,
                  textScaler: const TextScaler.linear(1.8),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.welcomeSetupCompletedMsg,
                style: const TextStyle(fontSize: 17),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              Text(
                AppLocalizations.of(context)!.welcomeSetupCompletedHopIntoTutorial,
                style: const TextStyle(fontSize: 17),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                /// Explore myself
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CupertinoButton(

                    padding: EdgeInsets.zero,
                    onPressed: () {
                      widget.onFinish(false);
                      // SystemChrome.setPreferredOrientations([]);
                    },
                    child: OverflowSafeText(
                      AppLocalizations.of(context)!.welcomeButtonExploreMyself,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Color(0xFFC16A03),
                        fontSize: 20,
                      )
                    ),
                  ),
                ),

                const SizedBox(height: 10,),

                /// Start Tutorial
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => widget.onFinish(true),
                  child: Text(
                    AppLocalizations.of(context)!.welcomeButtonStartTutorial,
                    style: const TextStyle(
                      color: Color(0xFFC16A03),
                      fontSize: 20,
                    )
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget animatedScreen(int index, Widget child){
    return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.translationValues(
            screenIndex == index
                ? 0
                : screenIndex <= index
                ? MediaQuery.of(context).size.width
                : - MediaQuery.of(context).size.width,
            0,
            0),
        curve: Curves.easeOut,
        child: child
    );
  }

  // Widget getBackupDialogChild() {
  //   return standardDialog(
  //       context: context,
  //       maxWidth: 400,
  //       widthFactor: 0.9,
  //       maxHeight: 680,
  //       child: getBackupDialogWelcomeScreen(context: context),
  //   );
  // }
}



