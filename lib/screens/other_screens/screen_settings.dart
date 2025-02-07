import 'package:fitness_app/assets/custom_icons/my_icons_icons.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/screens/main_screens/screen_workout_history/screen_workout_history.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/screen_workouts.dart';
import 'package:fitness_app/screens/other_screens/local_file_picker.dart';
import 'package:fitness_app/util/backup_functions.dart';
import 'package:fitness_app/util/language_config.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:fitness_app/widgets/my_slide_up_panel.dart';
import 'package:fitness_app/widgets/standard_popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../main.dart';
import '../../util/config.dart';
import '../../util/constants.dart';

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
  late CnScreenStatistics cnScreenStatistics = Provider.of<CnScreenStatistics>(context);
  late CnConfig cnConfig = Provider.of<CnConfig>(context);
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
      cnScreenStatistics.calcMinMaxDates();
      cnScreenStatistics.refresh();
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(
        canPop: true,
        onPopInvoked: (doPop){
          cnScreenStatistics.panelControllerSettings.animatePanelToPosition(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.decelerate
          );
        },
        child: Stack(
          children: [
            MySlideUpPanel(
              controller: cnScreenStatistics.panelControllerSettings,
              onPanelSlide: onPanelSlide,
              descendantAnimationControllerName: "ScreenStatistics",
              animationControllerName: "ScreenSettings",
              // animationController: cnScreenStatistics.animationControllerStatisticsScreen,
              /// Use panelBuilder in Order to get a ScrollController which enables closing the panel
              /// when swiping down in  ListView
              panelBuilder: (context, listView){
                return Column(
                  children: [
                    const SizedBox(height: 10,),
                    panelTopBar,
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
                            CupertinoListSection.insetGrouped(
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1)
                              ),
                              backgroundColor: Colors.transparent,
                              header: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(AppLocalizations.of(context)!.settingsGeneral, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w300),),
                              ),
                              children: [
                                /// Language
                                CupertinoListTile(
                                    leading:  const Icon(
                                        Icons.language
                                    ),
                                    title: getSelectLanguageButton()
                                ),
                                /// Tutorial
                                CupertinoListTile(
                                  onTap: (){
                                    if(currentTutorialStep != 0){
                                      cnConfig.setCurrentTutorialStep(0);
                                      currentTutorialStep = 0;
                                      tutorialIsRunning = false;
                                      Fluttertoast.showToast(
                                          msg: AppLocalizations.of(context)!.settingsTutorialHasBeenReset,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.SNACKBAR,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.grey[800]?.withOpacity(0.9),
                                          textColor: Colors.white,
                                          fontSize: 16.0
                                      );
                                    }
                                  },
                                  leading: const Icon(
                                      Icons.school
                                  ),
                                  trailing: trailingArrow,
                                  title: Text(AppLocalizations.of(context)!.settingsTutorialReset, style: const TextStyle(color: Colors.white)),
                                ),
                                /// Connect to Spotify
                                CupertinoListTile(
                                  leading: const Icon(
                                    MyIcons.spotify,
                                    color: Colors.white,
                                    // color: Color(0xff1ed560)
                                  ),
                                  title: Row(
                                    children: [
                                      Text(AppLocalizations.of(context)!.settingsConnectSpotify, style: const TextStyle(color: Colors.white)),
                                      const SizedBox(width: 5),
                                      if(cnConfig.useSpotify)
                                        FutureBuilder(
                                            future: cnConfig.isSpotifyInstalled(delayMilliseconds: 800, context: context),
                                            builder: (context, connected){
                                              if(!connected.hasData){
                                                return Center(
                                                  child: SizedBox(
                                                    height: 15,
                                                    width: 15,
                                                    child: CupertinoActivityIndicator(
                                                        radius: 8.0,
                                                        color: Colors.amber[800]
                                                    ),
                                                    // child: CircularProgressIndicator(strokeWidth: 2,)
                                                  ),
                                                );
                                              }
                                              return Icon(
                                                connected.data == true
                                                    ? Icons.check_circle
                                                    : Icons.close,
                                                size: 15,
                                                color: connected.data == true
                                                    ? Colors.green
                                                    : Colors.red,
                                              );
                                            }
                                        )
                                    ],
                                  ),
                                  trailing: CupertinoSwitch(
                                      value: cnConfig.useSpotify,
                                      activeColor: const Color(0xFFC16A03),
                                      onChanged: (value) async{
                                        setState(() {
                                          if(Platform.isAndroid){
                                            HapticFeedback.selectionClick();
                                          }
                                          cnConfig.setSpotify(value);
                                        });
                                      }
                                  ),
                                ),

                                /// Use Health Data
                                CupertinoListTile(
                                  leading: Stack(
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
                                        child: Padding(
                                          padding: const EdgeInsets.all(2),
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: Icon(
                                              MyIcons.heart,
                                              color: Colors.black.withOpacity(0.8),
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Row(
                                    children: [
                                      Text("Apple Health", style: const TextStyle(color: Colors.white)),
                                      const SizedBox(width: 5),
                                      if(cnConfig.useHealthData)
                                        FutureBuilder(
                                            future: cnConfig.isHealthDataAccessAllowed(cnScreenStatistics),
                                            builder: (context, connected){
                                              if(!connected.hasData){
                                                return Center(
                                                  child: SizedBox(
                                                    height: 15,
                                                    width: 15,
                                                    child: CupertinoActivityIndicator(
                                                        radius: 8.0,
                                                        color: Colors.amber[800]
                                                    ),
                                                    // child: CircularProgressIndicator(strokeWidth: 2,)
                                                  ),
                                                );
                                              }
                                              return Icon(
                                                connected.data == true
                                                    ? Icons.check_circle
                                                    : Icons.close,
                                                size: 15,
                                                color: connected.data == true
                                                    ? Colors.green
                                                    : Colors.red,
                                              );
                                            }
                                        )
                                    ],
                                  ),
                                  trailing: CupertinoSwitch(
                                      value: cnConfig.useHealthData,
                                      activeColor: const Color(0xFFC16A03),
                                      onChanged: (value) async{
                                        setState(() async{
                                          if(Platform.isAndroid){
                                            HapticFeedback.selectionClick();
                                          }
                                          cnConfig.setHealth(value);
                                          if(!value){
                                            Future.delayed(const Duration(milliseconds: 500), (){
                                              cnScreenStatistics.health.revokePermissions();
                                            });
                                          }
                                          await cnScreenStatistics.refreshHealthData().then((value){
                                            if(value){
                                              cnScreenStatistics.selectedExerciseName = "Gewicht";
                                            }
                                          });
                                          cnScreenStatistics.refreshData();
                                          cnScreenStatistics.calcMinMaxDates();
                                          cnScreenStatistics.refresh();
                                        });
                                      }
                                  ),
                                ),
                              ],
                            ),

                            /// Backup
                            CupertinoListSection.insetGrouped(
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1)
                              ),
                              backgroundColor: Colors.transparent,
                              header: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(AppLocalizations.of(context)!.settingsBackup, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w300),),
                              ),
                              /// More Informations footer
                              footer: GestureDetector(
                                onTap: () async{
                                  HapticFeedback.selectionClick();
                                  controllerExplainBackups.open();
                                  // await showDialog(
                                  //     context: context,
                                  //     builder: (context){
                                  //       return Center(
                                  //           child: getBackupDialogChild()
                                  //       );
                                  //     }
                                  // );
                                  // HapticFeedback.selectionClick();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info, size:12),
                                      const SizedBox(width: 5,),
                                      Text(AppLocalizations.of(context)!.settingsBackupMoreInfo, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w300),),
                                    ],
                                  ),
                                ),
                              ),
                              children: [
                                /// Save Backup Manual
                                CupertinoListTile(
                                  leading: const Icon(Icons.upload),
                                  title:getSelectCreateBackup(),
                                ),
                                /// Load Backup
                                CupertinoListTile(
                                  leading: const Icon(Icons.download),
                                  title: getSelectLoadBackupOption(),
                                ),
                                /// Save Backup Automatic
                                CupertinoListTile(
                                  leading: const Icon(Icons.sync),
                                  title: OverflowSafeText(
                                      maxLines: 1,
                                      AppLocalizations.of(context)!.settingsBackupSaveAutomatic,
                                      style: const TextStyle(color: Colors.white)
                                  ),
                                  trailing: CupertinoSwitch(
                                      value: cnConfig.automaticBackups,
                                      activeColor: const Color(0xFFC16A03),
                                      onChanged: (value){
                                        setState(() {
                                          if(Platform.isAndroid){
                                            HapticFeedback.selectionClick();
                                          }
                                          cnConfig.setAutomaticBackups(value);
                                        });
                                      }
                                  ),
                                ),

                                AnimatedContainer(
                                  height: cnConfig.showMoreSettingCloud? 5 : 0,
                                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                                  duration: const Duration(milliseconds: 300),
                                ),


                                /// Sync with Cloud
                                getCloudOptionsColumn(
                                    cnConfig: cnConfig,
                                    context: context,
                                    refresh: () => setState(() {})
                                )
                              ],
                            ),

                            /// About
                            CupertinoListSection.insetGrouped(
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1)
                              ),
                              backgroundColor: Colors.transparent,
                              header: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(AppLocalizations.of(context)!.settingsAbout, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w300),),
                              ),
                              children: [
                                /// Contact
                                CupertinoListTile(
                                  leading: const Icon(
                                      Icons.help_outline
                                  ),
                                  title: getSelectContactButton(),
                                ),
                                /// Github
                                CupertinoListTile(
                                  onTap: () async{
                                    await openUrl("https://github.com/Chris20008/O-n-e-D-a-y-");
                                  },
                                  leading: const Icon(
                                      MyIcons.github_circled
                                  ),
                                  trailing: trailingArrow,
                                  title: Text(AppLocalizations.of(context)!.settingsContribute, style: const TextStyle(color: Colors.white)),
                                ),
                                /// Term Of Use
                                CupertinoListTile(
                                  onTap: () async{
                                    await openUrl("https://github.com/Chris20008/O-n-e-D-a-y-/blob/master/TERMS%20OF%20USE.md#terms-of-use");
                                  },
                                  leading: const Icon(
                                      Icons.my_library_books_rounded
                                  ),
                                  trailing: trailingArrow,
                                  title: Text(AppLocalizations.of(context)!.settingsTermsOfUse, style: const TextStyle(color: Colors.white)),
                                ),
                                /// Privacy Policy
                                CupertinoListTile(
                                  onTap: () async{
                                    await openUrl("https://github.com/Chris20008/O-n-e-D-a-y-/blob/master/PRIVACY%20POLICY.md#privacy-policy");
                                  },
                                  leading: const Icon(
                                      Icons.lock_outline
                                  ),
                                  trailing: trailingArrow,
                                  title: Text(AppLocalizations.of(context)!.settingsPrivacyPolicy, style: const TextStyle(color: Colors.white)),
                                ),
                                /// Imprint
                                CupertinoListTile(
                                  onTap: () async{
                                    await openUrl("https://github.com/Chris20008/O-n-e-D-a-y-/blob/master/IMPRINT.md#imprint");
                                  },
                                  leading: const Text("§", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 18)),
                                  trailing: trailingArrow,
                                  title: Text(AppLocalizations.of(context)!.settingsImprint, style: const TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 50,)
                          ],
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
            MySlideUpPanel(
              controller: controllerExplainBackups,
              animationControllerName: "ExplainBackups",
              descendantAnimationControllerName: "ScreenSettings",
              panelBuilder: (context, listView){
                return Column(
                  children: [
                    const SizedBox(height: 10,),
                    panelTopBar,
                    const SizedBox(height: 10,),
                    Expanded(
                      child: listView(
                        padding: EdgeInsets.zero,
                        controller: scrollControllerBackups,
                        children: [
                          CupertinoListTile(
                            // onTap: getSelectCreateBackup,
                            leading: const Icon(
                                Icons.upload,
                            ),
                            title: OverflowSafeText(
                                maxLines: 1,
                                AppLocalizations.of(context)!.settingsBackupSaveManual,
                                style: const TextStyle(color: Colors.white)
                            ),
                          ),
                          Padding(padding: const EdgeInsets.only(left: 30, right: 15) ,child: Text(AppLocalizations.of(context)!.settingsBackupSaveManualExplanation)),
                          const SizedBox(height: 15),
                      
                          /// Load Backup
                          CupertinoListTile(
                            leading: const Icon(
                                Icons.download
                            ),
                            title: Text(AppLocalizations.of(context)!.settingsBackupLoad, style: const TextStyle(color: Colors.white)),
                          ),
                          Padding(padding: const EdgeInsets.only(left: 30, right: 15) ,child: Text(AppLocalizations.of(context)!.settingsBackupLoadExplanation)),
                          const SizedBox(height: 15),
                      
                          getBackupDialogWelcomeScreen(context: context)
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            if (_showLoadingIndicator)
              Container(
                color: Colors.black.withOpacity(0.5),
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

  Future _loadBackupFromFilePicker() async{
    setState(() {
      _showLoadingIndicator = true;
    });
    File? file = await getBackupFromFilePicker(cnHomepage: cnHomepage);
    setState(() {
      _showLoadingIndicator = false;
    });
    if(file != null){
      cnStandardPopUp.open(
          confirmText: AppLocalizations.of(context)!.yes,
          cancelText: AppLocalizations.of(context)!.no,
          widthFactor: 0.8,
          context: context,
          child: Column(
            children: [
              Text(AppLocalizations.of(context)!.settingsBackupLoad, style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 18),),
              const SizedBox(height: 5),
              Text(AppLocalizations.of(context)!.settingsBackupLoadTextToConfirm, textAlign: TextAlign.center, textScaler: const TextScaler.linear(0.9),)
            ],
          ),
          onConfirm: ()async{
            setState(() {
              _showLoadingIndicator = true;
            });
            bool resultLoadBackup = false;
            try{
              await loadBackupFromFile(file, cnHomepage: cnHomepage).then((result) => resultLoadBackup = result);
              tutorialIsRunning = false;
              currentTutorialStep = maxTutorialStep;
              cnConfig.setCurrentTutorialStep(currentTutorialStep);
              cnScreenStatistics.refreshData();
              cnScreenStatistics.resetGraph();
              cnScreenStatistics.refresh();
              await cnConfig.config.save();
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.backupLoadSuccess,
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey[800]?.withOpacity(0.9),
                  textColor: Colors.white,
                  fontSize: 16.0
              );
              setState(() {
                _showLoadingIndicator = false;
              });
            }
            catch (_){
              setState(() {
                _showLoadingIndicator = false;
              });
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.backupLoadNotSuccess,
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey[800]?.withOpacity(0.9),
                  textColor: Colors.white,
                  fontSize: 16.0
              );
            }
            if(resultLoadBackup){
              Future.delayed(const Duration(seconds: 5), (){
                saveCurrentData(cnConfig);
              });
            }
          }
      );
    }
  }

  void onPanelSlide(value){
    // cnScreenStatistics.animationControllerStatisticsScreen.value = value;
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

  Widget getSelectLanguageButton() {
    return PullDownButton(
      onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
      routeTheme: routeTheme,
      itemBuilder: (context) {
        final currentLanguage = getLanguageAsString(context);
        final List<String> lanAsStrings = languagesAsString.keys.toList();
        List<PullDownMenuItem> buttons = List.generate(lanAsStrings.length, (index) {
          return PullDownMenuItem.selectable(
            selected: currentLanguage == lanAsStrings[index],
            title: lanAsStrings[index],
            onTap: () {
              HapticFeedback.selectionClick();
              Future.delayed(const Duration(milliseconds: 200), (){
                MyApp.of(context)?.setLocale(languageCode: languagesAsString[lanAsStrings[index]], config: cnConfig);
              });
            },
          );
        });

        return buttons;
      },
      buttonBuilder: (context, showMenu) => CupertinoButton(
        onPressed: (){
          HapticFeedback.selectionClick();
          showMenu();
        },
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            Text(
                AppLocalizations.of(context)!.settingsLanguage,
                style: const TextStyle(color: Colors.white)
            ),
            const Spacer(),
            Text(
              getLanguageAsString(context),
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(width: 6,),
            trailingChoice()
          ],
        ),
      ),
    );
  }

  Widget getSelectLoadBackupOption() {
    return PullDownButton(
      onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
      routeTheme: routeTheme,
      itemBuilder: (context) {
        return [
          PullDownMenuItem(
            title: AppLocalizations.of(context)!.settingsBackupLoadExternal,
            onTap: () {
              HapticFeedback.selectionClick();
              Future.delayed(const Duration(milliseconds: 200), (){
                _loadBackupFromFilePicker();
              });
            },
          ),
          PullDownMenuItem(
            title: AppLocalizations.of(context)!.settingsBackupLoadLocal,
            onTap: () {
              HapticFeedback.selectionClick();
              Future.delayed(const Duration(milliseconds: 200), () async{
                final localFiles = await getLocalBackupFiles();
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => LocalFilePicker(localFiles: localFiles)
                    ));
              });
            },
          ),
        ];
      },
      buttonBuilder: (context, showMenu) => CupertinoButton(
          onPressed: (){
            HapticFeedback.selectionClick();
            showMenu();
          },
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              Text(AppLocalizations.of(context)!.settingsBackupLoad, style: const TextStyle(color: Colors.white)),
              const Spacer(),
              trailingChoice()
            ],
          )
      ),
    );
  }

  Widget getSelectContactButton() {
    return PullDownButton(
      onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
      routeTheme: routeTheme,
      itemBuilder: (context) {
        return [
          PullDownMenuItem(
            title: AppLocalizations.of(context)!.settingsQuestion,
            onTap: () {
              HapticFeedback.selectionClick();
              Future.delayed(const Duration(milliseconds: 200), (){
                sendMail(subject: "Question");
              });
            },
          ),
          PullDownMenuItem(
            title: AppLocalizations.of(context)!.settingsReportProblem,
            onTap: () {
              HapticFeedback.selectionClick();
              Future.delayed(const Duration(milliseconds: 200), (){
                sendMail(subject: "Report Problem");
              });
            },
          ),
          PullDownMenuItem(
            title: AppLocalizations.of(context)!.settingsImprovement,
            onTap: () {
              HapticFeedback.selectionClick();
              Future.delayed(const Duration(milliseconds: 200), (){
                sendMail(subject: "Suggestion for Improvement");
              });
            },
          ),
          PullDownMenuItem(
            title: AppLocalizations.of(context)!.settingsOther,
            onTap: () {
              HapticFeedback.selectionClick();
              Future.delayed(const Duration(milliseconds: 200), (){
                sendMail(subject: "");
              });
            },
          ),
        ];
      },
      buttonBuilder: (context, showMenu) => CupertinoButton(
          onPressed: (){
            HapticFeedback.selectionClick();
            showMenu();
          },
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              Text(AppLocalizations.of(context)!.settingsContact, style: const TextStyle(color: Colors.white)),
              const Spacer(),
              trailingChoice()
            ],
          )
      ),
    );
  }

  Widget getSelectCreateBackup() {
    return PullDownButton(
      onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
      routeTheme: routeTheme,
      itemBuilder: (context) {
        return [
          PullDownMenuItem(
            title: AppLocalizations.of(context)!.settingsBackupSaveManualMethodSave,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _showLoadingIndicator = true;
              });
              Future.delayed(const Duration(milliseconds: 300), () async{
                File? result = await saveBackup(withCloud: cnConfig.saveBackupCloud, cnConfig: cnConfig, automatic: false);
                await saveCurrentData(cnConfig);
                setState(() {
                  _showLoadingIndicator = false;
                });
                if(result != null){
                  Fluttertoast.showToast(
                      msg: "${AppLocalizations.of(context)!.createdManualBackup} ✅️",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.TOP,
                      timeInSecForIosWeb: 2,
                      backgroundColor: Colors.grey[800]?.withOpacity(0.9),
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                }
                else{
                  Fluttertoast.showToast(
                      msg: "${AppLocalizations.of(context)!.createdBackupFailed} ❌",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.TOP,
                      timeInSecForIosWeb: 2,
                      backgroundColor: Colors.grey[800]?.withOpacity(0.9),
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                }
              });
            },
          ),
          PullDownMenuItem(
          title: AppLocalizations.of(context)!.settingsBackupSaveManualMethodShare,
            onTap: () async{
              await shareBackup(cnConfig: cnConfig);
            },
          ),
        ];
      },
      buttonBuilder: (context, showMenu) => CupertinoButton(
        onPressed: (){
          HapticFeedback.selectionClick();
          showMenu();
        },
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            Expanded(
              child: OverflowSafeText(
                  maxLines: 1,
                  AppLocalizations.of(context)!.settingsBackupSaveManual,
                  style: const TextStyle(color: Colors.white)
              ),
            ),
            const SizedBox(width: 10),
            trailingChoice()
          ],
        ),
      ),
    );
  }

  // Widget getBackupDialogChild() {
  //   return standardDialog(
  //       context: context,
  //       maxWidth: 400,
  //       widthFactor: 0.9,
  //       maxHeight: 680,
  //       child: Column(
  //         children: [
  //
  //           /// Save manual backup
  //           CupertinoListTile(
  //             // onTap: getSelectCreateBackup,
  //             leading: const Icon(
  //                 Icons.upload
  //             ),
  //             title: OverflowSafeText(
  //                 maxLines: 1,
  //                 AppLocalizations.of(context)!.settingsBackupSaveManual,
  //                 style: const TextStyle(color: Colors.white)
  //             ),
  //           ),
  //           Padding(padding: const EdgeInsets.only(left: 30) ,child: Text(AppLocalizations.of(context)!.settingsBackupSaveManualExplanation)),
  //           const SizedBox(height: 15),
  //
  //           /// Load Backup
  //           CupertinoListTile(
  //             leading: const Icon(
  //                 Icons.download
  //             ),
  //             title: Text(AppLocalizations.of(context)!.settingsBackupLoad, style: const TextStyle(color: Colors.white)),
  //           ),
  //           Padding(padding: const EdgeInsets.only(left: 30) ,child: Text(AppLocalizations.of(context)!.settingsBackupLoadExplanation)),
  //           const SizedBox(height: 15),
  //
  //           getBackupDialogWelcomeScreen(context: context)
  //         ],
  //       )
  //   );
  // }
}