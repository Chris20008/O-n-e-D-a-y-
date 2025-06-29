import 'package:fitness_app/main.dart';
import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';

import '../../service/database_service/collection.dart';
import '../../service/sync_manager.dart';
import '../constants.dart';
import 'abstract_class_firebase_object.dart';
import 'mixin_checksum.dart';

@Entity()
class ObSickDays with Checksum implements FirebaseObject {

  /// Id properties
  @override
  @Id()
  int id;
  @override
  String uuid;

  /// Indexed Fields
  @override
  @Index()
  String checksum;

  /// Data Fields
  @Property(type: PropertyType.date)
  DateTime startDate;

  @Property(type: PropertyType.date)
  DateTime endDate;

  @override
  @Property(type: PropertyType.date)
  DateTime? lastUpdated;

  /// Constructor
  ObSickDays({
    this.id = 0,
    this.uuid = '-1',
    this.checksum = '-1',
    required this.startDate,
    required this.endDate,
    this.lastUpdated,
  }){
    if(uuid == "-1" || uuid.isEmpty) {
      uuid = const Uuid().v4();
    }

    updateLastUpdated();
  }

  ObSickDays.fromMap({required Map<String, dynamic> sickDaysMap, bool withId = false}): this(
      id: withId? sickDaysMap["id"]?? 0 : 0,
      startDate: DateTime.parse(sickDaysMap["startDate"]),
      endDate: DateTime.parse(sickDaysMap["endDate"]),
      uuid: sickDaysMap["uuid"]?? "-1",
      checksum: sickDaysMap["checksum"]?? "-1",
      lastUpdated: sickDaysMap["lastUpdated"] != null
          ? DateTime.parse(sickDaysMap["lastUpdated"])
          : null,
  );

  @override
  ObSickDays firebaseObjectConstructor(Map<String, dynamic> map){
    return ObSickDays.fromMap(sickDaysMap: map);
  }

  @override
  Future save({bool onlyLocal = false}) async{
    updateLastUpdated();
    final oldChecksum = checksum;
    final newId = objectbox.sickDaysBox.put(this);
    final newSickDay = objectbox.sickDaysBox.get(newId);

    if(newSickDay != null){
      newSickDay.updateChecksum();
      objectbox.sickDaysBox.putAsync(newSickDay);
      pr("Old Checksum $oldChecksum");
      pr("New Checksum ${newSickDay.checksum}");
      pr("");
      if(newSickDay.checksum != oldChecksum && !onlyLocal){
        await CnSyncManager.database?.addCollectionObject(ob: newSickDay, oldChecksum: oldChecksum);
      }
    }
  }

  void updateLastUpdated(){
    lastUpdated = DateTime.now();
  }

  void updateChecksum(){
    checksum = currentChecksum;
  }

  Future delete() async{
    objectbox.sickDaysBox.remove(id);
    await CnSyncManager.database?.deleteCollectionObject(ob: this);
  }

  bool isNewSickDays(){
    return id == 0;
  }

  @override
  Map<String, dynamic> asMap({bool withChecksum = false}){
    final result = {
      "id": id,
      "uuid": uuid,
      "startDate": startDate.toString(),
      "endDate": endDate.toString(),
      "lastUpdated": lastUpdated.toString(),
    };
    if(withChecksum){
      result["checksum"] = currentChecksum;
    }
    return result;
  }

  @override
  String get checksumString {
    final buffer = StringBuffer();

    buffer.write(uuid);
    buffer.write(startDate.toString());
    buffer.write(endDate.toString());

    return buffer.toString();
  }

  @override
  Collection get collection => Collection.sickDays;
}