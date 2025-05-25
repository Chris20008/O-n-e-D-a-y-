import 'dart:io';
import 'dart:math';

import 'package:fitness_app/main.dart';
import'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../all_exercises_panel.dart';

class LetterSideBar extends StatelessWidget {
  const LetterSideBar({super.key});

  @override
  Widget build(BuildContext context) {

    const bottomPaddingForSearchBar = 90;

    final double maxHeightSideBar = MediaQuery.of(context).size.height * 0.7;
    double minHeight = min(
        MediaQuery.of(context).size.height
        - MediaQuery.of(context).viewInsets.bottom
        - bottomPaddingForSearchBar
        - (Platform.isAndroid? 110 : 130)
        , maxHeightSideBar
    );
    final double heightSideBar = (maxHeightSideBar - MediaQuery.of(context).viewInsets.bottom*0.85).clamp(minHeight, maxHeightSideBar);

    final cnAllExercisesPanel = context.read<CnAllExercisesPanel>();
    final characters = context.select<CnAllExercisesPanel, List<TileItem>>((cn) => cn.characters);

    return ValueListenableBuilder(
        valueListenable: cnAllExercisesPanel.verticalPaddingSideBar,
        builder: (_, verticalPaddingSideBar, __) {
        return Positioned(
          bottom: bottomPaddingForSearchBar - verticalPaddingSideBar + MediaQuery.of(context).viewInsets.bottom,
          right: 0,
          child: Listener(
            onPointerDown: (details) {
              cnAllExercisesPanel.jumpToLetter(details, heightSideBar);
            },
            onPointerMove: (details){
              cnAllExercisesPanel.jumpToLetter(details, heightSideBar);
            },
            onPointerUp: (details){
              cnAllExercisesPanel.jumpToLetter(details, heightSideBar);
            },
            child: GestureDetector(
              onVerticalDragUpdate: (_){},
              child: Container(
                  key: cnAllExercisesPanel.keySideBar,
                  color: Colors.transparent,
                  height: heightSideBar,
                  // height: double.maxFinite,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: characters.map((letter) {
                      return Text(
                          letter.name,
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).viewInsets.bottom >= 20? 8 : 13,
                              fontWeight: FontWeight.bold,
                              color: buttonTextColor
                          )
                      );
                    }).toList(),
                  )
              ),
            ),
          ),
        );
      }
    );
  }
}
