import 'dart:async';
import 'dart:math';

import 'package:fitness_app/util/extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class SZController{

  // ValueNotifier<double> currentVisibleDays = ValueNotifier(0);
  // ValueNotifier<double> maxVisibleDays = ValueNotifier(0);
  // ValueNotifier<double> offsetMinX = ValueNotifier(0);
  // ValueNotifier<double> offsetMaxX = ValueNotifier(0);

  final ValueNotifier<ScrollZoomState> state;
  late ScrollZoomState _previousState;

  Timer? lockGraphTimer;
  bool graphLocked = false;
  int animationTime = 500;
  Offset? pointerA;
  Offset? pointerAPreviousPos;
  Offset? pointerAStartPositionForGraphLock;
  Offset? pointerB;
  int? pointerAIdentifier;
  int? pointerBIdentifier;
  double lastPointerDistance = 0;
  double focalPointPercent = 0;
  int allowedMovementForGraphLock = 4;

  late int totalRange = maxDate.toDate().difference(minDate.toDate()).inDays;
  double widthAxisTitles;
  double totalScreenWidth;
  late DateTime minDate;
  late DateTime maxDate;
  int leftPadding;
  late int totalPadding = leftPadding * 2;

  Map<String, List<FlSpot>> allSpots = {};

  ScrollZoomState get current => state.value;

  double get deltaMinX => _previousState.offsetMinX - state.value.offsetMinX;
  double get deltaMaxX => _previousState.offsetMaxX - state.value.offsetMaxX;
  double get deltaCurrentVisibleDays => _previousState.currentVisibleDays - state.value.currentVisibleDays;

  SZController({
    required this.widthAxisTitles,
    required this.totalScreenWidth,
    required this.leftPadding,
    required this.minDate,
    required this.maxDate
  }) : state = ValueNotifier(
    ScrollZoomState(
      offsetMinX: 0,
      offsetMaxX: 0,
      currentVisibleDays: maxDate.difference(minDate).inDays.toDouble() + 10,
      maxVisibleDays: 1900,
    ),
  ){
    _previousState = state.value.copy();
  }

  void updateGraph({
    double? offsetMinX,
    double? offsetMaxX,
    double? currentVisibleDays,
    double? maxVisibleDays,
  }) {
    _previousState = state.value.copy();
    state.value = current.copyWith(
      offsetMinX: offsetMinX,
      offsetMaxX: offsetMaxX,
      currentVisibleDays: currentVisibleDays,
      maxVisibleDays: maxVisibleDays,
    );

    allSpots = allSpots.map((key, spots) {
      final shifted = spots.map((spot) => FlSpot(spot.x + deltaMinX, spot.y)).toList();
      return MapEntry(key, shifted);
    });

    // refreshSpots();
  }

  void refreshSpots(){
    allSpots = allSpots.map((key, spots) {
      final shifted = spots.map((spot) => FlSpot(spot.x + deltaMinX, spot.y)).toList();
      return MapEntry(key, shifted);
    });
  }

  void resetGraph() {
    _previousState = state.value.copy();
    state.value = ScrollZoomState(
      offsetMinX: 0,
      offsetMaxX: 0,
      currentVisibleDays: maxDate.difference(minDate).inDays.toDouble() + 10,
      maxVisibleDays: 1900,
    );
    refreshSpots();
  }

  void updateConfig({
    double? widthAxisTitles,
    double? totalScreenWidth,
    int? leftPadding,
    DateTime? minDate,
    DateTime? maxDate
  }){
    this.widthAxisTitles = widthAxisTitles?? this.widthAxisTitles;
    this.totalScreenWidth = totalScreenWidth?? this.totalScreenWidth;
    this.leftPadding = leftPadding?? this.leftPadding;
    this.minDate = minDate?? this.minDate;
    this.maxDate = maxDate?? this.maxDate;

    totalPadding = this.leftPadding * 2;
    totalRange = this.maxDate.toDate().difference(this.minDate.toDate()).inDays;
  }

  void doAnimateVertical(double startPositionY) async{
    Map<String, List<FlSpot>> tempAllSpots = allSpots.map((key, spots) {
      return MapEntry(key, spots);
    });

    allSpots = allSpots.map((key, spots) {
      final shifted = spots.map((spot) => FlSpot(spot.x + deltaMinX, startPositionY)).toList();
      return MapEntry(key, shifted);
    });

    await Future.delayed(const Duration(milliseconds: 100), (){
      allSpots = tempAllSpots;
    });

    updateGraph();
  }

  void pointerDown(PointerDownEvent details){
    if(state.value.offsetMinX != 0 || state.value.offsetMaxX != 0){
      lockGraphTimer ??= Timer(const Duration(milliseconds: 250), (){
        graphLocked = true;
        HapticFeedback.selectionClick();
      });
    }

    animationTime = 0;
    if(pointerAIdentifier == null){
      pointerAIdentifier = details.pointer;
      pointerA = details.position;
      pointerAStartPositionForGraphLock = details.position;
      pointerAPreviousPos = Offset(pointerA!.dx, pointerA!.dy);
    }
    else if (pointerBIdentifier == null && details.pointer != pointerAIdentifier && !graphLocked){
      lockGraphTimer?.cancel();
      pointerBIdentifier = details.pointer;
      pointerB = details.position;
      lastPointerDistance = (pointerB!.dx - pointerA!.dx).abs();
      final minPos = pointerB!.dx < pointerA!.dx? pointerB!.dx : pointerA!.dx;
      /// the middle point between the two pointer in percent
      focalPointPercent = (lastPointerDistance/2 + minPos - widthAxisTitles) / totalScreenWidth;
    }
  }

  void pointerMove(PointerMoveEvent details, BoxConstraints constraints){
    if(graphLocked){
      return;
    }


    if(details.pointer == pointerAIdentifier){
      pointerA = details.position;
    }
    else if(details.pointer == pointerBIdentifier){
      pointerB = details.position;
    }

    /// ZOOM
    if(pointerA != null && pointerB != null){
      double sensibility = ((state.value.currentVisibleDays) / (1500 / sqrt(state.value.currentVisibleDays)));
      final currentPointerDistance = (pointerB!.dx - pointerA!.dx).abs();
      final difference = (lastPointerDistance - currentPointerDistance) * sensibility;
      lastPointerDistance = currentPointerDistance;

      double newOffsetMaxX;
      double newOffsetMinX;

      double tempOffsetMinX = state.value.offsetMinX;
      double tempOffsetMaxX = state.value.offsetMaxX;
      double tempCurrentVisibleDays = state.value.currentVisibleDays;

      newOffsetMaxX = (state.value.offsetMaxX - difference);
      newOffsetMaxX = newOffsetMaxX >= 0? newOffsetMaxX : 0;
      newOffsetMinX = (state.value.offsetMinX - difference * focalPointPercent);
      newOffsetMinX = newOffsetMinX >= 0? newOffsetMinX : 0;

      if(newOffsetMaxX + 5 < totalRange && totalRange + totalPadding - newOffsetMaxX <= state.value.maxVisibleDays){
        tempOffsetMinX = newOffsetMinX;
        tempOffsetMaxX = newOffsetMaxX;
      }

      /// Set max visible days
      final tempMaxX = maxDate.difference(minDate).inDays + totalPadding - state.value.offsetMaxX;
      if(tempMaxX > state.value.maxVisibleDays){
        final rest = tempMaxX - state.value.maxVisibleDays;
        if(state.value.currentVisibleDays <= 0){
          tempOffsetMinX += rest;
        }
        tempOffsetMaxX += rest - totalPadding;
        tempCurrentVisibleDays = state.value.maxVisibleDays;
      } else{
        tempCurrentVisibleDays = tempMaxX;
      }

      updateGraph(
        offsetMinX: tempOffsetMinX,
        offsetMaxX: tempOffsetMaxX,
        currentVisibleDays: tempCurrentVisibleDays
      );
    }

    /// SCROLL
    else if(pointerA != null && pointerB == null && pointerAPreviousPos != null && state.value.offsetMaxX > 0){

      final maxValueOffsetMinX = totalRange - state.value.currentVisibleDays + totalPadding;
      double sensibility = 1/ (state.value.currentVisibleDays / (constraints.maxWidth-widthAxisTitles));
      sensibility = sensibility < 0.1? 0.1 : sensibility > 500? 500 : sensibility;
      final currentPointerDistance = (pointerAPreviousPos!.dx - pointerA!.dx) / sensibility;

      if((pointerAStartPositionForGraphLock!.dx - pointerA!.dx).abs() > allowedMovementForGraphLock){
        lockGraphTimer?.cancel();
        lockGraphTimer = null;
        graphLocked = false;
      }

      double newOffsetMinX;

      newOffsetMinX = state.value.offsetMinX + currentPointerDistance;
      if(newOffsetMinX < 0 && state.value.offsetMinX != 0){
        updateGraph(
            offsetMinX: 0
        );
      }
      else if(newOffsetMinX > maxValueOffsetMinX && state.value.offsetMinX != maxValueOffsetMinX){
        updateGraph(
            offsetMinX: maxValueOffsetMinX
        );
      }
      else if(newOffsetMinX >= 0 && newOffsetMinX != state.value.offsetMinX && (newOffsetMinX <= maxValueOffsetMinX || newOffsetMinX <= state.value.offsetMinX)){
        pointerAPreviousPos = Offset(pointerA!.dx, pointerA!.dy);
        updateGraph(
            offsetMinX: newOffsetMinX
        );
      }
    }
  }

  void pointerUp(PointerUpEvent details){
    lockGraphTimer?.cancel();
    lockGraphTimer = null;
    graphLocked = false;
    pointerA = null;
    pointerAPreviousPos = null;
    pointerAIdentifier = null;
    pointerB = null;
    pointerBIdentifier = null;
    // refresh();

    /// Small delay to allow UI to be drawn at least once and after that reset the animation time back to allow animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(pointerA == null && pointerB == null){
        animationTime = 500;
      }
    });
  }

  void dispose() {
    state.dispose();
  }
}


