import 'package:fitness_app/screens/other_screens/screen_settings/functions/load_backup_from_file_picker.dart';
import 'package:fitness_app/util/backup_helper/delete_local_backup_file.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../../util/backup_helper/helper_functions/get_local_backup_files.dart';
import '../../../screen_settings.dart';
import '../functions/get_date_from_filename.dart';
import '../functions/get_file_size_text.dart';

class LocalBackupsListView extends StatelessWidget {

  const LocalBackupsListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    CnSettings cnSettings = context.read<CnSettings>();
    CnScreenStatistics cnScreenStatistics = context.read<CnScreenStatistics>();
    CnConfig cnConfig = context.read<CnConfig>();
    CnHomepage cnHomepage = context.read<CnHomepage>();

    Widget buildChild(List<FileSystemEntity> localFiles, int index){

      if(!File(localFiles[index].path).existsSync()){
        return const SizedBox();
      }

      int fileSize = File(localFiles[index].path).lengthSync();
      String filename = localFiles[index].path.split("/").last;
      bool automatic = filename.contains("Auto");
      DateTime date = getDateFromFileName(filename);
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: mySeparator(heightTop: 0, heightBottom: 0),
          ),
          CupertinoButton(
            sizeStyle: CupertinoButtonSize.small,
            padding: EdgeInsets.zero,
            onLongPress: () async{
              bool confirm = false;
              await showCupertinoModalPopup<void>(
                context: context,
                builder: (BuildContext context) => CupertinoActionSheet(
                  cancelButton: getActionSheetCancelButton(context),
                  title: Text("Backup löschen"),
                  message: Text("Möchtest du das Backup wirklich entgültig löschen?"),
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
                      child: Text(AppLocalizations.of(context)!.yes, style: cupButtonTextStyleOnlyFontSize),
                    ),
                  ],
                ),
              );

              if(confirm){
                final success = await deleteLocalBackupFile(file: localFiles[index]);
                if(success){
                  Future.delayed(const Duration(milliseconds: 100), (){
                    cnSettings.refreshLocalBackups();
                  });
                }
              }
            },
            onPressed: () async{
              File file = File(localFiles[index].path);

              await loadBackupFromFilePicker(
                  context: context,
                  setLoadingIndicator: cnSettings.setLoadingIndicator,
                  cnHomepage: cnHomepage,
                  cnConfig: cnConfig,
                  cnScreenStatistics: cnScreenStatistics,
                  file: file,
                  cnSettings: cnSettings
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 60,
              color: Colors.transparent,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Backup${automatic? " (${AppLocalizations.of(context)!.automatic})" : " (${AppLocalizations.of(context)!.manual})"}",
                        textScaler: const TextScaler.linear(1.1),
                        style: const TextStyle(color: CupertinoColors.white)
                      ),
                      const SizedBox(height: 4,),
                      getFileSizeText(fileSize)
                    ],
                  ),
                  const Spacer(),
                  Text(
                    date.toStringDateTime(),
                    style: const TextStyle(color: CupertinoColors.white),
                    textScaler: const TextScaler.linear(1.1),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        const Text("Zuletzt erstellte Backups"),
        const SizedBox(height: 30,),
        ValueListenableBuilder(
            valueListenable: cnSettings.reloadLocalBackups,
            builder: (_, state, __) {
              return FutureBuilder(
                  future: getLocalBackupFiles(delay: 0),
                  builder: (context, localFiles){

                    /// waiting for local files
                    if(!localFiles.hasData){
                      return Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Center(
                          child: RepaintBoundary(
                            child: CupertinoActivityIndicator(
                                radius: 20.0,
                                color: Colors.amber[800]
                            ),
                          ),
                        ),
                      );
                    }

                    /// No local files found
                    if(localFiles.data!.isEmpty) {
                      return Center(
                        child: Text(
                            AppLocalizations.of(context)!.settingsNoLocalBackups
                        ),
                      );
                    }

                    /// local files Column

                    return Column(
                      children: [
                        for(int index in List.generate(localFiles.data!.length, (i) => i))
                          buildChild(localFiles.data!, index)
                      ],
                    );
                }
              );
            }
        ),
      ],
    );
  }
}
