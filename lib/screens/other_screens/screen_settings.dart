import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/util/backup_functions.dart';
import 'package:fitness_app/widgets/bottom_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'dart:io';
import 'package:fitness_app/assets/custom_icons/my_icons.dart';
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

class _SettingsPanelState extends State<SettingsPanel> {
  late CnScreenStatistics cnScreenStatistics = Provider.of<CnScreenStatistics>(context);
  late CnBottomMenu cnBottomMenu = Provider.of<CnBottomMenu>(context, listen: false);
  late CnConfig cnConfig  = Provider.of<CnConfig>(context, listen: false);
  bool setOrientation = false;
  bool _tutorial = true;
  bool _automaticBackups = true;
  bool _syncWithCloud = false;

  @override
  void initState() {
    _tutorial = cnConfig.tutorial;
    _automaticBackups = cnConfig.automaticBackups;
    _syncWithCloud = cnConfig.syncWithCloud;
    super.initState();
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
        child: LayoutBuilder(
            builder: (context, constraints){
              return SlidingUpPanel(
                controller: cnScreenStatistics.panelControllerSettings,
                defaultPanelState: PanelState.CLOSED,
                maxHeight: constraints.maxHeight - (Platform.isAndroid? 50 : 70),
                minHeight: 0,
                isDraggable: true,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
                backdropEnabled: true,
                backdropColor: Colors.black,
                color: Colors.transparent,
                onPanelSlide: onPanelSlide,
                panel: ClipRRect(
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: Column(
                      children: [
                        const SizedBox(height: 10,),
                        panelTopBar,
                        const SizedBox(height: 10,),
                        Text(AppLocalizations.of(context)!.settings,textScaler: const TextScaler.linear(1.4)),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
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
                                    leading: const Icon(
                                        Icons.school
                                    ),
                                    trailing: CupertinoSwitch(
                                        value: _tutorial,
                                        activeColor: const Color(0xFFC16A03),
                                        onChanged: (value){
                                          setState(() {
                                            if(Platform.isAndroid){
                                              HapticFeedback.selectionClick();
                                            }
                                            _tutorial = value;
                                            cnConfig.setTutorial(_tutorial);
                                          });
                                        }
                                    ),
                                    title: Text(AppLocalizations.of(context)!.settingsTutorial, style: const TextStyle(color: Colors.white)),
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
                                    await showDialog(
                                        context: context,
                                        builder: (context){
                                          return Center(
                                              child: getBackupDialogChild()
                                          );
                                        }
                                    );
                                    HapticFeedback.selectionClick();
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
                                    // onTap: getSelectCreateBackup,
                                    leading: const Icon(
                                        Icons.backup
                                    ),
                                    title:getSelectCreateBackup(),
                                  ),
                                  /// Load Backup
                                  CupertinoListTile(
                                    onTap: () async{
                                      await loadBackup();
                                      cnScreenStatistics.refreshData();
                                      cnScreenStatistics.refresh();
                                    },
                                    leading: const Icon(
                                        Icons.cloud_download
                                    ),
                                    title: Text(AppLocalizations.of(context)!.settingsBackupLoad, style: const TextStyle(color: Colors.white)),
                                    trailing: trailingArrow,
                                  ),
                                  /// Save Backup Automatic
                                  CupertinoListTile(
                                    leading: const Icon(
                                        Icons.cloud_done
                                    ),
                                    title: Text(AppLocalizations.of(context)!.settingsBackupSaveAutomatic, style: const TextStyle(color: Colors.white)),
                                    trailing: CupertinoSwitch(
                                        value: _automaticBackups,
                                        activeColor: const Color(0xFFC16A03),
                                        onChanged: (value){
                                          setState(() {
                                            if(Platform.isAndroid){
                                              HapticFeedback.selectionClick();
                                            }
                                            _automaticBackups = value;
                                            cnConfig.setAutomaticBackups(_automaticBackups);
                                          });
                                        }
                                    ),
                                  ),
                                  /// Sync with Cloud
                                  CupertinoListTile(
                                    leading: const Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Icon(
                                              Icons.cloud
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 1),
                                            child: Center(
                                              child: Icon(
                                                Icons.sync,
                                                size: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ]
                                    ),
                                    trailing: CupertinoSwitch(
                                        value: _syncWithCloud,
                                        activeColor: const Color(0xFFC16A03),
                                        onChanged: (value)async{
                                          if(Platform.isAndroid){
                                            HapticFeedback.selectionClick();
                                            if(value == true){
                                              // cnConfig.signInGoogleDrive();
                                            } else{
                                              cnConfig.account = null;
                                            }
                                          }
                                          _syncWithCloud = value;
                                          cnConfig.setSyncWithCloud(_syncWithCloud);
                                          setState(() {});
                                        }
                                    ),
                                    title: Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Row(
                                        // crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: OverflowSafeText(
                                                maxLines: 1,
                                              Platform.isAndroid
                                                    ? AppLocalizations.of(context)!.settingsSyncGoogleDrive
                                                    : AppLocalizations.of(context)!.settingsSynciCloud,
                                                style: const TextStyle(color: Colors.white),
                                            ),
                                          ),
                                          if(_syncWithCloud && Platform.isAndroid)
                                            const SizedBox(width: 10),
                                          /// The future "cnConfig.signInGoogleDrive()" is currently not configured for IOS
                                          /// so calling it will lead to an crash
                                          /// We have to make sure it is only called on Android!
                                          if(_syncWithCloud && Platform.isAndroid)
                                            FutureBuilder(
                                                future: cnConfig.signInGoogleDrive(),
                                                builder: (context, connected){
                                                  if(!connected.hasData){
                                                    return const Center(
                                                      child: SizedBox(
                                                          height: 15,
                                                          width: 15,
                                                          child: CircularProgressIndicator(strokeWidth: 2,)
                                                      ),
                                                    );
                                                  }
                                                  return Icon(
                                                    cnConfig.account != null
                                                        ? Icons.check_circle
                                                        : Icons.close,
                                                    size: 15,
                                                    color: cnConfig.account != null
                                                        ? Colors.green
                                                        : Colors.red,
                                                  );
                                                }
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
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
                                        MyIcons.github
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
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
        )
    );
  }

  void onPanelSlide(value){
    cnScreenStatistics.animationControllerSettingPanel.value = value;
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
        return [
          PullDownMenuItem.selectable(
            selected: currentLanguage == 'Deutsch',
            title: 'Deutsch',
            onTap: () {
              HapticFeedback.selectionClick();
              Future.delayed(const Duration(milliseconds: 200), (){
                MyApp.of(context)?.setLocale(language: LANGUAGES.de, config: cnConfig);
              });
            },
          ),
          PullDownMenuItem.selectable(
            selected: currentLanguage == 'English',
            title: 'English',
            onTap: () {
              HapticFeedback.selectionClick();
              Future.delayed(const Duration(milliseconds: 200), (){
                MyApp.of(context)?.setLocale(language: LANGUAGES.en, config: cnConfig);
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
            trailingArrow
          ],
        ),
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
              trailingArrow
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
              Future.delayed(const Duration(milliseconds: 200), (){
                saveBackup(withCloud: _syncWithCloud, cnConfig: cnConfig);
              });
            },
          ),
          PullDownMenuItem(
          title: AppLocalizations.of(context)!.settingsBackupSaveManualMethodShare,
            onTap: () {
              /// ToDo: implement share functionality
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
            trailingArrow
          ],
        ),
      ),
    );
  }

  Widget getBackupDialogChild() {
    return standardDialog(
        context: context,
        maxWidth: 400,
        widthFactor: 0.9,
        maxHeight: 650,
        child: Column(
          children: [

            /// Save manual backup
            CupertinoListTile(
              // onTap: getSelectCreateBackup,
              leading: const Icon(
                  Icons.backup
              ),
              title: OverflowSafeText(
                  maxLines: 1,
                  AppLocalizations.of(context)!.settingsBackupSaveManual,
                  style: const TextStyle(color: Colors.white)
              ),
            ),
            Padding(padding: const EdgeInsets.only(left: 30) ,child: Text(AppLocalizations.of(context)!.settingsBackupSaveManualExplanation)),
            const SizedBox(height: 15),

            /// Load Backup
            CupertinoListTile(
              leading: const Icon(
                  Icons.cloud_download
              ),
              title: Text(AppLocalizations.of(context)!.settingsBackupLoad, style: const TextStyle(color: Colors.white)),
            ),
            Padding(padding: const EdgeInsets.only(left: 30) ,child: Text(AppLocalizations.of(context)!.settingsBackupLoadExplanation)),
            const SizedBox(height: 15),

            /// Save Backup Automatic
            CupertinoListTile(
              leading: const Icon(
                  Icons.cloud_done
              ),
              title: Text(AppLocalizations.of(context)!.settingsBackupSaveAutomatic, style: const TextStyle(color: Colors.white)),
            ),
            Padding(padding: const EdgeInsets.only(left: 30) ,child: Text(AppLocalizations.of(context)!.settingsBackupSaveAutomaticExplanation)),
            const SizedBox(height: 15),

            /// Sync with iCloud
            CupertinoListTile(
              leading: const Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                        Icons.cloud
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Center(
                        child: Icon(
                          Icons.sync,
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ]
              ),
              title: OverflowSafeText(
                  maxLines: 1,
                  Platform.isAndroid
                      ? AppLocalizations.of(context)!.settingsSyncGoogleDrive
                      : AppLocalizations.of(context)!.settingsSynciCloud,
                  style: const TextStyle(color: Colors.white)
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(Platform.isAndroid
                    ? AppLocalizations.of(context)!.settingsBackupSyncGoogleDriveExplanation
                    : AppLocalizations.of(context)!.settingsBackupSynciCloudExplanation
                )
            ),
            const SizedBox(height: 15),
          ],
        )
    );
  }
}