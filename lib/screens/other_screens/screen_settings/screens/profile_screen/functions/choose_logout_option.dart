import 'dart:io';

import 'package:fitness_app/main.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../service/auth_service.dart';
import '../../../../../../widgets/custom_navigator.dart';
import '../widgets/logout_options_button.dart';

Future chooseLogoutOption(BuildContext parentContext) async{

  final authService = AuthService();
  final CnScreenStatistics cnScreenStatistics = parentContext.read<CnScreenStatistics>();

  await showModalBottomSheet(
      useRootNavigator: true,
      constraints: null,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: parentContext,
      builder: (context){
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          child: Container(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height - (Platform.isAndroid? 250 : 270),
            color: Theme.of(context).primaryColor,
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                    height: 180,
                    child: Image.asset("lib/assets/pictures/welcome_brogy.png")
                ),
                const SizedBox(height: 40,),
                LogoutOptionsButton(
                  header: "Nur Verbindung trennen",
                  description: "Behalte deine Daten lokal, entferne nur die Account-Verbindung.",
                  leadingIcon: Icon(Icons.lock),
                  buttonColor: Colors.white12,
                  onPressed: () async{
                    await authService.signOut().then((_) => Navigator.pop(context));

                    await Future.delayed(const Duration(milliseconds: 300), () => CustomNavigator.pop(parentContext));
                  },
                ),
                const SizedBox(height: 20,),
                LogoutOptionsButton(
                    header: "Komplett abmelden",
                    description: "Alle lokalen Daten und die Account-Verbindung werden entfernt.",
                    leadingIcon: Icon(Icons.lock),
                    buttonColor: const Color(0xFFFF9A19),
                    onPressed: () async{
                      await authService.signOut().then((_) {
                        objectbox.workoutBox.removeAll();
                        objectbox.exerciseBox.removeAll();
                        objectbox.sickDaysBox.removeAll();
                        cnScreenStatistics.refreshData(context);
                        cnScreenStatistics.refresh();
                        /// Pop the logout options popUp context
                        Navigator.pop(context);
                      });
                      /// Pop the Profile screen
                      await Future.delayed(const Duration(milliseconds: 300), () => CustomNavigator.pop(parentContext));
                    },
                ),

                SizedBox(height: 20,),

                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, top: 2, right: 4),
                        child: Icon(
                          Icons.info,
                          color: Colors.white54,
                          size: 12,
                        ),
                      ),
                      // SizedBox(width: 4),
                      Expanded(
                        child: Text(
                            "Deine Account Daten bei uns auf dem Server bleiben erhalten. Eine vollständige Löschung erfolgt nur über \"Account löschen\".",
                            style: TextStyle(
                              color: Colors.white54,
                              // fontWeight: FontWeight.w
                            ),
                            textScaler: TextScaler.linear(0.8)
                        ),
                      ),
                    ],
                  )
                ),

              ],
            ),
          ),
        );
      });
}