import 'dart:io';

import 'package:fitness_app/widgets/slide_up_panel/my_slide_up_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../widgets/slide_up_panel/animation_controller_name.dart';
import '../../../../widgets/slide_up_panel/panel_header.dart';
import '../screen_settings.dart';
import '../widgets/settings_icon.dart';

class ExplainBackupPanel extends StatelessWidget {
  final bool reducedView;
  final Function(double value)? onPanelSlide;

  const ExplainBackupPanel({
    super.key,
    this.reducedView = false,
    this.onPanelSlide
  });

  @override
  Widget build(BuildContext context) {

    final CnSettings cnSettings = context.read<CnSettings>();

    return MySlideUpPanel(
      onPanelSlide: onPanelSlide,
      controller: cnSettings.panelControllerExplainBackups,
      animationControllerName: AnimationControllerName.explainBackups,
      descendantAnimationControllerName: cnSettings.explainBackupPanelDescendantAnimationControllerName,
      panelBuilder: (context, listView){
        return Stack(
          children: [
            listView(
              padding: const EdgeInsets.only(top: 60),
              controller: cnSettings.scrollControllerExplainBackups,
              children: [

                Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: Text(AppLocalizations.of(context)!.settinsgExplainWhyBackups(Platform.isAndroid? "Google Drive" : "iCloud"))
                ),
                const SizedBox(height: 30),

                if(!reducedView)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Create Backup
                      CupertinoListTile(
                        leading: const SettingsIcon(iconPath: "create_backup.png"),
                        title: OverflowSafeText(
                            maxLines: 1,
                            AppLocalizations.of(context)!.settingsBackupSaveManual,
                            style: const TextStyle(color: Colors.white)
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: Text(AppLocalizations.of(context)!.settingsBackupSaveManualExplanation + (Platform.isAndroid
                              ? AppLocalizations.of(context)!.saveGoogleDrive
                              : AppLocalizations.of(context)!.saveICloud)
                          )
                      ),
                      const SizedBox(height: 15),

                      /// Share Backup
                      CupertinoListTile(
                        leading: const SettingsIcon(iconPath: "share.png"),
                        title: OverflowSafeText(
                            maxLines: 1,
                            AppLocalizations.of(context)!.settingsShareBackup,
                            style: const TextStyle(color: Colors.white)
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: Text(AppLocalizations.of(context)!.settingsShareBackupExplanation)
                      ),
                      const SizedBox(height: 15),

                      /// Load Backup External
                      CupertinoListTile(
                        leading: const SettingsIcon(iconPath: "backup_from_cloud.png"),
                        title: Text(AppLocalizations.of(context)!.settingsBackupLoadExternal, style: const TextStyle(color: Colors.white)),
                      ),
                      Padding(padding: const EdgeInsets.only(left: 30, right: 30),child: Text(AppLocalizations.of(context)!.settingsBackupLoadExplanation)),
                      const SizedBox(height: 15),

                      /// Save Backup Automatic
                      CupertinoListTile(
                        leading: const SettingsIcon(iconPath: "sync_with_cloud.png"),
                        title: OverflowSafeText(
                            maxLines: 1,
                            AppLocalizations.of(context)!.settingsBackupSaveAutomatic,
                            style: const TextStyle(color: Colors.white)
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: Text(AppLocalizations.of(context)!.settingsBackupSaveAutomaticExplanation + (
                              Platform.isAndroid
                                  ? AppLocalizations.of(context)!.saveGoogleDrive
                                  : AppLocalizations.of(context)!.saveICloud
                          )
                          )
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),

                /// Connect with Cloud
                CupertinoListTile(
                  leading: SettingsIcon(iconPath: Platform.isAndroid? "google_drive.png" : "connect_icloud.png"),
                  title: OverflowSafeText(
                      maxLines: 1,
                      Platform.isAndroid
                          ? AppLocalizations.of(context)!.settingsConnectGoogleDrive
                          : AppLocalizations.of(context)!.settingsConnectiCloud,
                      style: const TextStyle(color: Colors.white)
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: Text(Platform.isAndroid
                        ? AppLocalizations.of(context)!.settingsConnectGoogleDriveExplanation
                        : AppLocalizations.of(context)!.settingsConnectiCloudExplanation
                    )
                ),
                const SizedBox(height: 30),
              ],
            ),

            PanelHeader(text: AppLocalizations.of(context)!.settingsBackups),
          ],
        );
      },
    );
  }
}
