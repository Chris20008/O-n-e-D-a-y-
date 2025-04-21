import 'package:flutter/material.dart';

Widget getFileSizeText(int fileSize){
  int factor = 1000;
  String unit = "kB";
  if((fileSize / 1000000) >= 1){
    factor = 1000000;
    unit = "MB";
  }
  return Text(
    "${(fileSize / factor).toStringAsFixed(2)} $unit",
    style: TextStyle(
        fontSize: 12,
        color: Colors.white.withValues(alpha: 0.6)
    ),
  );
}