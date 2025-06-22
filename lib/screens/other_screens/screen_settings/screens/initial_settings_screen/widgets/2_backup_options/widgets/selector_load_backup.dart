import 'dart:io';

import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/functions/load_backup_from_file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitness_app/util/backup_helper/backup_functions.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../../../../screen_settings.dart';

class SelectorLoadBackup extends StatelessWidget {

  const SelectorLoadBackup({super.key});

  @override
  Widget build(BuildContext context) {

    final CnSettings cnSettings = context.read<CnSettings>();
    final CnScreenStatistics cnScreenStatistics = context.read<CnScreenStatistics>();
    final CnConfig cnConfig = context.read<CnConfig>();
    final CnHomepage cnHomepage = context.read<CnHomepage>();

    return PullDownButton(
      onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
      routeTheme: routeTheme,
      itemBuilder: (context) {
        return [
          PullDownMenuItem(
            title: AppLocalizations.of(context)!.settingsBackupLoadExternal,
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
          ),
          PullDownMenuItem(
            title: AppLocalizations.of(context)!.settingsBackupLoadLocal,
            onTap: () {
              HapticFeedback.selectionClick();
              Future.delayed(const Duration(milliseconds: 200), () async{
                cnSettings.navigatorKey.currentState?.pushNamed('/localFilePicker');
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
}
