import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fitness_app/l10n/app_localizations.dart';

class GraphSection extends StatelessWidget {
  const GraphSection({super.key});

  @override
  Widget build(BuildContext context) {
    CnScreenStatistics cnScreenStatistics = context.read<CnScreenStatistics>();

    return StatefulBuilder(
        builder: (context, setModalState){
        return CupertinoListSection.insetGrouped(
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor
          ),
          backgroundColor: Colors.transparent,
          header: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text("Graph", style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w300),),
          ),
          children: [
            CupertinoListTile(
              title: OverflowSafeText(
                  maxLines: 1,
                  AppLocalizations.of(context)!.statisticsFilter1RM,
                  style: const TextStyle(color: Colors.white)
              ),
              trailing: CupertinoSwitch(
                  value: cnScreenStatistics.showOneRepMax,
                  activeTrackColor: activeColor,
                  onChanged: (value){
                    setModalState(() {
                      if(Platform.isAndroid){
                        HapticFeedback.selectionClick();
                      }
                      cnScreenStatistics.showOneRepMax = value;
                    });
                  }
              ),
            ),

            CupertinoListTile(
              title: OverflowSafeText(
                  maxLines: 2,
                  AppLocalizations.of(context)!.filterAvgMovWeightHead,
                  style: const TextStyle(color: Colors.white)
              ),
              trailing: CupertinoSwitch(
                  value: cnScreenStatistics.showAvgWeightPerSetLine,
                  activeTrackColor: activeColor,
                  onChanged: (value){
                    setModalState(() {
                      if(Platform.isAndroid){
                        HapticFeedback.selectionClick();
                      }
                      cnScreenStatistics.showAvgWeightPerSetLine = value;
                    });
                  }
              ),
            ),
            CupertinoListTile(
                title: OverflowSafeText(
                    maxLines: 1,
                    AppLocalizations.of(context)!.statisticsFilterSickDays,
                    style: const TextStyle(color: Colors.white)
                ),
                trailing: CupertinoSwitch(
                    value: cnScreenStatistics.showSickDays,
                    activeTrackColor: activeColor,
                    onChanged: (value){
                      setModalState(() {
                        if(Platform.isAndroid){
                          HapticFeedback.selectionClick();
                        }
                        cnScreenStatistics.showSickDays = value;
                      });
                    }
                )
            ),
          ],
        );
      }
    );
  }
}
