import 'package:fitness_app/util/backup_functions.dart';
import 'package:fitness_app/util/ios_channel.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'custom_cache_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  bool isWaitingForCloudResponse = false;
  bool isWaitingForSpotifyResponse = false;
  bool failedSpotifyConnection = false;
  bool showMoreSettingCloud = false;
  bool? isICloudAvailable;
  GoogleSignInAccount? account;
  String? folderIdGoogleDrive;
  String? currentDataIdGoogleDrive;

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

  // Future<bool> checkIfICloudAvailable() async {
  //   if(!connectWithCloud){
  //     return false;
  //   }
  //
  //   if(isICloudAvailable == null){
  //     isWaitingForCloudResponse = true;
  //     final res = await ICloudService.isICloudAvailable();
  //     await Future.delayed(const Duration(milliseconds: 1000), (){});
  //     isICloudAvailable = res;
  //     showMoreSettingCloud = isICloudAvailable!;
  //     if(!isICloudAvailable!){
  //       await setConnectWithCloud(false);
  //     }
  //     isWaitingForCloudResponse = false;
  //     refresh();
  //   } else {
  //     await Future.delayed(const Duration(milliseconds: 1000), (){});
  //     showMoreSettingCloud = isICloudAvailable!;
  //     if(!isICloudAvailable!){
  //       await setConnectWithCloud(false);
  //     }
  //   }
  //
  //   // while(isWaitingForCloudResponse){
  //   //   await Future.delayed(const Duration(milliseconds: 200));
  //   //   if(!isWaitingForCloudResponse){
  //   //     return isICloudAvailable?? false;
  //   //   }
  //   // }
  //
  //
  //   return isICloudAvailable ?? false;
  // }

  Future<bool> checkIfICloudAvailable() async {
    while(isWaitingForCloudResponse){
      await Future.delayed(const Duration(milliseconds: 200));
      if(!isWaitingForCloudResponse){
        return isICloudAvailable!;
      }
    }
    if(isICloudAvailable == null && Platform.isIOS){
      isWaitingForCloudResponse = true;
      isICloudAvailable = await ICloudService.isICloudAvailable();
      print("IS Cloud Available: $isICloudAvailable");
      await Future.delayed(const Duration(milliseconds: 1000), (){});
      isWaitingForCloudResponse = false;
      showMoreSettingCloud = true;

      /// If the connection failed we immediately set the sync value to false
      /// but give a small delay to show the failed connection to the user
      if(isICloudAvailable == false && !isWaitingForCloudResponse){
        revokeConnectCloud();
        await setConnectWithCloud(false);
        Future.delayed(const Duration(seconds: 1), ()async{
          refresh();
        });
      }
      else{
        Future.delayed(const Duration(milliseconds: 100), ()async{
          refresh();
        });
      }
    }
    return isICloudAvailable?? false;
  }

  Future<bool> signInGoogleDrive() async {
    while(isWaitingForCloudResponse){
      await Future.delayed(const Duration(milliseconds: 200));
      if(!isWaitingForCloudResponse){
        return account != null;
      }
    }
    if(account == null && Platform.isAndroid){
      isWaitingForCloudResponse = true;
      account = await getGoogleDriveAccount();
      await Future.delayed(const Duration(milliseconds: 1000), (){});
      isWaitingForCloudResponse = false;
      showMoreSettingCloud = true;

      /// If the connection failed we immediately set the sync value to false
      /// but give a small delay to show the failed connection to the user
      print("ACCOUNT: ${account?.id}");
      if(account == null && !isWaitingForCloudResponse){
        await setConnectWithCloud(false);
        showMoreSettingCloud = false;
        Future.delayed(const Duration(seconds: 1), ()async{
          refresh();
        });
      }
      else{
        Future.delayed(const Duration(milliseconds: 100), ()async{
          refresh();
        });
      }
    }
    return account != null;
  }

  void revokeConnectCloud(){
    account = null;
    isICloudAvailable = null;
    showMoreSettingCloud = false;
  }

  Future<bool> isSpotifyInstalled({int delayMilliseconds = 0, int secondsDelayMilliseconds = 1500, BuildContext? context}) async{
    isWaitingForSpotifyResponse = true;
    await Future.delayed(Duration(milliseconds: delayMilliseconds));
    final result = await canLaunchUrl(Uri.parse("spotify:"));
    isWaitingForSpotifyResponse = false;
    /// If the connection failed we immediately set the useSpotify value to false
    /// but give a small delay to show the failed connection to the user
    if(result != true && !isWaitingForSpotifyResponse){
      failedSpotifyConnection = true;
      Fluttertoast.cancel();
      Fluttertoast.showToast(
          msg: context != null? AppLocalizations.of(context)!.spotifyPleaseInstall : "Please install Spotify to use this function",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[800],
          textColor: Colors.white,
          fontSize: 16.0
      );
      await setSpotify(false);
      Future.delayed(Duration(milliseconds: secondsDelayMilliseconds), ()async{
        refresh();
      });
    } else if(failedSpotifyConnection){
      failedSpotifyConnection = false;
      refresh();
    }
    return result;
  }

  Future<Map<String, String>?> getGoogleDriveAuthHeaders() async{
    return await account?.authHeaders;
  }

  void refresh(){
    notifyListeners();
  }

  String? get languageCode => config.settings["languageCode"];
  bool get tutorial => config.settings["tutorial"]?? true;
  bool get welcomeScreen => config.settings["welcomeScreen"]?? true;
  bool get automaticBackups => config.settings["automaticBackups"]?? true;
  bool get connectWithCloud => config.settings["connectWithCloud"]?? false;
  bool get saveBackupCloud => (config.settings["saveBackupCloud"]?? true) && connectWithCloud;
  bool get syncMultipleDevices => (config.settings["syncMultipleDevices"]?? false) && connectWithCloud;
  int? get countdownTime => config.settings["countdownTime"];
  bool get useSpotify => config.settings["useSpotify"]?? false;
  int get currentTutorialStep => config.settings["currentTutorialStep"]?? 0;
  String? get lastBackupName => config.settings["lastBackupName"];

  Future setLastBackupName(String filename) async{
    config.settings["lastBackupName"] = filename;
    await config.save();
  }

  Future setCurrentTutorialStep(int? step) async{
    config.settings["currentTutorialStep"] = step;
    await config.save();
  }

  Future setCountdownTime(int? time) async{
    config.settings["countdownTime"] = time;
    await config.save();
  }

  Future setSpotify(bool value) async{
    config.settings["useSpotify"] = value;
    await config.save();
  }

  Future setSpotifyInstalled(bool value) async{
    config.settings["isSpotifyInstalled"] = value;
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

  Future setWelcomeScreen(bool value) async{
    config.settings["welcomeScreen"] = value;
    await config.save();
  }

  Future setAutomaticBackups(bool value) async{
    config.settings["automaticBackups"] = value;
    await config.save();
  }

  Future setConnectWithCloud(bool value) async{
    config.settings["connectWithCloud"] = value;
    await config.save();
  }

  Future setSyncMultipleDevices(bool value) async{
    print("Set Sync Multiple Devices: $value");
    config.settings["syncMultipleDevices"] = value;
    print(syncMultipleDevices);
    await config.save();
  }

  Future setSaveBackupCloud(bool value) async{
    config.settings["saveBackupCloud"] = value;
    await config.save();
  }
}