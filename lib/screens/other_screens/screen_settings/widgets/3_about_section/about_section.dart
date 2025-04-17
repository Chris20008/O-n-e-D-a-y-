import 'package:fitness_app/screens/other_screens/screen_settings/widgets/3_about_section/widgets/selector_contact_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fitness_app/assets/custom_icons/my_icons_icons.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor
      ),
      backgroundColor: Colors.transparent,
      header: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(AppLocalizations.of(context)!.settingsAbout, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w300),),
      ),
      children: [
        /// Contact
        const CupertinoListTile(
          leading: Icon(
            Icons.help_outline,
            color: Colors.white,
          ),
          title: SelectorContactButton(),
        ),
        /// Github
        CupertinoListTile(
          onTap: () async{
            await openUrl("https://github.com/Chris20008/O-n-e-D-a-y-");
          },
          leading: const Icon(
            MyIcons.github_circled,
            color: Colors.white,
          ),
          trailing: trailingArrow,
          title: Text(AppLocalizations.of(context)!.settingsContribute, style: const TextStyle(color: Colors.white)),
        ),
        /// Term Of Use
        CupertinoListTile(
          onTap: () async{
            await openUrl("https://github.com/Chris20008/O-n-e-D-a-y-/blob/master/TERMS%20OF%20USE.md#terms-of-use");
          },
          leading: const Icon(
            Icons.my_library_books_rounded,
            color: Colors.white,
          ),
          trailing: trailingArrow,
          title: Text(AppLocalizations.of(context)!.settingsTermsOfUse, style: const TextStyle(color: Colors.white)),
        ),
        /// Privacy Policy
        CupertinoListTile(
          onTap: () async{
            await openUrl("https://github.com/Chris20008/O-n-e-D-a-y-/blob/master/PRIVACY%20POLICY.md#privacy-policy");
          },
          leading: const Icon(
            Icons.lock_outline,
            color: Colors.white,
          ),
          trailing: trailingArrow,
          title: Text(AppLocalizations.of(context)!.settingsPrivacyPolicy, style: const TextStyle(color: Colors.white)),
        ),
        /// Imprint
        CupertinoListTile(
          onTap: () async{
            await openUrl("https://github.com/Chris20008/O-n-e-D-a-y-/blob/master/IMPRINT.md#imprint");
          },
          leading: const Text("§", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 18)),
          trailing: trailingArrow,
          title: Text(AppLocalizations.of(context)!.settingsImprint, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
