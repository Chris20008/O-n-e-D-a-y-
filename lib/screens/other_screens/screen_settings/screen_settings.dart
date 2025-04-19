import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/screens/main_screens/screen_workout_history/screen_workout_history.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/screen_workouts.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/widgets/1_general_settings/general_settings.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/widgets/2_backup_options/backup_options.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/widgets/3_about_section/about_section.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/widgets/panels/explain_backup_panel.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:fitness_app/widgets/slide_up_panel/my_slide_up_panel.dart';
import 'package:fitness_app/widgets/standard_popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../main.dart';
import '../../../util/config.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({
    super.key,

  });

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> with WidgetsBindingObserver {
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  late CnWorkoutHistory cnWorkoutHistory = Provider.of<CnWorkoutHistory>(context, listen: false);
  late CnScreenStatistics cnScreenStatistics;
  late CnConfig cnConfig;
  bool setOrientation = false;
  bool _showLoadingIndicator = false;
  PanelController controllerExplainBackups = PanelController();
  ScrollController scrollControllerSetting = ScrollController();
  ScrollController scrollControllerBackups = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state)async{
    Future.delayed(const Duration(milliseconds: 500), ()async{
      await cnScreenStatistics.refreshHealthData();
      cnScreenStatistics.calcMinMaxDates(context);
      cnScreenStatistics.refresh();
    });
    setState(() {});
  }

  void setLoadingIndicator(bool value){
    setState(() {
      _showLoadingIndicator = value;
    });
  }

  void refresh(Function f){
    setState(() => f());
  }

  void onPopInvoked(doPop, result){
    if(!_showLoadingIndicator){
      cnScreenStatistics.panelControllerSettings.animatePanelToPosition(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.decelerate
      );
    }
  }

  void onPanelSlide(value){
    cnBottomMenu.adjustHeight(value);
    if(value > 0 && !setOrientation){
      setOrientation = true;
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    else if (value == 0 && setOrientation){
      setOrientation = false;
      SystemChrome.setPreferredOrientations([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    cnConfig = Provider.of<CnConfig>(context);
    cnScreenStatistics = Provider.of<CnScreenStatistics>(context);

    return PopScope(
        canPop: true,
        onPopInvokedWithResult: onPopInvoked,
        child: Stack(
          children: [
            MySlideUpPanel(
              controller: cnScreenStatistics.panelControllerSettings,
              onPanelSlide: onPanelSlide,
              descendantAnimationControllerName: "ScreenStatistics",
              animationControllerName: "ScreenSettings",
              /// Use panelBuilder in Order to get a ScrollController which enables closing the panel
              /// when swiping down in  ListView
              panelBuilder: (context, listView){
                return Column(
                  children: [
                    const SizedBox(height: 10,),
                    Text(AppLocalizations.of(context)!.settings,textScaler: const TextScaler.linear(1.4)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: listView(
                        physics: const BouncingScrollPhysics(),
                        controller: scrollControllerSetting,
                        child: Column(
                          children: [

                            /// General
                            GeneralSettings(
                                setLoadingIndicator: setLoadingIndicator,
                                cnConfig: cnConfig,
                                cnScreenStatistics: cnScreenStatistics,
                                cnHomepage: cnHomepage,
                                refresh: refresh
                            ),

                            /// Backup
                            BackupOptions(
                                controllerExplainBackups: controllerExplainBackups,
                                setLoadingIndicator: setLoadingIndicator,
                                cnConfig: cnConfig,
                                cnScreenStatistics: cnScreenStatistics,
                                cnHomepage: cnHomepage,
                                refresh: refresh
                            ),

                            /// About
                            const AboutSection(),

                            /// Spacer
                            const SizedBox(height: 50,)
                          ],
                        ),
                      ),
                    )
                  ],
                );
              },
            ),

            ExplainBackupPanel(
                controllerExplainBackups: controllerExplainBackups,
                scrollControllerBackups: scrollControllerBackups
            ),

            if (_showLoadingIndicator)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: CupertinoActivityIndicator(
                      radius: 20.0,
                      color: Colors.amber[800]
                  ),
                ),
              ),
          ],
        )
    );
  }
}