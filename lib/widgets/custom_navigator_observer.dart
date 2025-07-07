import 'package:flutter/cupertino.dart';

class CustomNavigatorObserver extends NavigatorObserver {
  String? currentRouteName;
  final List<VoidCallback> _listeners = [];

  @override
  void didPush(Route route, Route? previousRoute) {
    currentRouteName = route.settings.name;
    _callListeners();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    currentRouteName = previousRoute?.settings.name;
    _callListeners();
  }

  void _callListeners(){
    for(VoidCallback f in List<VoidCallback>.from(_listeners)){
      f.call();
    }
  }

  void addListener(VoidCallback function){
    _listeners.add(function);
  }

  void removeListener(VoidCallback callback) {
    _listeners.remove(callback);
  }
}
