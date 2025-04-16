import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:fitness_app/util/backup_helper/backup_functions.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_down_button/pull_down_button.dart';

class SelectorCreateBackup extends StatelessWidget {

  final Function(bool value) setLoadingIndicator;
  final CnConfig cnConfig;

  const SelectorCreateBackup({
    super.key,
    required this.setLoadingIndicator,
    required this.cnConfig,
  });

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
      routeTheme: routeTheme,
      itemBuilder: (context) {
        return [
          PullDownMenuItem(
            title: AppLocalizations.of(context)!.settingsBackupSaveManualMethodSave,
            onTap: () {
              HapticFeedback.selectionClick();
              setLoadingIndicator(true);
              Future.delayed(const Duration(milliseconds: 300), () async{
                File? result = await saveBackup(withCloud: cnConfig.saveBackupCloud, cnConfig: cnConfig, automatic: false);
                await saveCurrentData(cnConfig);
                setLoadingIndicator(false);
                if(result != null){
                  Fluttertoast.showToast(
                      msg: "${AppLocalizations.of(context)!.createdManualBackup} ✅️",
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
                      msg: "${AppLocalizations.of(context)!.createdBackupFailed} ❌",
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
}