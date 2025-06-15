import 'package:fitness_app/service/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fitness_app/assets/custom_icons/my_icons_icons.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginSection extends StatelessWidget {
  const LoginSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

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
        StreamBuilder(
          stream: authService.authStateChanges(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.active){
              CupertinoButton(
                  child: const Text("Logout"),
                  onPressed: () => authService.signOut()
              );
            }
            return SignInWithAppleButton(
                onPressed: () => authService.signInWithApple()
            );
          }
        )
        /// Login
        // CupertinoListTile(
        //   onTap: () async{
        //     await openUrl("https://chris20008.github.io/O-n-e-D-a-y-Info/terms-of-use");
        //   },
        //   trailing: trailingArrow,
        //   title: SignInWithAppleButton(onPressed: (){}),
        // ),
      ],
    );
  }
}
