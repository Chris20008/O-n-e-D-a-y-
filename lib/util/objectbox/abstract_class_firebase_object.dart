import '../../service/database_service/collection.dart';

abstract class FirebaseObject{
  DateTime? lastUpdated;
  late int id;
  late String uuid;
  late String checksum;

  String get currentChecksum;
  Collection get collection;

  Future save();

  Map<String, dynamic> asMap({bool withChecksum});

  FirebaseObject? firebaseObjectConstructor(Map<String, dynamic> map);

}