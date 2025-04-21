import 'package:fitness_app/screens/other_screens/screen_settings/functions/load_backup_from_file_picker.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/util/backup_helper/backup_functions.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'functions/get_date_from_file_name.dart';
import 'functions/get_file_size_text.dart';

class LocalBackupsListView extends StatelessWidget {
  final Function(bool value) setLoadingIndicator;
  final CnScreenStatistics cnScreenStatistics;
  final CnConfig cnConfig;
  final CnHomepage cnHomepage;

  const LocalBackupsListView({
    super.key,
    required this.setLoadingIndicator,
    required this.cnScreenStatistics,
    required this.cnConfig,
    required this.cnHomepage,
  });

  @override
  Widget build(BuildContext context) {

    return Expanded(
      child: FutureBuilder(
          future: getLocalBackupFiles(delay: 600),
          builder: (context, localFiles){

            /// waiting for local files
            if(!localFiles.hasData){
              return Center(
                child: RepaintBoundary(
                  child: CupertinoActivityIndicator(
                      radius: 20.0,
                      color: Colors.amber[800]
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

            /// local files list view
            return ListView.separated(
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index){
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: mySeparator(heightTop: 0, heightBottom: 0),
                  );
                },
                itemCount: localFiles.data!.length,
                itemBuilder: (context, index){
                  int fileSize = File(localFiles.data![index].path).lengthSync();
                  String filename = localFiles.data![index].path.split("/").last;
                  bool automatic = filename.contains("Auto");
                  DateTime date = getDateFromFileName(filename);
                  return GestureDetector(
                    onTap: ()async{
                      BuildContext currentContext = context;
                      File file = File(localFiles.data![index].path);

                      bool result = await loadBackupFromFilePicker(
                          context: context,
                          setLoadingIndicator: (bool value) {
                            setLoadingIndicator(value);
                          },
                          cnHomepage: cnHomepage,
                          cnConfig: cnConfig,
                          cnScreenStatistics: cnScreenStatistics,
                          file: file
                      );

                      /// When result true close local backup screen
                      if (result && currentContext.mounted){
                        Navigator.of(currentContext).pop();
                      }
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
                              Text("Backup${automatic? " (${AppLocalizations.of(context)!.automatic})" : " (${AppLocalizations.of(context)!.manual})"}", textScaler: const TextScaler.linear(1.1),),
                              getFileSizeText(fileSize)
                            ],
                          ),
                          const Spacer(),
                          Text(
                            date.toStringDateTime(),
                            textScaler: const TextScaler.linear(1.1),
                          ),
                        ],
                      ),
                    ),
                  );
                }
            );
        }
      ),
    );
  }
}
