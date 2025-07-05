import 'dart:io';
import 'package:fitness_app/widgets/cupertino_switch_future.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../util/config.dart';
import '../../../../../../util/constants.dart';
import '../../../widgets/settings_icon.dart';

class ConnectWithCloud extends StatelessWidget {
  final EdgeInsets? padding;

  const ConnectWithCloud({
    super.key,
    this.padding
  });

  @override
  Widget build(BuildContext context) {

    final CnConfig cnConfig = context.watch<CnConfig>();

    return StatefulBuilder(
        builder: (context, setModalState){
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CupertinoListTile(
                padding: padding,
                leading: SettingsIcon(iconPath: Platform.isAndroid? "google_drive.png" : "connect_icloud.png"),
                trailing: CupertinoSwitchFuture(
                    initialState: cnConfig.connectWithCloud,
                    future: ()async{
                      if(cnConfig.connectWithCloud){
                        return Platform.isAndroid? await cnConfig.signInGoogleDrive() : await cnConfig.checkIfICloudAvailable();
                      }
                      return false;
                    },
                    onSwitch: (value)async{
                      if(!value){
                        await cnConfig.revokeConnectCloud();
                      }
                      cnConfig.setConnectWithCloud(value);
                      setModalState((){});
                    }
                ),
                title: Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: OverflowSafeText(
                          maxLines: 1,
                          Platform.isAndroid
                              ? AppLocalizations.of(context)!.settingsConnectGoogleDrive
                              : AppLocalizations.of(context)!.settingsConnectiCloud,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
    );
  }
}
