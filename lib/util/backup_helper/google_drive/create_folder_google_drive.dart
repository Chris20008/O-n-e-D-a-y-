import 'package:googleapis/drive/v3.dart' as ga;

import '../../config.dart';
import '../backup_constants.dart';

Future<String?> createFolderGoogleDrive(ga.DriveApi drive, CnConfig cnConfig) async{
  var fileMetadata = ga.File();
  fileMetadata.name = folderNameGoogleDrive;
  fileMetadata.mimeType = 'application/vnd.google-apps.folder';

  try {
    var file = await drive.files.create(fileMetadata);
    cnConfig.folderIdGoogleDrive = file.id;
    return file.id;
  } catch (e) {
    rethrow;
  }
}