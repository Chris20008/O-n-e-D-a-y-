import 'package:flutter/cupertino.dart';

class ExerciseContextId extends InheritedWidget {
  final String id;

  const ExerciseContextId({
    required this.id,
    required Widget child,
    super.key,
  }) : super(child: child);

  static String of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<ExerciseContextId>();
    assert(result != null, 'No FormContextId found in context');
    return result!.id;
  }

  @override
  bool updateShouldNotify(ExerciseContextId oldWidget) => id != oldWidget.id;
}
