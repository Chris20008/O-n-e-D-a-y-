import 'package:fitness_app/util/backup_functions.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'custom_cache_manager.dart';

class Config{

  Map cnRunningWorkout;
  Map cnScreenStatistics;
  Map settings;
  late CustomCacheManager cache;

  Config({
    Map? cnRunningWorkout,
    Map? cnScreenStatistics,
    Map? settings
  }) :  cnRunningWorkout = cnRunningWorkout ?? {},
        cnScreenStatistics = cnScreenStatistics ?? {},
        settings = settings ?? {}
  {
    cache = CustomCacheManager();
    save();
  }

  Map<String, dynamic> toJson() => {
    'cnRunningWorkout': cnRunningWorkout,
    'cnScreenStatistics': cnScreenStatistics,
    'settings': settings
  };

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
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
  GoogleSignInAccount? account;

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

  Future<bool> signInGoogleDrive() async {
    if(account == null && Platform.isAndroid){
      account = await getGoogleDriveAccount();
      await Future.delayed(const Duration(milliseconds: 1000), (){});
    }
    return account != null;
  }

  Future<Map<String, String>?> getGoogleDriveAuthHeaders() async{
    return await account?.authHeaders;
  }

  void refresh(){
    notifyListeners();
  }

  // Future setShowIntro(bool state) async{
  //   config.showIntro = state;
  //   await config.save();
  // }

  String? get languageCode => config.settings["languageCode"];
  bool get tutorial => config.settings["tutorial"]?? true;
  bool get automaticBackups => config.settings["automaticBackups"]?? true;
  bool get syncWithCloud => config.settings["syncWithCloud"]?? false;
  int? get countdownTime => config.settings["countdownTime"];

  Future setCountdownTime(int? time) async{
    config.settings["countdownTime"] = time;
    await config.save();
  }

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