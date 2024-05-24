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
  final Function onFinish;
  const WelcomeScreen({
    required this.onFinish,
    super.key,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  late CnConfig cnConfig  = Provider.of<CnConfig>(context, listen: false);
  final maxIndex = 2;
  int screenIndex = 0;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.initState();
  }

  @override
  void dispose() {
    // SystemChrome.setPreferredOrientations([]);
    super.dispose();
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
          nextButton(),
          if(screenIndex > 0)
            backButton(),
        ]
      ),
    );
  }

  Widget nextButton(){
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: CupertinoButton(
            child: screenIndex == maxIndex? Text("Finish") : Text("Next"),
            onPressed: (){
              setState(() {
                if(screenIndex < maxIndex) {
                  screenIndex += 1;
                } else{
                  widget.onFinish();
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
        padding: EdgeInsets.all(10),
        child: CupertinoButton(
            child: Text("Back"),
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Welcome to ",
                    textScaler: TextScaler.linear(1.8),
                  ),
                  Text(
                      "OneDay",
                      textScaler: TextScaler.linear(1.8),
                      style: TextStyle(decoration: TextDecoration.lineThrough)
                  )
                ],
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(left: 100),
          child: const Text(
            "Please select your language",
            textScaler: TextScaler.linear(1.1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 100),
          child: getSelectLanguageButton(),
        ),
        const Spacer(flex: 1),
      ],
    );
  }

  Widget screenTwo(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: const Text(
                  "How thinks work",
                  textScaler: TextScaler.linear(1.8),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OverflowSafeText(
                maxLines: 1,
                "You don't have to create an account",
                // textScaler: TextScaler.linear(1.2),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  OverflowSafeText(
                    maxLines: 1,
                    "to use ",
                  ),
                  OverflowSafeText(
                      maxLines: 1,
                      "OneDay",
                      style: TextStyle(decoration: TextDecoration.lineThrough, fontSize: 17)
                  ),
                ],
              ),
              const SizedBox(height: 30),
              OverflowSafeText(
                maxLines: 1,
                "🙌 Awesome isn't it?",
              ),
              const SizedBox(height: 30),
              OverflowSafeText(
                maxLines: 3,
                "But how can you restore you data when you change your device your ask?",
              ),
              const SizedBox(height: 30),
              const Text(
                  "That's a great question!",
                  style: TextStyle(fontSize: 17)
              )
            ],
          ),
        ),
        const Spacer(flex: 1),
      ],
    );
  }

  Widget screenThree(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: const Text(
                  "Automatic Backups",
                  textScaler: TextScaler.linear(1.8),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Text(
                  "You can create manual Backups whenever you want.",
                  style: TextStyle(fontSize: 17)
              ),
              const SizedBox(height: 20),
              Text(
                  "In Addition, automatic Backups will be created every time you finish a workout if you enable automatic Backups.",
                  style: TextStyle(fontSize: 17)
              ),
              const SizedBox(height: 20),
              Text(
                  "Those Backups will be stored right on your device in the Apps own storage.",
                  style: TextStyle(fontSize: 17)
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
        /// Save Backup Automatic
        CupertinoListTile(
          leading: const Icon(
              Icons.cloud_done
          ),
          title: Text(AppLocalizations.of(context)!.settingsBackupSaveAutomatic, style: const TextStyle(color: Colors.white)),
          trailing: CupertinoSwitch(
              value: cnConfig.automaticBackups?? false,
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
        // /// Sync with iCloud
        // CupertinoListTile(
        //   leading: const Stack(
        //       alignment: Alignment.center,
        //       children: [
        //         Icon(
        //             Icons.cloud
        //         ),
        //         Padding(
        //           padding: EdgeInsets.only(top: 1),
        //           child: Center(
        //             child: Icon(
        //               Icons.sync,
        //               size: 16,
        //               color: Colors.black,
        //             ),
        //           ),
        //         ),
        //       ]
        //   ),
        //   trailing: CupertinoSwitch(
        //       value: cnConfig.syncWithCloud?? false,
        //       activeColor: const Color(0xFFC16A03),
        //       onChanged: (value){
        //         setState(() {
        //           if(Platform.isAndroid){
        //             HapticFeedback.selectionClick();
        //           }
        //           cnConfig.setSyncWithCloud(value);
        //         });
        //       }
        //   ),
        //   title: Padding(
        //     padding: const EdgeInsets.only(right: 5),
        //     child: OverflowSafeText(
        //       maxLines: 1,
        //       Platform.isAndroid
        //           ? AppLocalizations.of(context)!.settingsSyncGoogleDrive
        //           : AppLocalizations.of(context)!.settingsSynciCloud,
        //       style: const TextStyle(color: Colors.white),
        //     ),
        //   ),
        // ),
        const Spacer(flex: 1),
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
}
