import 'package:fitness_app/screens/other_screens/screen_settings/screens/initial_settings_screen/widgets/1_general_settings/general_settings.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/screens/initial_settings_screen/widgets/3_Account/account.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/screens/initial_settings_screen/widgets/4_about_section/about_section.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitness_app/widgets/slide_up_panel/my_slide_up_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_app/l10n/app_localizations.dart';

import '../../../../../widgets/slide_up_panel/panel_header.dart';
import '../../screen_settings.dart';

class InitialSettingsScreen extends StatelessWidget {
  const InitialSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final CnSettings cnSettings = context.read<CnSettings>();
    final _ = context.select<CnSettings, int>((cn) => cn.refreshListViewInitialSettings);

    return Column(
      children: [
        PanelHeader(text: AppLocalizations.of(context)!.settings),
        Expanded(
          child: ListViewScope.of(context).listView(
            physics: const BouncingScrollPhysics(),
            controller: cnSettings.scrollControllerSetting,
            child: const Column(
              children: [

                /// General
                GeneralSettings(),

                /// About
                AboutSection(),

                /// Account
                AccountSection(),

                /// Spacer
                SizedBox(height: 50,)
              ],
            ),
          ),
        )
      ],
    );
  }
}
