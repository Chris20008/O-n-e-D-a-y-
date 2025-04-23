import 'package:fitness_app/screens/other_screens/screen_settings/widgets/2_backup_options/widgets/selector_create_backup.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/widgets/2_backup_options/widgets/selector_load_backup.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class BackupOptions extends StatelessWidget {

  final PanelController controllerExplainBackups;
  final Function(bool value) setLoadingIndicator;
  final CnConfig cnConfig;
  final CnScreenStatistics cnScreenStatistics;
  final CnHomepage cnHomepage;
  final Function(Function) refresh;

  const BackupOptions({
    super.key,
    required this.controllerExplainBackups,
    required this.setLoadingIndicator,
    required this.cnConfig,
    required this.cnScreenStatistics,
    required this.cnHomepage,
    required this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      decoration: BoxDecoration(
          color: CupertinoTheme.of(context).barBackgroundColor
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
          controllerExplainBackups.animatePanelToPosition(
              1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastEaseInToSlowEaseOut
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
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
      children: [
        /// Save Backup Manual
        CupertinoListTile(
          leading: const Icon(
            Icons.upload,
            color: Colors.white,
          ),
          title:SelectorCreateBackup(
            setLoadingIndicator: setLoadingIndicator,
            cnConfig: cnConfig,
          ),
        ),
        /// Load Backup
        CupertinoListTile(
          leading: const Icon(
            Icons.download,
            color: Colors.white,
          ),
          title: SelectorLoadBackup(
            setLoadingIndicator: setLoadingIndicator,
            cnScreenStatistics: cnScreenStatistics,
            cnConfig: cnConfig,
            cnHomepage: cnHomepage,
          ),
        ),
        /// Save Backup Automatic
        CupertinoListTile(
          leading: const Icon(
            Icons.sync,
            color: Colors.white,
          ),
          title: OverflowSafeText(
              maxLines: 1,
              AppLocalizations.of(context)!.settingsBackupSaveAutomatic,
              style: const TextStyle(color: Colors.white)
          ),
          trailing: CupertinoSwitch(
              value: cnConfig.automaticBackups,
              activeTrackColor: activeColor,
              onChanged: (value){
                refresh(() {
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
          color: CupertinoTheme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
          duration: const Duration(milliseconds: 300),
        ),


        /// Sync with Cloud
        getCloudOptionsColumn(
            cnConfig: cnConfig,
            context: context,
            refresh: () => refresh(() {})
        )
      ],
    );
  }
}
