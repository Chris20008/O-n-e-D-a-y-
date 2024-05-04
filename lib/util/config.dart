import 'package:flutter/cupertino.dart';

import 'custom_cache_manager.dart';

class Config{

  bool showIntro;
  Map cnRunningWorkout;
  String? languageCode;
  late CustomCacheManager cache;

  Config({
    this.showIntro = true,
    this.cnRunningWorkout = const {},
    this.languageCode
  }) {
    cache = CustomCacheManager();
    save();
  }

  Map<String, dynamic> toJson() => {
    'showIntro': showIntro,
    "languageCode": languageCode,
    'cnRunningWorkout': cnRunningWorkout
  };

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      showIntro: json['showIntro']?? false,
      languageCode: json['languageCode'],
      cnRunningWorkout: json['cnRunningWorkout']?? {}
    );
  }

  Future<bool> save() async{
    try{
      final json = toJson();
      print("JASON TO CACHE");
      print(json);
      await cache.saveData(json, "config");
      return true;
    } catch (e){
      print("Exception while saving: ${e.toString()}");
      return false;
    }
  }
}


class CnConfig extends ChangeNotifier {
  late CustomCacheManager cache;
  late Config config;
  bool isInitialized = false;

  Future initData() async{
    cache = CustomCacheManager();

    final Map<String, dynamic>? tempConfigData = await cache.readData(fileName: "config");

    print("Received Temp Config Data");
    print(tempConfigData);

    try{
      if(tempConfigData != null){
        config = Config.fromJson(tempConfigData);
      } else {
        config = Config();
      }
    } catch (e){
      config = Config();
    }
    isInitialized = true;

    await config.save();

    refresh();
  }

  void refresh(){
    notifyListeners();
  }

  Future setShowIntro(bool state) async{
    config.showIntro = state;
    await config.save();
  }

  Future setLanguage(String languageCode) async{
    config.languageCode = languageCode;
    await config.save();
  }

  Future setCnRunningWorkout(Map data) async{
    config.cnRunningWorkout = data;
    await config.save();
  }
}