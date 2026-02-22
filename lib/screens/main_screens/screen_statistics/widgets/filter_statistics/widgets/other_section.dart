import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fitness_app/l10n/app_localizations.dart';


class OtherSection extends StatelessWidget {
  const OtherSection({super.key});

  @override
  Widget build(BuildContext context) {
    CnScreenStatistics cnScreenStatistics = context.read<CnScreenStatistics>();

    return CupertinoListSection.insetGrouped(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor
      ),
      backgroundColor: Colors.transparent,
      header: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(AppLocalizations.of(context)!.other, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w300),),
      ),
      children: [
        StatefulBuilder(
            builder: (context, setModalState){
            return CupertinoListTile(
                title: OverflowSafeText(
                    maxLines: 1,
                    AppLocalizations.of(context)!.filterOnlyWorkingSets,
                    style: const TextStyle(color: Colors.white)
                ),
                trailing: CupertinoSwitch(
                    value: cnScreenStatistics.onlyWorkingSets,
                    activeTrackColor: activeColor,
                    onChanged: (value){
                      setModalState(() {
                        if(Platform.isAndroid){
                          HapticFeedback.selectionClick();
                        }
                        cnScreenStatistics.onlyWorkingSets = value;
                      });
                    }
                )
            );
          }
        ),
      ],
    );
  }
}
