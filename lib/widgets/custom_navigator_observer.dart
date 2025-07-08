import 'package:flutter/cupertino.dart';

class CustomNavigatorObserver extends NavigatorObserver {
  String? currentRouteName;
  String? previousRouteName;
  final List<String> _routeStack = [];
  final List<VoidCallback> _listeners = [];

  String? get parentRouteName {
    if(_routeStack.length <= 1){
      return null;
    }
    final parentIndex = _routeStack.indexOf(currentRouteName!) - 1;
    return _routeStack[parentIndex];
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    previousRouteName = currentRouteName;
    final newRouteName = route.settings.name;
    if(newRouteName != null){
      _routeStack.add(newRouteName);
    }
    currentRouteName = newRouteName;
    _callListeners();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    previousRouteName = currentRouteName;
    currentRouteName = previousRoute?.settings.name;
    _routeStack.removeLast();
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
