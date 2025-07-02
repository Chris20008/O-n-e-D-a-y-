import 'dart:io';
import 'package:fitness_app/util/backup_helper/save_backup.dart';
import 'package:fitness_app/util/config.dart';
import 'package:share_plus/share_plus.dart';

Future<bool> shareBackup({required CnConfig cnConfig, Function? afterReceiveFile}) async{
  File? file = await saveBackup(
      withCloud: false,
      cnConfig: cnConfig,
      automatic: false
  );
  if(file == null){
    return false;
  }
  else{
    XFile xfile = XFile(file.path);
    await Share.shareXFiles([xfile]);
    Future.delayed(const Duration(seconds: 1), (){
      file.delete();
    });
  }
  return true;
}