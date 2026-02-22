import 'package:fitness_app/screens/other_screens/screen_settings/widgets/settings_icon.dart';
import 'package:fitness_app/service/auth_service.dart';
import 'package:fitness_app/widgets/login_button_dynamic.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_app/l10n/app_localizations.dart';

import '../../../../../../../widgets/custom_navigator.dart';
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

          Widget loginState;

          if(uid == null){
            loginState = Padding(
                padding: const EdgeInsets.all(8.0),
                child: LoginButtonDynamic(onLogin: () => setModalState((){}))
            );
          }
          else{
            loginState = CupertinoListTile(
              onTap: () => CustomNavigator.pushNamed(context, "/profileScreen")?.then((_){
                cnSettings.doRefreshListViewInitialSettings();
                setModalState((){});
              }),
              leading: const SettingsIcon(iconPath: "profile.png"),
              trailing: trailingArrow,
              title: Text(AppLocalizations.of(context)!.profile, style: TextStyle(color: Colors.white)),
            );
          }

          return CupertinoListSection.insetGrouped(
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
                onTap: () => CustomNavigator.pushNamed(context, "/backupScreen")?.then((_) => cnSettings.doRefreshListViewInitialSettings()),
                leading: const SettingsIcon(iconPath: "backups.png"),
                trailing: trailingArrow,
                title: Text(AppLocalizations.of(context)!.settingsBackups, style: const TextStyle(color: Colors.white)),
              ),
              loginState
            ],
          );
      }
    );
  }
}
