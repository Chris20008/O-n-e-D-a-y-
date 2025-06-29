class ServerChecksums{
  final List<String> workoutChecksums;
  final List<String> sickDayChecksums;
  final DateTime workoutChecksumsLastUpdated;
  final DateTime sickDayChecksumsLastUpdated;

  ServerChecksums({
    required this.workoutChecksums,
    required this.sickDayChecksums,
    DateTime? workoutChecksumsLastUpdated,
    DateTime? sickDayChecksumsLastUpdated
  }) :
        workoutChecksumsLastUpdated = workoutChecksumsLastUpdated?? DateTime(1970),
        sickDayChecksumsLastUpdated = sickDayChecksumsLastUpdated?? DateTime(1970);
}