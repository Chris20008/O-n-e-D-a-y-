import 'package:fitness_app/screens/other_screens/all_exercises_panel/screens/all_exercises/widgets/all_exercises_list/all_exercises_separator.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../all_exercises_panel.dart';

class TopHeaderLetter extends StatefulWidget {
  const TopHeaderLetter({super.key});

  @override
  State<TopHeaderLetter> createState() => _TopHeaderLetterState();
}

class _TopHeaderLetterState extends State<TopHeaderLetter> {
  late CnAllExercisesPanel cnAllExercisesPanel = Provider.of<CnAllExercisesPanel>(context, listen: true);
  String currTopLetter = "A";
  double sizeListTile = 0;
  bool doBlur = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(cnAllExercisesPanel.scrollController.hasClients){
        cnAllExercisesPanel.scrollController.addListener(updateHeader);
      }
    });
  }

  @override
  void dispose(){
    super.dispose();
    cnAllExercisesPanel.scrollController.removeListener(updateHeader);
  }

  updateHeader({bool withRefresh = true}){
    bool doRefresh = false;
    if(cnAllExercisesPanel.filteredExercises.isEmpty){
      return;
    }
    initSize();
    final index = (
        (cnAllExercisesPanel.scrollController.position.pixels-10) ~/ (sizeListTile+ AllExercisesSeparator.height)
    ).clamp(0, cnAllExercisesPanel.filteredExercises.length-1);

    if(cnAllExercisesPanel.filteredExercises[index].name[0] != currTopLetter){
      currTopLetter = cnAllExercisesPanel.filteredExercises[index].name[0].normalizeGermanUmlauts(trimmed: true).toUpperCase();
      doRefresh = true;
    }

    if(doRefresh && withRefresh){
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if(cnAllExercisesPanel.scrollController.hasClients){
      updateHeader(withRefresh: false);
    }
    Widget text = Align(
        alignment: Alignment.centerLeft,
        child: Text(
          currTopLetter,
          textScaler: const TextScaler.linear(1.2),
          style: const TextStyle(
              color: Colors.grey)
        )
    );
    return Container(
        height: 45,
        width: double.maxFinite,
        color: Colors.transparent,
        padding: const EdgeInsets.only(left: 30),
        child: text
    );
  }

  void initSize(){
    if(sizeListTile == 0){
      sizeListTile = getWidgetSize(cnAllExercisesPanel.keyFirstListTile).height;
    }
  }
}
