import 'dart:io';

import '../../../main.dart';
import '../../ios_channel.dart';
import '../backup_constants.dart';
import '../load_backup/load_backup_from_string.dart';

Future<bool> loadNewestDataiCloud({CnHomepage? cnHomepage})async{
  try{
    bool success;
    if(Platform.isIOS) {
      String? result = await ICloudService.readFromICloud(currentDataFileName);
      if(result == null || result.isEmpty){
        cnHomepage?.msg = "No Data to Sync";
        cnHomepage?.finishSync(p:null);
        return false;
      }
      success = await loadBackupFromString(content: result, cnHomepage: cnHomepage);
    }
    else{
      cnHomepage?.msg = "No Data to Sync";
      cnHomepage?.finishSync(p:null);
      return false;
    }
    return success;
  }
  catch (_) {
    cnHomepage?.msg = "Sync failed\nAn Error occurred";
    cnHomepage?.finishSync(p:null);
    return false;
  }
}