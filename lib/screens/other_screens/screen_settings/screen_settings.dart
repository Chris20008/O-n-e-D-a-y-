import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/screens/main_screens/screen_workout_history/screen_workout_history.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/screen_workouts.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/panels/explain_backup_panel.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/screens/backups_screen/backups_screen.dart';
import 'package:fitness_app/widgets/custom_navigator_observer.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/screens/initial_settings_screen/initial_settings_screen.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:fitness_app/widgets/slide_up_panel/my_slide_up_panel.dart';
import 'package:fitness_app/widgets/standard_popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../main.dart';
import '../../../util/config.dart';
import '../../../util/constants.dart';
import '../../../widgets/slide_up_panel/animation_controller_name.dart';

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
  late CnSettings cnSettings;
  late CnScreenStatistics cnScreenStatistics;
  late CnConfig cnConfig;
  bool setOrientation = false;
  final settingsObserver = CustomNavigatorObserver();

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

  void refresh(Function f){
    setState(() => f());
  }

  void onPopInvoked(doPop, result){
    if(cnSettings.panelControllerExplainBackups.panelPosition > 0.9){
      cnSettings.panelControllerExplainBackups.close();
    }
    else if(settingsObserver.currentRouteName != '/initialSettingsScreen'){
      cnSettings.navigatorKey.currentState?.pop();
    }
    else if(!cnSettings.showLoadingIndicator){
      cnSettings.panelControllerSettings.animatePanelToPosition(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.decelerate
      );
    }
  }

  void onPanelSlide(value){
    cnBottomMenu.adjustHeight(value);
    if(value == 0){
      cnSettings.showContent.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    cnConfig = Provider.of<CnConfig>(context);
    cnScreenStatistics = Provider.of<CnScreenStatistics>(context);
    cnSettings = context.read<CnSettings>();
    cnSettings.explainBackupPanelDescendantAnimationControllerName = AnimationControllerName.screenSettings;

    pr("Rebuild Screen Settings");

    return ValueListenableBuilder(
        valueListenable: cnSettings.showContent,
        builder: (context, showContent, _){
          if(!showContent){
            return const SizedBox();
          }

          return PopScope(
            canPop: true,
            onPopInvokedWithResult: onPopInvoked,
            child: Stack(
              children: [
                MySlideUpPanel(
                  controller: cnSettings.panelControllerSettings,
                  onPanelSlide: onPanelSlide,
                  descendantAnimationControllerName: AnimationControllerName.screenStatistics,
                  animationControllerName: AnimationControllerName.screenSettings,
                  /// Use panelBuilder in Order to get a ScrollController which enables closing the panel
                  /// when swiping down in  ListView
                  panelBuilder: (context, listView){
                    return Navigator(
                      key: cnSettings.navigatorKey,
                      initialRoute: '/initialSettingsScreen',
                      observers: [settingsObserver],
                      onGenerateRoute: (RouteSettings settings) {
                        final routes = <String, WidgetBuilder>{
                          '/initialSettingsScreen': (_) => const PopScope(
                              canPop: false,
                              child: InitialSettingsScreen()
                          ),
                          '/backupScreen': (_) => const BackupsScreen(),
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

                const ExplainBackupPanel(),

                Selector<CnSettings, bool>(
                    selector: (_, cn) => cn.showLoadingIndicator,
                    builder: (_, showLoadingIndicator, ___){
                      if(showLoadingIndicator){
                        return Container(
                          color: Colors.black.withValues(alpha: 0.5),
                          child: Center(
                            child: CupertinoActivityIndicator(
                                radius: 20.0,
                                color: Colors.amber[800]
                            ),
                          ),
                        );
                      }

                      return const SizedBox();
                  }
                ),
              ],
            ),
          );
      }
    );
  }

}

class CnSettings extends ChangeNotifier{
  ValueNotifier<bool> showContent = ValueNotifier(false);
  final ValueNotifier<int> _reloadLocalBackups = ValueNotifier(0);
  bool showLoadingIndicator = false;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  PanelController panelControllerExplainBackups = PanelController();
  PanelController panelControllerSettings = PanelController();
  ScrollController scrollControllerSetting = ScrollController();
  ScrollController scrollControllerBackupsScreen = ScrollController();
  ScrollController scrollControllerExplainBackups = ScrollController();
  AnimationControllerName explainBackupPanelDescendantAnimationControllerName = AnimationControllerName.screenSettings;
  int refreshListViewInitialSettings = 0;
  final int animationTime = 500;

  ValueNotifier<int> get reloadLocalBackups => _reloadLocalBackups;

  void refreshLocalBackups(){
    _reloadLocalBackups.value += 1;
  }

  void doRefreshListViewInitialSettings(){
    refreshListViewInitialSettings += 1;
    refresh();
  }

  void setLoadingIndicator(bool value){
    showLoadingIndicator = value;
    refresh();
  }

  Future openPanelSettings(BuildContext context) async{
    OverlayEntry ov = blockUserInput(context, duration: null)!;
    showContent.value = true;
    await waitForNextFrame();
    if(!panelControllerSettings.isAttached){
      return;
    }
    /// jump to minimal position to make initial build
    /// so that the slide up is smooth
    /// also allow the Panel to build it's content since it's a SizedBox()
    /// when closed
    await panelControllerSettings.animatePanelToPosition(
        0.001,
        duration: const Duration(milliseconds: 0)
    );
    /// Trigger Rebuild only for
    refresh();
    /// Wait 100 ms that the first build is fully done
    await Future.delayed(const Duration(milliseconds: 100));
    await panelControllerSettings.animatePanelToPosition(
        1,
        duration: Duration(milliseconds: animationTime),
        curve: Curves.fastEaseInToSlowEaseOut
    );
    ov.remove();
    return;
  }

  Future openPanelExplainBackups() async{
    await panelControllerExplainBackups.animatePanelToPosition(
        1,
        duration: Duration(milliseconds: animationTime),
        curve: Curves.fastEaseInToSlowEaseOut
    );
    return;
  }

  void refresh(){
    notifyListeners();
  }
}