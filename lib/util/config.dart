import 'package:flutter/cupertino.dart';

import 'custom_cache_manager.dart';

class Config{

  // bool showIntro;
  Map cnRunningWorkout;
  Map cnScreenStatistics;
  Map settings;
  // String? languageCode;
  late CustomCacheManager cache;

  Config({
    // this.showIntro = true,
    this.cnRunningWorkout = const {},
    this.cnScreenStatistics = const {},
    this.settings = const {}
    // this.languageCode
  }) {
    cache = CustomCacheManager();
    save();
  }

  Map<String, dynamic> toJson() => {
    // 'showIntro': showIntro,
    // "languageCode": languageCode,
    'cnRunningWorkout': cnRunningWorkout,
    'cnScreenStatistics': cnScreenStatistics,
    'settings': settings
  };

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      // showIntro: json['showIntro']?? false,
      // languageCode: json['languageCode'],
      cnRunningWorkout: json['cnRunningWorkout']?? {},
      cnScreenStatistics: json['cnScreenStatistics']?? {},
      settings: json['settings']?? {}
    );
  }

  Future<bool> save() async{
    try{
      final json = toJson();
      // print("JASON TO CACHE");
      // print(json);
      await cache.saveData(json, "config");
      return true;
    } catch (e){
      // print("Exception while saving: ${e.toString()}");
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

    // print("Received Temp Config Data");
    // print(tempConfigData);

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

  // Future setShowIntro(bool state) async{
  //   config.showIntro = state;
  //   await config.save();
  // }

  get languageCode => config.settings["languageCode"];
  get tutorial => config.settings["tutorial"];
  get automaticBackups => config.settings["automaticBackups"];
  get syncWithCloud => config.settings["syncWithCloud"];


  Future setLanguage(String languageCode) async{
    config.settings["languageCode"] = languageCode;
    await config.save();
  }

  Future setCnRunningWorkout(Map data) async{
    config.cnRunningWorkout = data;
    await config.save();
  }

  Future setTutorial(bool value) async{
    config.settings["tutorial"] = value;
    await config.save();
  }

  Future setAutomaticBackups(bool value) async{
    config.settings["automaticBackups"] = value;
    await config.save();
  }

  Future setSyncWithCloud(bool value) async{
    config.settings["syncWithCloud"] = value;
    await config.save();
  }
}