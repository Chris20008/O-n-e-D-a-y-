import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/objectbox/ob_sick_days.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'ios_channel.dart';
import 'objectbox/ob_exercise.dart';
import 'objectbox/ob_workout.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';

const folderNameGoogleDrive = "OneDay Backups";
const currentDataFileName = "Current_Data.txt";
/// !!! Having 'Documents' as the beginning of the path is MANDATORY in order
/// to see the Folder in ICloud File Explorer. Do NOT remove !!!
const folderPathiCloud = "Documents/backups/";
const String workoutSickDaySeparator = "b8c512d6eddb893c5a79349173756c030e6df92d30d2e4d0cc7abef593b910a7";

Future<bool> shareBackup({required CnConfig cnConfig, Function? afterReceiveFile}) async{
  File? file = await saveBackup(
      withCloud: false,
      cnConfig: cnConfig,
      automatic: false
  );
  if(file == null){
    return false;
  }
  else{
    XFile xfile = XFile(file.path);
    await Share.shareXFiles([xfile]);
    Future.delayed(const Duration(seconds: 1), (){
      file.delete();
    });
  }
  return true;
}

Future<String> getLocalPath() async{
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File?> getBackupFromFilePicker({CnHomepage? cnHomepage}) async{
  FilePickerResult? result = await FilePicker.platform.pickFiles(
      initialDirectory: "/storage/emulated/0/Android/data/christian.range.fitnessapp.fitness_app/files"
  );

  if (result != null) {
    File file = File(result.files.single.path!);
    return file;
    // await loadBackupFromFile(file, cnHomepage: cnHomepage);
  } else {
    return null;
  }

}

Future<bool> loadBackupFromFile(File file, {CnHomepage? cnHomepage}) async{
  final content = await file.readAsString();
  return await loadBackupFromString(content: content, cnHomepage: cnHomepage);
}

Future<bool> loadBackupFromString({required String content, CnHomepage? cnHomepage}) async{
  /// Todo: Improve Performance of split and for loop
  /// They both take long and block the UI when the data is very large
  final result = content.split(workoutSickDaySeparator);
  result.removeWhere((element) => element.trim() == "");
  final allWorkoutsAsListString = result.first.split(";");
  allWorkoutsAsListString.removeWhere((element) => element.trim() == "");
  final allWorkouts = allWorkoutsAsListString.map((e) => jsonDecode(e));
  List<ObWorkout> allObWorkouts = [];
  for (Map w in allWorkouts){
    ObWorkout workout = ObWorkout.fromMap(workoutMap: w, withId: true);
    final List<ObExercise> exs = List.from(w["exercises"].map((ex) => ObExercise.fromMap(ex)));
    workout.addExercises(exs);
    allObWorkouts.add(workout);
  }

  objectbox.sickDaysBox.removeAll();
  if (result.length > 1){
    final allSickDaysAsListString = result[1].split(";");
    allSickDaysAsListString.removeWhere((element) => element.trim() == "");
    final allSickDays = allSickDaysAsListString.map((e) => jsonDecode(e));
    final List<ObSickDays> allObSickDays = List.from(allSickDays.map((m) => ObSickDays.fromMap(sickDaysMap: m)));
    await objectbox.sickDaysBox.putManyAsync(allObSickDays);
  }

  final hadDifferences = await loadDifferencesWorkouts(allObWorkouts, cnHomepage: cnHomepage);
  return hadDifferences;
}

Future<bool> loadDifferencesWorkouts(List<ObWorkout> workouts, {CnHomepage? cnHomepage}) async{
  if(cnHomepage != null && cnHomepage.msg.isEmpty){
    cnHomepage.msg = "Load Backup";
  }
  int batchSize = (workouts.length~/100).clamp(5, 15);
  // int batchSize = 10;
  int counter = 0;
  bool hadDifferences = false;
  List<ObWorkout> allCurrentWorkouts = await objectbox.workoutBox.getAllAsync();
  Map<int, ObWorkout> hashMapBig = {};
  for (var obWorkout in allCurrentWorkouts) {
    final key = obWorkout.getHash();
    hashMapBig[key] = obWorkout;
  }

  Map<int, ObWorkout> hashMapSmall = {};
  for (var obWorkout in allCurrentWorkouts) {
    final key = obWorkout.getHashId();
    hashMapSmall[key] = obWorkout;
  }
  final length = workouts.length;

  for(ObWorkout wo in workouts){

    final woHashSmall = wo.getHashId();
    final woHashBig = wo.getHash();

    /// ################################################################################################################
    /// ################################################################################################################
    ///                                     Workout with same ID, name and Date
    /// ################################################################################################################
    /// ################################################################################################################

    /// Find an existing workout with same id, name and date
    ObWorkout? existingWorkout = hashMapSmall[woHashSmall];

    /// When this workout exists and they are not completely the same (compare HashKeyBig) we can modify the workout without the need to add a new one
    if(existingWorkout != null && !hashMapBig.keys.contains(woHashBig)){
      allCurrentWorkouts.remove(existingWorkout);
      List<ObExercise> allUpdateableExercises = existingWorkout.exercises;

      for(ObExercise ex in wo.exercises){

        /// Since each Exercise name is only allowed once per Workout
        /// we try to find the ex name in the existingWorkouts Exercises
        ObExercise? existingExercise = allUpdateableExercises.firstWhereOrNull((element) => element.name == ex.name);

        /// When an exercise with this name exists and is not equal to the current one, we update it
        if(existingExercise != null && !existingExercise.equals(ex)){
          allUpdateableExercises.remove(existingExercise);
          ex.id = existingExercise.id;
          objectbox.exerciseBox.put(ex);
        }
        /// No ex with this name found -> new Exercise
        else{
          objectbox.exerciseBox.put(ex);
        }
      }

      if(allUpdateableExercises.isNotEmpty){
        await objectbox.exerciseBox.removeManyAsync(allUpdateableExercises.map((e) => e.id).toList());
      }

      existingWorkout = wo;

      await objectbox.workoutBox.putAsync(wo);
      await objectbox.exerciseBox.putManyAsync(wo.exercises);
      hadDifferences = true;
      // continue;
    }

    /// ################################################################################################################
    /// ################################################################################################################
    ///                                         Workout new or exactly same
    /// ################################################################################################################
    /// ################################################################################################################

    else{
      /// If not it means the id does not exists, but maybe the workout itself exists because objectbox entries
      /// on different devices can have different id's
      /// So we check just for equal through the bigHash
      ObWorkout? existingWorkout = hashMapBig[woHashBig];

      /// However, if there is no existing workout that equals the new workout, even when ignoring the ID
      /// It means this is a completely new workout
      if(existingWorkout == null){
        hadDifferences = true;
        wo.id = 0;
        await objectbox.workoutBox.putAsync(wo);
        await objectbox.exerciseBox.putManyAsync(wo.exercises);
        /// Add it to the HashMap in case there is an exact same workout
        hashMapBig[woHashBig] = wo;
      }
      /// This workout exists as it is
      else{
        allCurrentWorkouts.remove(existingWorkout);
      }
    }

    counter += 1;
    /// Await a small delay after each completed Batch to allow the UI to refresh
    /// For better performance this whole function should be executed in an Isolate
    /// Will be implemented later
    if(counter % batchSize == 0){
      await Future.delayed(const Duration(milliseconds: 5));
    }

    if(cnHomepage != null && counter % (batchSize*2) == 0){
      final p = counter / length;
      cnHomepage.updateSyncStatus(p);
    }
  }

  if(allCurrentWorkouts.isNotEmpty){
    hadDifferences = true;
  }

  if(cnHomepage != null){
    final p = counter / length;
    cnHomepage.updateSyncStatus(p);
  }

  objectbox.exerciseBox.removeMany(allCurrentWorkouts.map((w) => w.exercises).expand((element) => element).map((e) => e.id).toList());
  objectbox.workoutBox.removeMany(allCurrentWorkouts.map((w) => w.id).toList());
  if(cnHomepage != null){
    cnHomepage.finishSync();
  }
  return hadDifferences;
}

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
  catch (_) {
    return null;
  }
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
  final allObSickDays = objectbox.sickDaysBox.getAll();
  final allWorkouts = List<String>.from(allObWorkouts.map((workout) => jsonEncode(workout.asMap())));
  final allSickDays = List<String>.from(allObSickDays.map((sickDay) => jsonEncode(sickDay.asMap())));

  return allWorkouts + [workoutSickDaySeparator] + allSickDays;
}

