import 'package:fitness_app/widgets/slide_up_panel/my_slide_up_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../widgets/slide_up_panel/animation_controller_name.dart';
import '../screen_settings.dart';

class ExplainBackupPanel extends StatelessWidget {

  const ExplainBackupPanel({super.key,});

  @override
  Widget build(BuildContext context) {

    final CnSettings cnSettings = context.read<CnSettings>();

    return MySlideUpPanel(
      controller: cnSettings.controllerExplainBackups,
      animationControllerName: AnimationControllerName.explainBackups,
      descendantAnimationControllerName: AnimationControllerName.screenSettings,
      panelBuilder: (context, listView){
        return Column(
          children: [
            const SizedBox(height: 10,),
            // panelTopBar,
            const SizedBox(height: 10,),
            Expanded(
              child: listView(
                padding: EdgeInsets.zero,
                controller: cnSettings.scrollControllerExplainBackups,
                children: [
                  CupertinoListTile(
                    leading: const Icon(
                      Icons.upload,
                      color: Colors.white,
                    ),
                    title: OverflowSafeText(
                        maxLines: 1,
                        AppLocalizations.of(context)!.settingsBackupSaveManual,
                        style: const TextStyle(color: Colors.white)
                    ),
                  ),
                  Padding(padding: const EdgeInsets.only(left: 30, right: 15) ,child: Text(AppLocalizations.of(context)!.settingsBackupSaveManualExplanation)),
                  const SizedBox(height: 15),

                  /// Load Backup
                  CupertinoListTile(
                    leading: const Icon(
                      Icons.download,
                      color: Colors.white,
                    ),
                    title: Text(AppLocalizations.of(context)!.settingsBackupLoad, style: const TextStyle(color: Colors.white)),
                  ),
                  Padding(padding: const EdgeInsets.only(left: 30, right: 15) ,child: Text(AppLocalizations.of(context)!.settingsBackupLoadExplanation)),
                  const SizedBox(height: 15),

                  getBackupDialogWelcomeScreen(context: context)
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
