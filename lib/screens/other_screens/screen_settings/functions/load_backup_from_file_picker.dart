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

Future<bool> loadBackupFromFilePicker({
  required BuildContext context,
  required Function(bool value) setLoadingIndicator,
  required CnHomepage cnHomepage,
  required CnConfig cnConfig,
  required CnScreenStatistics cnScreenStatistics,
  required File file
}) async{
  bool success = false;
  bool confirm = false;
  BuildContext previousContext = context;

  await showCupertinoModalPopup<void>(
    context: previousContext,
    builder: (BuildContext context) => CupertinoActionSheet(
      cancelButton: getActionSheetCancelButton(context),
      title: Text(AppLocalizations.of(previousContext)!.settingsBackupLoad),
      message: Text(AppLocalizations.of(previousContext)!.settingsBackupLoadTextToConfirm),
      actions: <Widget>[
        CupertinoActionSheetAction(
          /// This parameter indicates the action would perform
          /// a destructive action such as delete or exit and turns
          /// the action's text color to red.
          isDestructiveAction: true,
          onPressed: ()async{
            Navigator.of(context).pop();
            confirm = true;
          },
          child: Text(AppLocalizations.of(previousContext)!.yes, style: cupButtonTextStyleOnlyFontSize),
        ),
      ],
    ),
  );

  if(confirm){
    setLoadingIndicator(true);
    try{
      await loadBackupFromFile(file, cnHomepage: cnHomepage);
      await saveCurrentData(cnConfig);
      tutorialIsRunning = false;
      currentTutorialStep = maxTutorialStep;
      await cnConfig.setCurrentTutorialStep(currentTutorialStep);
      if(!previousContext.mounted){
        throw Exception("Context not mounted");
      }
      cnScreenStatistics.refreshData(context);
      cnScreenStatistics.resetGraph();
      cnScreenStatistics.refresh();
      await cnConfig.config.save();
      if(!previousContext.mounted){
        throw Exception("Context not mounted");
      }
      await Fluttertoast.showToast(
          msg: AppLocalizations.of(previousContext)!.backupLoadSuccess,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[800]?.withValues(alpha: 0.9),
          textColor: Colors.white,
          fontSize: 16.0
      );
      setLoadingIndicator(false);
      success = true;
    }
    catch (_){
      setLoadingIndicator(false);
      if(previousContext.mounted){
        await Fluttertoast.showToast(
            msg: AppLocalizations.of(previousContext)!.backupLoadNotSuccess,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[800]?.withValues(alpha: 0.9),
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }
  }
  return success;
}