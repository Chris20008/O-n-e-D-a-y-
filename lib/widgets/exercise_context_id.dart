import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class GlobalKeyContext extends InheritedWidget {
  final Map<KeyContextId, String> ids;

  const GlobalKeyContext({
    required this.ids,
    required Widget child,
    super.key,
  }) : super(child: child);

  static String of(BuildContext context, KeyContextId id) {
    final result = context.dependOnInheritedWidgetOfExactType<GlobalKeyContext>();
    assert(result != null, 'No KeyContext found in context');
    return result!.ids[id]!;
  }

  @override
  bool updateShouldNotify(GlobalKeyContext oldWidget) => !mapEquals(ids, oldWidget.ids);
}

enum KeyContextId {
  newExercisePanel,
  allExercisePanel
}