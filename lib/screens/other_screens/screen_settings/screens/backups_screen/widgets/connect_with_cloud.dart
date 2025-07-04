import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../util/config.dart';
import '../../../../../../util/constants.dart';
import '../../../widgets/settings_icon.dart';

class ConnectWithCloud extends StatelessWidget {
  const ConnectWithCloud({super.key});

  @override
  Widget build(BuildContext context) {

    final CnConfig cnConfig = context.watch<CnConfig>();

    return StatefulBuilder(
        builder: (context, setModalState){
          return CupertinoListTile(
            leading: const SettingsIcon(iconPath: "connect_icloud.png"),
            trailing: CupertinoSwitch(
                value: cnConfig.connectWithCloud,
                activeTrackColor: activeColor,
                onChanged: (value)async{
                  if(Platform.isAndroid){
                    HapticFeedback.selectionClick();
                  }
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
                // crossAxisAlignment: CrossAxisAlignment.end,
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
                  if(!cnConfig.connectWithCloud)
                    const SizedBox(width: 15),
                  if(cnConfig.connectWithCloud)
                    FutureBuilder(
                        future: Platform.isAndroid? cnConfig.signInGoogleDrive() : cnConfig.checkIfICloudAvailable(),
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
                            cnConfig.account != null || (cnConfig.isICloudAvailable?? false)
                                ? Icons.check_circle
                                : Icons.close,
                            size: 15,
                            color: cnConfig.account != null || (cnConfig.isICloudAvailable?? false)
                                ? Colors.green
                                : Colors.red,
                          );
                        }
                    )
                ],
              ),
            ),
          );
        }
    );
  }
}
