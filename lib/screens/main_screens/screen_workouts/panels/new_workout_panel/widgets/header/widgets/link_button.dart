import 'package:flutter/material.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fitness_app/widgets/standard_popup.dart';
import 'package:flutter/services.dart';

class LinkButton extends StatelessWidget {

  const LinkButton({
    Key? key
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);
    final CnStandardPopUp cnStandardPopUp = Provider.of<CnStandardPopUp>(context, listen: false);

    return SizedBox(
      width: 50,
      height: 50,
      child: IconButton(
        key: cnNewWorkout.keyAddLink,
        icon: const Icon(Icons.add_link, color: Color(0xFF5F9561)),
        onPressed: ()async{
          if(cnNewWorkout.panelController.isPanelClosed){
            HapticFeedback.selectionClick();
            await cnNewWorkout.openPanel();
          }
          cnStandardPopUp.open(
              context: context,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardAppearance: Brightness.dark,
                      maxLength: 15,
                      keyboardType: TextInputType.text,
                      controller: cnNewWorkout.linkNameController,
                      style: const TextStyle(
                          fontSize: 20
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                        labelText: AppLocalizations.of(context)!.groupName,
                        counterText: "",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8 ,vertical: 8.0),
                        suffixIcon: IconButton(
                            onPressed: () async{
                              HapticFeedback.selectionClick();
                              await getExplainExerciseGroups(context);
                              HapticFeedback.selectionClick();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            icon: Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white54,
                            )
                        )
                      ),
                      onChanged: (value){},
                    ),
                  ),
                ],
              ),
              onConfirm: (){
                cnNewWorkout.addLink(context, cn: cnStandardPopUp);
              },
              onCancel: (){
                cnNewWorkout.linkNameController.clear();
                Future.delayed(Duration(milliseconds: cnStandardPopUp.animationTime*2), (){
                  FocusScope.of(context).unfocus();
                });
              },
          );
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
          shape: MaterialStateProperty.all(RoundedRectangleBorder( borderRadius: BorderRadius.circular(10))),
        ),
      ),
    );
  }
}