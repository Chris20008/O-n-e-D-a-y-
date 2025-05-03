import '../../../../../../../../objects/exercise.dart';
import '../../../../../../../../util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SetHeaderRow extends StatelessWidget {

  final Exercise exercise;

  const SetHeaderRow({
    super.key,
    required this.exercise
  });
  final double _widthOfTextField = 55;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            width: _widthOfTextField,
            child: OverflowSafeText(
              AppLocalizations.of(context)!.set,
              textAlign: TextAlign.center,
              // fontSize: 12,
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70
              ),
              minFontSize: 12,
              maxLines: 1,
            )
        ),
        Expanded(
            flex: 2,
            child: OverflowSafeText(
                AppLocalizations.of(context)!.template,
                textAlign: TextAlign.center,
                // fontSize: 12,
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70
                ),
                minFontSize: 12,
                maxLines: 1
            )
        ),
        /// TextField Headers
        Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: _widthOfTextField+10,
                    child: OverflowSafeText(
                      // AppLocalizations.of(context)!.weight,
                        exercise.getLeftTitle(context),
                        textAlign: TextAlign.center,
                        // fontSize: 12,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70
                        ),
                        minFontSize: 12,
                        maxLines: 1
                    )
                ),
                const SizedBox(width: 4,),
                SizedBox(
                    width: _widthOfTextField+10,
                    child: OverflowSafeText(
                      // AppLocalizations.of(context)!.amount,
                        exercise.getRightTitle(context),
                        textAlign: TextAlign.center,
                        // fontSize: 12,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70
                        ),
                        minFontSize: 12,
                        maxLines: 1
                    )
                )
              ],
            )
        )
      ],
    );
  }
}
