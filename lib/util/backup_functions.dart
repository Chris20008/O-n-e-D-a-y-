import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/objects/workout.dart';
import 'package:fitness_app/util/config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'ios_channel.dart';
import 'objectbox/ob_exercise.dart';
import 'objectbox/ob_workout.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:http/http.dart';
import 'package:path/path.dart';

const folderNameGoogleDrive = "OneDay Backups";
const currentDataFileName = "Current_Data.txt";
/// !!! Having 'Documents' as the beginning of the path is MANDATORY in order
/// to see the Folder in ICloud File Explorer. Do NOT remove !!!
const folderPathiCloud = "Documents/backups/";

Future<String> getLocalPath() async{
  // if(Platform.isAndroid){
  // return await getExternalStorageDirectory();
  // return await getApplicationDocumentsDirectory();
  // }
  // else{
  //   return await getApplicationDocumentsDirectory();
  // }
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future loadBackupFromFilePicker({CnHomepage? cnHomepage}) async{
  FilePickerResult? result = await FilePicker.platform.pickFiles(
      initialDirectory: "/storage/emulated/0/Android/data/christian.range.fitnessapp.fitness_app/files"
  );

  if (result != null) {
    print("result file Path: ${result.files.single.path!}");
    File file = File(result.files.single.path!);
    await loadBackupFromFile(file, cnHomepage: cnHomepage);
  } else {
    // User canceled the picker
  }

}

Future<bool> loadBackupFromFile(File file, {CnHomepage? cnHomepage}) async{
  final content = await file.readAsString();
  return await loadBackupFromString(content: content, cnHomepage: cnHomepage);
  // final allWorkoutsAsListString = contents.split(";");
  // final allWorkouts = allWorkoutsAsListString.map((e) => jsonDecode(e));
  // List<ObWorkout> allObWorkouts = [];
  // List<ObExercise> allObExercises = [];
  // for (Map w in allWorkouts){
  //   ObWorkout workout = ObWorkout.fromMap(workoutMap: w, withId: true);
  //   final List<ObExercise> exs = List.from(w["exercises"].map((ex) => ObExercise.fromMap(ex)));
  //   workout.addExercises(exs);
  //   allObWorkouts.add(workout);
  //   allObExercises.addAll(exs);
  // }
  // final hadDifferences = await loadDifferences(allObWorkouts, cnHomepage: cnHomepage);
  // return hadDifferences;
}

Future<bool> loadBackupFromString({required String content, CnHomepage? cnHomepage}) async{
  final allWorkoutsAsListString = content.split(";");
  final allWorkouts = allWorkoutsAsListString.map((e) => jsonDecode(e));
  List<ObWorkout> allObWorkouts = [];
  List<ObExercise> allObExercises = [];
  for (Map w in allWorkouts){
    ObWorkout workout = ObWorkout.fromMap(workoutMap: w, withId: true);
    final List<ObExercise> exs = List.from(w["exercises"].map((ex) => ObExercise.fromMap(ex)));
    workout.addExercises(exs);
    allObWorkouts.add(workout);
    allObExercises.addAll(exs);
  }
  final hadDifferences = await loadDifferences(allObWorkouts, cnHomepage: cnHomepage);
  return hadDifferences;
}

Future<bool> loadDifferences(List<ObWorkout> workouts, {CnHomepage? cnHomepage}) async{
  if(cnHomepage != null && cnHomepage.msg.isEmpty){
    cnHomepage.msg = "Load Backup";
  }
  int batchSize = 10;
  int counter = 0;
  bool hadDifferences = false;
  List<ObWorkout> allCurrentWorkouts = await objectbox.workoutBox.getAllAsync();
  // final length = allCurrentWorkouts.length + workouts.length;
  final length = workouts.length;
  print("LENGTH: $length");

  for(ObWorkout wo in workouts){
    // print("");
    // print("Workout");
    // print("CHECKING OBWOKROUT ID: ${wo.id}");
    // final existingWorkout = allCurrentWorkouts.firstWhereOrNull((workout) => Workout.fromObWorkout(wo).equals(Workout.fromObWorkout(workout)));
    ObWorkout? existingWorkout = allCurrentWorkouts.firstWhereOrNull((workout) => workout.id == wo.id);

    /// We have to first check if an matching id exists and if the workout correlated to this id has differences the workout with id from cloud
    /// If so we update the existing workout
    if(existingWorkout != null && !Workout.fromObWorkout(wo).equals(Workout.fromObWorkout(existingWorkout))){
      print("UPDATE WORKOUT");
      allCurrentWorkouts.remove(existingWorkout);
      existingWorkout = wo;
      objectbox.workoutBox.put(wo);
      objectbox.exerciseBox.putMany(wo.exercises);
      hadDifferences = true;
      // continue;
    }
    else{
      /// If not it means the id does not exists, but maybe the workout itself exists because objectbox entries
      /// on different devices can have different id's
      /// So we check just for equal
      existingWorkout = allCurrentWorkouts.firstWhereOrNull((workout) => Workout.fromObWorkout(wo).equals(Workout.fromObWorkout(workout)));

      /// However, if there is no existing workout that equals the new workout, even when ignoring the ID
      /// It means this is a completely new workout
      if(existingWorkout == null){
        print("NEW WORKOUT");
        hadDifferences = true;
        wo.id = 0;
        objectbox.workoutBox.putAsync(wo);
        objectbox.exerciseBox.putManyAsync(wo.exercises);
      } else{
        allCurrentWorkouts.remove(existingWorkout);
        print("FOUND EXISTING WORKOUT");
      }
    }


    // if(existingWorkout != null){
    //   allCurrentWorkouts.remove(existingWorkout);
    //   print("FOUND EXISTING WORKOUT");
    // }
    counter += 1;
    if(counter % batchSize == 0){
      await Future.delayed(const Duration(milliseconds: 20));
    }

    if(cnHomepage != null && counter % (batchSize*2) == 0){
      final p = counter / length;
      // print("PERCENT: $p");
      cnHomepage.updateSyncStatus(p);
    }
  }

  if(allCurrentWorkouts.isNotEmpty){
    hadDifferences = true;
  }

  print("Workouts found to remove: ${allCurrentWorkouts.length}");
  if(cnHomepage != null){
    final p = counter / length;
    // print("PERCENT: $p");
    cnHomepage.updateSyncStatus(p);
  }

  await objectbox.exerciseBox.removeManyAsync(allCurrentWorkouts.map((w) => w.exercises).expand((element) => element).map((e) => e.id).toList());
  await objectbox.workoutBox.removeManyAsync(allCurrentWorkouts.map((w) => w.id).toList());
  if(cnHomepage != null){
    cnHomepage.finishSync();
  }
  return hadDifferences;
}

Future<File?> saveBackup({
  required bool withCloud,
  required CnConfig cnConfig,
  String? content,
  bool currentDataCloud = false
}) async{
  // Directory? appDocDir = await getLocalPath();
  // final path = appDocDir?.path;
  final path = await getLocalPath();

  /// Seems like having ':' in the filename leads to issues, so we replace them
  final filename = currentDataCloud? currentDataFileName : "Auto_Backup_${DateTime.now()}.txt".replaceAll(":", "-");
  final fullPath = '$path/$filename';
  final file = File(fullPath);
  content = content?? getWorkoutsAsStringList().join("; ");
  await file.writeAsString(content);

  if(Platform.isIOS && withCloud){
    await saveBackupiCloud(fullPath, filename);
  }
  else if(Platform.isAndroid && withCloud){
    Map<String, String>? headers = await cnConfig.getGoogleDriveAuthHeaders();
    if(headers != null){
      await saveBackUpGoogleDrive(
          authHeader: headers,
          file: file,
          cnConfig: cnConfig,
          overwrite: currentDataCloud
      );
    }
  }

  /// Delete local CurrentData File
  if(currentDataCloud){
    await file.delete();
    return null;
  }

  cnConfig.setLastBackupName(filename);
  return file;
}

Future<File?> saveCurrentData(CnConfig cnConfig) async{
  if(cnConfig.syncMultipleDevices) {
    return await saveBackup(
        withCloud: true,
        cnConfig: cnConfig,
        currentDataCloud: true
    );
  }
  return null;
}

List getWorkoutsAsStringList(){
  final allObWorkouts = objectbox.workoutBox.getAll();
  final allWorkouts = List<String>.from(allObWorkouts.map((e) => jsonEncode(e.asMap())));
  return allWorkouts;
}

/// ################################################################################################
/// iCloud load Backup
/// ################################################################################################
Future saveBackupiCloud(String sourceFilePath, String filename)async{
  if(Platform.isIOS && dotenv.env["ICLOUD_CONTAINER_ID"] != null) {
    await ICloudStorage.upload(
      containerId: dotenv.env["ICLOUD_CONTAINER_ID"]!,
      filePath: sourceFilePath,
      destinationRelativePath: '$folderPathiCloud$filename',
      // onProgress: (stream) {
      //   final uploadProgressSub = stream.listen(
      //         (progress) => print('Upload File Progress: $progress'),
      //     onDone: () => print('Upload File Done'),
      //     onError: (err) => print('Upload File Error: $err'),
      //     cancelOnError: true,
      //   );
      // },
    );
  }
}

Future<bool> loadNewestDataiCloud({CnHomepage? cnHomepage})async{
  bool success;
  if(Platform.isIOS) {
    String? result = await ICloudService.readFromICloud(currentDataFileName);
    print("RESULT: $result");
    if(result == null){
      return false;
    }
    success = await loadBackupFromString(content: result, cnHomepage: cnHomepage);
  } else{
    success = false;
  }
  return success;
}


/// ################################################################################################
/// GoogleDrive load Backup
/// ################################################################################################
Future<ga.File?> saveBackUpGoogleDrive({
  required Map<String, String> authHeader,
  required File file,
  required CnConfig cnConfig,
  bool overwrite = false
}) async {
  var client = GoogleAuthClient(authHeader);
  ga.DriveApi drive = ga.DriveApi(client);

  /// get folder id if folder exists, otherwise create folder and retrieve id from this instead
  String? folderId = await getGoogleDriveFolderId(drive, cnConfig)?? await createGoogleDriveFolder(drive, cnConfig);

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
      print("create new file");
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

Future<bool> loadNewestDataGoogleDrive(CnConfig cnConfig, {CnHomepage? cnHomepage}) async{
  Map<String, String>? headers = await cnConfig.getGoogleDriveAuthHeaders();

  if(headers == null) {
    return false;
  }

  var client = GoogleAuthClient(headers);
  ga.DriveApi drive = ga.DriveApi(client);

  /// get folder id if folder exists, otherwise create folder and retrieve id from this instead
  String? folderId = await getGoogleDriveFolderId(drive, cnConfig);

  if(folderId == null){
    return false;
  }

  ga.FileList allFiles = await drive.files.list(orderBy: "modifiedTime desc", q: "'$folderId' in parents and trashed=false and name = '$currentDataFileName'", pageSize: 1);

  /// CurrentData file does not exist
  if(allFiles.files == null || allFiles.files!.isEmpty){
    return false;
  }

  /// Get Data from Google Drive file as Stream
  var response = await drive.files.get(allFiles.files!.first.id!, downloadOptions: ga.DownloadOptions.fullMedia);
  if (response is! ga.Media) throw Exception("invalid response");
  /// Decode this Stream to receive it as a String
  var content = await utf8.decodeStream(response.stream);

  final loadedNewData = await loadBackupFromString(content: content, cnHomepage: cnHomepage);
  if(loadedNewData){
    return true;
  }

  // /// Create a temp local File from this String data
  // final tempLocalFile = await saveBackup(withCloud: false, cnConfig: cnConfig, content: content);
  // if(tempLocalFile != null){
  //   final loadedNewData = await loadBackupFromFile(tempLocalFile, cnHomepage: cnHomepage);
  //   tempLocalFile.delete();
  //   if(loadedNewData){
  //     return true;
  //   }
  // }
  return false;
}

Future<GoogleSignInAccount?> getGoogleDriveAccount() async {
  GoogleSignInAccount? account;

  GoogleSignIn googleSignIn = GoogleSignIn(scopes: [ga.DriveApi.driveFileScope]);
  try {
    account = await googleSignIn.signIn();
  } catch (error) {
    //
  }
  return account;
}

Future<String?> getGoogleDriveFolderId(ga.DriveApi drive, CnConfig cnConfig) async {
  if(cnConfig.folderIdGoogleDrive != null){
    print("------------------ FOLDER ID IS CACHED");
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

Future<String?> getCurrentDataId({
  required ga.DriveApi drive,
  required CnConfig cnConfig,
  required String folderId
}) async {

  print("TRY GET CACHED DATA ID: ${cnConfig.currentDataIdGoogleDrive}");
  if(cnConfig.currentDataIdGoogleDrive != null){
    print("------------------ CURRENT DATA ID IS CACHED");
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

Future<String?> createGoogleDriveFolder(ga.DriveApi drive, CnConfig cnConfig) async{
  var fileMetadata = ga.File();
  fileMetadata.name = folderNameGoogleDrive;
  fileMetadata.mimeType = 'application/vnd.google-apps.folder';

  try {
    var file = await drive.files.create(fileMetadata);
    cnConfig.folderIdGoogleDrive = file.id;
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