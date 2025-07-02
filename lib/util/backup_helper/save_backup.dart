import 'dart:async';
import 'dart:io';
import '../config.dart';
import 'google_drive/save_backup_google_drive.dart';
import 'helper_functions/get_local_path.dart';
import 'helper_functions/get_workout_as_string_list.dart';
import 'icloud/save_backup_icloud.dart';

const currentDataFileName = "Current_Data.txt";

Future<File?> saveBackup({
  required bool withCloud,
  required CnConfig cnConfig,
  String? content,
  bool currentDataCloud = false,
  bool automatic = true
}) async{
  try {
    final path = await getLocalPath();

    String praefix = automatic? "Auto" : "Manual";

    /// Seems like having ':' in the filename leads to issues, so we replace them
    final filename = currentDataCloud
        ? currentDataFileName
        : "${praefix}_Backup_${DateTime.now()}.txt".replaceAll(":", "-");
    final fullPath = '$path/$filename';
    final file = File(fullPath);
    content = content ?? getWorkoutsAsStringList().join("; ");
    await file.writeAsString(content);

    if (Platform.isIOS && withCloud) {
      await saveBackupiCloud(fullPath, filename);
    }
    else if (Platform.isAndroid && withCloud) {
      Map<String, String>? headers = await cnConfig.getGoogleDriveAuthHeaders();
      if (headers != null) {
        await saveBackUpGoogleDrive(
            authHeader: headers,
            file: file,
            cnConfig: cnConfig,
            overwrite: currentDataCloud
        );
      }
    }

    /// Delete local CurrentData File
    if (currentDataCloud) {
      await file.delete();
      return File("");
    }

    return file;
  }
  catch (e) {
    return null;
  }
}