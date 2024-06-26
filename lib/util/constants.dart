import 'dart:convert';
import 'dart:io';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:collection/collection.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../objectbox.g.dart';
import '../objects/workout.dart';
import '../screens/main_screens/screen_workouts/panels/new_workout_panel.dart';

List<Color> linkColors = [
  const Color(0xFF5F9561),
  const Color(0xFFFFEA30),
  const Color(0xFF558FDF),
  const Color(0xFFF48E40),
  const Color(0xFFA349D1),
  const Color(0xFF8AEAC3),
  const Color(0xFF4F8447),
];

const folderNameGoogleDrive = "OneDay Backups";

const List<int> predefinedTimes = [
  30,
  60,
  90,
  120,
  150,
  180,
  210,
  240,
  270,
  300
];

String mapRestInSecondsToString({required int restInSeconds, bool short = true}){
  if (restInSeconds == 0) {
    return ("-");
  }
  else if (restInSeconds < 60) {
    return "${restInSeconds}s";
  }
  else if (restInSeconds % 60 != 0) {
    int seconds = restInSeconds % 60;
    final secondsString = seconds > 9? seconds.toString() : "0$seconds";
    if(short){
      return "${(restInSeconds / 60).floor()}:${secondsString}m";
    }
    return "${(restInSeconds / 60).floor()}:$secondsString min";
  }
  else {
    if(short){
      return "${(restInSeconds / 60).round()}m";
    }
    return "${(restInSeconds / 60).floor()}:00 min";
  }
}

const routeTheme = PullDownMenuRouteTheme(
    backgroundColor: CupertinoColors.secondaryLabel
);

const trailingArrow = Icon(
  Icons.arrow_forward_ios,
  size: 12,
  color: Colors.grey,
);

Color? getLinkColor({required String linkName, required Workout workout}){
  int index = workout.linkedExercises.indexOf(linkName);
  if(index >= 0){
    return linkColors[index % linkColors.length];
  }
  return null;
}

Widget mySeparator({double heightTop = 20, double heightBottom = 20, double minusWidth = 50, double opacity = 0.4}){
  return Column(
    children: [
      SizedBox(height: heightTop),
      Container(
        height: 1,
        width: double.maxFinite - minusWidth,
        // color: const Color(0xFFC16A03).withOpacity(opacity),
          color: Colors.amber[900]!.withOpacity(opacity)
        // color: Colors.amber[900]!.withOpacity(0.6),
      ),
      SizedBox(height: heightBottom),
    ],
  );
}

Future openUrl(String url)async{
  final Uri parsedUrl = Uri.parse(url);
  if (!await launchUrl(parsedUrl)) {
    throw Exception('Could not launch $parsedUrl');
  }
}

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

String getLanguageAsString(BuildContext context){
  final lan =  Localizations.localeOf(context).toString();
  if(lan == "en"){
    return "English";
  } else{
    return "Deutsch";
  }
}

Widget verticalGreySpacer = Container(
  height: double.maxFinite,
  width: 0.5,
  color: Colors.grey[700]!.withOpacity(0.5),
);

Widget horizontalGreySpacer = Container(
  height: 0.5,
  width: double.maxFinite,
  color: Colors.grey[700]!.withOpacity(0.5),
);

Widget panelTopBar = Container(
  height: 2,
  width: 40,
  decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.5),
      borderRadius: BorderRadius.circular(2)
  ),
);

Widget standardDialog({
  required BuildContext context,
  required Widget child,
  double widthFactor = 0.8,
  double maxWidth = 330,
  double maxHeight = 800,
  EdgeInsets padding = const EdgeInsets.all(10),
  TextStyle? confirmTextStyle,
}){
  return ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: ConstrainedBox(
      constraints: BoxConstraints(
          minWidth: 150,
          minHeight: 100,
          maxWidth: maxWidth,
          maxHeight: [maxHeight, MediaQuery.of(context).size.height-150].min
      ),
      child: Container(
          width: MediaQuery.of(context).size.width * widthFactor,
          color: Theme.of(context).primaryColor,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: padding,
              child: child,
            ),
          )
      ),
    ),
  );
}

