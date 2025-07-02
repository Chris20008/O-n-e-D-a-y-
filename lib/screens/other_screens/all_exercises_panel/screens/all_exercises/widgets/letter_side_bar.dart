import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:fitness_app/main.dart';
import 'package:fitness_app/util/constants.dart';
import'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../all_exercises_panel.dart';
import 'package:glass/glass.dart';

class LetterSideBar extends StatelessWidget {
  const LetterSideBar({super.key});

  @override
  Widget build(BuildContext context) {

    double bottomPaddingForSearchBar = 70;

    final double maxHeightSideBar = MediaQuery.of(context).size.height * 0.7;
    double minHeight = min(
        MediaQuery.of(context).size.height
        - MediaQuery.of(context).viewInsets.bottom
        - bottomPaddingForSearchBar
        - (Platform.isAndroid? 110 : 130)
        , maxHeightSideBar
    );

    final cnAllExercisesPanel = context.read<CnAllExercisesPanel>();
    final characters = context.select<CnAllExercisesPanel, List<TileItem>>((cn) => cn.characters);

    final double heightSideBar = (maxHeightSideBar - MediaQuery.of(context).viewInsets.bottom*0.8).clamp(minHeight, maxHeightSideBar) / 27 * characters.length;

    final minFontSize = mapValueClamped(
        characters.length.toDouble(),
        0,
        27,
        13,
        8
    );

    String lastLetter = "";

    Timer? resetLetterTimer;

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + bottomPaddingForSearchBar, top: 80),
          child: Align(
            alignment: Alignment.centerRight,
            child: Listener(
              onPointerDown: (details) {
                cnAllExercisesPanel.jumpToLetter(details: details, heightSideBar: heightSideBar, context: context);
              },
              onPointerMove: (details){
                cnAllExercisesPanel.jumpToLetter(details: details, heightSideBar: heightSideBar, context: context);
              },
              onPointerUp: (details){
                cnAllExercisesPanel.jumpToLetter(details: details, heightSideBar: heightSideBar, context: context);
              },
              child: GestureDetector(
                onVerticalDragUpdate: (_){},
                child: Container(
                    color: Colors.red.withValues(alpha: 0),
                    height: heightSideBar,
                    width: 26,
                    // height: double.maxFinite,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      key: cnAllExercisesPanel.getSideBarKey(context),
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: characters.map((letter) {
                        return Text(
                            letter.name,
                            style: TextStyle(
                                fontSize: mapValueClamped(
                                    MediaQuery.of(context).viewInsets.bottom,
                                    0,
                                    250,
                                    13,
                                    minFontSize),
                                fontWeight: FontWeight.bold,
                                color: buttonTextColor
                            )
                        );
                      }).toList(),
                    )
                ),
              ),
            ),
          ),
        ),
        Center(
          child: ValueListenableBuilder(
              valueListenable: cnAllExercisesPanel.lastJumpedLetter,
              builder: (_, lastJumpedLetter, __){

                resetLetterTimer?.cancel();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  lastLetter = lastJumpedLetter;
                });

                resetLetterTimer = Timer(const Duration(milliseconds: 700), (){
                  cnAllExercisesPanel.lastJumpedLetter.value = "";
                });

                return AnimatedOpacity(
                  opacity: lastJumpedLetter != lastLetter && lastJumpedLetter.isNotEmpty? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: true,
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: Center(
                        child: Text(
                          lastJumpedLetter.isNotEmpty? lastJumpedLetter : lastLetter,
                          textScaler: const TextScaler.linear(1.5),
                        ),
                      ),
                    ).asGlass(
                      frosted: true,
                      clipBorderRadius: BorderRadius.circular(12)
                    ),
                  ),
                );
              }
          )
        )
      ],
    );
  }
}
