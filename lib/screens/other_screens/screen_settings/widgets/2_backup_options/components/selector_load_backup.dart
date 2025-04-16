import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/screens/other_screens/local_file_picker.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/functions/load_backup_from_file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitness_app/util/backup_helper/backup_functions.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pull_down_button/pull_down_button.dart';

class SelectorLoadBackup extends StatelessWidget {

  final Function(bool value) setLoadingIndicator;
  final CnScreenStatistics cnScreenStatistics;
  final CnConfig cnConfig;
  final CnHomepage cnHomepage;

  const SelectorLoadBackup({
    super.key,
    required this.setLoadingIndicator,
    required this.cnScreenStatistics,
    required this.cnConfig,
    required this.cnHomepage,
  });

  @override
  Widget build(BuildContext context) {
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
                if(context.mounted){
                  loadBackupFromFilePicker(
                    context: context,
                    setLoadingIndicator: (bool value) {
                      setLoadingIndicator(value);
                    },
                    cnHomepage: cnHomepage,
                    cnConfig: cnConfig,
                    cnScreenStatistics: cnScreenStatistics,
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
}
