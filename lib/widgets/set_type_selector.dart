import 'package:fitness_app/objects/exercise.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../util/constants.dart' show routeTheme;

class SetTypeSelector extends StatelessWidget {

  final int index;
  final Exercise newEx;
  final double width;
  final Function onConfirm;
  final double height;

  const SetTypeSelector({
    super.key,
    required this.index,
    required this.newEx,
    required this.width,
    required this.onConfirm,
    this.height = 30,
  });

  @override
  Widget build(BuildContext context) {
    final SingleSet s = newEx.sets[index];

    return SizedBox(
      height: height,
      child: PullDownButton(
        onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
        routeTheme: routeTheme,
        itemBuilder: (context) {
          return [
            PullDownMenuItem.selectable(
              selected: s.setType == 0,
              title: 'Working Set',
              onTap: () {
                // HapticFeedback.selectionClick();
                FocusManager.instance.primaryFocus?.unfocus();
                Future.delayed(const Duration(milliseconds: 200), (){
                  s.setType = 0;
                  onConfirm();
                });
              },
            ),
            PullDownMenuItem.selectable(
              selected: s.setType == 1,
              title: 'Warm-Up Set',
              icon: Icons.circle,
              iconColor: Colors.blue,
              onTap: () {
                // HapticFeedback.selectionClick();
                FocusManager.instance.primaryFocus?.unfocus();
                Future.delayed(const Duration(milliseconds: 200), (){
                  s.setType = 1;
                  onConfirm();
                });
              },
            ),
            // const PullDownMenuDivider.large(),
            // rpePullDownMenuItem(s, 1),
            // rpePullDownMenuItem(s, 2),
            // rpePullDownMenuItem(s, 3),
            // rpePullDownMenuItem(s, 4),
            // rpePullDownMenuItem(s, 5),
            // rpePullDownMenuItem(s, 6),
            // rpePullDownMenuItem(s, 7),
            // rpePullDownMenuItem(s, 8),
            // rpePullDownMenuItem(s, 9),
            // rpePullDownMenuItem(s, 10)
          ];
        },
        buttonBuilder: (context, showMenu) => CupertinoButton(
          onPressed: (){
            // HapticFeedback.selectionClick();
            FocusManager.instance.primaryFocus?.unfocus();
            showMenu();
          },
          padding: EdgeInsets.zero,
          child: SizedBox(
            // color: Colors.red,
            height: height,
            width: width,
            child: Stack(
              // alignment: Alignment.center,
              children: [
                if(s.setType == 1)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(left: 1.5),
                      width: height * (0.75 + (index + 1).toString().length/4),
                      height: height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(height/2),
                        border: Border.all(
                          color: Colors.blue,
                          width: 0.8,
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: Text(
                    textAlign: TextAlign.center,
                    "${index +1 }",
                    textScaler: const TextScaler.linear(1.2),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                if(s.setType != null && s.setType! > 10)
                  Align(
                      alignment: Alignment.bottomRight,
                      child:Padding(
                        padding: EdgeInsets.only(right: index < 10? (s.setType == 20? 5 : 10) : (s.setType == 20? 0 : 5)),
                        child: Text(
                          "${s.setType!-10}",
                          textScaler: const TextScaler.linear(0.7),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700
                          ),
                        ),
                      )
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}