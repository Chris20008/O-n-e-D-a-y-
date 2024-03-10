import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

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