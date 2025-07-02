import 'package:flutter/cupertino.dart';

class AllExercisesSeparator extends StatelessWidget {
  const AllExercisesSeparator({super.key});

  static const double height = 0.2;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(left: 20),
      color: CupertinoColors.systemGrey.withOpacity(0.5),
    );
  }
}
