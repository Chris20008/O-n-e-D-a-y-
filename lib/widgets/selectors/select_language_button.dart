import 'package:fitness_app/util/language_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/services.dart';
import 'package:pull_down_button/pull_down_button.dart';

class SelectLanguageButton extends StatelessWidget {

  final CnConfig cnConfig;
  final PullDownMenuAnchor buttonAnchor;
  final Widget buttonChild;

  const SelectLanguageButton({
    super.key,
    required this.cnConfig,
    required this.buttonChild,
    this.buttonAnchor = PullDownMenuAnchor.end
  });

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      buttonAnchor: buttonAnchor,
      onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
      routeTheme: routeTheme,
      itemBuilder: (context) {
        final currentLanguage = getLanguageAsString(context);
        final List<String> lanAsStrings = languagesAsString.keys.toList();
        List<PullDownMenuItem> buttons = List.generate(lanAsStrings.length, (index) {
          return PullDownMenuItem.selectable(
            selected: currentLanguage == lanAsStrings[index],
            title: lanAsStrings[index],
            onTap: () {
              HapticFeedback.selectionClick();
              Future.delayed(const Duration(milliseconds: 200), (){
                MyApp.of(context)?.setLocale(languageCode: languagesAsString[lanAsStrings[index]], config: cnConfig);
              });
            },
          );
        });
        return buttons;
      },
      buttonBuilder: (context, showMenu) => CupertinoButton(
        onPressed: (){
          HapticFeedback.selectionClick();
          showMenu();
        },
        padding: EdgeInsets.zero,
        child: buttonChild,
      ),
    );
  }
}
