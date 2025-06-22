import 'package:fitness_app/screens/other_screens/screen_settings/screens/backups_screen/widgets/connect_with_cloud.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../../../util/backup_helper/backup_functions.dart';
import '../../../../screen_settings.dart';
import '../../../backups_screen/widgets/create_backup.dart';
import '../../../backups_screen/widgets/load_backup_external.dart';

class BackupOptions extends StatelessWidget {

  const BackupOptions({super.key});

  @override
  Widget build(BuildContext context) {

    final CnSettings cnSettings = context.read<CnSettings>();
    final CnConfig cnConfig = context.read<CnConfig>();

    return CupertinoListSection.insetGrouped(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor
      ),
      backgroundColor: Colors.transparent,
      // header: Padding(
      //   padding: const EdgeInsets.only(left: 10),
      //   child: Text(AppLocalizations.of(context)!.settingsBackup, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w300),),
      // ),
      /// More Informations footer
      footer: GestureDetector(
        onTap: () async{
          HapticFeedback.selectionClick();
          cnSettings.controllerExplainBackups.animatePanelToPosition(
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

        /// Create manual backup
        const CreateBackup(),

        /// Share backup
        CupertinoListTile(
          // leadingSize: 28,
          // leading: const Icon(
          //   MyIcons.backup_share,
          //   color: Colors.white,
          // ),
          leading: Image.asset("lib/assets/pictures/share.png"),
          title: Text(AppLocalizations.of(context)!.settingsBackupSaveManualMethodShare, style: const TextStyle(color: Colors.white),),
          onTap: () async{
            await shareBackup(cnConfig: cnConfig);
          },
          trailing: trailingArrow,
        ),

        /// Load Backup External
        const LoadExternalBackup(),

        /// Load Backup Local
        CupertinoListTile(
          leading: const Icon(
            Icons.file_download,
            color: Colors.white,
          ),
          title: Text(AppLocalizations.of(context)!.settingsBackupLoadLocal, style: const TextStyle(color: Colors.white),),
          onTap: () {
            HapticFeedback.selectionClick();
            cnSettings.navigatorKey.currentState?.pushNamed('/localFilePicker');
          },
          trailing: trailingArrow,
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
                if(Platform.isAndroid){
                  HapticFeedback.selectionClick();
                }
                cnConfig.setAutomaticBackups(value);
                cnSettings.refresh();
              }
          ),
        ),

        // AnimatedContainer(
        //   height: cnConfig.showMoreSettingCloud? 5 : 0,
        //   color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
        //   duration: const Duration(milliseconds: 300),
        // ),


        /// Sync with Cloud
        const ConnectWithCloud()
        // getCloudOptionsColumn(
        //     cnConfig: cnConfig,
        //     context: context,
        //     refresh: cnSettings.refresh
        // )
      ],
    );
  }
}
