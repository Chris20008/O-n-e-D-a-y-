import 'dart:async';
import 'dart:io';
import 'package:fitness_app/util/backup_helper/google_drive/create_folder_google_drive.dart';
import 'package:fitness_app/util/config.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:path/path.dart';

import 'get_current_data_id_google_drive.dart';
import 'get_google_drive_folder_id.dart';
import 'google_auth_clint.dart';


Future<ga.File?> saveBackUpGoogleDrive({
  required Map<String, String> authHeader,
  required File file,
  required CnConfig cnConfig,
  bool overwrite = false
}) async {
  var client = GoogleAuthClient(authHeader);
  ga.DriveApi drive = ga.DriveApi(client);

  /// get folder id if folder exists, otherwise create folder and retrieve id from this instead
  String? folderId = await getGoogleDriveFolderId(drive, cnConfig)?? await createFolderGoogleDrive(drive, cnConfig);

  if(folderId != null){
    ga.File uploadFile = ga.File();

    ga.File? response;

    /// Overwrite existing file - used for currentData
    if(overwrite){
      final currentDataId = await getCurrentDataId(drive: drive, cnConfig: cnConfig, folderId: folderId);
      if(currentDataId != null){
        response = await drive.files.update(
            uploadFile,
            currentDataId,
            uploadMedia: ga.Media(file.openRead(), file.lengthSync())
        );
      } else{
        overwrite = false;
      }
    }

    /// Create new File - used for creating Backups
    if(!overwrite){
      uploadFile.name = basename(file.path);
      uploadFile.parents = [folderId];
      response = await drive.files.create(
          uploadFile,
          uploadMedia: ga.Media(file.openRead(), file.lengthSync())
      );
    }

    return response;
  }
  return null;
}