import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChildLeftHeaderRow extends StatelessWidget {
  const ChildLeftHeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.arrow_back_ios,
            size: 18,
            color: Colors.amber[800]?? const Color(0xFFFF9A19),
          ),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context)!.welcomeBack,
            style: TextStyle(
                color: Colors.amber[800]?? const Color(0xFFFF9A19)
            ),
          )
        ],
      ),
    );
  }
}
