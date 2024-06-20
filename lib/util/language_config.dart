import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';

List<Locale> supportedLocales = const [
  Locale('en'),
  Locale('de'),
  Locale('es'),
  Locale('fr'),
  Locale('it'),
  Locale('nl'),
  Locale('pl'),
  Locale('pt'),
];

class Language{
  final String languageCode;
  final String countryCode;

  Language({required this.languageCode, required this.countryCode});
}

String getLanguageAsString(BuildContext context){
  final lan =  Localizations.localeOf(context).toString();
  if(lan == "en"){
    return "English";
  }
  else if(lan == "es"){
    return "Español";
  }
  else if(lan == "fr"){
    return "Français";
  }
  else if(lan == "it"){
    return "Italiano";
  }
  else if(lan == "nl"){
    return "Nederlands";
  }
  else if(lan == "pt"){
    return "Português";
  }
  else if(lan == "pl"){
    return "Polski";
  }
  else{
    return "Deutsch";
  }
}

Map<String, String> languagesAsString = {
  "Deutsch": "de",
  "English": "en",
  "Español": "es",
  "Français": "fr",
  "Italiano": "it",
  "Nederlands": "nl",
  "Português": "pt",
  "Polski": "pl",
};

Map languages = {
  "de": Language(languageCode: "de", countryCode: "de_DE"),
  "de_DE": Language(languageCode: "de", countryCode: "de_DE"),

  "en": Language(languageCode: "en", countryCode: "en_US"),
  "en_US": Language(languageCode: "en", countryCode: "en_US"),

  "es": Language(languageCode: "es", countryCode: "es_ES"),
  "es_ES": Language(languageCode: "es", countryCode: "es_ES"),

  "fr": Language(languageCode: "fr", countryCode: "fr_FR"),
  "fr_FR": Language(languageCode: "fr", countryCode: "fr_FR"),

  "it": Language(languageCode: "it", countryCode: "it_IT"),
  "it_IT": Language(languageCode: "it", countryCode: "it_IT"),

  "nl": Language(languageCode: "nl", countryCode: "nl_NL"),
  "nl_NL": Language(languageCode: "nl", countryCode: "nl_NL"),

  "pl": Language(languageCode: "pl", countryCode: "pl_PL"),
  "pl_PL": Language(languageCode: "pl", countryCode: "pl_PL"),

  "pt": Language(languageCode: "pt", countryCode: "pt_PT"),
  "pt_PT": Language(languageCode: "pt", countryCode: "pt_PT"),
};

Future<Language> initFromSystemLanguage()async{
  final res = await findSystemLocale();
  return languages[res]?? languages["en"];
}

enum LANGUAGES{
  de ("de"),
  en ("en"),
  es ("es"),
  fr ("fr"),
  it ("it"),
  nl ("nl"),
  pl ("pl"),
  pt ("pt");

  const LANGUAGES(this.value);
  final String value;
}

Future setIntlLanguage({String? countryCode})async{
  final res = await findSystemLocale();
  Intl.systemLocale = countryCode?? res;
}