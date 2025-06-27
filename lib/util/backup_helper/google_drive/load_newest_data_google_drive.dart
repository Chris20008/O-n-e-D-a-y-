import 'dart:convert';

import 'package:googleapis/drive/v3.dart' as ga;

import '../../../main.dart';
import '../../config.dart';
import '../backup_constants.dart';
import '../load_backup/load_backup_from_string.dart';
import 'get_google_drive_folder_id.dart';
import 'google_auth_clint.dart';

Future<bool> loadNewestDataGoogleDrive(CnConfig cnConfig, {CnHomepage? cnHomepage}) async{
  try {
    Map<String, String>? headers = await cnConfig.getGoogleDriveAuthHeaders();

    if (headers == null) {
      cnHomepage?.msg = "Sync failed\nUser not signed in";
      cnHomepage?.finishSync(p:null);
      return false;
    }

    var client = GoogleAuthClient(headers);
    ga.DriveApi drive = ga.DriveApi(client);

    /// get folder id if folder exists, otherwise create folder and retrieve id from this instead
    String? folderId = await getGoogleDriveFolderId(drive, cnConfig);

    if (folderId == null) {
      cnHomepage?.msg = "No Data to Sync";
      cnHomepage?.finishSync(p:null);
      return false;
    }

    ga.FileList allFiles = await drive.files.list(
        orderBy: "modifiedTime desc",
        q: "'$folderId' in parents and trashed=false and name = '$currentDataFileName'",
        pageSize: 1
    );

    /// CurrentData file does not exist
    if (allFiles.files == null || allFiles.files!.isEmpty) {
      cnHomepage?.msg = "No Data to Sync";
      cnHomepage?.finishSync(p:null);
      return false;
    }

    /// Get Data from Google Drive file as Stream
    var response = await drive.files.get(allFiles.files!.first.id!,
        downloadOptions: ga.DownloadOptions.fullMedia);
    if (response is! ga.Media) throw Exception("invalid response");

    /// Decode this Stream to receive it as a String
    var content = await utf8.decodeStream(response.stream);

    if(content.isEmpty){
      cnHomepage?.msg = "No Data to Sync";
      cnHomepage?.finishSync(p:null);
      return false;
    }

    final loadedNewData = await loadBackupFromString(
        content: content, cnHomepage: cnHomepage);
    if (loadedNewData) {
      return true;
    }
    return false;
  }
  catch (_) {
    cnHomepage?.msg = "Sync failed\nAn Error occurred";
    cnHomepage?.finishSync(p:null);
    return false;
  }
}