TextStyle getTextStyleForTextField(String text, {Color? color}){
  return TextStyle(
    fontSize: text.length < 4
    ?18
    : text.length < 5
    ? 16
    : text.length < 6
    ? 13 : 10,
    color: color,
  );
}

Widget getSelectRestInSeconds({
  required Widget child,
  required Function(dynamic value) onConfirm
}) {
  return PullDownButton(
    buttonAnchor: PullDownMenuAnchor.start,
    routeTheme: routeTheme,
    itemBuilder: (context) {
      List times = List.from(predefinedTimes);
      times.insert(0, "Clear");
      times.insert(1, "Custom");
      List<PullDownMenuItem> timeWidgets = List.generate(times.length, (index) => PullDownMenuItem(
          title: times[index] is String? times[index] : mapRestInSecondsToString(restInSeconds: times[index], short: false),
          onTap: () {
            HapticFeedback.selectionClick();
            FocusManager.instance.primaryFocus?.unfocus();
            Future.delayed(const Duration(milliseconds: 200), (){
              onConfirm(times[index]);
            });
          })
      );
      return [
        ...timeWidgets.sublist(0, 2),
        const PullDownMenuDivider.large(),
        ...timeWidgets.sublist(2),
      ];
    },
    onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
    buttonBuilder: (context, showMenu) => CupertinoButton(
      onPressed: (){
        HapticFeedback.selectionClick();
        showMenu();
      },
      padding: EdgeInsets.zero,
      child: child
    ),
  );
}

Widget getSelectSeatLevel({
  required Widget child,
  required Function(dynamic value) onConfirm
}) {
  return PullDownButton(
    buttonAnchor: PullDownMenuAnchor.start,
    routeTheme: routeTheme,
    itemBuilder: (context) {
      List seatLevels = List.generate(21, (index) => index);
      seatLevels.insert(0, "Clear");
      List<PullDownMenuItem> seatLevelWidgets = List.generate(seatLevels.length, (index) => PullDownMenuItem(
          title: seatLevels[index] is String? seatLevels[index] : seatLevels[index].toString(),
          onTap: () {
            HapticFeedback.selectionClick();
            FocusManager.instance.primaryFocus?.unfocus();
            Future.delayed(const Duration(milliseconds: 200), (){
              onConfirm(seatLevels[index]);
            });
          })
      );
      return [
        seatLevelWidgets.first,
        const PullDownMenuDivider.large(),
        ...seatLevelWidgets.sublist(1)
      ];
    },
    onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
    buttonBuilder: (context, showMenu) => CupertinoButton(
        onPressed: (){
          HapticFeedback.selectionClick();
          showMenu();
        },
        padding: EdgeInsets.zero,
        child: child
    ),
  );
}

String validateDoubleTextInput(String text){
  text = text.replaceAll(",", ".");
  if(text.characters.last == "."){
    final count = ".".allMatches(text).length;
    if(count > 1){
      text = text.substring(0, text.length-1);
    }
  }
  if(text.characters.first == "."){
    text = "0$text";
  }
  return text;
}

String checkOnlyOneDecimalPoint(String text){
  if(text.characters.last == "."){
    final count = ".".allMatches(text).length;
    if(count > 1){
      text = text.substring(0, text.length-1);
    }
  }
  return text;
}

Future setIntlLanguage({String? countryCode})async{
  final res = await findSystemLocale();
  Intl.systemLocale = countryCode?? res;
  // print("SET LAGNUAGE TO: $res");
  // print(context.mounted);
  // MyApp.of(context)?.setLocale(languageCode: countryCode?? res);
}

class Language{
  final String languageCode;
  final String countryCode;

  Language({required this.languageCode, required this.countryCode});
}

Map languages = {
  "de": Language(languageCode: "de", countryCode: "de_DE"),
  "de_DE": Language(languageCode: "de", countryCode: "de_DE"),
  "en": Language(languageCode: "en", countryCode: "en_US"),
  "en_US": Language(languageCode: "en", countryCode: "en_US")
};

