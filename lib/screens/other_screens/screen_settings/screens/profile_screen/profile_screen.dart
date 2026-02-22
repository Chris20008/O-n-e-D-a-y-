import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitness_app/l10n/app_localizations.dart';

import '../../../../../util/constants.dart';
import '../../../../../widgets/custom_navigator.dart';
import '../../../../../widgets/slide_up_panel/my_slide_up_panel.dart';
import '../../../../../widgets/slide_up_panel/panel_header.dart';
import '../../widgets/settings_icon.dart';
import 'functions/show_delete_account_dialog.dart';
import 'functions/choose_logout_option.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          PanelHeader(text: AppLocalizations.of(context)!.profile),
          Expanded(
            child: ListViewScope.of(context).listView(
              physics: const BouncingScrollPhysics(),
              controller: ScrollController(),
              child: CupertinoListSection.insetGrouped(
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor
                ),
                backgroundColor: Colors.transparent,
                // header: Padding(
                //   padding: const EdgeInsets.only(left: 10),
                //   child: Text(AppLocalizations.of(context)!.settingsAccount, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w300),),
                // ),
                children: [
                  CupertinoListTile(
                    // onTap: () async => await authService.signOut().then((_) => cnSettings.navigatorKey.currentState?.pop()),
                    onTap: () => chooseLogoutOption(context),
                    leading: const SettingsIcon(iconPath: "logout.png"),
                    trailing: trailingArrow,
                    title: Text(AppLocalizations.of(context)!.settingsLogout, style: const TextStyle(color: Colors.white)),
                  ),
                  CupertinoListTile(
                    onTap: () => showDeleteAccountDialog(context, () => CustomNavigator.pop(context)),
                    leading: const SettingsIcon(iconPath: "delete_account.png"),
                    trailing: trailingArrow,
                    title: Text(AppLocalizations.of(context)!.deleteAccount1, style: const TextStyle(color: Colors.white)),
                  )
                ],
              )
            ),
          )
        ],
      ),
    );
  }
}
