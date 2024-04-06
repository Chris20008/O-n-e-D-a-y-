import 'dart:convert';
import 'dart:io';
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
  Directory? appDocDir = await getExternalStorageDirectory();
  final path = appDocDir?.parent.path;
  final file = File('$path/20240406_Backup.txt');
  print("FILE PATH: ${file.path}");
  await file.writeAsString(jsonEncode(testdata));
  print("FINISHED WRITING FILE");

  // final res = await getExternalStorageDirectories();
  // for (Directory r in res!){
  //   print("FILE PATH: ${r.path}");
  // }
  return true;
}