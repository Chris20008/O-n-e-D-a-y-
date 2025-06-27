import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../../util/backup_helper/save_backup.dart';
import '../../../../../../util/backup_helper/save_current_data.dart';
import '../../../../../../util/config.dart';
import '../../../../../../util/constants.dart';
import '../../../screen_settings.dart';
import '../../../widgets/settings_icon.dart';

class CreateBackup extends StatelessWidget {
  const CreateBackup({super.key});

  @override
  Widget build(BuildContext context) {

    final CnConfig cnConfig = context.read<CnConfig>();
    final CnSettings cnSettings = context.read<CnSettings>();

    return CupertinoListTile(
      // leading: const Icon(
      //   Icons.upload,
      //   color: Colors.white,
      // ),
      leading: const SettingsIcon(iconPath: "create_backup.png"),
      title: Text(AppLocalizations.of(context)!.settingsBackupSaveManualMethodSave, style: const TextStyle(color: Colors.white),),
      onTap: () {
        HapticFeedback.selectionClick();
        cnSettings.setLoadingIndicator(true);
        Future.delayed(const Duration(milliseconds: 100), () async{
          File? result = await saveBackup(withCloud: cnConfig.connectWithCloud, cnConfig: cnConfig, automatic: false);
          await saveCurrentData(cnConfig);
          cnSettings.refreshLocalBackups();
          cnSettings.setLoadingIndicator(false);
          final currentContext = cnSettings.navigatorKey.currentContext?? context;
          if(!currentContext.mounted){
            return;
          }
          if(result != null){
            Fluttertoast.showToast(
                msg: "${AppLocalizations.of(currentContext)!.createdManualBackup} ✅️",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.grey[800]?.withValues(alpha: 0.9),
                textColor: Colors.white,
                fontSize: 16.0
            );
          }
          else{
            Fluttertoast.showToast(
                msg: "${AppLocalizations.of(currentContext)!.createdBackupFailed} ❌",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.grey[800]?.withValues(alpha: 0.9),
                textColor: Colors.white,
                fontSize: 16.0
            );
          }
        });
      },
      trailing: trailingArrow,
    );
  }
}
