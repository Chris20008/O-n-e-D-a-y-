import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/screen_workouts.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/screen_settings.dart';
import 'package:fitness_app/screens/other_screens/screen_welcome/screens/cloud_connect/cloud_connect.dart';
import 'package:fitness_app/screens/other_screens/screen_welcome/screens/connect_health.dart';
import 'package:fitness_app/screens/other_screens/screen_welcome/screens/connect_spotify.dart';
import 'package:fitness_app/screens/other_screens/screen_welcome/screens/language.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../util/config.dart';

import '../../../widgets/custom_navigator.dart';
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

  static const buttonWidthPercent = 0.8;
  static const buttonHeight = 50.0;
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: 16, horizontal: 20);
  static const int defaultDuration = 500;
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
  }

  @override
  Widget build(BuildContext context) {
    cnConfig  = Provider.of<CnConfig>(context);
    cnScreenStatistics = Provider.of<CnScreenStatistics>(context);
    cnSettings.explainBackupPanelDescendantAnimationControllerName = AnimationControllerName.screenWelcome;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvoked,
      child: CustomNavigator(
        navigatorKey: navigatorKey,
        observer: settingsObserver,
        additionalObserver: [HeroController()],
        initialRoute: WelcomeRoute.welcomeLanguage.value,
        onGenerateRoute: (RouteSettings settings) {
          final routes = <String, WidgetBuilder>{
            WelcomeRoute.welcomeLanguage.value: (_) => const PopScope(
                canPop: false,
                child: ScreenLanguage()
            ),
            WelcomeRoute.connectCloud.value: (_) => const ConnectCloud(),
            WelcomeRoute.connectSpotify.value: (_) => const ConnectSpotify(),
            WelcomeRoute.connectHealth.value: (_) => ConnectHealth(onFinish: widget.onFinish),
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

  // Widget imprintButton(){
  //   return Align(
  //     alignment: Alignment.bottomCenter,
  //     child: Padding(
  //       padding: Platform.isAndroid? EdgeInsets.zero : const EdgeInsets.only(bottom: 20),
  //       child: SizedBox(
  //         height: 20,
  //         child: CupertinoButton(
  //           padding: EdgeInsets.zero,
  //           onPressed: () async{
  //             HapticFeedback.selectionClick();
  //             await openUrl("https://chris20008.github.io/O-n-e-D-a-y-Info/imprint");
  //           },
  //           child: Text(
  //             AppLocalizations.of(context)!.settingsImprint,
  //             style: const TextStyle(
  //                 color: CupertinoColors.systemGrey,
  //                 decoration: TextDecoration.underline,
  //                 fontSize: 10
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

enum WelcomeRoute{
  welcomeLanguage ("/welcomeLanguage"),
  connectCloud ("/connectCloud"),
  connectCloudWithoutAccount ("/connectCloudWithoutAccount"),
  connectSpotify ("/connectSpotify"),
  connectHealth ("/connectHealth");

  const WelcomeRoute(this.value);
  final String value;
}



