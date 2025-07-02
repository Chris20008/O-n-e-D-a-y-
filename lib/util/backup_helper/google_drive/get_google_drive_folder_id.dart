import 'package:googleapis/drive/v3.dart' as ga;

import '../../config.dart';
import '../backup_constants.dart';

Future<String?> getGoogleDriveFolderId(ga.DriveApi drive, CnConfig cnConfig) async {
  if(cnConfig.folderIdGoogleDrive != null){
    return cnConfig.folderIdGoogleDrive;
  }

  final allFiles = await drive.files.list(q: "trashed=false and name = '$folderNameGoogleDrive'");
  for(ga.File f in allFiles.files?? []){
    if(f.name == folderNameGoogleDrive){
      cnConfig.folderIdGoogleDrive = f.id;
      return f.id;
    }
  }
  return null;
}