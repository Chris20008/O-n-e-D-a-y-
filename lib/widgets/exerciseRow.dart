import 'package:flutter/material.dart';
import '../objects/exercise.dart';

class exerciseRow extends StatelessWidget {
  final Exercise exercise;
  final double textScaleFactor;
  final EdgeInsetsGeometry? padding;

  const exerciseRow({
    super.key,
    required this.exercise,
    this.textScaleFactor = 1,
    this.padding
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding?? const EdgeInsets.all(0),
      child: Row(
        children: [
          Expanded(
              flex:3,
              child: Text(exercise.name, textScaleFactor: textScaleFactor,)
          ),
          Expanded(
            flex: 7,
            child: SizedBox(
              height: 60,
              child: ListView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (var set in exercise.sets)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 3, right: 3),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 30,
                                decoration: BoxDecoration(
                                    color: Colors.grey[500]!.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5),
                                    // border: Border.all(color: Colors.black, width: 1)
                                  // border: BoxBorder
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text("${set.weight}"),
                                  Container(
                                    color: Colors.grey[900],
                                    height: 1,
                                    width: 15,
                                  ),
                                  Text("${set.amount}")
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                  ]
              ),
            ),
          )
        ],
      ),
    );
  }
}
