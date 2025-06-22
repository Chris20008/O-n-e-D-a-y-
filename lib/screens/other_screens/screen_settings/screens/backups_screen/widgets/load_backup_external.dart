import 'dart:io';

import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../../util/backup_helper/backup_functions.dart';
import '../../../../../../util/config.dart';
import '../../../../../../util/constants.dart';
import '../../../functions/load_backup_from_file_picker.dart';
import '../../../screen_settings.dart';

class LoadExternalBackup extends StatelessWidget {
  const LoadExternalBackup({super.key});

  @override
  Widget build(BuildContext context) {

    final CnConfig cnConfig = context.read<CnConfig>();
    final CnHomepage cnHomepage = context.read<CnHomepage>();
    final CnScreenStatistics cnScreenStatistics = context.read<CnScreenStatistics>();
    final CnSettings cnSettings = context.read<CnSettings>();

    return CupertinoListTile(
      leading: const Icon(
        Icons.cloud_download,
        color: Colors.white,
      ),
      title: Text(AppLocalizations.of(context)!.settingsBackupLoadExternal, style: const TextStyle(color: Colors.white),),
      onTap: () {
        HapticFeedback.selectionClick();
        Future.delayed(const Duration(milliseconds: 200), () async {
          if(context.mounted){
            cnSettings.setLoadingIndicator(true);
            File? file = await getBackupFromFilePicker(cnHomepage: cnHomepage);
            cnSettings.setLoadingIndicator(false);

            if(!context.mounted || file == null){
              return;
            }

            await loadBackupFromFilePicker(
                context: context,
                setLoadingIndicator: (bool value) {
                  cnSettings.setLoadingIndicator(value);
                },
                cnHomepage: cnHomepage,
                cnConfig: cnConfig,
                cnScreenStatistics: cnScreenStatistics,
                file: file,
                cnSettings: cnSettings
            );
          }
        });
      },
      trailing: trailingArrow,
    );
  }
}
