import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
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

  DateTime getMidDayOfMonth(){
    return DateTime(year, month, 15);
  }

  DateTime getMidDayOfWeek() {
    int delta = DateTime.wednesday - weekday;

    return addSafe(Duration(days: delta));
  }

  DateTime getFirstDayOfWeek() {
    int delta = DateTime.monday - weekday;

    return addSafe(Duration(days: delta));
  }

  DateTime getLastDayOfWeek() {
    int delta = DateTime.sunday - weekday;

    return addSafe(Duration(days: delta));
  }

  String formatAsFirstLastDayOfWeek(BuildContext context){
    return "${DateFormat("d.MMM", Localizations.localeOf(context).languageCode).format(getFirstDayOfWeek())} - ${DateFormat("d.MMM", Localizations.localeOf(context).languageCode).format(getLastDayOfWeek())}";
  }

  Duration differenceSafe(DateTime other){
    return toUtcSafe().difference(other.toUtcSafe());
  }

  DateTime addSafe(Duration d){
    return toUtcSafe().add(d).toLocal();
  }

  DateTime subtractSafe(Duration d){
    return toUtcSafe().subtract(d).toLocal();
  }

  DateTime round(){
    DateTime current = toUtc();
    if(current.hour > 12){
      current = current.add(const Duration(hours: 13)).copyWith(hour: 0);
    } else if(current.hour <= 12){
      current = current.copyWith(hour: 0);
    }
    return current;
  }

  DateTime toUtcSafe(){
    return DateTime.utc(year, month, day, hour, minute, second, millisecond, microsecond);
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

  String toStringDateTime(){
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    return "${twoDigits(day)}."
        "${twoDigits(month)}."
        "$year  "
        "${twoDigits(hour)}:"
        "${twoDigits(minute)}";
  }
}

extension ListExtension on List {
  List getDuplicates(){
    List dupes = List.from(this);
    Set dupes2 = Set.from(this);
    for (var element in dupes2) {
      dupes.remove(element);
    }
    return dupes;
  }

  List without(List l){
    return whereNot((e) => l.contains(e)).toList();
  }
}

extension StringExtensions on String{
  bool startsWithLatinLetter(){
    if (length == 0) return false;

    String char = this[0];

    final normalized = char.toLowerCase().normalizeGermanUmlauts();

    return normalized.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
        normalized.codeUnitAt(0) <= 'z'.codeUnitAt(0);
  }

  String normalizeGermanUmlauts({bool trimmed = false}) {
    if(trimmed){
      return replaceAll('ä', 'a')
          .replaceAll('ö', 'o')
          .replaceAll('ü', 'u')
          .replaceAll('Ä', 'A')
          .replaceAll('Ö', 'O')
          .replaceAll('Ü', 'U');
    }
    return replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('Ä', 'Ae')
        .replaceAll('Ö', 'Oe')
        .replaceAll('Ü', 'Ue');
  }
}