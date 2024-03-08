import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

Widget ExerciseNameText(
    String name,
    {int maxLines = 2})
{
  return AutoSizeText(
    name,
    maxLines: maxLines,
    style: const TextStyle(fontSize: 17),
    minFontSize: 10,
    overflow: TextOverflow.ellipsis,
  );
}