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

  int numOfDaysTillLastDayOfMonth(){
    return DateTime(year, month+1, 0).difference(this).inDays + 1;
  }

  int numOfDaysTillFirstDayOfMonth(){
    return toDate().difference(DateTime(year, month, 1)).inDays + 1;
  }

  int numOfDaysOfMonth(){
    return DateTime(year, month+1, 0).difference(DateTime(year, month, 1)).inDays + 1;
  }

  List<DateTime> getDatesBetween(DateTime other, {bool onlySameMonth = true}){
    int length = 0;

    if(onlySameMonth && !isSameMonth(other)){
      if(isBefore(other)){
        length = -numOfDaysTillLastDayOfMonth();
      }
      else if(isAfter(other)){
        length = numOfDaysTillFirstDayOfMonth();
      }
    }
    else{
      length = toDate().difference(other.toDate()).inDays;
      if(length < 0){
        length -= 1;
      }
      else if(length > 0){
        length += 1;
      }
    }
    length = length * -1;
    final result = List.generate(length.abs(), (index) => (DateTime(year, month, day).add(Duration(days: index * (length >= 0? 1 : -1), hours: 1)).toDate()));
    return result;
  }
}

extension List_E on List {
  List getDuplicates(){
    List dupes = List.from(this);
    Set dupes2 = Set.from(this);
    for (var element in dupes2) {
      dupes.remove(element);
    }
    return dupes;
  }
}