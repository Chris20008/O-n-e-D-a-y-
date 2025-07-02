import 'dart:io';
import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/util/CupertinoSwitchFuture.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitness_app/util/config.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../../../../../util/constants.dart';
import '../../../../../widgets/settings_icon.dart';

class CupertinoListTileSwitchHealth extends StatefulWidget {
  const CupertinoListTileSwitchHealth({super.key});

  @override
  State<CupertinoListTileSwitchHealth> createState() => _CupertinoListTileSwitchHealthState();
}

class _CupertinoListTileSwitchHealthState extends State<CupertinoListTileSwitchHealth> {

  late CnConfig cnConfig;
  late CnScreenStatistics cnScreenStatistics;
  int delayMilliseconds = 300;

  @override
  Widget build(BuildContext context) {

    cnConfig = context.read<CnConfig>();
    cnScreenStatistics = context.read<CnScreenStatistics>();

    return CupertinoListTile(
      leading: const SettingsIcon(iconPath: "apple_health.png"),
      title:  Text(Platform.isIOS? "Apple Health" : "Health", style: const TextStyle(color: Colors.white)),
      trailing: CupertinoSwitchFuture(
        initialState: cnConfig.useHealthData,
        future: (targetState) async{
          final result = await cnConfig.isHealthDataAccessAllowed(cnScreenStatistics, targetState: targetState);
          if(!result && targetState && context.mounted){
            notificationPopUp(
                context: context,
                title: AppLocalizations.of(context)!.accessDenied,
                message: AppLocalizations.of(context)!.accessDeniedHealth
            );
          }
          return result;
        }
      ),
    );
  }
}
