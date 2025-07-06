import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../service/auth_service.dart';
import '../../../../../../util/cupertino_alert_dialog_custom.dart';
import '../../../../../../util/loading_overlay.dart';

showDeleteAccountDialog(BuildContext context, Function refresh){
  String deleteString = "LÖSCHEN";
  bool valid = true;
  TextEditingController controller = TextEditingController();
  cupertinoAlertDialogCustom(
    context: context,
    validator: () => controller.text == deleteString,
    actionDestructive: ()async{
      await futureWithLoadingOverlay(
          context: context,
          future: AuthService().deleteAccount
      );
      // setModalState((){});
      refresh((){});
    },
    header: 'Account löschen',
    cancel: AppLocalizations.of(context)!.cancel,
    destructive: AppLocalizations.of(context)!.delete,
    body: Column(
      children: [
        const Text("Bitte gib LÖSCHEN ein, um das Löschen deines Accounts zu bestätigen.", textAlign: TextAlign.center, textScaler: TextScaler.linear(0.8)),
        SizedBox(height: 15,),
        Container(
          height: 35,
          child: StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    onTapUpOutside: (_){
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    decoration: InputDecoration(
                      error: valid? null : const SizedBox(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      counterText: "",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0 ,vertical: 0.0),
                      hintFadeDuration: const Duration(milliseconds: 200),
                      // errorBorder: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(8),
                      //   borderSide: const BorderSide(color: Colors.red),
                      // ),
                    ),
                    keyboardAppearance: Brightness.dark,
                    maxLength: deleteString.length,
                    textAlign: TextAlign.center,
                    controller: controller,
                    onTap: (){},
                    onChanged: (value){
                      if(value != deleteString && value.isNotEmpty){
                        setModalState((){
                          valid = false;
                        });
                      }
                      else{
                        setModalState((){
                          valid = true;
                        });

                      }
                    },
                  ),
                );
              }
          ),
        ),
      ],
    ),
  );
}