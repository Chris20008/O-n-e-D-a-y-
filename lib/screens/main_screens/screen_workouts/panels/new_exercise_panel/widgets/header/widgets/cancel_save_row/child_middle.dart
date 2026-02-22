import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitness_app/l10n/app_localizations.dart';

class ChildMiddle extends StatelessWidget {
  const ChildMiddle({super.key});

  @override
  Widget build(BuildContext context) {

    return Text(
      AppLocalizations.of(context)!.exercise,
      style: const TextStyle(fontSize: 17),
      textAlign: TextAlign.center,
    );
  }
}
