import 'package:flutter/cupertino.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectorContactButton extends StatelessWidget {
  const SelectorContactButton({super.key});

  Future<void> sendMail({required String subject}) async {
    const email = "OneDayApp@icloud.com";
    final String emailSubject = subject;
    final Uri parsedMailto = Uri.parse("mailto:<$email>?subject=$emailSubject");
    if (!await launchUrl(
      parsedMailto,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not send Mail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      useRootNavigator: true,
      onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
      routeTheme: routeTheme,
      itemBuilder: (context) {
        return [
          PullDownMenuItem(
            title: AppLocalizations.of(context)!.settingsQuestion,
            onTap: () {
              HapticFeedback.selectionClick();
              Future.delayed(const Duration(milliseconds: 200), (){
                sendMail(subject: "Question");
              });
            },
          ),
          PullDownMenuItem(
            title: AppLocalizations.of(context)!.settingsReportProblem,
            onTap: () {
              HapticFeedback.selectionClick();
              Future.delayed(const Duration(milliseconds: 200), (){
                sendMail(subject: "Report Problem");
              });
            },
          ),
          PullDownMenuItem(
            title: AppLocalizations.of(context)!.settingsImprovement,
            onTap: () {
              HapticFeedback.selectionClick();
              Future.delayed(const Duration(milliseconds: 200), (){
                sendMail(subject: "Suggestion for Improvement");
              });
            },
          ),
          PullDownMenuItem(
            title: AppLocalizations.of(context)!.settingsOther,
            onTap: () {
              HapticFeedback.selectionClick();
              Future.delayed(const Duration(milliseconds: 200), (){
                sendMail(subject: "");
              });
            },
          ),
        ];
      },
      buttonBuilder: (context, showMenu) => CupertinoButton(
          onPressed: (){
            HapticFeedback.selectionClick();
            showMenu();
          },
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              Text(AppLocalizations.of(context)!.settingsContact, style: const TextStyle(color: Colors.white)),
              const Spacer(),
              trailingChoice()
            ],
          )
      ),
    );
  }
}
