import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/util/objectbox/ob_workout.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../objectbox.g.dart';
import '../objects/workout.dart';
import 'objectbox/ob_exercise.dart';

TextStyle getTextStyleForTextField(String text, {Color? color}){
  return TextStyle(
    fontSize: text.length < 4
    ?18
    : text.length < 5
    ? 16
    : text.length < 6
    ? 13 : 10,
    color: color,
  );
}

String validateDoubleTextInput(String text){
  if(text.characters.last == "."){
    final count = ".".allMatches(text).length;
    if(count > 1){
      text = text.substring(0, text.length-1);
    }
  }
  if(text.characters.first == "."){
    text = "0$text";
  }
  return text;
}

String checkOnlyOneDecimalPoint(String text){
  if(text.characters.last == "."){
    final count = ".".allMatches(text).length;
    if(count > 1){
      text = text.substring(0, text.length-1);
    }
  }
  return text;
}

Future setIntlLanguage({String? countryCode})async{
  final res = await findSystemLocale();
  Intl.systemLocale = countryCode?? res;
}

class Language{
  final String languageCode;
  final String countryCode;

  Language({required this.languageCode, required this.countryCode});
}

Map languages = {
  "de": Language(languageCode: "de", countryCode: "de_DE"),
  "en": Language(languageCode: "en", countryCode: "en_US")
};

enum LANGUAGES{
  de ("de"),
  en ("en");

  const LANGUAGES(this.value);
  final String value;
}

Widget myIconButton({required Icon icon, Function()? onPressed, Key? key}){
  Widget iconButton = IconButton(
    key: key,
    iconSize: 25,
    onPressed: onPressed,
    icon: icon,
  );
  return ClipRRect(
    borderRadius: BorderRadius.circular(40),
    child: Container(
      height: 40,
      width: 40,
      // color: Colors.grey.withOpacity(0.3),
      child: iconButton
    ),
  );
}

enum TimeInterval {
  monthly ("Monthly"),
  quarterly ("Quarterly"),
  yearly ("Yearly");

  const TimeInterval(this.value);
  final String value;
}

Widget OverflowSafeText(
    String name,
    {
      int maxLines = 2,
      double? fontSize = 17,
      double? minFontSize = 10,
      TextStyle? style,
      TextAlign? textAlign
    })
{
  fontSize = fontSize?? 17;
  minFontSize = minFontSize?? 10;
  return AutoSizeText(
    name,
    maxLines: maxLines,
    style: style?? TextStyle(fontSize: fontSize, color: Colors.white),
    minFontSize: minFontSize,
    overflow: TextOverflow.ellipsis,
    textAlign: textAlign,
  );
}

Future<bool> saveBackup() async{
  Directory? appDocDir = await getDirectory();
  final path = appDocDir?.path;
  /// Seems like having ':' in the filename leads to issues, so we replace them
  final filename = "Auto_Backup_${DateTime.now()}.txt".replaceAll(":", "-");
  final fullPath = '$path/$filename';
  final file = File(fullPath);
  await file.writeAsString(getWorkoutsAsStringList().join("; "));

  if(Platform.isIOS){
    await saveBackupIOS(fullPath, filename);

    // final fileList = await ICloudStorage.gather(
    //     containerId: dotenv.env["ICLOUD_CONTAINER_ID"]!
    // );
    // print("Files gathered");
    // fileList.forEach((element) {print(element.relativePath);});
  }

  return true;
}

Future saveBackupIOS(String sourceFilePath, String filename)async{
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

List getWorkoutsAsStringList(){
  final allObWorkouts = objectbox.workoutBox.getAll();
  final allWorkouts = List<String>.from(allObWorkouts.map((e) => jsonEncode(e.asMap())));
  return allWorkouts;
}

Future<Directory?> getDirectory() async{
  if(Platform.isAndroid){
    return await getExternalStorageDirectory();
  }
  else{
    return await getApplicationDocumentsDirectory();
  }
}

void loadBackup() async{
  FilePickerResult? result = await FilePicker.platform.pickFiles(
      initialDirectory: "/storage/emulated/0/Android/data/christian.range.fitnessapp.fitness_app/files"
  );

  if (result != null) {
    print("------- GOT RESULT -------");
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

void pickBackupPath() async{
  // FilePickerResult? result = await FilePicker.platform.pickFiles();
  String? result = await FilePicker.platform.getDirectoryPath();

  if (result != null) {
    print("------- GOT pickBackupPath RESULT -------");
    print(result);
  } else {
    // User canceled the picker
  }
}

Future<bool> hasInternet()async{
  final conRes = await Connectivity().checkConnectivity();
  List<ConnectivityResult> options = [ConnectivityResult.mobile, ConnectivityResult.wifi, ConnectivityResult.vpn];
  // print("CON RES RESULT: $conRes - ${[ConnectivityResult.mobile, ConnectivityResult.wifi, ConnectivityResult.vpn].contains(conRes)}");
  return options.any((option) => conRes.contains(option));
}

void vibrateCancel(){
  HapticFeedback.selectionClick();
  Future.delayed(const Duration(milliseconds: 180), (){
    HapticFeedback.heavyImpact();
  });
}

void vibrateConfirm(){
  HapticFeedback.mediumImpact();
  Future.delayed(const Duration(milliseconds: 180), (){
    HapticFeedback.selectionClick();
  });
}

void vibrateSuccess(){
  HapticFeedback.heavyImpact();
  Future.delayed(const Duration(milliseconds: 100), (){
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 100), (){
      HapticFeedback.heavyImpact();
    });
  });
}

bool workoutNameExistsInTemplates({required String workoutName}){
  final result = objectbox.workoutBox.query(ObWorkout_.name.equals(workoutName, caseSensitive: false).and(ObWorkout_.isTemplate.equals(true))).build().findFirst();
  if(result == null){
    return false;
  }
  return true;
}

bool exerciseNameExistsInWorkout({required Workout workout, required String exerciseName}){
  final List<String> exNames = workout.exercises.map((e) => e.name.toLowerCase()).toList();
  if(exNames.contains(exerciseName.toLowerCase())){
    return true;
  }
  return false;
}

// bool exerciseNameExistsInWorkout({required String workoutName, required String exerciseName}){
//   /// create builder
//   final builder = objectbox.workoutBox.query(ObWorkout_.name.equals(workoutName, caseSensitive: false).and(ObWorkout_.isTemplate.equals(true)));
//   /// link builder with exercises
//   builder.linkMany(ObWorkout_.exercises, ObExercise_.name.equals(exerciseName, caseSensitive: false));
//   /// find first workout
//   final result = builder.build().findFirst();
//   if(result == null){
//     return false;
//   }
//   return true;
// }