Future<Language> initFromSystemLanguage()async{
  final res = await findSystemLocale();
  return languages[res]?? languages["en"];
}

enum LANGUAGES{
  de ("de"),
  en ("en");

  const LANGUAGES(this.value);
  final String value;
}

Widget myIconButton({required Icon icon, Function()? onPressed, Key? key}){
  Widget iconButton = IconButton(
    key: key,
    iconSize: 25,
    onPressed: onPressed,
    icon: icon,
  );
  return ClipRRect(
    borderRadius: BorderRadius.circular(40),
    child: SizedBox(
      height: 40,
      width: 40,
      // color: Colors.grey.withOpacity(0.3),
      child: iconButton
    ),
  );
}

// enum TimeInterval {
//   // monthly ("Monthly"),
//   // quarterly ("Quarterly"),
//   yearly ("Yearly");
//
//   const TimeInterval(this.value);
//   final String value;
// }

Widget OverflowSafeText(
    String name,
    {
      int maxLines = 2,
      double? fontSize = 17,
      double? minFontSize = 10,
      TextStyle? style,
      TextAlign? textAlign
    })
{
  fontSize = fontSize?? 17;
  minFontSize = minFontSize?? 10;
  return AutoSizeText(
    name,
    maxLines: maxLines,
    style: style?? TextStyle(fontSize: fontSize, color: Colors.white),
    minFontSize: minFontSize,
    overflow: TextOverflow.ellipsis,
    textAlign: textAlign,
  );
}



List getWorkoutsAsStringList(){
  final allObWorkouts = objectbox.workoutBox.getAll();
  final allWorkouts = List<String>.from(allObWorkouts.map((e) => jsonEncode(e.asMap())));
  return allWorkouts;
}

Future<Directory?> getDirectory() async{
  if(Platform.isAndroid){
    return await getExternalStorageDirectory();
  }
  else{
    return await getApplicationDocumentsDirectory();
  }
}

Future<bool> hasInternet()async{
  final conRes = await Connectivity().checkConnectivity();
  List<ConnectivityResult> options = [ConnectivityResult.mobile, ConnectivityResult.wifi, ConnectivityResult.vpn];
  // print("CON RES RESULT: $conRes - ${[ConnectivityResult.mobile, ConnectivityResult.wifi, ConnectivityResult.vpn].contains(conRes)}");
  return options.any((option) => conRes.contains(option));
}

void vibrateCancel(){
  HapticFeedback.selectionClick();
  Future.delayed(const Duration(milliseconds: 180), (){
    HapticFeedback.heavyImpact();
  });
}

void vibrateConfirm(){
  HapticFeedback.mediumImpact();
  Future.delayed(const Duration(milliseconds: 180), (){
    HapticFeedback.selectionClick();
  });
}

void vibrateSuccess(){
  HapticFeedback.heavyImpact();
  Future.delayed(const Duration(milliseconds: 100), (){
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 100), (){
      HapticFeedback.heavyImpact();
    });
  });
}

bool workoutNameExistsInTemplates({required String workoutName}){
  final result = objectbox.workoutBox.query(ObWorkout_.name.equals(workoutName, caseSensitive: false).and(ObWorkout_.isTemplate.equals(true))).build().findFirst();
  if(result == null){
    return false;
  }
  return true;
}

bool exerciseNameExistsInWorkout({required Workout workout, required String exerciseName}){
  return workout.exercises.map((e) => e.name.toLowerCase()).contains(exerciseName.toLowerCase());
}

