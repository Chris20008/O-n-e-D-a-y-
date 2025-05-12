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

  final int _offsetZoomArea = 10;
  final double _minZoomArea = 20;
  final double _maxZoomArea = 1200;
  final double _defaultZoomArea = 365;
  final String _originalLineNameDefault = "original";

  final ValueNotifier<ScrollZoomState> state;
  late ScrollZoomState _previousState;
  VelocityTracker _velocityTracker = VelocityTracker.withKind(PointerDeviceKind.touch);

  Timer? lockGraphTimer;
  Timer? doubleTapTimer;
  Timer? afterScrollTimer;
  bool _allowAfterScroll = true;

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
  late double totalRange = maxDate.toDate().difference(minDate.toDate()).inDays.toDouble();
  double widthAxisTitles;
  double totalScreenWidth;
  late DateTime minDate;
  late DateTime maxDate;
  int leftPadding;
  late int totalPadding = leftPadding * 2;
  bool graphIsReduced = false;

  Map<String, List<FlSpot>> allSpots = {};

  ScrollZoomState get current => state.value;
  double get maxVisibleArea => min(_maxZoomArea, (totalRange+totalPadding).toDouble());
  double get totalRangeWithOffset => totalRange + _offsetZoomArea;
  double get _minZoomAreaWithOffset => _minZoomArea + _offsetZoomArea;
  double get _maxZoomAreaWithOffset => _maxZoomArea + _offsetZoomArea;
  double get _defaultZoomAreaWithOffset => _defaultZoomArea + _offsetZoomArea;
  double get _scrollPositionZoomedIn => (totalRangeWithOffset - _defaultZoomArea).clamp(0, totalRangeWithOffset);
  double get deltaScrollPosition => _previousState.scrollPosition - state.value.scrollPosition;
  double get _velocity => _velocityTracker.getVelocity().pixelsPerSecond.dx * 0.00006 * (state.value.zoomArea * 0.5);
  double get maxScrollPosition => totalRange - state.value.zoomArea + totalPadding;

  void addLine({
    required String key,
    required List<FlSpot> value
  }){
    allSpots[key] = List.from(value);
    allSpots["${_originalLineNameDefault}_$key"] = value;
  }

  List<FlSpot> getLine({required String key}) => allSpots[key]?? [];

  Map<DateTime, double> getLineFormatted({required String key}){
    final spots = allSpots[key]?? [];
    final entries = spots.mapIndexed((index, spot) => MapEntry(minDate.add(Duration(days: (spot.x + state.value.scrollPosition).toInt(), microseconds: index)), spot.y));
    return { for (var item in entries) item.key : item.value };
  }

  SZController({
    required this.widthAxisTitles,
    required this.totalScreenWidth,
    required this.leftPadding,
    required this.minDate,
    required this.maxDate
  }) : state = ValueNotifier(
    ScrollZoomState(
      scrollPosition: 0,
      zoomArea: maxDate.difference(minDate).inDays.toDouble() + 10, /// 10 is value of _visibleDayOffset
    ),
  ){
    if(state.value.zoomArea > _defaultZoomArea){
      updateGraph(
        zoomArea: _defaultZoomArea,
        scrollPosition: _scrollPositionZoomedIn
      );
    }
    if(state.value.zoomArea > _maxZoomAreaWithOffset){
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
    // final stopwatch = Stopwatch()..start();
    allSpots = allSpots.map((key, spots) {
      final shifted = spots.map((spot) => FlSpot(spot.x + deltaScrollPosition, spot.y)).toList();
      return MapEntry(key, shifted);
    });

    final reduce = state.value.zoomArea > _defaultZoomArea;
    if(reduce){
      if(graphIsReduced){
        return;
      }
      for(String key in allSpots.keys){
        if (key.contains(_originalLineNameDefault) || key.contains("sickDaysSpots")) continue;
        animationTime = 500;

        List<FlSpot> newSpots = [];
        List<FlSpot> tempSpots = [];
        DateTime? lastSpotDate;
        FlSpot lastSpot = allSpots[key]!.last;

        for(FlSpot spot in allSpots[key]!){
          final spotsDate = minDate.add(Duration(days: (spot.x + state.value.scrollPosition).toInt()));
          lastSpotDate ??= spotsDate;

          if(lastSpotDate.isSameMonth(spotsDate)){
            tempSpots.add(spot);
          }
          else{
            tempSpots.sort((a, b){
              if(a.y > b.y){
                return -1;
              }
              else if(a.y < b.y){
                return 1;
              }
              else if(a.x > b.y){
                return -11;
              }
              return 1;
            });
            FlSpot? maxSpot = tempSpots.firstOrNull;
            if(maxSpot != null){
              final double newX = (lastSpotDate.getMidDayOfMonth().difference(minDate).inDays - state.value.scrollPosition).clamp(-state.value.scrollPosition, totalRangeWithOffset).toDouble();
              maxSpot = FlSpot(newX, maxSpot.y);
              newSpots.addAll(List.generate(tempSpots.length, (_) => maxSpot!));
            }
            tempSpots.clear();
            lastSpotDate = spotsDate;
            tempSpots.add(spot);
          }


          if(spot == lastSpot){
            FlSpot? maxSpot = tempSpots.firstOrNull;
            if(maxSpot != null){
              final double newX = (lastSpotDate.getMidDayOfMonth().difference(minDate).inDays - state.value.scrollPosition).clamp(-state.value.scrollPosition, totalRangeWithOffset).toDouble();
              maxSpot = FlSpot(newX, maxSpot.y);
              newSpots.addAll(List.generate(tempSpots.length, (_) => maxSpot!));
            }
          }
        }
        allSpots[key] = newSpots;
      }
      graphIsReduced = true;
      updateGraph();
    }
    else if(graphIsReduced){
      graphIsReduced = false;
      for(String key in allSpots.keys) {
        if (key.contains(_originalLineNameDefault)) continue;
        allSpots[key] = List.from(allSpots['${_originalLineNameDefault}_$key']!);
        animationTime = 500;
      }
      updateGraph();
    }
  }

  void resetGraph({
    doubleUpdate = false
  }) {
    resetAnimationTime(withPostFrameCallBack: false);
    _allowAfterScroll = false;
    _previousState = state.value.copy();

    /// Zoom to max outer position
    double newZoomArea = min(totalRangeWithOffset, _maxZoomAreaWithOffset);
    double scrollPosition = (totalRangeWithOffset - newZoomArea).clamp(0, totalRangeWithOffset);

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
    totalRange = this.maxDate.toDate().difference(this.minDate.toDate()).inDays.toDouble();
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

    // if(doubleTapTimer == null){
    //   doubleTapTimer ??= Timer(const Duration(milliseconds: 250), (){
    //     doubleTapTimer = null;
    //   });
    // }
    // else if(doubleTapTimer!.isActive && pointerA == null){
    //   onDoubleTap(details);
    //   return;
    // }
    // else{
    //   doubleTapTimer?.cancel();
    //   doubleTapTimer = null;
    // }

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
      if(newScrollPosition + newCurrentVisibleDays > totalRangeWithOffset){
        newScrollPosition = totalRangeWithOffset - newCurrentVisibleDays;
      }

      // _velocityTracker = VelocityTracker.withKind(PointerDeviceKind.touch);

      /// Set new values
      updateGraph(
          scrollPosition: newScrollPosition,
          zoomArea: newCurrentVisibleDays
      );
    }

    /// SCROLL
    else if(
      pointerA != null && pointerB == null && pointerAPreviousPos != null &&
      state.value.zoomArea <= totalRangeWithOffset
    ){

      _velocityTracker.addPosition(details.timeStamp, details.position);

      final maxValueOffsetMinX = maxScrollPosition;
      double sensibility = 1/ (state.value.zoomArea / (constraints.maxWidth-widthAxisTitles));
      sensibility = sensibility < 0.1? 0.1 : sensibility > 500? 500 : sensibility;
      final currentPointerDistance = (pointerAPreviousPos!.dx - pointerA!.dx) / sensibility;

      if((pointerAStartPositionForGraphLock!.dx - pointerA!.dx).abs() > allowedMovementForGraphLock){
        lockGraphTimer?.cancel();
        lockGraphTimer = null;
        graphLocked = false;
      }

      double newOffsetMinX;

      newOffsetMinX = state.value.scrollPosition + currentPointerDistance;
      if(newOffsetMinX < 0 && state.value.scrollPosition != 0){
        updateGraph(
            scrollPosition: 0
        );
      }
      else if(newOffsetMinX > maxValueOffsetMinX && state.value.scrollPosition != maxValueOffsetMinX){
        updateGraph(
            scrollPosition: maxValueOffsetMinX
        );
      }
      else if(newOffsetMinX >= 0 && newOffsetMinX != state.value.scrollPosition && (newOffsetMinX <= maxValueOffsetMinX || newOffsetMinX <= state.value.scrollPosition)){
        pointerAPreviousPos = Offset(pointerA!.dx, pointerA!.dy);
        updateGraph(
            scrollPosition: newOffsetMinX
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
      // /// Small delay to allow UI to be drawn at least once and after that reset the animation time back to allow animations
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   if(pointerA == null && pointerB == null){
      //     animationTime = 500;
      //   }
      // });
    }
  }

  void resetAnimationTime({bool withPostFrameCallBack = true}){
    if(withPostFrameCallBack){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(pointerA == null && pointerB == null){
          animationTime = 500;
        }
      });
    }
    else{
      if(pointerA == null && pointerB == null){
        animationTime = 500;
      }
    }

    // if(pointerA == null && pointerB == null){
    //   animationTime = 500;
    // }
  }

  bool handleAfterScroll() {
    double vel = _velocity;
    const friction = 0.98;

    if (vel.abs() > 0) {
      void tick(Duration timeStamp) {
        vel *= friction;

        final newScrollPos = (state.value.scrollPosition - vel)
            .clamp(0, totalRangeWithOffset - state.value.zoomArea)
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
  //   zoomTo(details.position.dx);
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

