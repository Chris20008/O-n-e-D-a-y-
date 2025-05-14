import 'dart:math';

import 'package:flutter/cupertino.dart';

class ScrollZoomStateManager {
  final double minZoomArea;
  final double maxZoomArea;
  final double defaultZoom;
  final double initialZoom;
  double totalRangeWithPadding;
  double leftPaddingGraph;
  bool allowAfterScroll = true;

  final int defaultAnimationTime;

  final ValueNotifier<ScrollZoomState> state;

  ScrollZoomState _previousState;
  int animationTime;


  ScrollZoomStateManager({
    required this.minZoomArea,
    required this.maxZoomArea,
    required this.defaultZoom,
    required this.initialZoom,
    required this.totalRangeWithPadding,
    required this.leftPaddingGraph,
    this.defaultAnimationTime = 500,
  })  : state = ValueNotifier(ScrollZoomState(scrollPosition: 0, zoomArea: initialZoom)),
        _previousState = ScrollZoomState(scrollPosition: 0, zoomArea: initialZoom),
        animationTime = defaultAnimationTime{

    /// initialZoom is the max possible zoom between min and max date
    /// if it's larger than the default zoom, we reduce the current zoom
    /// to default zoom and scroll to the most right position
    if(current.zoomArea > defaultZoom){
      update(
          zoomArea: defaultZoom,
          scrollPosition: scrollPositionZoomedIn
      );
    }

    /// if the currentZoom is larger than it's maximum allowed
    /// we reduce it to it's maximum by resetting the graph and scroll
    /// to the most right position
    if(current.zoomArea > _maxZoomAreaWithPadding){
      resetGraph();
    }

    _previousState = state.value.copy();
  }

  ScrollZoomState get current => state.value;
  double get deltaScroll => _previousState.scrollPosition - current.scrollPosition;

  /// maximum possible zoom are with offset
  double get _maxZoomAreaWithPadding => maxZoomArea + _totalPaddingGraph;

  /// scroll position when zoomed in to default zoom
  double get scrollPositionZoomedIn => (totalRangeWithPadding - defaultZoom).clamp(0, totalRangeWithPadding);

  double get _totalPaddingGraph => leftPaddingGraph * 2;

  void update({
    double? scrollPosition,
    double? zoomArea,
  }) {
    _previousState = state.value;
    state.value = current.copyWith(
      scrollPosition: scrollPosition,
      zoomArea: zoomArea,
    );
  }

  void resetGraph({forceToDefault = false}) {
    resetAnimationTime(immediate: false);
    allowAfterScroll = false;
    _previousState = state.value.copy();

    /// Zoom to max outer position
    double newZoomArea = min(totalRangeWithPadding, _maxZoomAreaWithPadding);
    double scrollPosition = (totalRangeWithPadding - newZoomArea).clamp(0, totalRangeWithPadding);

    /// Zoom to default state
    if(newZoomArea > defaultZoom && (state.value.zoomArea != defaultZoom || forceToDefault)){
      newZoomArea = defaultZoom;
      scrollPosition = scrollPositionZoomedIn;
    }

    update(
        scrollPosition: scrollPosition,
        zoomArea: newZoomArea
    );
  }

  void resetAnimationTime({bool immediate = false}) {
    if (immediate) {
      animationTime = defaultAnimationTime;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        animationTime = defaultAnimationTime;
      });
    }
  }

  void dispose() => state.dispose();
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
    double? zoomArea,
  }) {
    return ScrollZoomState(
      scrollPosition: scrollPosition ?? this.scrollPosition,
      zoomArea: zoomArea ?? this.zoomArea,
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