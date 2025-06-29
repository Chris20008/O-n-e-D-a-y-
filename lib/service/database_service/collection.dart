import 'package:cloud_firestore/cloud_firestore.dart';

enum Collection{
  workouts,
  sickDays;

  Map<String, dynamic> get asMap {
    switch (this) {
      case Collection.workouts:
        return {"sickDayChecksums": "trainer", "sickDayChecksumsLastUpdated": ["edit", "view"]};
      case Collection.sickDays:
        return {"role": "athlete", "permissions": ["view"]};
    }
  }

  Map<String, dynamic> checksumMap(String checksum, FieldValue Function(List<dynamic>) value){
    if(this == Collection.workouts){
      return {
        "workoutChecksums": value([checksum]),
        "workoutChecksumsLastUpdated": Timestamp.fromDate(DateTime.now())
      };
    }

    return {
      "sickDayChecksums": value([checksum]),
      "sickDayChecksumsLastUpdated": Timestamp.fromDate(DateTime.now())
    };
  }
}