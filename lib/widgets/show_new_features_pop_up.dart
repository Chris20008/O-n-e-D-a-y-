import 'package:fitness_app/assets/custom_icons/my_icons_icons.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/widgets/cupertino_button_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future showNewFeaturesPopUp({
  required BuildContext context,
  required CnScreenStatistics cnScreenStatistics,
  required CnConfig cnConfig
}) async{
  await showModalBottomSheet(
      constraints: null,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context){
        return StatefulBuilder(
            builder: (context, setModalState) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Container(
                    width: double.maxFinite,
                    height: MediaQuery.of(context).size.height - (Platform.isAndroid? 50 : 70),
                    color: Theme.of(context).primaryColor,
                    child: Stack(
                      children: [
                        ListView(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            children:[
                              const SizedBox(height: 40),
                              CupertinoListSection.insetGrouped(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor
                                ),
                                backgroundColor: Colors.transparent,
                                header: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(AppLocalizations.of(context)!.settingsGeneral, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w300),),
                                ),
                                children: [
                                  Container(
                                    width: double.maxFinite,
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        listSection(AppLocalizations.of(context)!.new1),
                                        listSection(AppLocalizations.of(context)!.new2),
                                        listSection(AppLocalizations.of(context)!.new3),
                                        listSection(AppLocalizations.of(context)!.new4),
                                        listSection(AppLocalizations.of(context)!.new5),
                                        listSection(AppLocalizations.of(context)!.new6),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              CupertinoListSection.insetGrouped(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor
                                ),
                                backgroundColor: Colors.transparent,
                                header: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(AppLocalizations.of(context)!.new7, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w300),),
                                ),
                                children: [
                                  Container(
                                    width: double.maxFinite,
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        listSection(AppLocalizations.of(context)!.new8),
                                        listSection(AppLocalizations.of(context)!.new9),
                                        listSection(AppLocalizations.of(context)!.new10),
                                        /// Use Health Data
                                        CupertinoListTile(
                                          padding: EdgeInsets.zero,
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
                                                child: const Padding(
                                                  padding: EdgeInsets.all(2),
                                                  child: Align(
                                                    alignment: Alignment.topRight,
                                                    child: Icon(
                                                      MyIcons.heart,
                                                      color: Colors.red,
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
                                              activeColor: activeColor,
                                              onChanged: (value) async{
                                                setModalState(() {
                                                  if(Platform.isAndroid){
                                                    HapticFeedback.selectionClick();
                                                  }
                                                  cnConfig.setHealth(value);
                                                });
                                                await cnConfig.isHealthDataAccessAllowed(cnScreenStatistics);
                                                if(!value){
                                                  await Future.delayed(const Duration(milliseconds: 500), (){
                                                    cnScreenStatistics.health.revokePermissions();
                                                    setModalState(() {});
                                                  });
                                                }
                                                else{
                                                  await cnScreenStatistics.refreshHealthData().then((value){
                                                    setModalState(() {
                                                      if(value){
                                                        cnScreenStatistics.selectedExerciseName = AppLocalizations.of(context)!.statisticsWeight;
                                                      }
                                                      else{
                                                        notificationPopUp(
                                                            context: context,
                                                            title: AppLocalizations.of(context)!.accessDenied,
                                                            message: AppLocalizations.of(context)!.accessDeniedHealth
                                                        );
                                                      }
                                                    });
                                                  });
                                                }
                                              }
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              CupertinoListSection.insetGrouped(
                                decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor
                                ),
                                backgroundColor: Colors.transparent,
                                header: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(AppLocalizations.of(context)!.new11, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w300),),
                                ),
                                children: [
                                  Container(
                                    width: double.maxFinite,
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        listSection(AppLocalizations.of(context)!.new12),
                                        listSection(AppLocalizations.of(context)!.new13),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 30,)
                            ]
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          width: double.maxFinite,
                          height: 50,
                          color: Theme.of(context).primaryColor,
                          child: Stack(
                            children: [
                              Center(child: Text(AppLocalizations.of(context)!.newVersion, textScaler: const TextScaler.linear(1.3),)),
                              Align(
                                alignment: Alignment.centerRight,
                                child: CupertinoButtonText(
                                    text: AppLocalizations.of(context)!.close,
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    }
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                ),
              );
            }
        );
      }
  );
}

Widget listSection(String text){
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text("• "),
        Expanded(
          child: Text(text, textScaler: const TextScaler.linear(1.15),),
        ),
      ],
    ),
  );
}