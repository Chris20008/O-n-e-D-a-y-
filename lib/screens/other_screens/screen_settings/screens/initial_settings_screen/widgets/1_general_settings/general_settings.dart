import 'package:fitness_app/util/language_config.dart';
import 'package:fitness_app/widgets/selectors/select_language_button.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fitness_app/assets/custom_icons/my_icons_icons.dart';
import 'package:provider/provider.dart';

import '../../../../screen_settings.dart';

class GeneralSettings extends StatelessWidget {

  const GeneralSettings({super.key});

  @override
  Widget build(BuildContext context) {

    final CnSettings cnSettings = context.read<CnSettings>();
    final CnScreenStatistics cnScreenStatistics = context.read<CnScreenStatistics>();
    final CnConfig cnConfig = context.read<CnConfig>();

    return CupertinoListSection.insetGrouped(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor
      ),
      backgroundColor: Colors.transparent,
      header: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(AppLocalizations.of(context)!.settingsGeneral, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w300),),
      ),
      children: [
        /// Language
        CupertinoListTile(
            leading:  const Icon(
              Icons.language,
              color: Colors.white,
            ),
            title: SelectLanguageButton(
                cnConfig: cnConfig,
                buttonChild: Row(
                  children: [
                    Text(
                        AppLocalizations.of(context)!.settingsLanguage,
                        style: const TextStyle(color: Colors.white)
                    ),
                    const Spacer(),
                    Text(
                      getLanguageAsString(context),
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(width: 6,),
                    trailingChoice()
                  ],
                )
            )
        ),
        /// Tutorial
        CupertinoListTile(
          onTap: (){
            if(currentTutorialStep != 0){
              showCupertinoModalPopup<void>(
                context: context,
                builder: (BuildContext context) => CupertinoActionSheet(
                  cancelButton: getActionSheetCancelButton(
                      context,
                      text: AppLocalizations.of(context)!.yes,
                      onPressed: (){
                        cnConfig.setCurrentTutorialStep(0);
                        currentTutorialStep = 0;
                        tutorialIsRunning = false;
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!.settingsTutorialHasBeenReset,
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.SNACKBAR,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.grey[800]?.withValues(alpha: 0.9),
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                  ),
                  title: Column(
                    children: [
                      Text("${AppLocalizations.of(context)!.settingsTutorialReset}?", textScaler: const TextScaler.linear(1.2)),
                    ],
                  ),
                  actions: <CupertinoActionSheetAction>[
                    CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      isDefaultAction: false,
                      child: Text(AppLocalizations.of(context)!.no, style: cupButtonTextStyleOnlyFontSize),
                    ),
                  ],
                ),
              );
            }
          },
          leading: const Icon(
            Icons.school,
            color: Colors.white,
          ),
          trailing: trailingArrow,
          title: Text(AppLocalizations.of(context)!.settingsTutorialReset, style: const TextStyle(color: Colors.white)),
        ),
        /// Connect to Spotify
        CupertinoListTile(
          leading: const Icon(
            MyIcons.spotify,
            color: Colors.white,
            // color: Color(0xff1ed560)
          ),
          title: Row(
            children: [
              Text(AppLocalizations.of(context)!.settingsConnectSpotify, style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 5),
              if(cnConfig.useSpotify)
                FutureBuilder(
                    future: cnConfig.isSpotifyInstalled(delayMilliseconds: 800, context: context),
                    builder: (context, connected){
                      if(!connected.hasData){
                        return Center(
                          child: SizedBox(
                            height: 15,
                            width: 15,
                            child: CupertinoActivityIndicator(
                                radius: 8.0,
                                color: Colors.amber[800]
                            ),
                            // child: CircularProgressIndicator(strokeWidth: 2,)
                          ),
                        );
                      }
                      return Icon(
                        connected.data == true
                            ? Icons.check_circle
                            : Icons.close,
                        size: 15,
                        color: connected.data == true
                            ? Colors.green
                            : Colors.red,
                      );
                    }
                )
            ],
          ),
          trailing: CupertinoSwitch(
              value: cnConfig.useSpotify,
              activeTrackColor: activeColor,
              onChanged: (value) async{
                if(Platform.isAndroid){
                  HapticFeedback.selectionClick();
                }
                await cnConfig.setSpotify(value);
                cnSettings.refresh();

              }
          ),
        ),

        /// Use Health Data
        CupertinoListTile(
          leading: Stack(
            children: [
              Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(6)
                ) ,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Icon(
                      MyIcons.heart,
                      color: Colors.black.withValues(alpha: 0.8),
                      size: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: Row(
            children: [
              Text(Platform.isIOS? "Apple Health" : "Health", style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 5),
              if(cnConfig.useHealthData)
                FutureBuilder(
                    future: cnConfig.isHealthDataAccessAllowed(cnScreenStatistics),
                    builder: (context, connected){
                      if(!connected.hasData){
                        return Center(
                          child: SizedBox(
                            height: 15,
                            width: 15,
                            child: CupertinoActivityIndicator(
                                radius: 8.0,
                                color: Colors.amber[800]
                            ),
                            // child: CircularProgressIndicator(strokeWidth: 2,)
                          ),
                        );
                      }
                      return Icon(
                        connected.data == true
                            ? Icons.check_circle
                            : Icons.close,
                        size: 15,
                        color: connected.data == true
                            ? Colors.green
                            : Colors.red,
                      );
                    }
                )
            ],
          ),
          trailing: CupertinoSwitch(
              value: cnConfig.useHealthData,
              activeTrackColor: activeColor,
              onChanged: (value) async{
                if(Platform.isAndroid){
                  HapticFeedback.selectionClick();
                }
                cnConfig.setHealth(value);
                cnSettings.refresh();
                await cnConfig.isHealthDataAccessAllowed(cnScreenStatistics);
                if(!value){
                  await Future.delayed(const Duration(milliseconds: 500), (){
                    cnScreenStatistics.health.revokePermissions();
                    cnScreenStatistics.refreshData(context);
                    cnScreenStatistics.refresh();
                  });
                }
                else{
                  await cnScreenStatistics.refreshHealthData().then((value){
                    if(value){
                      cnScreenStatistics.selectedExerciseName = AppLocalizations.of(context)!.statisticsWeight;
                      cnScreenStatistics.refreshData(context);
                      cnScreenStatistics.refresh();
                    }
                    else{
                      notificationPopUp(
                          context: context,
                          title: AppLocalizations.of(context)!.accessDenied,
                          message: AppLocalizations.of(context)!.accessDeniedHealth
                      );
                    }
                  });
                }
              }
          ),
        ),
      ],
    );
  }
}
