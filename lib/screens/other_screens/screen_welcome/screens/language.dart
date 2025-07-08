import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../../../util/config.dart';
import '../../../../util/constants.dart';
import '../../../../util/language_config.dart';
import '../../../../widgets/custom_navigator.dart';
import '../../../../widgets/selectors/select_language_button.dart';
import '../screen_welcome.dart';
import 'brogy_hero.dart';

class ScreenLanguage extends StatelessWidget {
  const ScreenLanguage({super.key});

  @override
  Widget build(BuildContext context) {

    final CnConfig cnConfig = context.read<CnConfig>();
    final buttonWidth = MediaQuery.of(context).size.width * 0.8;
    const buttonHeight = 50.0;

    return Container(
      color: Theme.of(context).primaryColor,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100,),
              BrogyHero(),
              // SizedBox(
              //     height: 180,
              //     child: Image.asset("lib/assets/pictures/welcome_brogy.png")
              // ),
              SizedBox(height: 50,),
              const Text(
                "Hey Gymrat!",
                textScaler: TextScaler.linear(1.8),
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.welcome,
                    textScaler: const TextScaler.linear(1.8),
                  ),
                  const Text(
                      "O̶n̶e̶D̶a̶y̶",
                      textScaler: TextScaler.linear(1.8),
                      style: TextStyle(decoration: TextDecoration.lineThrough)
                  )
                ],
              ),
            ],
          ),

          /// Buttons
          Positioned(
              bottom: 150,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: buttonHeight,
                    width: buttonWidth,
                    decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: SelectLanguageButton(
                        cnConfig: cnConfig,
                        buttonAnchor: PullDownMenuAnchor.center,
                        buttonChild: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text(
                                getLanguageAsString(context),
                                style: const TextStyle(
                                  color: Colors.white,
                                  // fontSize: 16
                                ),
                              ),
                            ),
                            const Padding(
                                padding: EdgeInsets.only(right: 20),
                                child: trailingArrow
                            ),
                          ],
                        )
                    ),
                  ),

                  CupertinoButton(
                      onPressed: () => CustomNavigator.pushNamed(context, WelcomeRoute.connectCloud.value),
                      child: Container(
                        height: buttonHeight,
                        width: buttonWidth,
                        decoration: BoxDecoration(
                            color: const Color(0xFFFF9A19),
                            borderRadius: BorderRadius.circular(15)
                        ),
                        child: const Center(
                            child: Text(
                                "Los geht's",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600
                                ),
                                textScaler: TextScaler.linear(1.1)
                            )
                        ),
                      )
                  ),
                ],
              )
          )
        ],
      ),
    );
  }
}