@immutable
class ScrollZoomState {
  final double offsetMinX;
  final double offsetMaxX;
  final double currentVisibleDays;
  final double maxVisibleDays;
  // final double deltaCurrentVisibleDays;

  const ScrollZoomState({
    required this.offsetMinX,
    required this.offsetMaxX,
    required this.currentVisibleDays,
    required this.maxVisibleDays,
    // this.deltaCurrentVisibleDays
  });

  ScrollZoomState copyWith({
    double? offsetMinX,
    double? offsetMaxX,
    double? currentVisibleDays,
    double? maxVisibleDays,
  }) {
    return ScrollZoomState(
      offsetMinX: offsetMinX ?? this.offsetMinX,
      offsetMaxX: offsetMaxX ?? this.offsetMaxX,
      currentVisibleDays: currentVisibleDays ?? this.currentVisibleDays,
      maxVisibleDays: maxVisibleDays ?? this.maxVisibleDays,
    );
  }

  ScrollZoomState copy() {
    return ScrollZoomState(
      offsetMinX: offsetMinX,
      offsetMaxX: offsetMaxX,
      currentVisibleDays: currentVisibleDays,
      maxVisibleDays: maxVisibleDays,
    );
  }

  @override
  String toString() {
    return 'ScrollZoomState(offsetMinX: $offsetMinX, offsetMaxX: $offsetMaxX, currentVisibleDays: $currentVisibleDays, maxVisibleDays: $maxVisibleDays)';
  }
}

