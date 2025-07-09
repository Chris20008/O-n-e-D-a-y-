import 'package:fitness_app/widgets/slide_up_panel/initial_animated_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../widgets/slide_up_panel/animation_controller_name.dart';
import '../../screen_settings/screens/initial_settings_screen/widgets/1_general_settings/widgets/switch_health.dart';
import 'brogy_hero.dart';

class ConnectHealth extends StatelessWidget {
  final Function(bool) onFinish;
  const ConnectHealth({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {

    final buttonWidth = MediaQuery.of(context).size.width * 0.8;
    const buttonHeight = 50.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          InitialAnimatedScreen(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            animationControllerName: AnimationControllerName.screenWelcome,
            child: Stack(
              alignment: Alignment.center,
              children: [

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 130,),
                    BrogyHero(),
                    SizedBox(height: 30,),
                    SizedBox(
                      width: 300,
                      child: const Text(
                        "Health verbinden",
                        textScaler: TextScaler.linear(2.2),
                        textAlign: TextAlign.center,
                        // style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 30,),
                    SizedBox(
                      width: 350,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "Damit ich dein Körpergewicht bei Übungen korrekt berücksichtigen kann.",
                          textScaler: const TextScaler.linear(1.1),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),

                /// Buttons
                Positioned(
                    bottom: 150,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Sync with iCloud
                        Container(
                            height: buttonHeight,
                            decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(15)
                            ),
                            width: buttonWidth,
                            child: const CupertinoListTileSwitchHealth()
                        ),

                        CupertinoButton(
                            onPressed: () => onFinish(false),
                            // onPressed: () {},
                            child: Container(
                              height: buttonHeight,
                              width: buttonWidth,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFF9A19),
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              child: const Center(
                                  child: Text(
                                      "Fertig",
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}