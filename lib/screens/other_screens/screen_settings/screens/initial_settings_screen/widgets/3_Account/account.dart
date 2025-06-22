import 'package:fitness_app/service/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../../../../assets/custom_icons/my_icons_icons.dart';
import '../../../../screen_settings.dart';

class AccountSection extends StatelessWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context) {

    final CnSettings cnSettings = context.read<CnSettings>();

    final AuthService authService = AuthService();

    return StreamBuilder(
        stream: authService.authStateChanges(),
        builder: (context, snapshot) {

          Widget? loginState;

          if(snapshot.connectionState == ConnectionState.active){
            final user = snapshot.data;

            if(user == null){
              loginState = Padding(
                padding: const EdgeInsets.all(8.0),
                child: SignInWithAppleButton(
                    onPressed: () => authService.signInWithApple()
                ),
              );
            }

            else{
              loginState = CupertinoListTile(
               onTap: () => authService.signOut(),
               leading: const Icon(Icons.logout, color: Colors.white),
               trailing: trailingArrow,
               title:const Text("Logout", style: TextStyle(color: Colors.white)),
             );
            }
          }
          else{
            loginState = CupertinoListTile(
              onTap: () {},
              title: Center(
                child: CupertinoActivityIndicator(
                    radius: 8.0,
                    color: Colors.amber[800]
                ),
              ),
            );
          }

          Widget child = CupertinoListSection.insetGrouped(
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor
            ),
            backgroundColor: Colors.transparent,
            header: const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text("Account", style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w300),),
            ),
            children: [
              CupertinoListTile(
                onTap: () => cnSettings.navigatorKey.currentState?.pushNamed("/backupScreen").then((_) => cnSettings.doRefreshListViewInitialSettings()),
                leading: Icon(MyIcons.shield_alt, color: Colors.white),
                trailing: trailingArrow,
                title:const Text("Backups", style: TextStyle(color: Colors.white)),
              ),
              loginState
            ],
          );

          return child;
      }
    );
  }
}
