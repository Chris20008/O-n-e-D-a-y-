import 'dart:async';
import 'dart:math';
import 'package:fitness_app/screens/main_screens/screen_statistics/widgets/charts/spot_manager.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/widgets/charts/sz_state_manager.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class SZController{

  final double _minZoomArea = 20;
  final double _maxZoomArea = 1200;
  final double _defaultZoomArea = 364;
  final double _weeklyZoomArea = 150;
  final double _monthlyZoomArea = 365;


  late final ScrollZoomStateManager stateManager;
  late final SpotManager spotManager;

  VelocityTracker _velocityTracker = VelocityTracker.withKind(PointerDeviceKind.touch);

  /// Gesture Variables
  Timer? lockGraphTimer;
  Timer? doubleTapTimer;
  Timer? afterScrollTimer;
  bool graphLocked = false;
  Offset? pointerA;
  Offset? pointerAPreviousPos;
  Offset? pointerAStartPositionForGraphLock;
  Offset? pointerB;
  int? pointerAIdentifier;
  int? pointerBIdentifier;
  double lastPointerDistance = 0;
  double focalPointPercent = 0;
  int allowedMovementForGraphLock = 4;

  double widthAxisTitles;
  double totalScreenWidth;
  late DateTime minDate;

  late DateTime maxDate;

  double get totalRange => maxDate.toDate().differenceSafe(minDate.toDate()).inDays.toDouble();

  double get _leftPaddingGraph {
    if (totalRange < 15) return 1;
    if (totalRange < 40) return 2;
    if (totalRange < 80) return 5;
    if (totalRange < 200) return 10;
    return 15;
  }

  double get _totalPaddingGraph => _leftPaddingGraph * 2;

  double get maxVisibleArea => min(_maxZoomArea, (totalRange+_totalPaddingGraph).toDouble());

  /// range between minDate and maxDate plus the offset
  double get totalRangeWithPadding => totalRange + _totalPaddingGraph;

  /// calculated velocity of last current scroll
  double get _velocity => _velocityTracker.getVelocity().pixelsPerSecond.dx * 0.00006 * (stateManager.current.zoomArea * 0.5);

  /// maximum possible scroll position
  double get maxScrollPosition => totalRange - stateManager.current.zoomArea + _totalPaddingGraph;

  double get leftPaddingGraph => _leftPaddingGraph;

  SZController({
    required this.widthAxisTitles,
    required this.totalScreenWidth,
    required this.minDate,
    required this.maxDate
  }) {

    stateManager = ScrollZoomStateManager(
      minZoomArea: _minZoomArea,
      maxZoomArea: _maxZoomArea,
      defaultZoom: _defaultZoomArea,
      initialZoom: maxDate.differenceSafe(minDate).inDays.toDouble() + _totalPaddingGraph,
      leftPaddingGraph: _leftPaddingGraph,
      totalRangeWithPadding: totalRangeWithPadding
    );

    spotManager = SpotManager(
      stateManager: stateManager,
      leftPaddingGraph: _leftPaddingGraph,
      minDate: minDate,
      weeklyZoomArea: _weeklyZoomArea,
      monthlyZoomArea: _monthlyZoomArea,
      totalRange: totalRange
    );
  }

  void updateConfig({
    double? widthAxisTitles,
    double? totalScreenWidth,
    DateTime? minDate,
    DateTime? maxDate,
    bool forceToDefault = false
  }){
    this.widthAxisTitles = widthAxisTitles?? this.widthAxisTitles;
    this.totalScreenWidth = totalScreenWidth?? this.totalScreenWidth;
    this.minDate = minDate?? this.minDate;
    this.maxDate = maxDate?? this.maxDate;

    /// Update Managers
    stateManager.totalRangeWithPadding = totalRangeWithPadding;
    stateManager.leftPaddingGraph = _leftPaddingGraph;

    spotManager.minDate = minDate?? spotManager.minDate;
    spotManager.totalRange = totalRange;
    spotManager.leftPaddingGraph = _leftPaddingGraph;

    resetGraph(forceToDefault: forceToDefault);
  }

  void update({
    double? scrollPosition,
    double? zoomArea,
  }) {
    stateManager.update(
      scrollPosition: scrollPosition,
      zoomArea: zoomArea
    );
    spotManager.refreshSpots();
  }

  void resetGraph({forceToDefault = false}){
    stateManager.resetGraph(forceToDefault: forceToDefault);
    spotManager.refreshSpots();
  }

  void pointerDown(PointerDownEvent details){
    afterScrollTimer?.cancel();
    stateManager.allowAfterScroll = false;
    if(stateManager.current.scrollPosition != 0 || totalRange > stateManager.current.zoomArea){
      lockGraphTimer ??= Timer(const Duration(milliseconds: 250), (){
        graphLocked = true;
        HapticFeedback.selectionClick();
      });
    }

    // onDoubleTap(details);

    _velocityTracker = VelocityTracker.withKind(PointerDeviceKind.touch);
    _velocityTracker.addPosition(details.timeStamp, details.position);

    stateManager.animationTime = 0;
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

    stateManager.allowAfterScroll = false;

    if(details.pointer == pointerAIdentifier){
      pointerA = details.position;
    }
    else if(details.pointer == pointerBIdentifier){
      pointerB = details.position;
    }

    /// ZOOM
    if(pointerA != null && pointerB != null){

      if(stateManager.animationTime != 0){
        pointerUp(null);
        return;
      }

      /// Zoom is not possible if _minZoomArea >= maxVisibleArea
      if(_minZoomArea >= maxVisibleArea){
        return;
      }

      /// calc difference
      double sensibility = ((stateManager.current.zoomArea) / (300 / pow(stateManager.current.zoomArea, 0.1)));
      final currentPointerDistance = (pointerB!.dx - pointerA!.dx).abs();
      final difference = (lastPointerDistance - currentPointerDistance) * sensibility;
      lastPointerDistance = currentPointerDistance;

      /// Zoom value
      double newZoomArea = (stateManager.current.zoomArea + difference).clamp(_minZoomArea, maxVisibleArea).toDouble();

      if(newZoomArea == stateManager.current.zoomArea){
        return;
      }

      /// Scroll Position
      double newScrollPosition = stateManager.current.scrollPosition;
      double tempScrollPosition = (stateManager.current.scrollPosition - difference * focalPointPercent);
      tempScrollPosition = tempScrollPosition >= 0? tempScrollPosition : 0;

      if(_minZoomArea < stateManager.current.zoomArea + difference){
        newScrollPosition = tempScrollPosition;
      }
      if(newScrollPosition + newZoomArea > totalRangeWithPadding){
        newScrollPosition = totalRangeWithPadding - newZoomArea;
      }

      /// Set new values
      update(
          scrollPosition: newScrollPosition,
          zoomArea: newZoomArea
      );
    }

    /// SCROLL
    else if(
      pointerA != null && pointerB == null && pointerAPreviousPos != null &&
          stateManager.current.zoomArea <= totalRangeWithPadding
    ){
      stateManager.animationTime = 0;
      _velocityTracker.addPosition(details.timeStamp, details.position);

      double sensibility = 1/ (stateManager.current.zoomArea / (constraints.maxWidth-widthAxisTitles));
      sensibility = sensibility < 0.1? 0.1 : sensibility > 500? 500 : sensibility;
      final currentPointerDistance = (pointerAPreviousPos!.dx - pointerA!.dx) / sensibility;

      if((pointerAStartPositionForGraphLock!.dx - pointerA!.dx).abs() > allowedMovementForGraphLock){
        lockGraphTimer?.cancel();
        lockGraphTimer = null;
        graphLocked = false;
      }

      /// calc newScrollPosition and limit it to its bounds
      double newScrollPosition = (stateManager.current.scrollPosition + currentPointerDistance).clamp(0, maxScrollPosition);

      /// When the scrollPosition is different from the current one, set it and update Graph
      if(newScrollPosition != stateManager.current.scrollPosition){
        pointerAPreviousPos = Offset(pointerA!.dx, pointerA!.dy);
        update(
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
    stateManager.allowAfterScroll = true;

    if(!handleAfterScroll()){
      stateManager.resetAnimationTime();
    }
  }

  bool handleAfterScroll() {
    double vel = _velocity;
    const friction = 0.98;

    if (vel.abs() > 0) {
      void tick(Duration timeStamp) {
        vel *= friction;

        final newScrollPos = (stateManager.current.scrollPosition - vel)
            .clamp(0, totalRangeWithPadding - stateManager.current.zoomArea)
            .toDouble();

        // Stoppkriterium
        if (vel.abs() < 0.05 || newScrollPos == stateManager.current.scrollPosition || !stateManager.allowAfterScroll) {
          vel = 0;
          if(pointerA == null){
            stateManager.resetAnimationTime();
          }
          return;
        }

        update(scrollPosition: newScrollPos);

        // nächstes Frame planen
        SchedulerBinding.instance.scheduleFrameCallback(tick);
      }

      // erstes Frame starten
      SchedulerBinding.instance.scheduleFrameCallback(tick);
      return true;
    }

    return false;
  }

  void dispose() {
    stateManager.dispose();
  }
}


enum SpotDetailLevel{
  daily ("daily"),
  weekly ("weekly"),
  monthly ("monthly");

  const SpotDetailLevel(this.value);
  final String value;
}