import 'dart:io';

import 'package:fitness_app/widgets/login_button_dynamic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:fitness_app/l10n/app_localizations.dart';

import '../../../../../../service/auth_service.dart';
import '../../../../../../util/constants.dart';
import '../../../../../../util/sign_in_with_google_button.dart';
import '../../../../../../widgets/custom_navigator.dart';
import '../../../../screen_settings/widgets/settings_icon.dart';
import '../../../screen_welcome.dart';

class LoginState extends StatefulWidget {

  const LoginState({super.key});

  @override
  State<LoginState> createState() => _LoginStateState();
}

class _LoginStateState extends State<LoginState> {

  final AuthService authService = AuthService();
  late final buttonWidth = MediaQuery.of(context).size.width * ScreenWelcome.buttonWidthPercent;
  final buttonHeight = ScreenWelcome.buttonHeight;
  final EdgeInsets buttonPadding = ScreenWelcome.buttonPadding;
  bool isLoading = false;

  late Widget loginButton = Platform.isAndroid
      ? SignInWithGoogleButton(onPressed: () async => await handleLogin(authService.signInWithGoogle))
      : SignInWithAppleButton(onPressed: () async => await handleLogin(authService.signInWithApple));

  Future handleLogin(Future Function() login) async{
    setState(() => isLoading = true);
    await login();
    // await Future.delayed(const Duration(milliseconds: 1000));
    setState(() => isLoading = false);
  }

  Widget defaultSizedBox({required Widget child}){
    return SizedBox(
        height: buttonHeight,
        width: buttonWidth,
        child: child
    );
  }

  @override
  Widget build(BuildContext context) {

    late List<Widget> columnChildren;

    /// Login option since user is not logged in
    if(authService.getUid() == null){

      columnChildren = [
        LoginButtonDynamic(
          onLogin: () => setState((){}),
          buttonWidth: buttonWidth,
        )
      ];
    }

    /// Logout option since user is logged in
    else{
      columnChildren = [
        Container(
          decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(15)
          ),
          margin: buttonPadding,
          child: defaultSizedBox(
            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CupertinoListTile(
                    onTap: () async => await authService.signOut().then((_) => setState((){})),
                    leading: const SettingsIcon(iconPath: "logout.png"),
                    trailing: trailingArrow,
                    title: Text(AppLocalizations.of(context)!.settingsLogout, style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
        defaultSizedBox(
          child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => CustomNavigator.pushNamed(context, WelcomeRoute.connectSpotify.value),
              child: Container(
                decoration: BoxDecoration(
                    color: const Color(0xFFFF9A19),
                    borderRadius: BorderRadius.circular(15)
                ),
                child: Center(
                    child: Text(
                        AppLocalizations.of(context)!.welcomeNext,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        textScaler: const TextScaler.linear(1.1)
                    )
                ),
              )
          ),
        )

      ];
    }


    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...columnChildren
      ],
    );
  }
}
