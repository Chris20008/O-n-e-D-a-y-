import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/util/config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'constants.dart';
import 'objectbox/ob_exercise.dart';
import 'objectbox/ob_workout.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:http/http.dart';
import 'package:path/path.dart';

Future loadBackup() async{
  FilePickerResult? result = await FilePicker.platform.pickFiles(
      initialDirectory: "/storage/emulated/0/Android/data/christian.range.fitnessapp.fitness_app/files"
  );

  if (result != null) {
    File file = File(result.files.single.path!);
    final contents = await file.readAsString();
    final allWorkoutsAsListString = contents.split(";");
    final allWorkouts = allWorkoutsAsListString.map((e) => jsonDecode(e));
    List<ObWorkout> allObWorkouts = [];
    List<ObExercise> allObExercises = [];
    for (Map w in allWorkouts){
      ObWorkout workout = ObWorkout.fromMap(w);
      final List<ObExercise> exs = List.from(w["exercises"].map((ex) => ObExercise.fromMap(ex)));
      workout.addExercises(exs);
      allObWorkouts.add(workout);
      allObExercises.addAll(exs);
    }
    objectbox.workoutBox.removeAll();
    objectbox.exerciseBox.removeAll();
    objectbox.workoutBox.putMany(allObWorkouts);
    objectbox.exerciseBox.putMany(allObExercises);
  } else {
    // User canceled the picker
  }
}

Future<File?> saveBackup({required bool withCloud, required CnConfig cnConfig}) async{
  Directory? appDocDir = await getDirectory();
  final path = appDocDir?.path;
  /// Seems like having ':' in the filename leads to issues, so we replace them
  final filename = "Auto_Backup_${DateTime.now()}.txt".replaceAll(":", "-");
  final fullPath = '$path/$filename';
  final file = File(fullPath);
  await file.writeAsString(getWorkoutsAsStringList().join("; "));

  if(Platform.isIOS && withCloud){
    await saveBackupiCloud(fullPath, filename);
  }
  else if(Platform.isAndroid && withCloud){
    Map<String, String>? headers = await cnConfig.getGoogleDriveAuthHeaders();
    if(headers != null){
      await saveBackUpGoogleDrive(headers, file);
    }
  }
  return file;
}

/// ############
/// iCloud load Backup
/// ############
Future saveBackupiCloud(String sourceFilePath, String filename)async{
  if(Platform.isIOS && dotenv.env["ICLOUD_CONTAINER_ID"] != null) {
    await ICloudStorage.upload(
      containerId: dotenv.env["ICLOUD_CONTAINER_ID"]!,
      filePath: sourceFilePath,

      /// !!! Having 'Documents' as the beginning of the path is MANDATORY in order
      /// to see the Folder in ICloud File Explorer. Do NOT remove !!!
      destinationRelativePath: 'Documents/backups/$filename',
      onProgress: (stream) {
        // final uploadProgressSub = stream.listen(
        //       (progress) => print('Upload File Progress: $progress'),
        //   onDone: () => print('Upload File Done'),
        //   onError: (err) => print('Upload File Error: $err'),
        //   cancelOnError: true,
        // );
      },
    );
  }
}
/// ############
/// GoogleDrive load Backup
/// ############
Future saveBackUpGoogleDrive(Map<String, String> authHeader, File backupFile) async {
  var client = GoogleAuthClient(authHeader);
  ga.DriveApi drive = ga.DriveApi(client);

  /// get folder id if folder exists, otherwise create folder and retrieve id from this instead
  String? folderId = await getGoogleDriveFolderId(drive)?? await createGoogleDriveFolder(drive);

  if(folderId != null){
    ga.File uploadFile = ga.File();
    uploadFile.name = basename(backupFile.path);
    uploadFile.parents = [folderId];

    var response = await drive.files.create(
        uploadFile,
        uploadMedia: ga.Media(backupFile.openRead(), backupFile.lengthSync())
    );

    return response;
  }
}

Future<GoogleSignInAccount?> getGoogleDriveAccount() async {
  GoogleSignInAccount? account;

  GoogleSignIn googleSignIn = GoogleSignIn(scopes: [ga.DriveApi.driveFileScope]);
  try {
    account = await googleSignIn.signIn();
  } catch (error) {
    // print("GOT ERROR e: $error");
  }
  return account;
}

Future<String?> getGoogleDriveFolderId(ga.DriveApi drive) async {
  final allFiles = await drive.files.list();
  for(ga.File f in allFiles.files?? []){
    if(f.name == folderNameGoogleDrive){
      return f.id;
    }
  }
  return null;
}

Future<String?> createGoogleDriveFolder(ga.DriveApi drive) async{
  var fileMetadata = ga.File();
  fileMetadata.name = folderNameGoogleDrive;
  fileMetadata.mimeType = 'application/vnd.google-apps.folder';

  try {
    var file = await drive.files.create(fileMetadata);
    return file.id;
  } catch (e) {
    // TODO: Handle error appropriately
    // print('Unable to create folder: $e');
    rethrow;
  }
}

class GoogleAuthClient extends BaseClient {
  final Map<String, String> _headers;

  final Client _client = Client();

  GoogleAuthClient(this._headers);

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}