import 'package:fitness_app/l10n/app_localizations.dart';
import 'package:fitness_app/screens/other_screens/screen_welcome/screens/cloud_connect/widgets/login_button.dart';
import 'package:flutter/material.dart';
import '../../../screen_welcome.dart';
import '../../brogy_hero.dart';

class ViewCreateAccount extends StatelessWidget {

  final bool withoutAccount;
  final double flexibleHeight;

  const ViewCreateAccount({
    super.key,
    required this.withoutAccount,
    required this.flexibleHeight
  });

  @override
  Widget build(BuildContext context) {

    const  int defaultDuration = ScreenWelcome.defaultDuration;
    const  EdgeInsets buttonPadding = ScreenWelcome.buttonPadding;

    return /// Account
      AnimatedContainer(
        // color: Colors.red,
        width: double.maxFinite,
        // color: Theme.of(context).cardColor,
        color: Theme.of(context).primaryColor,
        duration: const Duration(milliseconds: defaultDuration),
        curve: Curves.easeInOut,
        height: flexibleHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              curve: Curves.fastOutSlowIn.flipped,
              opacity: withoutAccount? 0 : 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 130,),
                  BrogyHero(
                    tag: withoutAccount? "none" : null,
                    pathCloud: "lib/assets/pictures/brogy_connect_cloud.png",
                  ),
                  SizedBox(height: 20,),
                  SizedBox(
                    width: 300,
                    child: Text(
                      AppLocalizations.of(context)!.connectCloud6,
                      textScaler: TextScaler.linear(2.2),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30,),
                  SizedBox(
                    width: 350,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        AppLocalizations.of(context)!.connectCloud7,
                        textScaler: const TextScaler.linear(1.1),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// Buttons
            AnimatedPositioned(
                bottom: withoutAccount? -600 : 150,
                curve: Curves.easeInOut,
                duration: Duration(milliseconds: withoutAccount ? 500 : 600),
                // bottom: 150,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    AnimatedOpacity(
                        curve: Curves.easeInOut,
                        duration:  Duration(milliseconds: withoutAccount? 1000 : 150),
                        opacity: withoutAccount? 0 : 1,
                        child: const Padding(
                          padding: buttonPadding,
                          child: LoginState(),
                        )
                    ),
                  ],
                )
            ),
          ],
        ),
      );
  }
}
