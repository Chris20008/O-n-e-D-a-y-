import 'package:flutter/cupertino.dart';

class CustomNavigatorObserver extends NavigatorObserver {
  String? currentRouteName;

  @override
  void didPush(Route route, Route? previousRoute) {
    currentRouteName = route.settings.name;
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    currentRouteName = previousRoute?.settings.name;
  }
}
