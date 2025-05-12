import 'package:flutter/cupertino.dart';
import 'package:fitness_app/widgets/cupertino_button_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FilterStatisticsHeader extends StatelessWidget {
  const FilterStatisticsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              flex: 10,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: CupertinoButtonText(
                      onPressed: (){
                        Navigator.of(context).pop(false);
                      },
                      text: AppLocalizations.of(context)!.cancel,
                      textAlign: TextAlign.left
                  )
              )
          ),
          Expanded(
              flex: 11,
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.statisticsFilter,
                  textScaler: const TextScaler.linear(1.3),
                  textAlign: TextAlign.center,
                ),
              )
          ),
          Expanded(
              flex: 10,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButtonText(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      text: AppLocalizations.of(context)!.save,
                      textAlign: TextAlign.right
                  )
              )
          ),
        ],
      ),
    );
  }
}
