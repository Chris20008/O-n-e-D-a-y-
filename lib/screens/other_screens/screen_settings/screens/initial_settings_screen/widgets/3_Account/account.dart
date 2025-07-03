import 'package:fitness_app/screens/other_screens/screen_settings/widgets/settings_icon.dart';
import 'package:fitness_app/service/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../screen_settings.dart';

class AccountSection extends StatelessWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context) {

    final CnSettings cnSettings = context.read<CnSettings>();
    final authService = AuthService();

    return StatefulBuilder(
        builder: (context, setModalState) {
          final String? uid = authService.getUid();

          Widget? loginState;

          if(uid == null){
            loginState = Padding(
              padding: const EdgeInsets.all(8.0),
              child: SignInWithAppleButton(
                  onPressed: () async => await authService.signInWithApple().then((_) => setModalState((){}))
              ),
            );
          }
          else{
            loginState = CupertinoListTile(
             onTap: () async => await authService.signOut().then((_) => setModalState((){})),
             // leading: const Icon(Icons.logout, color: Colors.white),
            leading: const SettingsIcon(iconPath: "logout.png"),
             trailing: trailingArrow,
             title: Text(AppLocalizations.of(context)!.settingsLogout, style: const TextStyle(color: Colors.white)),
           );
          }

          Widget child = CupertinoListSection.insetGrouped(
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor
            ),
            backgroundColor: Colors.transparent,
            header: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(AppLocalizations.of(context)!.settingsAccount, style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w300),),
            ),
            children: [
              CupertinoListTile(
                onTap: () => cnSettings.navigatorKey.currentState?.pushNamed("/backupScreen").then((_) => cnSettings.doRefreshListViewInitialSettings()),
                // leading: Icon(MyIcons.shield_alt, color: Colors.white),
                leading: const SettingsIcon(iconPath: "backups.png"),
                trailing: trailingArrow,
                title: Text(AppLocalizations.of(context)!.settingsBackups, style: const TextStyle(color: Colors.white)),
              ),
              loginState
            ],
          );

          return child;
      }
    );
  }
}