Future<List<FileSystemEntity>> getLocalBackupFiles() async{
  final path = await getLocalPath();

  List<FileSystemEntity> localFiles = Directory("$path/").listSync().where((element) => element.path.contains("_Backup")).toList();
  /// Todo: order list, on IOS at least it is not ordered, on Android it seems to be ordered
  // localFiles = localFiles.where((element) => element.path.contains("_Backup")).toList().reversed.toList();

  /// Compute [FileStat] results for each file.  Use [Future.wait] to do it
  /// efficiently without needing to wait for each I/O operation sequentially.
  // var statResults = await Future.wait([
  //   for (var file in localFiles) FileStat.stat(file.path),
  // ]);

  /// Map file paths to modification times.
  // var mtimes = <String, DateTime>{
  //   for (var i = 0; i < localFiles.length; i += 1)
  //     localFiles[i].path: statResults[i].changed,
  // };

  // var mtimes = <String, DateTime>{
  //   for (var i = 0; i < localFiles.length; i += 1)
  //     String timeString = localFiles[i].path.split("_");
  //     localFiles[i].path: statResults[i].changed,
  // };

  /// Sort [fileList] by modification times, from oldest to newest.
  // localFiles.sort((a, b) => mtimes[b.path]!.compareTo(mtimes[a.path]!));
  // localFiles.forEach((element) {
  //   print(element.path.split("_").last);
  // });
  localFiles.sort((a, b) => b.path.split("_").last.compareTo(a.path.split("_").last));
  // print("");
  // localFiles.forEach((element) {
  //   print(element.path.split("_").last);
  // });
  return localFiles;
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

Future<GoogleSignInAccount?> getGoogleDriveAccount() async {
  GoogleSignInAccount? account;

  GoogleSignIn googleSignIn = GoogleSignIn(scopes: [ga.DriveApi.driveFileScope]);
  try {
    account = await googleSignIn.signIn();
  } catch (error) {
    Fluttertoast.showToast(
        msg: error.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  return account;
}

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

Future<String?> createGoogleDriveFolder(ga.DriveApi drive, CnConfig cnConfig) async{
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

class GoogleAuthClient extends BaseClient {
  final Map<String, String> _headers;

  final Client _client = Client();

  GoogleAuthClient(this._headers);

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}