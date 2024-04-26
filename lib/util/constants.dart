import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/util/objectbox/ob_workout.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'objectbox/ob_exercise.dart';

final testdata = {
  "Name": "TESTNAME",
  "Exercises": {
    "Dips": [2, 3, 4, 5, 6, 7],
    "ChestFlys": [7, 6, 5, 4, 3, 2]
  }
};

Widget blurredIconButton({required Icon icon, Function()? onPressed, Key? key}){
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
      color: Colors.grey.withOpacity(0.3),
      child: FutureBuilder(
        future: test(iconButton),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return snapshot.data!;
          }
          return iconButton;
        },
      ),
    ),
  );
}

Future<Widget> computeBlurredBackground(Widget child) async{
  return BackdropFilter(
    filter: ImageFilter.blur(
        sigmaX: 10.0,
        sigmaY: 10.0,
        tileMode: TileMode.mirror
    ),
    child: child
  );
}

Future<Widget> test(Widget child) async{
  return await computeBlurredBackground(child);
}

enum TimeInterval {
  monthly ("Monthly"),
  quarterly ("Quarterly"),
  yearly ("Yearly");

  const TimeInterval(this.value);
  final String value;
}

Widget ExerciseNameText(
    String name,
    {
      int maxLines = 2,
      double fontsize = 17,
      double minFontSize = 10
    })
{
  return AutoSizeText(
    name,
    maxLines: maxLines,
    style: TextStyle(fontSize: fontsize, color: Colors.white),
    minFontSize: minFontSize,
    overflow: TextOverflow.ellipsis,
  );
}

Future<bool> saveBackup() async{
  Directory? appDocDir = await getDirectory();
  // if(Platform.isAndroid){
  //   appDocDir = await getExternalStorageDirectory();
  // }
  // else{
  //   appDocDir = await getApplicationDocumentsDirectory();
  // }
  final path = appDocDir?.path;
  final file = File('$path/Auto_Backup_${DateTime.now()}.txt');
  // final file = File('$path/Test_Backup.txt');
  print("FILE PATH: ${file.path}");
  await file.writeAsString(getWorkoutsAsStringList().join("; "));
  // print("Länge nach Split ${resultString.split(";").length}");
  print("FINISHED WRITING FILE");
  return true;
}

List getWorkoutsAsStringList(){
  final allObWorkouts = objectbox.workoutBox.getAll();
  final allWorkouts = List<String>.from(allObWorkouts.map((e) => jsonEncode(e.asJson())));
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
  FilePickerResult? result = await FilePicker.platform.pickFiles();

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

Future<bool> hasInternet()async{
  final conRes = await Connectivity().checkConnectivity();
  List<ConnectivityResult> options = [ConnectivityResult.mobile, ConnectivityResult.wifi, ConnectivityResult.vpn];
  // print("CON RES RESULT: $conRes - ${[ConnectivityResult.mobile, ConnectivityResult.wifi, ConnectivityResult.vpn].contains(conRes)}");
  return options.any((option) => conRes.contains(option));
}
