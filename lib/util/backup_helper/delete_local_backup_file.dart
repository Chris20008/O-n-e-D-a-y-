import 'dart:io';

import '../constants.dart';

Future<bool> deleteLocalBackupFile({required FileSystemEntity file}) async{
  try{
    await file.delete();
    return true;
  } catch (e){
    pr("File could not be deleted: ${file.toString}");
    pr(e);
    return false;
  }
}