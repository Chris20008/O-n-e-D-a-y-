import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/util/backup_functions.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/widgets/standard_popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class LocalFilePicker extends StatefulWidget {
  final List<FileSystemEntity> localFiles;
  const LocalFilePicker({
    super.key,
    required this.localFiles
  });

  @override
  State<LocalFilePicker> createState() => _LocalFilePickerState();
}

class _LocalFilePickerState extends State<LocalFilePicker> {
  late CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);
  late CnScreenStatistics cnScreenStatistics = Provider.of<CnScreenStatistics>(context, listen: false);
  late CnConfig cnConfig = Provider.of<CnConfig>(context, listen: false);
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context);
  bool _isLoadingBackup = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        body: PopScope(
          canPop: !_isLoadingBackup,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(AppLocalizations.of(context)!.localBackups, textScaler: const TextScaler.linear(1.3),),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          separatorBuilder: (context, index){
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: mySeparator(heightTop: 0, heightBottom: 0),
                            );
                          },
                          itemCount: widget.localFiles.length,
                          itemBuilder: (context, index){
                            int fileSize = File(widget.localFiles[index].path).lengthSync();
                            String filename = widget.localFiles[index].path.split("/").last;
                            bool automatic = filename.contains("Auto");
                            DateTime date = getDateFromFileName(filename);
                            return GestureDetector(
                              onTap: (){
                                cnStandardPopUp.open(
                                  confirmText: AppLocalizations.of(context)!.yes,
                                  cancelText: AppLocalizations.of(context)!.no,
                                  widthFactor: 0.8,
                                    context: context,
                                    child: Column(
                                      children: [
                                        Text(AppLocalizations.of(context)!.settingsBackupLoad, style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 18),),
                                        const SizedBox(height: 5),
                                        Text(AppLocalizations.of(context)!.settingsBackupLoadTextToConfirm, textAlign: TextAlign.center, textScaler: const TextScaler.linear(0.9),)
                                      ],
                                    ),
                                    onConfirm: ()async{
                                      setState(() {
                                        _isLoadingBackup = true;
                                      });
                                      try{
                                        File file = File(widget.localFiles[index].path);
                                        await loadBackupFromFile(file, cnHomepage: cnHomepage);
                                        saveCurrentData(cnConfig);
                                        tutorialIsRunning = false;
                                        currentTutorialStep = 100;
                                        cnConfig.setCurrentTutorialStep(currentTutorialStep);
                                        cnScreenStatistics.refreshData();
                                        cnScreenStatistics.resetGraph();
                                        cnScreenStatistics.refresh();
                                        Navigator.of(context).pop();
                                        Fluttertoast.showToast(
                                            msg: AppLocalizations.of(context)!.backupLoadSuccess,
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.grey[800],
                                            textColor: Colors.white,
                                            fontSize: 16.0
                                        );
                                      }
                                      catch (_){
                                        setState(() {
                                          _isLoadingBackup = false;
                                        });
                                        Fluttertoast.showToast(
                                            msg: AppLocalizations.of(context)!.backupLoadNotSuccess,
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.grey[800],
                                            textColor: Colors.white,
                                            fontSize: 16.0
                                        );
                                      }

                                    }
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
                                        Text("Backup${automatic? " (${AppLocalizations.of(context)!.automatic})" : " (${AppLocalizations.of(context)!.manual})"}", textScaler: const TextScaler.linear(1.1),),
                                        getFileSizeText(fileSize)
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                        "${date.day.toString().length == 1? "0${date.day}" : date.day}."
                                        "${date.month.toString().length == 1? "0${date.month}" : date.month}."
                                        "${date.year}  "
                                        "${date.hour.toString().length == 1? "0${date.hour}" : date.hour}:"
                                        "${date.minute.toString().length == 1? "0${date.minute}" : date.minute}",
                                      textScaler: const TextScaler.linear(1.1),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                    SizedBox(height: 20,)
                  ],
                ),
              ),
              const StandardPopUp(),
              if (_isLoadingBackup)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CupertinoActivityIndicator(
                        radius: 20.0,
                        color: Colors.amber[800]
                    ),
                  ),
                ),
              if(cnHomepage.isSyncingWithCloud)
                IgnorePointer(
                  child: SafeArea(
                    child: Column(
                      children: [
                        SizedBox(height: 45),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.black.withOpacity(0.4)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 5),
                              Text(cnHomepage.msg, style: const TextStyle(color: CupertinoColors.white)),
                              const SizedBox(width: 5),
                              if(cnHomepage.percent != null)
                                Text("${(cnHomepage.percent! * 100).round()}%", style: const TextStyle(color: CupertinoColors.white)),
                              if(cnHomepage.percent != null)
                                const SizedBox(width: 5),
                              if(!cnHomepage.syncWithCloudCompleted)
                                SizedBox(
                                  height: 15,
                                  width: 15,
                                  child: Center(
                                    child: CupertinoActivityIndicator(
                                        radius: 8.0,
                                        color: Colors.amber[800]
                                    ),
                                  ),
                                  // child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1,))
                                )
                              else
                                const Icon(
                                    Icons.check_circle,
                                    size: 15,
                                    color: Colors.green
                                ),
                              const SizedBox(width: 5)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        )
    );
  }

  Widget getFileSizeText(int fileSize){
    int factor = 1000;
    String unit = "kB";
    if((fileSize / 1000000) >= 1){
      factor = 1000000;
      unit = "MB";
    }
    return Text(
      "${(fileSize / factor).toStringAsFixed(2)} $unit",
      style: TextStyle(
        fontSize: 12,
        color: Colors.white.withOpacity(0.6)
      ),
    );
  }

  DateTime getDateFromFileName(String filename){
    filename = filename.split("_").last;
    String dateAsString = filename.split(".").first;
    List<String> dateAndTime = dateAsString.split(" ");
    String date = dateAndTime.first;
    String time = dateAndTime.last.replaceAll("-", ":");

    return DateTime.parse("$date $time");
  }
}
