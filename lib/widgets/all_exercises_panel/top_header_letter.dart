import 'dart:ui';

import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/widgets/all_exercises_panel/all_exercises_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        cnAllExercisesPanel.scrollController.addListener(() {
          updateHeader();
        });
      }
    });
  }

  updateHeader({bool withRefresh = true}){
    bool doRefresh = false;
    if(cnAllExercisesPanel.filteredExercises.isEmpty){
      return;
    }
    initSize();
    final index = (
        (cnAllExercisesPanel.scrollController.position.pixels-10) ~/ (sizeListTile+0.25)
    ).clamp(0, cnAllExercisesPanel.filteredExercises.length-1);

    if(cnAllExercisesPanel.scrollController.position.pixels <= 15 && doBlur){
      doBlur = false;
      doRefresh = true;
    } else if(cnAllExercisesPanel.scrollController.position.pixels > 15 && !doBlur){
      doBlur = true;
      doRefresh = true;
    }

    if(cnAllExercisesPanel.filteredExercises[index].name[0] != currTopLetter){
      currTopLetter = cnAllExercisesPanel.filteredExercises[index].name[0].toUpperCase();
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
        child: Text(currTopLetter, style: const TextStyle(color: Colors.grey),)
    );
    if(!doBlur){
      return Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
              height: 45,
              width: double.maxFinite,
              color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.only(left: 30),
              child: text
          )
      );
    }
    return Positioned(
        left: 0,
        right: 0,
        top: 0,
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: 60.0,
                sigmaY: 60.0,
                tileMode: TileMode.mirror
            ),
            child: Container(
                height: 45,
                width: double.maxFinite,
                color: Colors.transparent,
                padding: EdgeInsets.only(left: 30),
                child: text
            ),
          ),
        )
    );
  }

  void initSize(){
    if(sizeListTile == 0){
      sizeListTile = getWidgetSize(cnAllExercisesPanel.keyFirstListTile).height;
    }
  }
}