Widget buildCalendarDialogButton({
  required BuildContext context,
  required CnNewWorkOutPanel cnNewWorkout,
  bool justShow = false,
  Function? onConfirm,
  bool buttonIsCalender = false
}) {
  const colorAmber = Color(0xFFC16A03);
  const arrowSize = 15.0;
  const dayTextStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.w700);
  final weekendTextStyle = TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w600);
  final config = CalendarDatePicker2WithActionButtonsConfig(
    // cancelButton: justShow? Container() : null,
    // okButton: justShow? Container() : null,
    lastMonthIcon: const Icon(
      Icons.arrow_back_ios,
      size: arrowSize,
      color: colorAmber,
    ),
    nextMonthIcon: const Icon(
      Icons.arrow_forward_ios,
      size: arrowSize,
      color: colorAmber,
    ),
    disableMonthPicker: true,
    gapBetweenCalendarAndButtons: 0,
    daySplashColor: Colors.transparent,
    // buttonPadding: justShow? const EdgeInsets.only(right: 100) : null,
    dayTextStyle: dayTextStyle,
    // closeDialogOnOkTapped: !justShow,
    // closeDialogOnCancelTapped: !justShow,
    calendarType: CalendarDatePicker2Type.single,
    selectedDayHighlightColor: colorAmber,
    // closeDialogOnCancelTapped: true,
    firstDayOfWeek: 1,

    weekdayLabelTextStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    controlsTextStyle: const TextStyle(
      color: colorAmber,
      fontSize: 15,
      fontWeight: FontWeight.bold,
    ),
    centerAlignModePicker: true,
    customModePickerIcon: const SizedBox(),
    selectedDayTextStyle: dayTextStyle.copyWith(color: Colors.white),
    dayTextStylePredicate: ({required date}) {
      TextStyle? textStyle;
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        textStyle = weekendTextStyle;
      }
      return textStyle;
    },
    monthTextStyle: const TextStyle(color: Colors.white),
    yearTextStyle: const TextStyle(color: Colors.white),
    dayBuilder: ({
      required date,
      textStyle,
      decoration,
      isSelected,
      isDisabled,
      isToday,
    }) {
      Widget? dayWidget;
      bool exists = false;
      late DateTime relevantDate;
      for(DateTime d in cnNewWorkout.allWorkoutDates.keys){
        if(d.isSameDate(date)){
          exists = true;
          relevantDate = d;
          break;
        }
      }
      if (exists) {
        dayWidget = Container(
          decoration: decoration,
          child: Center(
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Text(
                  MaterialLocalizations.of(context).formatDecimal(date.day),
                  style: textStyle,
                ),
                /// Workout Name as Label
                Padding(
                    padding: const EdgeInsets.only(top: 26.5, left: 2, right: 2),
                    child: OverflowSafeText(
                        cnNewWorkout.allWorkoutDates[relevantDate] is List? "${cnNewWorkout.allWorkoutDates[relevantDate].length} workouts" : cnNewWorkout.allWorkoutDates[relevantDate],
                        maxLines: 1,
                        fontSize: 5,
                        textAlign: TextAlign.center,
                        // minFontSize: 4,
                        style: TextStyle(
                            color: (isSelected?? false)
                                ? Colors.white
                                : date.isSameDate(cnNewWorkout.originalWorkout.date) && !justShow
                                ? const Color(0xFFFFD995)
                                : colorAmber)
                    )
                ),
                // only dot indicator
                // Padding(
                //   padding: const EdgeInsets.only(top: 27.5),
                //   child: Container(
                //     height: 5,
                //     width: 5,
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(5),
                //       color: date.isSameDate(cnNewWorkout.originalWorkout.date)? Colors.blue : colorAmber,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      }
      return dayWidget;
    },
  );
  return CupertinoButton(
    onPressed: () async {
      cnNewWorkout.getAllWorkoutDays();
      HapticFeedback.selectionClick();
      final values = await showCalendarDatePicker2Dialog(
        context: context,
        config: config,
        dialogSize: const Size(325, 400),
        borderRadius: BorderRadius.circular(15),
        value: [cnNewWorkout.workout.date],
        dialogBackgroundColor: Theme.of(context).primaryColor,
      );
      if (values != null && onConfirm != null) {
        onConfirm(values);
      }
    },
    child: buttonIsCalender
        ? const Icon(
          Icons.calendar_month,
          size: 30,
          color: Colors.white
        )
        : Text(
          DateFormat('EEEE d. MMMM', Localizations.localeOf(context).languageCode).format(cnNewWorkout.workout.date!),
          style: const TextStyle(
            fontSize: 18,
          ),
    )
  );
}