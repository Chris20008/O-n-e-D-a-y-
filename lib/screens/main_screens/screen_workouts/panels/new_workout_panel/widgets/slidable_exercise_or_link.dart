import 'package:fitness_app/objects/exercise.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlidableExerciseOrLink{
  Exercise? exercise;
  String? _linkName;
  final SlidableController slidableController;
  final key = GlobalKey();

  SlidableExerciseOrLink({
    required this.exercise,
    required linkName,
    required this.slidableController
  }) : _linkName = linkName;

  bool get isExercise => exercise != null;
  bool get isLink => !isExercise;
  String get name => exercise?.name?? "";
  String? get linkName => isLink? _linkName : exercise?.linkName;
  bool get hasLink => linkName != null;
}