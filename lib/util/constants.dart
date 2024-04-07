import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fitness_app/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

final testdata = {
  "Name": "TESTNAME",
  "Exercises": {
    "Dips": [2, 3, 4, 5, 6, 7],
    "ChestFlys": [7, 6, 5, 4, 3, 2]
  }
};

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
  // final file = File('$path/Auto_Backup_${DateTime.now()}.txt');
  final file = File('$path/Test_Backup.txt');
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
    print(contents);
  } else {
    // User canceled the picker
  }
  // Directory? appDocDir = await getDirectory();
  // final path = appDocDir?.path;
  // final file = File('$path/Test_Backup.txt');
  // final contents = await file.readAsString();
  // print(contents);
}
