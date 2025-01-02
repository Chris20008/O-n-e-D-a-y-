import 'package:fitness_app/main.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class ObSickDays{
  @Id()
  int id;

  @Property(type: PropertyType.date)
  DateTime startDate;
  DateTime endDate;

  ObSickDays({
    this.id = 0,
    required this.startDate,
    required this.endDate
  });

  ObSickDays.fromMap({required Map sickDaysMap, bool withId = false}): this(
      id: withId? sickDaysMap["id"]?? 0 : 0,
      startDate: DateTime.parse(sickDaysMap["startDate"]),
      endDate: DateTime.parse(sickDaysMap["endDate"])
  );

  void save(){
    objectbox.sickDaysBox.put(this);
  }

  void delete(){
    objectbox.sickDaysBox.remove(id);
  }

  Map asMap(){
    final result = {
      "id": id,
      "startDate": startDate.toString(),
      "endDate": endDate.toString(),
    };
    return result;
  }
}