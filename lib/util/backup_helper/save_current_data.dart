import 'dart:io';
import 'package:fitness_app/util/backup_helper/save_backup.dart';
import '../config.dart';

Future<File?> saveCurrentData(CnConfig cnConfig) async{
  try{
    if(cnConfig.connectWithCloud) {
      return await saveBackup(
          withCloud: true,
          cnConfig: cnConfig,
          currentDataCloud: true
      );
    }
    return null;
  } catch(_){
    return null;
  }
}