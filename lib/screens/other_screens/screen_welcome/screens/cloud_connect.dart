import 'package:fitness_app/screens/other_screens/screen_settings/screen_settings.dart';
import 'package:fitness_app/widgets/slide_up_panel/initial_animated_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/slide_up_panel/animation_controller_name.dart';
import '../../screen_settings/panels/explain_backup_panel.dart';
import '../../screen_settings/screens/backups_screen/widgets/connect_with_cloud.dart';

class ConnectCloud extends StatelessWidget {
  const ConnectCloud({super.key});

  @override
  Widget build(BuildContext context) {

    final CnSettings cnSettings = context.read<CnSettings>();
    final buttonWidth = MediaQuery.of(context).size.width * 0.8;
    const buttonHeight = 50.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          InitialAnimatedScreen(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            animationControllerName: AnimationControllerName.screenWelcome,
            child: Stack(
              alignment: Alignment.center,
              children: [

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100,),
                    SizedBox(
                      height: 180,
                        child: Image.asset("lib/assets/pictures/brogy_connect_cloud.png")
                    ),
                    SizedBox(height: 20,),
                    SizedBox(
                      width: 300,
                      child: const Text(
                        "Deine Daten. Immer sicher",
                        textScaler: TextScaler.linear(2.2),
                        textAlign: TextAlign.center,
                        // style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 30,),
                    SizedBox(
                      width: 350,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "Ob mit oder ohne Account - sichere deine Fortschritte automatisch in Google Drive.",
                          textScaler: const TextScaler.linear(1.1),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),

                /// Buttons
                Positioned(
                    bottom: 150,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Sync with iCloud
                        Container(
                            height: buttonHeight,
                            decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(15)
                            ),
                            width: buttonWidth,
                            child: const ConnectWithCloud()
                        ),

                        CupertinoButton(
                            onPressed: () => Navigator.pushNamed(context, "/connectSpotify"),
                            child: Container(
                              height: buttonHeight,
                              width: buttonWidth,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFF9A19),
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              child: const Center(
                                  child: Text(
                                      "Weiter",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600
                                      ),
                                      textScaler: TextScaler.linear(1.1)
                                  )
                              ),
                            )
                        ),
                      ],
                    )
                ),
                Positioned(
                  bottom: 20,
                  child: SizedBox(
                    width: buttonWidth,
                    child: CupertinoButton(
                      sizeStyle: CupertinoButtonSize.small,
                      padding: EdgeInsets.zero,
                      onPressed: () async{
                        HapticFeedback.selectionClick();
                        cnSettings.openPanelExplainBackups();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.info,
                            size:12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5,),
                          Text(
                              AppLocalizations.of(context)!.settingsBackupMoreInfo,
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300
                              )
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          StatefulBuilder(
            builder: (context, setModalState) {
              return PopScope(
                  canPop: cnSettings.panelControllerExplainBackups.isAttached? cnSettings.panelControllerExplainBackups.panelPosition <= 0.1 : true,
                  onPopInvokedWithResult: (_, __) async{
                    if(cnSettings.panelControllerExplainBackups.panelPosition > 0.99){
                      await cnSettings.panelControllerExplainBackups.close();
                      // setModalState((){});
                    }
                  },
                  child: ExplainBackupPanel(
                    // reducedView: true,
                    onPanelSlide: (value){
                        if(value == 1 || value == 0){
                          setModalState((){});
                        }
                    },
                  )
              );
            }
          )
        ],
      ),
    );
  }
}