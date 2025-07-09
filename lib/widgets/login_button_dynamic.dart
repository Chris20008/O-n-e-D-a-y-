import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../../../service/auth_service.dart';
import '../../../../../../util/sign_in_with_google_button.dart';

class LoginButtonDynamic extends StatefulWidget {

  final Function onLogin;
  final double buttonWidth;

  const LoginButtonDynamic({
    super.key,
    required this.onLogin,
    this.buttonWidth = double.maxFinite
  });

  @override
  State<LoginButtonDynamic> createState() => _LoginButtonDynamicState();
}

class _LoginButtonDynamicState extends State<LoginButtonDynamic> {

  final AuthService authService = AuthService();
  bool isLoading = false;

  late Widget loginButton = Platform.isAndroid
      ? SignInWithGoogleButton(onPressed: () async => await handleLogin(authService.signInWithGoogle))
      : SignInWithAppleButton(onPressed: () async => await handleLogin(authService.signInWithApple));

  Future handleLogin(Future Function() login) async{
    setState(() => isLoading = true);
    await login();
    widget.onLogin();
    setState(() => isLoading = false);
  }

  Widget defaultSizedBox({required Widget child}){
    return SizedBox(
        height: signInButtonHeight,
        width: widget.buttonWidth,
        child: child
    );
  }

  @override
  Widget build(BuildContext context) {

    if(isLoading){
      return Container(
        decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8)
        ),
        child: defaultSizedBox(
            child: CupertinoActivityIndicator(
                radius: 8.0,
                color: Colors.amber[800]
            )
        ),
      );
    }

    return defaultSizedBox(child: loginButton);
  }
}
