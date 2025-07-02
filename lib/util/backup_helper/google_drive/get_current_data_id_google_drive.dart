import 'package:googleapis/drive/v3.dart' as ga;

import '../../config.dart';
import '../backup_constants.dart';

Future<String?> getCurrentDataId({
  required ga.DriveApi drive,
  required CnConfig cnConfig,
  required String folderId
}) async {
  if(cnConfig.currentDataIdGoogleDrive != null){
    return cnConfig.currentDataIdGoogleDrive;
  }

  final receivedFile = await drive.files.list(q: "'$folderId' in parents and name = '$currentDataFileName' and trashed=false", pageSize: 1);
  if(receivedFile.files?.isNotEmpty?? false){
    final file = receivedFile.files?.first;
    cnConfig.currentDataIdGoogleDrive = file?.id;
    return file?.id;
  }
  return null;
}