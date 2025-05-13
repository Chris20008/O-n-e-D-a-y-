import 'dart:async';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class SZController{

  final double _minZoomArea = 20;
  final double _maxZoomArea = 1200;
  final double _defaultZoomArea = 365;
  final String _originalLineNameDefault = "original";
  final double _leftPaddingGraph = 15;
  late final double _totalPaddingGraph = _leftPaddingGraph * 2;
  final int _defaultAnimationTime = 500;

  final ValueNotifier<ScrollZoomState> state;
  late ScrollZoomState _previousState;
  VelocityTracker _velocityTracker = VelocityTracker.withKind(PointerDeviceKind.touch);

  Timer? lockGraphTimer;
  Timer? doubleTapTimer;
  Timer? afterScrollTimer;
  bool _allowAfterScroll = true;

  bool graphLocked = false;
  late int animationTime = _defaultAnimationTime;
  Offset? pointerA;
  Offset? pointerAPreviousPos;
  Offset? pointerAStartPositionForGraphLock;
  Offset? pointerB;
  int? pointerAIdentifier;
  int? pointerBIdentifier;
  double lastPointerDistance = 0;
  double focalPointPercent = 0;
  int allowedMovementForGraphLock = 4;
  late double totalRange = maxDate.toDate().differenceSafe(minDate.toDate()).inDays.toDouble();
  double widthAxisTitles;
  double totalScreenWidth;
  late DateTime minDate;
  late DateTime maxDate;
  bool graphIsReduced = false;

  Map<String, List<FlSpot>> allSpots = {};

  ScrollZoomState get current => state.value;
  double get maxVisibleArea => min(_maxZoomArea, (totalRange+_totalPaddingGraph).toDouble());

  /// range between minDate and maxDate plus the offset
  double get totalRangeWithPadding => totalRange + _totalPaddingGraph;

  /// maximum possible zoom are with offset
  double get _maxZoomAreaWithPadding => _maxZoomArea + _totalPaddingGraph;

  /// scroll position when zoomed in to default zoom
  double get _scrollPositionZoomedIn => (totalRangeWithPadding - _defaultZoomArea).clamp(0, totalRangeWithPadding);

  /// delta between current and last scroll position
  double get deltaScrollPosition => _previousState.scrollPosition - state.value.scrollPosition;

  double get scrollPositionWithPadding => state.value.scrollPosition + _leftPaddingGraph;

  /// calculated velocity of last current scroll
  double get _velocity => _velocityTracker.getVelocity().pixelsPerSecond.dx * 0.00006 * (state.value.zoomArea * 0.5);

  /// maximum possible scroll position
  double get maxScrollPosition => totalRange - state.value.zoomArea + _totalPaddingGraph;

  double get _minPossibleXCoordinate => -state.value.scrollPosition + _leftPaddingGraph;

  double get _maxPossibleXCoordinate => totalRange -state.value.scrollPosition + _leftPaddingGraph;

  double get leftPaddingGraph => _leftPaddingGraph;

  void addLine({
    required String key,
    required List<FlSpot> value
  }){
    /// move graph on x-axis according to padding
    value = value.map((spot) => FlSpot(spot.x + _leftPaddingGraph, spot.y)).toList();
    allSpots[key] = List.from(value);
    allSpots["${_originalLineNameDefault}_$key"] = value;

    handleFlPointReduction(key);
  }

  List<FlSpot> getLine({required String key}) => allSpots[key]?? [];

  Map<DateTime, double> getLineFormatted({required String key}){
    final spots = allSpots[key]?? [];
    final entries = spots.mapIndexed((index, spot) => MapEntry(minDate.addSafe(Duration(days: (spot.x + state.value.scrollPosition).ceil() - _leftPaddingGraph.toInt(), microseconds: index)), spot.y));
    return { for (var item in entries) item.key : item.value };
  }

  SZController({
    required this.widthAxisTitles,
    required this.totalScreenWidth,
    // required this.leftPaddingGraph,
    required this.minDate,
    required this.maxDate
  }) : state = ValueNotifier(
    ScrollZoomState(
      scrollPosition: 0,
      zoomArea: maxDate.differenceSafe(minDate).inDays.toDouble() + 30, /// 30 is value of _totalPaddingGraph
    ),
  ){
    if(state.value.zoomArea > _defaultZoomArea){
      updateGraph(
        zoomArea: _defaultZoomArea,
        scrollPosition: _scrollPositionZoomedIn
      );
    }
    if(state.value.zoomArea > _maxZoomAreaWithPadding){
      resetGraph();
    }
    _previousState = state.value.copy();
  }

  void updateGraph({
    double? scrollPosition,
    double? zoomArea,
    double? maxZoomArea,
  }) {

    _previousState = state.value.copy();
    state.value = current.copyWith(
      scrollPosition: scrollPosition,
      currentVisibleDays: zoomArea,
    );

    refreshSpots();
  }

  void refreshSpots(){
    allSpots = allSpots.map((key, spots) {
      final shifted = spots.map((spot) => FlSpot(spot.x + deltaScrollPosition, spot.y)).toList();
      return MapEntry(key, shifted);
    });

    /// reduce spots
    final reduce = state.value.zoomArea > _defaultZoomArea;
    if(reduce){
      if(graphIsReduced){
        return;
      }
      for(String key in allSpots.keys){
        handleFlPointReduction(key);
      }
      graphIsReduced = true;
      updateGraph();
    }
    else if(graphIsReduced){
      graphIsReduced = false;
      for(String key in allSpots.keys) {
        if (key.contains(_originalLineNameDefault)) continue;
        allSpots[key] = List.from(allSpots['${_originalLineNameDefault}_$key']!);
        animationTime = _defaultAnimationTime;
      }
      updateGraph();
    }
  }

  void handleFlPointReduction(String key){
    if(state.value.zoomArea <= _defaultZoomArea){
      return;
    }
    if (key.contains(_originalLineNameDefault) || key.contains("sickDaysSpots")){
     return;
    }

    double calcNewX(DateTime spot){
      return (spot.getMidDayOfMonth().differenceSafe(minDate).inDays - state.value.scrollPosition - leftPaddingGraph)
          .clamp(_minPossibleXCoordinate, _maxPossibleXCoordinate)
          .toDouble();
    }

    animationTime = _defaultAnimationTime;

    List<FlSpot> newSpots = [];
    List<FlSpot> tempSpots = [];
    DateTime? lastSpotDate;
    int lastIndex = allSpots[key]!.length - 1;

    for(var entry in allSpots[key]!.asMap().entries){
      final index = entry.key;
      final spot = entry.value;
      final spotsDate = minDate.addSafe(Duration(days: (spot.x + scrollPositionWithPadding).toInt()));
      lastSpotDate ??= spotsDate;

      /// Same month as previous, just add spot
      if(lastSpotDate.isSameMonth(spotsDate)){
        tempSpots.add(spot);
      }
      /// Different month => save current temp spots, clear them and add the new spot
      else{
        /// sort from highest to lowest y-axis
        tempSpots.sort(highestToLowestSort);
        /// take highest y-axis spot
        FlSpot? maxSpot = tempSpots.firstOrNull;
        if(maxSpot != null){
          /// newX can't be lower than minDate
          /// Take difference in days
          /// if difference is negative we clamp it to the most low value which is the negative state.value.scrollPosition
          final double newX = calcNewX(lastSpotDate);
          maxSpot = FlSpot(newX, maxSpot.y);
          newSpots.addAll(List.generate(tempSpots.length, (_) => maxSpot!));
        }
        tempSpots.clear();
        lastSpotDate = spotsDate;
        tempSpots.add(spot);
      }

      /// Last Spot
      if(index == lastIndex){
        /// sort from highest to lowest y-axis
        tempSpots.sort(highestToLowestSort);
        FlSpot? maxSpot = tempSpots.firstOrNull;
        if(maxSpot != null){
          final double newX = calcNewX(lastSpotDate);
          maxSpot = FlSpot(newX, maxSpot.y);
          newSpots.addAll(List.generate(tempSpots.length, (_) => maxSpot!));
        }
      }
    }
    allSpots[key] = newSpots;
  }

  int highestToLowestSort(a, b){
    if(a.y > b.y){
      return -1;
    }
    else if(a.y < b.y){
      return 1;
    }
    else if(a.x > b.y){
      return -1;
    }
    return 1;
  }

  void resetGraph({
    doubleUpdate = false
  }) {
    resetAnimationTime(withPostFrameCallBack: false);
    _allowAfterScroll = false;
    _previousState = state.value.copy();

    /// Zoom to max outer position
    double newZoomArea = min(totalRangeWithPadding, _maxZoomAreaWithPadding);
    double scrollPosition = (totalRangeWithPadding - newZoomArea).clamp(0, totalRangeWithPadding);

    /// Zoom to default state
    if(newZoomArea > _defaultZoomArea && state.value.zoomArea != _defaultZoomArea){
      newZoomArea = _defaultZoomArea;
      scrollPosition = _scrollPositionZoomedIn;
    }

    updateGraph(
      scrollPosition: scrollPosition,
      zoomArea: newZoomArea
    );
  }

  void updateConfig({
    double? widthAxisTitles,
    double? totalScreenWidth,
    // double? leftPadding,
    DateTime? minDate,
    DateTime? maxDate
  }){
    this.widthAxisTitles = widthAxisTitles?? this.widthAxisTitles;
    this.totalScreenWidth = totalScreenWidth?? this.totalScreenWidth;
    // this.leftPaddingGraph = leftPadding?? this.leftPaddingGraph;
    this.minDate = minDate?? this.minDate;
    this.maxDate = maxDate?? this.maxDate;

    // totalPaddingGraph = this.leftPaddingGraph * 2;
    totalRange = this.maxDate.toDate().differenceSafe(this.minDate.toDate()).inDays.toDouble();
  }

  void doAnimateVertical(double startPositionY) async{
    Map<String, List<FlSpot>> tempAllSpots = allSpots.map((key, spots) {
      return MapEntry(key, spots);
    });

    allSpots = allSpots.map((key, spots) {
      final shifted = spots.map((spot) => FlSpot(spot.x + deltaScrollPosition, startPositionY)).toList();
      return MapEntry(key, shifted);
    });

    await Future.delayed(const Duration(milliseconds: 100), (){
      allSpots = tempAllSpots;
    });

    updateGraph();
  }

  void pointerDown(PointerDownEvent details){
    afterScrollTimer?.cancel();
    _allowAfterScroll = false;
    if(state.value.scrollPosition != 0 || totalRange > state.value.zoomArea){
      lockGraphTimer ??= Timer(const Duration(milliseconds: 250), (){
        graphLocked = true;
        HapticFeedback.selectionClick();
      });
    }

    // onDoubleTap(details);

    _velocityTracker = VelocityTracker.withKind(PointerDeviceKind.touch);
    _velocityTracker.addPosition(details.timeStamp, details.position);

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

    _allowAfterScroll = true;

    if(details.pointer == pointerAIdentifier){
      pointerA = details.position;
    }
    else if(details.pointer == pointerBIdentifier){
      pointerB = details.position;
    }

    /// ZOOM
    if(pointerA != null && pointerB != null){

      if(animationTime != 0){
        pointerUp(null);
        return;
      }

      /// calc difference
      double sensibility = ((state.value.zoomArea) / (1500 / sqrt(state.value.zoomArea)));
      final currentPointerDistance = (pointerB!.dx - pointerA!.dx).abs();
      final difference = (lastPointerDistance - currentPointerDistance) * sensibility;
      lastPointerDistance = currentPointerDistance;

      /// Zoom value
      double newCurrentVisibleDays = (state.value.zoomArea + difference).clamp(_minZoomArea, maxVisibleArea).toDouble();

      if(newCurrentVisibleDays == state.value.zoomArea){
        return;
      }

      /// Scroll Position
      double newScrollPosition = state.value.scrollPosition;
      double tempScrollPosition = (state.value.scrollPosition - difference * focalPointPercent);
      tempScrollPosition = tempScrollPosition >= 0? tempScrollPosition : 0;

      if(_minZoomArea < state.value.zoomArea + difference){
        newScrollPosition = tempScrollPosition;
      }
      if(newScrollPosition + newCurrentVisibleDays > totalRangeWithPadding){
        newScrollPosition = totalRangeWithPadding - newCurrentVisibleDays;
      }

      /// Set new values
      updateGraph(
          scrollPosition: newScrollPosition,
          zoomArea: newCurrentVisibleDays
      );
    }

    /// SCROLL
    else if(
      pointerA != null && pointerB == null && pointerAPreviousPos != null &&
      state.value.zoomArea <= totalRangeWithPadding
    ){

      _velocityTracker.addPosition(details.timeStamp, details.position);

      double sensibility = 1/ (state.value.zoomArea / (constraints.maxWidth-widthAxisTitles));
      sensibility = sensibility < 0.1? 0.1 : sensibility > 500? 500 : sensibility;
      final currentPointerDistance = (pointerAPreviousPos!.dx - pointerA!.dx) / sensibility;

      if((pointerAStartPositionForGraphLock!.dx - pointerA!.dx).abs() > allowedMovementForGraphLock){
        lockGraphTimer?.cancel();
        lockGraphTimer = null;
        graphLocked = false;
      }

      /// calc newScrollPosition and limit it to its bounds
      double newScrollPosition = (state.value.scrollPosition + currentPointerDistance).clamp(0, maxScrollPosition);

      /// When the scrollPosition is different from the current one, set it and update Graph
      if(newScrollPosition != state.value.scrollPosition){
        pointerAPreviousPos = Offset(pointerA!.dx, pointerA!.dy);
        updateGraph(
            scrollPosition: newScrollPosition
        );
      }
    }
  }

  void pointerUp(PointerUpEvent? details){
    lockGraphTimer?.cancel();
    lockGraphTimer = null;
    graphLocked = false;
    pointerA = null;
    pointerAPreviousPos = null;
    pointerAIdentifier = null;
    pointerB = null;
    pointerBIdentifier = null;
    _allowAfterScroll = true;

    if(!handleAfterScroll()){
      resetAnimationTime();
    }
  }

  void resetAnimationTime({bool withPostFrameCallBack = true}){
    if(withPostFrameCallBack){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(pointerA == null && pointerB == null){
          animationTime = _defaultAnimationTime;
        }
      });
    }
    else{
      if(pointerA == null && pointerB == null){
        animationTime = _defaultAnimationTime;
      }
    }

    // if(pointerA == null && pointerB == null){
    //   animationTime = _defaultAnimationTime;
    // }
  }

  bool handleAfterScroll() {
    double vel = _velocity;
    const friction = 0.98;

    if (vel.abs() > 0) {
      void tick(Duration timeStamp) {
        vel *= friction;

        final newScrollPos = (state.value.scrollPosition - vel)
            .clamp(0, totalRangeWithPadding - state.value.zoomArea)
            .toDouble();

        // Stoppkriterium
        if (vel.abs() < 0.05 || newScrollPos == state.value.scrollPosition || !_allowAfterScroll) {
          vel = 0;
          resetAnimationTime();
          return;
        }

        updateGraph(scrollPosition: newScrollPos);

        // nächstes Frame planen
        SchedulerBinding.instance.scheduleFrameCallback(tick);
      }

      // erstes Frame starten
      SchedulerBinding.instance.scheduleFrameCallback(tick);
      return true;
    }

    return false;
  }

  // void onDoubleTap(PointerDownEvent details){
  //   if(doubleTapTimer == null){
  //     doubleTapTimer ??= Timer(const Duration(milliseconds: 250), (){
  //       doubleTapTimer = null;
  //     });
  //   }
  //   else if(doubleTapTimer!.isActive && pointerA == null){
  //     zoomTo(details.position.dx);
  //     return;
  //   }
  //   else{
  //     doubleTapTimer?.cancel();
  //     doubleTapTimer = null;
  //   }
  //   pr("------------ DOUBLE TAP");
  // }
  //
  // void zoomTo(double x){
  //   if(x > totalScreenWidth/2){
  //     updateGraph(
  //       scrollPosition: state.value.scrollPosition + 20,
  //       currentVisibleDays: state.value.currentVisibleDays - 50
  //     );
  //   }
  //   else{
  //     updateGraph(
  //         scrollPosition: state.value.scrollPosition - 20,
  //         currentVisibleDays: state.value.currentVisibleDays - 50
  //     );
  //   }
  // }

  void dispose() {
    state.dispose();
  }
}


@immutable
class ScrollZoomState {
  final double scrollPosition;
  final double zoomArea;

  const ScrollZoomState({
    required this.scrollPosition,
    required this.zoomArea,
  });

  ScrollZoomState copyWith({
    double? scrollPosition,
    double? currentVisibleDays,
  }) {
    return ScrollZoomState(
      scrollPosition: scrollPosition ?? this.scrollPosition,
      zoomArea: currentVisibleDays ?? this.zoomArea,
    );
  }

  ScrollZoomState copy() {
    return ScrollZoomState(
      scrollPosition: scrollPosition,
      zoomArea: zoomArea,
    );
  }

  @override
  String toString() {
    return 'ScrollZoomState(offsetMinX: $scrollPosition, currentVisibleDays: $zoomArea)';
  }
}

