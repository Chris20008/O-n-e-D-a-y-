import 'package:fitness_app/screens/other_screens/screen_settings/screens/initial_settings_screen/widgets/1_general_settings/widgets/switch_health.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/screens/initial_settings_screen/widgets/1_general_settings/widgets/switch_spotify.dart';
import 'package:fitness_app/screens/other_screens/screen_settings/widgets/settings_icon.dart';
import 'package:fitness_app/util/language_config.dart';
import 'package:fitness_app/widgets/selectors/select_language_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class GeneralSettings extends StatelessWidget {

  const GeneralSettings({super.key});

  @override
  Widget build(BuildContext context) {

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
            leading: const SettingsIcon(iconPath: "language.png"),
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

        /// Use Spotify
        const CupertinoListTileSwitchSpotify(),

        /// Use Health Data
        const CupertinoListTileSwitchHealth(),

      ],
    );
  }
}
