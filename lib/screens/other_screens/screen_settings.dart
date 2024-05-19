import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
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
  final Widget trailingArrow = const Icon(
    Icons.arrow_forward_ios,
    size: 12,
    color: Colors.grey,
  );

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
                maxHeight: constraints.maxHeight - 50,
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
                            CupertinoListTile(
                              leading: const Icon(
                                Icons.language
                              ),
                              trailing: getSelectLanguageButton(),
                              title: Text(AppLocalizations.of(context)!.settingsLanguage, style: const TextStyle(color: Colors.white)),
                            ),
                            CupertinoListTile(
                              leading: const Icon(
                                  Icons.school
                              ),
                              trailing: CupertinoSwitch(
                                  value: true,
                                  activeColor: const Color(0xFFC16A03),
                                  onChanged: (value){
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
                            onTap: (){
                              showDialog(
                                  context: context,
                                  builder: (context){
                                    return Center(
                                      child: getBackupDialogChild()
                                    );
                                  }
                              );
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
                            /// Save Backup
                            CupertinoListTile(
                              onTap: saveBackup,
                              leading: const Icon(
                                  Icons.backup
                              ),
                              title: Text(AppLocalizations.of(context)!.settingsBackupSave, style: const TextStyle(color: Colors.white)),
                            ),
                            /// Load Backup
                            CupertinoListTile(
                              onTap: loadBackup,
                              leading: const Icon(
                                  Icons.cloud_download
                              ),
                              title: Text(AppLocalizations.of(context)!.settingsBackupLoad, style: const TextStyle(color: Colors.white)),
                            ),
                            /// Sync with iCloud
                            CupertinoListTile(
                              leading: const Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                      Icons.cloud
                                  ),
                                  Center(
                                    child: Icon(
                                      Icons.sync,
                                      size: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ]
                              ),
                              trailing: CupertinoSwitch(
                                  value: true,
                                  activeColor: const Color(0xFFC16A03),
                                  onChanged: (value){}
                              ),
                              title: Text(AppLocalizations.of(context)!.settingsSynciCloud, style: const TextStyle(color: Colors.white)),
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
                              onTap: () {sendMailto();},
                              leading: const Icon(
                                  Icons.help_outline
                              ),
                              trailing: trailingArrow,
                              title: Text(AppLocalizations.of(context)!.settingsContact, style: const TextStyle(color: Colors.white)),
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
                              leading: const Icon(
                                  Icons.my_library_books_rounded
                              ),
                              title: Text(AppLocalizations.of(context)!.settingsTermsOfUse, style: const TextStyle(color: Colors.white)),
                            ),
                            /// Privacy Policy
                            CupertinoListTile(
                              leading: const Icon(
                                  Icons.lock_outline
                              ),
                              title: Text(AppLocalizations.of(context)!.settingsPrivacyPolicy, style: const TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
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
  }

  Widget getBackupDialogChild() {
    return standardDialog(
        context: context,
        child: const Center(
            child: Text("test")
        )
    );
  }

  Widget getSelectLanguageButton() {
    return PullDownButton(
      itemBuilder: (context) {
        final currentLanguage = getLanguageAsString(context);
        return [
          PullDownMenuItem.selectable(
            selected: currentLanguage == 'Deutsch',
            title: 'Deutsch',
            onTap: () {
              if(Platform.isAndroid){
                HapticFeedback.selectionClick();
              }
              Future.delayed(const Duration(milliseconds: 200), (){
                MyApp.of(context)?.setLocale(language: LANGUAGES.de, config: cnConfig);
              });
            },
          ),
          PullDownMenuItem.selectable(
            selected: currentLanguage == 'English',
            title: 'English',
            onTap: () {
              if(Platform.isAndroid){
                HapticFeedback.selectionClick();
              }
              Future.delayed(const Duration(milliseconds: 200), (){
                MyApp.of(context)?.setLocale(language: LANGUAGES.en, config: cnConfig);
              });
            },
          ),
        ];
      },
      buttonBuilder: (context, showMenu) => CupertinoButton(
        onPressed: (){
          if(Platform.isAndroid){
            HapticFeedback.selectionClick();
          }
          showMenu();
        },
        padding: EdgeInsets.zero,
        child: Row(
          children: [
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
}


























