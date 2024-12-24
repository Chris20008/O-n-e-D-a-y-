import 'package:fitness_app/assets/custom_icons/my_icons.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/screen_workouts.dart';
import 'package:fitness_app/util/language_config.dart';
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
        final List<String> lanAsStrings = languagesAsString.keys.toList();
        List<PullDownMenuItem> buttons = List.generate(lanAsStrings.length, (index) {
          return PullDownMenuItem.selectable(
            selected: currentLanguage == lanAsStrings[index],
            title: lanAsStrings[index],
            onTap: () {
              HapticFeedback.selectionClick();
              Future.delayed(const Duration(milliseconds: 200), (){
                MyApp.of(context)?.setLocale(languageCode: languagesAsString[lanAsStrings[index]], config: cnConfig);
              });
            },
          );
        });
        return buttons;
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
              style: TextStyle(
                  color: const Color(0xFFC16A03),
                  fontSize: 16
              ),
            ),
            const SizedBox(width: 6,),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              // color: Colors.amber[800],
              color: const Color(0xFFC16A03)
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
    return SafeArea(
      child: Column(
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
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                /// Save Backup Automatic
                CupertinoListTile(
                  leading: const Icon(Icons.sync),
                  title: OverflowSafeText(
                      maxLines: 1,
                      AppLocalizations.of(context)!.settingsBackupSaveAutomatic,
                      style: const TextStyle(color: Colors.white)
                  ),
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
                getCloudOptionsColumn(
                    cnConfig: cnConfig,
                    context: context,
                    refresh: () => setState(() {})
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
              ],
            )
          ),
          SizedBox(height: 20,)
        ],
      ),
    );
  }

  Widget screenThree(){
    return SafeArea(
      child: Column(
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
                            future: cnConfig.isSpotifyInstalled(delayMilliseconds: 800, context: context),
                            builder: (context, connected){
                              if(!connected.hasData){
                                return Center(
                                  child: SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CupertinoActivityIndicator(
                                          radius: 8.0,
                                          color: Colors.amber[800]
                                      ),
                                      // child: CircularProgressIndicator(strokeWidth: 2,)
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: CupertinoButton(

                    padding: EdgeInsets.zero,
                    onPressed: () {
                      widget.onFinish(false);
                      SystemChrome.setPreferredOrientations([]);
                    },
                    child: OverflowSafeText(
                      AppLocalizations.of(context)!.welcomeButtonExploreMyself,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Color(0xFFC16A03),
                        fontSize: 20,
                      )
                    ),
                  ),
                ),

                const SizedBox(height: 10,),

                /// Start Tutorial
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => widget.onFinish(true),
                  child: Text(
                    AppLocalizations.of(context)!.welcomeButtonStartTutorial,
                    style: const TextStyle(
                      color: Color(0xFFC16A03),
                      fontSize: 20,
                    )
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
        child: getBackupDialogWelcomeScreen(context: context),
    );
  }
}



