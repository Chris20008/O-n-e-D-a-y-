import 'package:fitness_app/assets/custom_icons/my_icons.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/screen_workouts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../main.dart';
import '../../util/config.dart';
import '../../util/constants.dart';
import 'dart:io';

class WelcomeScreen extends StatefulWidget {
  final Function(bool) onFinish;
  const WelcomeScreen({
    required this.onFinish,
    super.key,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnConfig cnConfig  = Provider.of<CnConfig>(context);
  final maxIndex = 3;
  int screenIndex = 0;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Stack(
        children: [
          animatedScreen(0, screenOne()),
          animatedScreen(1, screenTwo()),
          animatedScreen(2, screenThree()),
          animatedScreen(3, screenFour()),
          if(screenIndex < maxIndex)
            nextButton(),
          if(screenIndex > 0)
            backButton(),
          imprintButton()
        ]
      ),
    );
  }

  Widget imprintButton(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: Platform.isAndroid? EdgeInsets.zero : const EdgeInsets.only(bottom: 20),
        child: SizedBox(
          height: 20,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () async{
              HapticFeedback.selectionClick();
              await openUrl("https://github.com/Chris20008/O-n-e-D-a-y-/blob/master/IMPRINT.md#imprint");
            },
            child: Text(
              AppLocalizations.of(context)!.settingsImprint,
              style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  decoration: TextDecoration.underline,
                  fontSize: 10
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget nextButton(){
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: CupertinoButton(
            child: Text(AppLocalizations.of(context)!.welcomeNext),
            onPressed: (){
              setState(() {
                if(screenIndex < maxIndex) {
                  screenIndex += 1;
                }
              });
            }
        ),
      ),
    );
  }

  Widget backButton(){
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: CupertinoButton(
            child: Text(AppLocalizations.of(context)!.welcomeBack),
            onPressed: (){
              setState(() {
                screenIndex -= 1;
                screenIndex = screenIndex <= 0? 0 : screenIndex;
              });
            }
        ),
      ),
    );
  }

  Widget getSelectLanguageButton() {
    return PullDownButton(
      buttonAnchor: PullDownMenuAnchor.start,
      routeTheme: routeTheme,
      itemBuilder: (context) {
        final currentLanguage = getLanguageAsString(context);
        return [
          PullDownMenuItem.selectable(
            selected: currentLanguage == 'Deutsch',
            title: 'Deutsch',
            onTap: () {
              HapticFeedback.selectionClick();
              Future.delayed(const Duration(milliseconds: 200), (){
                MyApp.of(context)?.setLocale(language: LANGUAGES.de, config: cnConfig);
              });
            },
          ),
          PullDownMenuItem.selectable(
            selected: currentLanguage == 'English',
            title: 'English',
            onTap: () {
              HapticFeedback.selectionClick();
              Future.delayed(const Duration(milliseconds: 200), (){
                MyApp.of(context)?.setLocale(language: LANGUAGES.en, config: cnConfig);
              });
            },
          ),
        ];
      },
      buttonBuilder: (context, showMenu) => CupertinoButton(
        onPressed: (){
          HapticFeedback.selectionClick();
          showMenu();
        },
        padding: EdgeInsets.zero,
        child: Row(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              getLanguageAsString(context),
              style: TextStyle(color: Colors.amber[800], fontSize: 16),
            ),
            const SizedBox(width: 6,),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.amber[800],
            )
          ],
        ),
      ),
    );
  }

  Widget screenOne(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "👋 Hey Gymrat!",
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
                      "OneDay",
                      textScaler: TextScaler.linear(1.8),
                      style: TextStyle(decoration: TextDecoration.lineThrough)
                  )
                ],
              ),
            ],
          ),
        ),

        SizedBox(
          width: MediaQuery.of(context).size.width/1.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.welcomeSelectLanguage,
                textScaler: const TextScaler.linear(1.1),
              ),
              getSelectLanguageButton(),
            ],
          ),
        ),

        const Spacer(flex: 1),
      ],
    );
  }

  Widget screenTwo(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: OverflowSafeText(
                    maxLines: 1,
                    Platform.isAndroid? AppLocalizations.of(context)!.welcomeSyncGoogleDrive : AppLocalizations.of(context)!.welcomeSynciCloud,
                    fontSize: 25,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OverflowSafeText(
                maxLines: 1,
                AppLocalizations.of(context)!.welcomeNoAccount,
              ),
              OverflowSafeText(
                maxLines: 1,
                AppLocalizations.of(context)!.welcomeNoAccount2,
              ),
              const SizedBox(height: 20),
              OverflowSafeText(
                maxLines: 1,
                AppLocalizations.of(context)!.welcomeAwesome,
              ),
              const SizedBox(height: 80),
              OverflowSafeText(
                maxLines: 2,
                AppLocalizations.of(context)!.welcomeLocalBackups,
                textAlign: TextAlign.center
              ),
              const SizedBox(height: 20),
              OverflowSafeText(
                  maxLines: 2,
                  Platform.isAndroid? AppLocalizations.of(context)!.welcomeSyncGoogleDrive2 : AppLocalizations.of(context)!.welcomeSynciCloud2,
                  textAlign: TextAlign.center
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              /// Save Backup Automatic
              CupertinoListTile(
                leading: const Icon(
                    Icons.cloud_done
                ),
                title: Text(AppLocalizations.of(context)!.settingsBackupSaveAutomatic, style: const TextStyle(color: Colors.white)),
                trailing: CupertinoSwitch(
                    value: cnConfig.automaticBackups,
                    activeColor: const Color(0xFFC16A03),
                    onChanged: (value){
                      setState(() {
                        if(Platform.isAndroid){
                          HapticFeedback.selectionClick();
                        }
                        cnConfig.setAutomaticBackups(value);
                      });
                    }
                ),
              ),
              /// Sync with iCloud
              CupertinoListTile(
                leading: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                          Icons.cloud
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Center(
                          child: Icon(
                            Icons.sync,
                            size: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ]
                ),
                trailing: CupertinoSwitch(
                    value: cnConfig.syncWithCloud,
                    activeColor: const Color(0xFFC16A03),
                    onChanged: (value)async{
                      if(Platform.isAndroid){
                        HapticFeedback.selectionClick();
                        if(!value){
                          cnConfig.account = null;
                        }
                      }
                      cnConfig.setSyncWithCloud(value);
                      setState(() {});
                    }
                ),
                title: Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: OverflowSafeText(
                          maxLines: 1,
                          Platform.isAndroid
                              ? AppLocalizations.of(context)!.settingsSyncGoogleDrive
                              : AppLocalizations.of(context)!.settingsSynciCloud,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      if(Platform.isAndroid)
                        SizedBox(width: cnConfig.syncWithCloud? 0 : 15),
                      /// The future "cnConfig.signInGoogleDrive()" is currently not configured for IOS
                      /// so calling it will lead to an crash
                      /// We have to make sure it is only called on Android!
                      if(cnConfig.syncWithCloud && Platform.isAndroid)
                        FutureBuilder(
                            future: cnConfig.signInGoogleDrive(),
                            builder: (context, connected){
                              if(!connected.hasData){
                                return const Center(
                                  child: SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(strokeWidth: 2,)
                                  ),
                                );
                              }
                              return Icon(
                                cnConfig.account != null
                                    ? Icons.check_circle
                                    : Icons.close,
                                size: 15,
                                color: cnConfig.account != null
                                    ? Colors.green
                                    : Colors.red,
                              );
                            }
                        )
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async{
                  HapticFeedback.selectionClick();
                  await showDialog(
                      context: context,
                      builder: (context){
                        return Center(
                            child: getBackupDialogChild()
                        );
                      }
                  );
                  HapticFeedback.selectionClick();
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.info, size:12),
                      const SizedBox(width: 5,),
                      Text(AppLocalizations.of(context)!.settingsBackupMoreInfo, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w300),),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          )
        ),
      ],
    );
  }

  Widget screenThree(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  AppLocalizations.of(context)!.welcomeControlMusic,
                  textScaler: const TextScaler.linear(1.8),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.welcomeMusicQuestion,
                  style: const TextStyle(fontSize: 17),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              Text(
                AppLocalizations.of(context)!.welcomeMusicSolution,
                  style: const TextStyle(fontSize: 17),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              Text(
                AppLocalizations.of(context)!.welcomeMusicExplanation,
                  style: const TextStyle(fontSize: 17),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Connect to Spotify
              CupertinoListTile(
                leading: const Icon(
                    MyIcons.spotify,
                    // color: Colors.amber[800],
                    color: Color(0xff1ed560)
                ),
                title: Row(
                  children: [
                    Text(AppLocalizations.of(context)!.settingsConnectSpotify, style: const TextStyle(color: Colors.white)),
                    const SizedBox(width: 5),
                    if(cnConfig.useSpotify)
                      FutureBuilder(
                          future: cnConfig.isSpotifyInstalled(delayMilliseconds: 500, context: context),
                          builder: (context, connected){
                            if(!connected.hasData){
                              return const Center(
                                child: SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: CircularProgressIndicator(strokeWidth: 2,)
                                ),
                              );
                            }
                            return Icon(
                              connected.data == true
                                  ? Icons.check_circle
                                  : Icons.close,
                              size: 15,
                              color: connected.data == true
                                  ? Colors.green
                                  : Colors.red,
                            );
                          }
                      )
                  ],
                ),
                trailing: CupertinoSwitch(
                    value: cnConfig.useSpotify,
                    activeColor: const Color(0xFFC16A03),
                    onChanged: (value) async{
                      setState(() {
                        if(Platform.isAndroid){
                          HapticFeedback.selectionClick();
                        }
                        cnConfig.setSpotify(value);
                        cnWorkouts.refresh();
                      });
                    }
                ),
              ),
              Container(
                height: 20,
                padding: const EdgeInsets.only(left: 30),
                child: cnConfig.failedSpotifyConnection? Text(AppLocalizations.of(context)!.welcomeSpotifyError, textAlign: TextAlign.left,) : null
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ],
    );
  }

  Widget screenFour(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100,),
              Center(
                child: Text(
                  AppLocalizations.of(context)!.welcomeSetupCompleted,
                  textScaler: const TextScaler.linear(1.8),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.welcomeSetupCompletedMsg,
                style: const TextStyle(fontSize: 17),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              Text(
                AppLocalizations.of(context)!.welcomeSetupCompletedHopIntoTutorial,
                style: const TextStyle(fontSize: 17),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                /// Explore myself
                CupertinoButton(

                  padding: EdgeInsets.zero,
                  onPressed: () {
                    widget.onFinish(false);
                    SystemChrome.setPreferredOrientations([]);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.welcomeButtonExploreMyself,
                    textScaler: const TextScaler.linear(1.2),
                  ),
                ),

                const SizedBox(height: 10,),

                /// Start Tutorial
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => widget.onFinish(true),
                  child: Text(
                    AppLocalizations.of(context)!.welcomeButtonStartTutorial,
                    textScaler: const TextScaler.linear(1.2),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget animatedScreen(int index, Widget child){
    return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.translationValues(
            screenIndex == index
                ? 0
                : screenIndex <= index
                ? MediaQuery.of(context).size.width
                : - MediaQuery.of(context).size.width,
            0,
            0),
        curve: Curves.easeInOut,
        child: child
    );
  }

  Widget getBackupDialogChild() {
    return standardDialog(
        context: context,
        maxWidth: 400,
        widthFactor: 0.9,
        maxHeight: 680,
        child: Column(
          children: [

            /// Save Backup Automatic
            CupertinoListTile(
              leading: const Icon(
                  Icons.cloud_done
              ),
              title: Text(AppLocalizations.of(context)!.settingsBackupSaveAutomatic, style: const TextStyle(color: Colors.white)),
            ),
            Padding(padding: const EdgeInsets.only(left: 30) ,child: Text(AppLocalizations.of(context)!.settingsBackupSaveAutomaticExplanation)),
            const SizedBox(height: 15),

            /// Sync with iCloud
            CupertinoListTile(
              leading: const Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                        Icons.cloud
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Center(
                        child: Icon(
                          Icons.sync,
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ]
              ),
              title: OverflowSafeText(
                  maxLines: 1,
                  Platform.isAndroid
                      ? AppLocalizations.of(context)!.settingsSyncGoogleDrive
                      : AppLocalizations.of(context)!.settingsSynciCloud,
                  style: const TextStyle(color: Colors.white)
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(Platform.isAndroid
                    ? AppLocalizations.of(context)!.settingsBackupSyncGoogleDriveExplanation
                    : AppLocalizations.of(context)!.settingsBackupSynciCloudExplanation
                )
            ),
            const SizedBox(height: 15),
          ],
        )
    );
  }
}





// Widget screenOne(){
//   return Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Expanded(
//         flex: 3,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const Text(
//               "👋 Hey Gymrat!",
//               textScaler: TextScaler.linear(1.8),
//             ),
//             SizedBox(height: 10,),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   "Welcome to ",
//                   textScaler: TextScaler.linear(1.8),
//                 ),
//                 Text(
//                     "OneDay",
//                     textScaler: TextScaler.linear(1.8),
//                     style: TextStyle(decoration: TextDecoration.lineThrough)
//                 )
//               ],
//             ),
//           ],
//         ),
//       ),
//
//       Padding(
//         padding: const EdgeInsets.only(left: 100),
//         child: const Text(
//           "Please select your language",
//           textScaler: TextScaler.linear(1.1),
//         ),
//       ),
//       Padding(
//         padding: const EdgeInsets.only(left: 100),
//         child: getSelectLanguageButton(),
//       ),
//       const Spacer(flex: 1),
//     ],
//   );
// }
//
// Widget screenTwo(){
//   return Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Expanded(
//         flex: 3,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Center(
//               child: const Text(
//                 "How thinks work",
//                 textScaler: TextScaler.linear(1.8),
//               ),
//             ),
//           ],
//         ),
//       ),
//
//       Padding(
//         padding: EdgeInsets.symmetric(horizontal: 30),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             OverflowSafeText(
//               maxLines: 1,
//               "You don't have to create an account",
//               // textScaler: TextScaler.linear(1.2),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 OverflowSafeText(
//                   maxLines: 1,
//                   "to use ",
//                 ),
//                 OverflowSafeText(
//                     maxLines: 1,
//                     "OneDay",
//                     style: TextStyle(decoration: TextDecoration.lineThrough, fontSize: 17)
//                 ),
//               ],
//             ),
//             const SizedBox(height: 30),
//             OverflowSafeText(
//               maxLines: 1,
//               "🙌 Awesome isn't it?",
//             ),
//             const SizedBox(height: 30),
//             OverflowSafeText(
//               maxLines: 3,
//               "But how can you restore you data when you change your device your ask?",
//             ),
//             const SizedBox(height: 30),
//             const Text(
//                 "That's a great question!",
//                 style: TextStyle(fontSize: 17)
//             )
//           ],
//         ),
//       ),
//       const Spacer(flex: 1),
//     ],
//   );
// }
//
// Widget screenThree(){
//   return Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Expanded(
//         flex: 3,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Center(
//               child: const Text(
//                 "Automatic Backups",
//                 textScaler: TextScaler.linear(1.8),
//               ),
//             ),
//           ],
//         ),
//       ),
//
//       Padding(
//         padding: EdgeInsets.symmetric(horizontal: 30),
//         child: Column(
//           children: [
//             Text(
//                 "You can create manual Backups whenever you want.",
//                 style: TextStyle(fontSize: 17)
//             ),
//             const SizedBox(height: 20),
//             Text(
//                 "In Addition, automatic Backups will be created every time you finish a workout if you enable automatic Backups.",
//                 style: TextStyle(fontSize: 17)
//             ),
//             const SizedBox(height: 20),
//             Text(
//                 "Those Backups will be stored right on your device in the Apps own storage.",
//                 style: TextStyle(fontSize: 17)
//             ),
//           ],
//         ),
//       ),
//
//       const SizedBox(height: 40),
//       /// Save Backup Automatic
//       CupertinoListTile(
//         leading: const Icon(
//             Icons.cloud_done
//         ),
//         title: Text(AppLocalizations.of(context)!.settingsBackupSaveAutomatic, style: const TextStyle(color: Colors.white)),
//         trailing: CupertinoSwitch(
//             value: cnConfig.automaticBackups?? false,
//             activeColor: const Color(0xFFC16A03),
//             onChanged: (value){
//               setState(() {
//                 if(Platform.isAndroid){
//                   HapticFeedback.selectionClick();
//                 }
//                 cnConfig.setAutomaticBackups(value);
//               });
//             }
//         ),
//       ),
//       // /// Sync with iCloud
//       // CupertinoListTile(
//       //   leading: const Stack(
//       //       alignment: Alignment.center,
//       //       children: [
//       //         Icon(
//       //             Icons.cloud
//       //         ),
//       //         Padding(
//       //           padding: EdgeInsets.only(top: 1),
//       //           child: Center(
//       //             child: Icon(
//       //               Icons.sync,
//       //               size: 16,
//       //               color: Colors.black,
//       //             ),
//       //           ),
//       //         ),
//       //       ]
//       //   ),
//       //   trailing: CupertinoSwitch(
//       //       value: cnConfig.syncWithCloud?? false,
//       //       activeColor: const Color(0xFFC16A03),
//       //       onChanged: (value){
//       //         setState(() {
//       //           if(Platform.isAndroid){
//       //             HapticFeedback.selectionClick();
//       //           }
//       //           cnConfig.setSyncWithCloud(value);
//       //         });
//       //       }
//       //   ),
//       //   title: Padding(
//       //     padding: const EdgeInsets.only(right: 5),
//       //     child: OverflowSafeText(
//       //       maxLines: 1,
//       //       Platform.isAndroid
//       //           ? AppLocalizations.of(context)!.settingsSyncGoogleDrive
//       //           : AppLocalizations.of(context)!.settingsSynciCloud,
//       //       style: const TextStyle(color: Colors.white),
//       //     ),
//       //   ),
//       // ),
//       const Spacer(flex: 1),
//     ],
//   );
// }