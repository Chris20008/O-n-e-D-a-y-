import 'package:flutter/cupertino.dart';

import 'custom_navigator_observer.dart';

class CustomNavigator extends StatelessWidget {
  final CustomNavigatorObserver observer;
  final GlobalKey<NavigatorState> navigatorKey;
  final String? initialRoute;
  final Route<dynamic>? Function(RouteSettings) onGenerateRoute;

  const CustomNavigator({
    required this.observer,
    required this.navigatorKey,
    required this.initialRoute,
    required this.onGenerateRoute,
    super.key,
  });

  static CustomNavigatorScope of(BuildContext context){
    return CustomNavigatorScope.of(context);
  }

  static Future<Object?>? pushNamed(BuildContext context, String routeName){
    return of(context).navigatorKey.currentState?.pushNamed(routeName);
  }

  static void pop(BuildContext context){
    if(context.mounted){
      of(context).navigatorKey.currentState?.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomNavigatorScope(
      navigatorKey: navigatorKey,
      observer: observer,
      child: Navigator(
        key: navigatorKey,
        observers: [observer],
        initialRoute: initialRoute,
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }
}

class CustomNavigatorScope extends InheritedWidget {
  final CustomNavigatorObserver observer;
  final GlobalKey<NavigatorState> navigatorKey;

  const CustomNavigatorScope({
    required this.observer,
    required this.navigatorKey,
    required Widget child,
    super.key,
  }) : super(child: child);

  static CustomNavigatorScope of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<CustomNavigatorScope>();
    assert(result != null, 'No CustomNavigator found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(CustomNavigatorScope oldWidget) {
    return false;
  }
}