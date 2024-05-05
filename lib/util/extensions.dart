import 'package:jiffy/jiffy.dart';

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isToday() {
    final today = DateTime.now();
    return year == today.year && month == today.month && day == today.day;
  }

  bool isYesterday() {
    final today = DateTime.now().subtract(const Duration(days: 1));
    return year == today.year && month == today.month && day == today.day;
  }

  bool isInLastSevenDays(){
    final lastSevenDays = DateTime.now().subtract(const Duration(days: 7));
    return isAfter(lastSevenDays);
  }

  bool isSameMonth(DateTime other){
    return year == other.year && month == other.month;
  }

  bool isSameWeek(DateTime other){
    return Jiffy.parseFromDateTime(other).weekOfYear == Jiffy.parseFromDateTime(this).weekOfYear;
  }
}