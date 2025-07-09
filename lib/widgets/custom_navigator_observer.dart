import 'package:flutter/cupertino.dart';
import 'package:fitness_app/util/extensions.dart';

class CustomNavigatorObserver extends NavigatorObserver {
  String? currentRouteName;
  String? previousRouteName;
  final List<String> _routeStack = [];
  final List<VoidCallback> _listeners = [];
  final Map<String?, String> overwrittenRouteNames = {};

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
    currentRouteName = newRouteName;

    _applyOverwrittenRouteNames();

    if(currentRouteName != null){
      _routeStack.add(currentRouteName!);
    }
    _callListeners();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    previousRouteName = currentRouteName;
    currentRouteName = previousRoute?.settings.name;
    _routeStack.removeLast();
    _checkOverwrittenRouteNames();
    _applyOverwrittenRouteNames();
    _callListeners();
  }

  void _callListeners(){
    for(VoidCallback f in List<VoidCallback>.from(_listeners)){
      f.call();
    }
  }

  void overwriteCurrentRouteName(String route){
    overwrittenRouteNames.remove(currentRouteName);

    overwrittenRouteNames[currentRouteName] = route;
    currentRouteName = route;
    _applyOverwrittenRouteNames();
    _routeStack.removeLast();
    _routeStack.add(route);
  }

  void _applyOverwrittenRouteNames(){
    for(String s in overwrittenRouteNames.keys.whereType<String>()){
      if(currentRouteName == s){
        currentRouteName = overwrittenRouteNames[s];
      }
      if(previousRouteName == s){
        previousRouteName = overwrittenRouteNames[s];
      }
    }
  }

  void _checkOverwrittenRouteNames(){
    final List<String> valsToRemove = overwrittenRouteNames.values.whereType<String>().toList().without(_routeStack);
    for (var val in valsToRemove) {
      overwrittenRouteNames.removeWhere((key, value) => value == val);
    }
  }

  void addListener(VoidCallback function){
    if (!_listeners.contains(function)) {
      _listeners.add(function);
    }
  }

  void removeListener(VoidCallback callback) {
    _listeners.remove(callback);
  }
}
