import 'dart:io';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/util/backup_helper/backup_functions.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future loadBackupFromFilePicker({
  required BuildContext context,
  required Function(bool value) setLoadingIndicator,
  required CnHomepage cnHomepage,
  required CnConfig cnConfig,
  required CnScreenStatistics cnScreenStatistics,
}) async{
  setLoadingIndicator(true);
  File? file = await getBackupFromFilePicker(cnHomepage: cnHomepage);
  setLoadingIndicator(false);

  if(!context.mounted){
    return;
  }

  if(file != null){
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        cancelButton: getActionSheetCancelButton(context),
        title: Text(AppLocalizations.of(context)!.settingsBackupLoad),
        message: Text(AppLocalizations.of(context)!.settingsBackupLoadTextToConfirm),
        actions: <Widget>[
          CupertinoActionSheetAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as delete or exit and turns
            /// the action's text color to red.
            isDestructiveAction: true,
            onPressed: ()async{

              Navigator.of(context).pop();
              setLoadingIndicator(true);
              try{
                await loadBackupFromFile(file, cnHomepage: cnHomepage);
                saveCurrentData(cnConfig);
                tutorialIsRunning = false;
                currentTutorialStep = maxTutorialStep;
                cnConfig.setCurrentTutorialStep(currentTutorialStep);
                if(!context.mounted){
                  throw Exception("Context not mounted");
                }
                cnScreenStatistics.refreshData(context);
                cnScreenStatistics.resetGraph();
                cnScreenStatistics.refresh();
                await cnConfig.config.save();
                if(!context.mounted){
                  throw Exception("Context not mounted");
                }
                Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)!.backupLoadSuccess,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.grey[800]?.withValues(alpha: 0.9),
                    textColor: Colors.white,
                    fontSize: 16.0
                );
                setLoadingIndicator(false);
              }
              catch (_){
                setLoadingIndicator(false);
                Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)!.backupLoadNotSuccess,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.grey[800]?.withValues(alpha: 0.9),
                    textColor: Colors.white,
                    fontSize: 16.0
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.yes),
          ),
        ],
      ),
    );
  }
}