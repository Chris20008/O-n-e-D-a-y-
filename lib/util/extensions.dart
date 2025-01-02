import 'package:jiffy/jiffy.dart';

extension DateOnlyCompare on DateTime {

  bool isSameDate(DateTime? other) {
    if(other  == null){
      return false;
    }
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameWeek(DateTime? other){
    if(other  == null){
      return false;
    }
    return Jiffy.parseFromDateTime(other).weekOfYear == Jiffy.parseFromDateTime(this).weekOfYear;
  }

  bool isSameMonth(DateTime? other){
    if(other  == null){
      return false;
    }
    return year == other.year && month == other.month;
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
    final endOfToday = DateTime.now().copyWith(hour: 23, minute: 59, second: 59);
    final lastSevenDays = DateTime.now().subtract(const Duration(days: 7));
    return isAfter(lastSevenDays) && isBefore(endOfToday);
  }

  bool isInFuture(){
    final endOfToday = DateTime.now().copyWith(hour: 23, minute: 59, second: 59);
    return isAfter(endOfToday);
  }

  bool isLeapYear(){
    return (year%4==0 && (year%100!=0 || year%400==0));
  }

  DateTime toDate() {
    return DateTime(year, month, day);
  }
}