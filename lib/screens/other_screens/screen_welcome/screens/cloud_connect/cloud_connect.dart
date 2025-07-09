import 'dart:io';

import 'package:fitness_app/screens/other_screens/screen_settings/screen_settings.dart';
import 'package:fitness_app/screens/other_screens/screen_welcome/screens/cloud_connect/views/view_create_account.dart';
import 'package:fitness_app/widgets/slide_up_panel/initial_animated_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../service/auth_service.dart';
import '../../../../../widgets/custom_navigator.dart';
import '../../../../../widgets/slide_up_panel/animation_controller_name.dart';
import '../../../screen_settings/panels/explain_backup_panel.dart';
import '../../../screen_settings/screens/backups_screen/widgets/connect_with_cloud.dart';
import '../../screen_welcome.dart';
import '../brogy_hero.dart';

class ConnectCloud extends StatefulWidget {
  const ConnectCloud({super.key});

  @override
  State<ConnectCloud> createState() => _ConnectCloudState();
}

class _ConnectCloudState extends State<ConnectCloud> {

  late final CnSettings cnSettings = context.read<CnSettings>();
  late final buttonWidth = MediaQuery.of(context).size.width * ScreenWelcome.buttonWidthPercent;
  final buttonHeight = ScreenWelcome.buttonHeight;
  final EdgeInsets buttonPadding = ScreenWelcome.buttonPadding;
  late final screenHeight = MediaQuery.of(context).size.height;
  final double minHeight = 0;
  late final maxHeight = screenHeight;
  late double flexibleHeight = maxHeight;
  bool withoutAccount = false;
  late final double changeButtonDefaultBottomMargin = (minHeight - buttonHeight)/2;
  final int defaultDuration = ScreenWelcome.defaultDuration;
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          InitialAnimatedScreen(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            animationControllerName: AnimationControllerName.screenWelcome,
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [

                          AnimatedPositioned(
                            top: - (flexibleHeight - minHeight),
                            duration: Duration(milliseconds: withoutAccount ? 700 : 450),
                            curve: Curves.easeInOut,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 130,),
                                BrogyHero(
                                  tag: withoutAccount? null : "none",
                                  pathCloud: Platform.isAndroid? "lib/assets/pictures/brogy_google_drive.png" : "lib/assets/pictures/brogy_icloud.png",
                                ),
                                SizedBox(height: 20,),
                                SizedBox(
                                  width: 300,
                                  child: const Text(
                                    "Deine Daten. Immer sicher",
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
                                      "Ob mit oder ohne Account - sichere deine Fortschritte automatisch in Google Drive.",
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
                              bottom: 150 - buttonHeight - buttonPadding.top + (withoutAccount? 0 : 400),
                              curve: Curves.easeInOut,
                              duration: Duration(milliseconds: withoutAccount ? 500 : 1000),
                              // bottom: 150,
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
                                      child: const ConnectWithCloud()
                                  ),

                                  IgnorePointer(
                                    child: CupertinoButton(
                                      padding: buttonPadding,
                                        child: SizedBox(height: buttonHeight - buttonPadding.top),
                                        onPressed: (){}
                                    ),
                                  ),

                                  AnimatedOpacity(
                                    curve: Curves.easeInOut,
                                    duration:  Duration(milliseconds: withoutAccount? 1000 : 150),
                                    opacity: withoutAccount? 1 : 0,
                                    child: CupertinoButton(
                                        padding: buttonPadding,
                                        onPressed: () => CustomNavigator.pushNamed(context, WelcomeRoute.connectSpotify.value),
                                        child: Container(
                                          height: buttonHeight,
                                          width: buttonWidth,
                                          decoration: BoxDecoration(
                                              // color: const Color(0xFFFF9A19),
                                              // color: Colors.white12,
                                              borderRadius: BorderRadius.circular(15)
                                          ),
                                          child: const Center(
                                              child: Text(
                                                  "Weiter ohne Account",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      // fontWeight: FontWeight.w600
                                                  ),
                                                  textScaler: TextScaler.linear(1.1)
                                              )
                                          ),
                                        )
                                    ),
                                  ),
                                ],
                              )
                          ),
                          Positioned(
                            bottom: 20,
                            child: AnimatedOpacity(
                              curve: Curves.easeInOut,
                              duration:  Duration(milliseconds: withoutAccount? 500 : 250),
                              opacity: withoutAccount? 1 : 0,
                              child: SizedBox(
                                width: buttonWidth,
                                child: CupertinoButton(
                                  sizeStyle: CupertinoButtonSize.small,
                                  padding: EdgeInsets.zero,
                                  onPressed: () async{
                                    HapticFeedback.selectionClick();
                                    cnSettings.openPanelExplainBackups();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.info,
                                        size:12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 5,),
                                      Text(
                                          AppLocalizations.of(context)!.settingsBackupMoreInfo,
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w300
                                          )
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Account
                    ViewCreateAccount(
                      withoutAccount: withoutAccount,
                      flexibleHeight: flexibleHeight,
                    ),
                    // AnimatedContainer(
                    //   // color: Colors.red,
                    //   width: double.maxFinite,
                    //   // color: Theme.of(context).cardColor,
                    //   color: Theme.of(context).primaryColor,
                    //   duration: Duration(milliseconds: defaultDuration),
                    //   curve: Curves.easeInOut,
                    //   height: flexibleHeight,
                    //   child: Stack(
                    //     alignment: Alignment.center,
                    //     children: [
                    //       AnimatedOpacity(
                    //           duration: Duration(milliseconds: 600),
                    //           curve: Curves.fastOutSlowIn.flipped,
                    //           opacity: withoutAccount? 0 : 1,
                    //           child: Column(
                    //             mainAxisAlignment: MainAxisAlignment.start,
                    //             crossAxisAlignment: CrossAxisAlignment.center,
                    //             children: [
                    //               const SizedBox(height: 130,),
                    //               BrogyHero(
                    //                   tag: withoutAccount? "none" : null,
                    //                   pathCloud: "lib/assets/pictures/brogy_connect_cloud.png",
                    //               ),
                    //               SizedBox(height: 20,),
                    //               SizedBox(
                    //                 width: 300,
                    //                 child: const Text(
                    //                   "Erstelle einen Account",
                    //                   textScaler: TextScaler.linear(2.2),
                    //                   textAlign: TextAlign.center,
                    //                 ),
                    //               ),
                    //               const SizedBox(height: 30,),
                    //               SizedBox(
                    //                 width: 350,
                    //                 child: Padding(
                    //                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    //                   child: Text(
                    //                     "Synchronisiere deine Daten zwischen Geräten und greife von überall auf deinen Fortschritt zu.",
                    //                     textScaler: const TextScaler.linear(1.1),
                    //                     textAlign: TextAlign.center,
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //       ),
                    //
                    //       /// Buttons
                    //       AnimatedPositioned(
                    //           bottom: withoutAccount? -600 : 150,
                    //           curve: Curves.easeInOut,
                    //           duration: Duration(milliseconds: withoutAccount ? 500 : 600),
                    //           // bottom: 150,
                    //           child: Column(
                    //             mainAxisSize: MainAxisSize.min,
                    //             children: [
                    //
                    //               AnimatedOpacity(
                    //                 curve: Curves.easeInOut,
                    //                 duration:  Duration(milliseconds: withoutAccount? 1000 : 150),
                    //                 opacity: withoutAccount? 0 : 1,
                    //                 child: Padding(
                    //                   padding: buttonPadding,
                    //                   child: StatefulBuilder(
                    //                     builder: (context, setModalState) {
                    //                       return Column(
                    //                         mainAxisSize: MainAxisSize.min,
                    //                         children: [
                    //                           if(authService.getUid() != null)
                    //                             Container(
                    //                               height: buttonHeight,
                    //                               width: buttonWidth,
                    //                               margin: buttonPadding,
                    //                               child: Container(
                    //                                 height: buttonHeight,
                    //                                 decoration: BoxDecoration(
                    //                                     color: Colors.white12,
                    //                                     borderRadius: BorderRadius.circular(15)
                    //                                 ),
                    //                                 width: buttonWidth,
                    //                                 child: Column(
                    //                                   mainAxisAlignment: MainAxisAlignment.center,
                    //                                   mainAxisSize: MainAxisSize.min,
                    //                                   children: [
                    //                                     CupertinoListTile(
                    //                                       // onTap: () async => await authService.signOut().then((_) => cnSettings.navigatorKey.currentState?.pop()),
                    //                                       onTap: () async => await authService.signOut().then((_) => setModalState((){})),
                    //                                       leading: const SettingsIcon(iconPath: "logout.png"),
                    //                                       trailing: trailingArrow,
                    //                                       title: Text(AppLocalizations.of(context)!.settingsLogout, style: const TextStyle(color: Colors.white)),
                    //                                     ),
                    //                                   ],
                    //                                 ),
                    //                               ),
                    //                             ),
                    //                           SizedBox(
                    //                             height: buttonHeight,
                    //                             width: buttonWidth,
                    //                             child: authService.getUid() == null
                    //                                 ? getLoginButton(setModalState)
                    //                                 : CupertinoButton(
                    //                                 // padding: buttonPadding,
                    //                               padding: EdgeInsets.zero,
                    //                                 onPressed: () => CustomNavigator.pushNamed(context, WelcomeRoute.connectSpotify.value),
                    //                                 child: Container(
                    //                                   decoration: BoxDecoration(
                    //                                     color: const Color(0xFFFF9A19),
                    //                                       borderRadius: BorderRadius.circular(15)
                    //                                   ),
                    //                                   child: const Center(
                    //                                       child: Text(
                    //                                           "Weiter",
                    //                                           style: TextStyle(
                    //                                             color: Colors.white,
                    //                                             // fontWeight: FontWeight.w600
                    //                                           ),
                    //                                           textScaler: TextScaler.linear(1.1)
                    //                                       )
                    //                                   ),
                    //                                 )
                    //                             ),
                    //                           ),
                    //                         ],
                    //                       );
                    //                     }
                    //                   ),
                    //                 )
                    //               ),
                    //             ],
                    //           )
                    //       ),
                    //     ],
                    //   ),
                    // )
                  ],
                ),

                /// Change Option Button
                AnimatedPositioned(
                  duration: Duration(milliseconds: defaultDuration),
                  curve: Curves.easeInOut,
                  // bottom:0,
                  // bottom: withoutAccount? changeButtonDefaultBottomMargin : flexibleHeight + changeButtonDefaultBottomMargin,
                  bottom: withoutAccount? 150 : maxHeight - buttonHeight - MediaQuery.of(context).padding.top - buttonPadding.top,
                  left: 0,
                  right: 0,
                  child: CupertinoButton(
                      padding: buttonPadding,
                      // padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          if(withoutAccount){
                            CustomNavigator.of(context).observer.overwriteCurrentRouteName(WelcomeRoute.connectCloud.value);
                            flexibleHeight = maxHeight;
                            withoutAccount = false;
                          }else{
                            CustomNavigator.of(context).observer.overwriteCurrentRouteName(WelcomeRoute.connectCloudWithoutAccount.value);
                            flexibleHeight = minHeight;
                            withoutAccount = true;
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 750),
                        curve: Curves.easeInOut,
                        height: buttonHeight,
                        width: buttonWidth,
                        decoration: BoxDecoration(
                            color: withoutAccount?  const Color(0xFFFF9A19) : Colors.transparent,
                            borderRadius: BorderRadius.circular(15)
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          // clipBehavior: Clip.none,
                          children: [
                            AnimatedPositioned(
                              top: withoutAccount? 0 : 35,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 100),
                                curve: Curves.easeInOut,
                                opacity: withoutAccount? 1 : 0,
                                child: SizedBox(
                                  height: buttonHeight,
                                  child: Center(
                                    child: Text(
                                        "Account erstellen",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600
                                        ),
                                        textScaler: TextScaler.linear(1.1)
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            AnimatedPositioned(
                              top: withoutAccount? -35 : 0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 100),
                                curve: Curves.easeInOut,
                                opacity: withoutAccount? 0 : 1,
                                child: SizedBox(
                                  height: buttonHeight,
                                  child: Center(
                                    child: Text(
                                        "Ohne Account fortfahren",
                                        style: TextStyle(
                                            color: Colors.white38,
                                            fontWeight: FontWeight.w400
                                        ),
                                        textScaler: TextScaler.linear(0.8)
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  ),
                ),
              ],
            ),
          ),

          StatefulBuilder(
              builder: (context, setModalState) {
                return PopScope(
                    canPop: cnSettings.panelControllerExplainBackups.isAttached? cnSettings.panelControllerExplainBackups.panelPosition <= 0.1 : true,
                    onPopInvokedWithResult: (_, __) async{
                      if(cnSettings.panelControllerExplainBackups.panelPosition > 0.99){
                        await cnSettings.panelControllerExplainBackups.close();
                        // setModalState((){});
                      }
                    },
                    child: ExplainBackupPanel(
                      // reducedView: true,
                      onPanelSlide: (value){
                        if(value == 1 || value == 0){
                          setModalState((){});
                        }
                      },
                    )
                );
              }
          )
        ],
      ),
    );
  }
}