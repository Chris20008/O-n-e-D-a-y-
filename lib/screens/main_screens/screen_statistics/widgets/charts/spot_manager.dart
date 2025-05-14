import 'package:collection/collection.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/widgets/charts/sz_controller.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/widgets/charts/sz_state_manager.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:fl_chart/fl_chart.dart';

class SpotManager {
  final ScrollZoomStateManager stateManager;
  final double leftPadding;
  DateTime minDate;
  final double weeklyZoomArea;
  final double monthlyZoomArea;
  double totalRange;

  Map<String, List<FlSpot>> _spots = {};
  final String _originalLineNameDefault = "original";
  SpotDetailLevel _spotDetailLevel = SpotDetailLevel.daily;

  SpotManager({
    required this.stateManager,
    required this.leftPadding,
    required this.minDate,
    required this.weeklyZoomArea,
    required this.monthlyZoomArea,
    required this.totalRange,
  });

  double get _minPossibleXCoordinate => -stateManager.current.scrollPosition + leftPadding;
  double get _maxPossibleXCoordinate => totalRange -stateManager.current.scrollPosition + leftPadding;
  double get scrollPositionMinusPadding => stateManager.current.scrollPosition - leftPadding;
  SpotDetailLevel get spotDetailLevel => _spotDetailLevel;

  void addLine({required String key, required List<FlSpot> value}) {
    /// move graph on x-axis according to padding
    value = value.map((spot) => FlSpot(spot.x + leftPadding - stateManager.current.scrollPosition, spot.y)).toList();
    _spots[key] = List.from(value);
    _spots["${_originalLineNameDefault}_$key"] = value;

    handleFlPointReduction(key);
  }

  void handleFlPointReduction(String key){
    /// return if no reduction is needed
    if(stateManager.current.zoomArea <= weeklyZoomArea){
      return;
    }
    /// reduction is not needed for sickDaysSpots and the original Lists
    if (key.contains(_originalLineNameDefault) || key.contains("sickDaysSpots")){
      return;
    }

    /// reset to original spots
    _spots[key] = List.from(_spots['${_originalLineNameDefault}_$key']!);

    double calcNewX(DateTime spot){
      if(_spotDetailLevel == SpotDetailLevel.monthly){
        return calcNewXMonthly(spot);
      }
      return calcNewXWeekly(spot);
    }

    bool isSamePeriod(DateTime first, DateTime second){
      if(_spotDetailLevel == SpotDetailLevel.monthly){
        return first.isSameMonth(second);
      }
      return first.isSameWeek(second);
    }

    stateManager.resetAnimationTime(immediate: true);

    List<FlSpot> newSpots = [];
    List<FlSpot> tempSpots = [];
    DateTime? lastSpotDate;
    int lastIndex = _spots[key]!.length - 1;

    for(var entry in _spots[key]!.asMap().entries){
      final index = entry.key;
      final spot = entry.value;
      final spotsDate = scrollPositionToDateTime(spot.x);
      lastSpotDate ??= spotsDate;

      /// When is same period (either week or month) just add spot
      if(isSamePeriod(lastSpotDate, spotsDate)){
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
    _spots[key] = newSpots;
  }

  void refreshSpots(){
    _spots = _spots.map((key, spots) {
      final shifted = spots.map((spot) => FlSpot(spot.x + stateManager.deltaScroll, spot.y)).toList();
      return MapEntry(key, shifted);
    });

    /// check if reduce spots
    final level = calcSpotDetailLevel();
    /// if level is not daily we need to reduce the spots
    /// but we only reduce if the current _spotDetailLevel != level
    if(level != SpotDetailLevel.daily && _spotDetailLevel != level){
      _spotDetailLevel = level;
      for(String key in _spots.keys){
        handleFlPointReduction(key);
      }
      stateManager.update();
    }
    else if(level == SpotDetailLevel.daily && _spotDetailLevel != level){
      _spotDetailLevel = level;
      for(String key in _spots.keys) {
        if (key.contains(_originalLineNameDefault)) continue;
        _spots[key] = List.from(_spots['${_originalLineNameDefault}_$key']!);
        stateManager.resetAnimationTime(immediate: true);
        // animationTime = _defaultAnimationTime;
      }
      stateManager.update();
    }
  }

  SpotDetailLevel calcSpotDetailLevel(){
    if(stateManager.current.zoomArea > monthlyZoomArea){
      return SpotDetailLevel.monthly;
    }
    if(stateManager.current.zoomArea >weeklyZoomArea){
      return SpotDetailLevel.weekly;
    }
    return SpotDetailLevel.daily;
  }

  double calcNewXMonthly(DateTime spot){
    return (spot.getMidDayOfMonth().differenceSafe(minDate).inDays - stateManager.current.scrollPosition + leftPadding)
        .clamp(_minPossibleXCoordinate, _maxPossibleXCoordinate)
        .toDouble();
  }

  double calcNewXWeekly(DateTime spot){
    return (spot.getMidDayOfWeek().differenceSafe(minDate).inDays - stateManager.current.scrollPosition + leftPadding)
        .clamp(_minPossibleXCoordinate, _maxPossibleXCoordinate)
        .toDouble();
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

  void doAnimateVertical(double startPositionY) async{
    Map<String, List<FlSpot>> tempAllSpots = _spots.map((key, spots) {
      return MapEntry(key, spots);
    });

    _spots = _spots.map((key, spots) {
      final shifted = spots.map((spot) => FlSpot(spot.x + stateManager.deltaScroll, startPositionY)).toList();
      return MapEntry(key, shifted);
    });

    await Future.delayed(const Duration(milliseconds: 100), (){
      _spots = tempAllSpots;
    });

    stateManager.update();
  }

  List<FlSpot> getLine(String key) => _spots[key] ?? [];

  Map<DateTime, double> getLineFormatted(String key){
    final spots = _spots[key]?? [];
    final entries = spots.mapIndexed((index, spot) => MapEntry(
        scrollPositionToDateTime(spot.x).addSafe(Duration(microseconds: index)).toUtcSafe(), /// We add the index as microseconds to prevent loosing entries when having same date
        spot.y
    ));
    return { for (var item in entries) item.key : item.value };
  }

  DateTime scrollPositionToDateTime(double scrollPosition){
    return minDate.addSafe(Duration(days: (scrollPosition + scrollPositionMinusPadding).toInt()));
  }

  double dateTimeToScrollPosition(DateTime date){
    final xPos = date.toDate().differenceSafe(minDate.toDate()).inDays.toDouble();
    return xPos + leftPadding - stateManager.current.scrollPosition;
  }

  void shiftSpotsByScrollDelta() {
    final delta = stateManager.deltaScroll;
    _spots.updateAll((key, value) {
      return value.map((spot) => FlSpot(spot.x + delta, spot.y)).toList();
    });
  }

  void resetSpotDetailLevel(){
    _spotDetailLevel = SpotDetailLevel.daily;
  }
}
