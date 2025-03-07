import 'dart:io';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:collection/collection.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/objects/exercise.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:fitness_app/widgets/cupertino_button_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:page_indicator_plus/page_indicator_plus.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../objectbox.g.dart';
import '../objects/workout.dart';
import '../screens/main_screens/screen_workouts/panels/new_workout_panel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

List<Color> linkColors = [
  const Color(0xFF5F9561),
  const Color(0xFFFFEA30),
  const Color(0xFF558FDF),
  const Color(0xFFF48E40),
  const Color(0xFFA349D1),
  const Color(0xFF8AEAC3),
  const Color(0xFF4F8447),
];

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

const int maxTutorialStep = 999999;

TextStyle cupButtonTextStyle = TextStyle(color: Colors.amber[800]?? const Color(0xFFFF9A19));

const Color activeColor = Color(0xffdb7b01);

Widget backgroundSingleSet = Container(
  decoration: BoxDecoration(
    // color: Colors.grey[500]!.withOpacity(0.2),
    color: Colors.white.withOpacity(0.15),
    borderRadius: BorderRadius.circular(5),
  ),
);

Widget dataSingleSet(SingleSet set, Exercise exercise){
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Center(
            child: FittedBox(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: (set.weightAsTrimmedDouble?? "").toString(), style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
                    TextSpan(text: exercise.categoryIsCardio()? " km":" kg", style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w400, color: Colors.white))
                  ]
                )
              ),
            ),
          ),
        ),
        Container(
          color: set.setType == 1? Colors.blue : set.setType == 2? Colors.green : Colors.white.withOpacity(0.3),//Colors.grey[900],
          height: 1,
          width: 20,
        ),
        Expanded(
          child: Center(
            child: FittedBox(
              child: RichText(
                  text: TextSpan(
                      children: [
                        TextSpan(
                            text: exercise.categoryIsReps()
                                ? "${set.amount}"
                                : (set.amountAsTime?? "").toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white
                            )
                        ),
                      ]
                  )
              ),
              // child: Text(exercise.categoryIsReps()
              //     ? "${set.amount}"
              //     : (set.amountAsTime?? "").toString(),
              //   style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
              // ),
            ),
          ),
        )
      ],
    ),
  );
}

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
  size: 14,
  color: Colors.grey,
);

Widget trailingChoice({double size = 16, Color color = Colors.grey}){
 return Stack(
   alignment: Alignment.center,
   children: [
     Padding(
         padding: const EdgeInsets.only(bottom: 7),
         child: Icon(Icons.keyboard_arrow_up, size: size, color: color)
     ),
     Padding(
       padding: const EdgeInsets.only(top: 7),
       child: Icon(Icons.keyboard_arrow_down, size: size, color: color),
     ),
   ],
 );
}

Color? getLinkColor({required String linkName, required Workout workout}){
  int index = workout.linkedExercises.indexOf(linkName);
  if(index >= 0){
    return linkColors[index % linkColors.length];
  }
  return null;
}

Widget mySeparator({
  Key? key,
  double heightTop = 20,
  double heightBottom = 20,
  double minusWidth = 50,
  double opacity = 0.4,
  Color? color,
  bool ignoring= true,
  double height = 1,
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  double width = double.maxFinite
}){
  return IgnorePointer(
    key: key,
    ignoring: ignoring,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Container(height: heightTop, color: Colors.transparent,),
        Container(
          height: height,
          width: width - minusWidth,
            color: (color?? Colors.amber[900])!.withOpacity(opacity)
        ),
        Container(height: heightTop, color: Colors.transparent,),
      ],
    ),
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

TextStyle getTextStyleForTextField(String text, {Color? color, bool sizeSmall = true}){
  if(sizeSmall){
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
  return TextStyle(
    fontSize: text.length < 4
    ?18
    : text.length < 5
    ? 17
    : text.length < 6
    ? 14 : 12,
    color: color,
  );
}

TextStyle getTextStyleForSetView(String text){
  return TextStyle(
    // fontSize: text.length < 3
    //     ? 15
    //     : text.length < 4
    //     ? 13
    //     : text.length < 6
    //     ? 11 : 9,
    fontSize: 15,
    fontWeight: text.length > 4? FontWeight.w500 : FontWeight.w400
  );
}

/// returns a List with '(timeAsInt, timeAsString)'
List<dynamic> parseTextControllerAmountToTime(dynamic amount){
  String value = amount.toString().replaceAll(":", "");
  int timeAsInt = int.tryParse(value)?? 0;
  /// if greater 5 digits remove the last until 5
  while(timeAsInt > 99999){
    timeAsInt = (timeAsInt/10).floor();
  }
  String timeAsString = timeAsInt.toString().padLeft(5, "0");
  String hours = timeAsString.substring(0, 1);
  String minutes = timeAsString.substring(1, 3);
  String seconds = timeAsString.substring(3, 5);
  if(timeAsString.substring(0, 1) == "0"){
    timeAsString = "$minutes:$seconds";
  }
  else{
    timeAsString = "$hours:$minutes:$seconds";
  }

  return [timeAsInt, timeAsString];
}

Widget getSelectRestInSeconds({
  required int currentTime,
  required Widget child,
  required Function(dynamic value) onConfirm,
  required BuildContext context
}) {
  return PullDownButton(
    buttonAnchor: PullDownMenuAnchor.start,
    routeTheme: routeTheme,
    itemBuilder: (context) {
      List times = List.from(predefinedTimes);
      times.insert(0, AppLocalizations.of(context)!.clear);
      times.insert(1, AppLocalizations.of(context)!.custom);
      List<PullDownMenuItem> timeWidgets = List.generate(times.length, (index) => PullDownMenuItem.selectable(
          selected: (currentTime == times[index]) || (currentTime > 0 && times[index] == AppLocalizations.of(context)!.custom && !times.contains(currentTime)),
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
  required int? currentSeatLevel,
  required Widget child,
  required Function(dynamic value) onConfirm,
  required BuildContext context
}) {
  return PullDownButton(
    buttonAnchor: PullDownMenuAnchor.start,
    routeTheme: routeTheme,
    itemBuilder: (context) {
      List seatLevels = List.generate(21, (index) => index);
      seatLevels.insert(0, AppLocalizations.of(context)!.clear);
      List<PullDownMenuItem> seatLevelWidgets = List.generate(seatLevels.length, (index) => PullDownMenuItem.selectable(
          selected: currentSeatLevel == null? false : currentSeatLevel == seatLevels[index],
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

Widget getSelectCategory({
  Key? key,
  required Widget child,
  required Function(int category) onConfirm,
  required BuildContext context,
  required int currentCategory
}) {
  return PullDownButton(
    key: key,
    buttonAnchor: PullDownMenuAnchor.start,
    routeTheme: routeTheme,
    itemBuilder: (context) {
      List categories = categoryMapping.keys.toList();
      List<PullDownMenuItem> categoryWidgets = List.generate(categories.length, (index) => PullDownMenuItem.selectable(
          selected: currentCategory == categories[index],
          title: categoryMapping[categories[index]],
          onTap: () {
            HapticFeedback.selectionClick();
            FocusManager.instance.primaryFocus?.unfocus();
            Future.delayed(const Duration(milliseconds: 200), (){
              onConfirm(categories[index]);
            });
          })
      );
      return categoryWidgets;
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

Widget getSelectBodyWeightPercent({
  Key? key,
  required Widget child,
  required Function(int bodyWeight) onConfirm,
  required BuildContext context,
  required double currentBodyWeightPercent
}) {
  return PullDownButton(
    key: key,
    buttonAnchor: PullDownMenuAnchor.start,
    routeTheme: routeTheme,
    itemBuilder: (context) {
      List percents = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
      List<PullDownMenuItem> percentWidgets = List.generate(percents.length, (index) => PullDownMenuItem.selectable(
          selected: currentBodyWeightPercent == percents[index]/100,
          title: "${percents[index]} %",
          onTap: () {
            HapticFeedback.selectionClick();
            FocusManager.instance.primaryFocus?.unfocus();
            Future.delayed(const Duration(milliseconds: 200), (){
              onConfirm(percents[index]);
            });
          })
      );
      return percentWidgets;
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

Widget getSet({
  required int index,
  required Exercise newEx,
  required double width,
  required Function onConfirm,
  double height = 30,
  required BuildContext context
}){

  // PullDownMenuItem rpePullDownMenuItem(SingleSet set, int value){
  //   return PullDownMenuItem.selectable(
  //     selected: set.setType == value+10,
  //     title: 'RPE $value',
  //     onTap: () {
  //       HapticFeedback.selectionClick();
  //       FocusManager.instance.primaryFocus?.unfocus();
  //       Future.delayed(const Duration(milliseconds: 200), (){
  //         set.setType = value+10;
  //         // print(setType);
  //         onConfirm();
  //       });
  //     },
  //   );
  // }

  final SingleSet s = newEx.sets[index];
  return SizedBox(
    height: height,
    child: PullDownButton(
      onCanceled: () => FocusManager.instance.primaryFocus?.unfocus(),
      routeTheme: routeTheme,
      itemBuilder: (context) {
        return [
          PullDownMenuItem.selectable(
            selected: s.setType == 0,
            title: 'Working Set',
            onTap: () {
              HapticFeedback.selectionClick();
              FocusManager.instance.primaryFocus?.unfocus();
              Future.delayed(const Duration(milliseconds: 200), (){
                s.setType = 0;
                onConfirm();
              });
            },
          ),
          PullDownMenuItem.selectable(
            selected: s.setType == 1,
            title: 'Warm-Up Set',
            icon: Icons.circle,
            iconColor: Colors.blue,
            onTap: () {
              HapticFeedback.selectionClick();
              FocusManager.instance.primaryFocus?.unfocus();
              Future.delayed(const Duration(milliseconds: 200), (){
                s.setType = 1;
                onConfirm();
              });
            },
          ),
          // const PullDownMenuDivider.large(),
          // rpePullDownMenuItem(s, 1),
          // rpePullDownMenuItem(s, 2),
          // rpePullDownMenuItem(s, 3),
          // rpePullDownMenuItem(s, 4),
          // rpePullDownMenuItem(s, 5),
          // rpePullDownMenuItem(s, 6),
          // rpePullDownMenuItem(s, 7),
          // rpePullDownMenuItem(s, 8),
          // rpePullDownMenuItem(s, 9),
          // rpePullDownMenuItem(s, 10)
        ];
      },
      buttonBuilder: (context, showMenu) => CupertinoButton(
        onPressed: (){
          HapticFeedback.selectionClick();
          FocusManager.instance.primaryFocus?.unfocus();
          showMenu();
        },
        padding: EdgeInsets.zero,
        child: SizedBox(
          // color: Colors.red,
          height: height,
          width: width,
          child: Stack(
            // alignment: Alignment.center,
            children: [
              if(s.setType == 1)
              Center(
                child: Container(
                  margin: const EdgeInsets.only(left: 1.5),
                  width: height * (0.75 + (index + 1).toString().length/4),
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height/2),
                    border: Border.all(
                      color: Colors.blue,
                      width: 0.8,
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  textAlign: TextAlign.center,
                  "${index +1 }",
                  textScaler: const TextScaler.linear(1.2),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if(s.setType != null && s.setType! > 10)
                Align(
                  alignment: Alignment.bottomRight,
                  child:Padding(
                    padding: EdgeInsets.only(right: index < 10? (s.setType == 20? 5 : 10) : (s.setType == 20? 0 : 5)),
                    child: Text(
                      "${s.setType!-10}",
                      textScaler: const TextScaler.linear(0.7),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700
                      ),
                    ),
                  )
                )
            ],
          ),
        ),
      ),
    ),
  );
}

Future notificationPopUp({
  required BuildContext context,
  required String title,
  required String message
}) async {
  await showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: Column(
        children: [
          Text(title, textScaler: const TextScaler.linear(1.2)),
          const SizedBox(height: 15,)
        ],
      ),
      message: Text(message, textScaler: const TextScaler.linear(1.2)),
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          isDefaultAction: true,
          child: Text('Ok', style: cupButtonTextStyle),
        ),
      ],
    ),
  );
}

String intToLexicographic(int value){
  String result = List.generate(value~/26, (index) => "Z").join();
  result = result + String.fromCharCode(65 + value%26);
  return result;
}

String getSetKeyName(String exName, int index){
  return "${exName}_${intToLexicographic(index)}";
}

double calcEpley({
  required double weight,
  required int reps,
  double bodyWeight = 0
}){
  return double.parse((((weight+bodyWeight) * (1 + 0.0333 * reps)) - bodyWeight).toStringAsFixed(1));
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



Widget myIconButton({required Icon icon, Function()? onPressed, Key? key}){
  Widget iconButton = IconButton(
    key: key,
    // iconSize: 25,
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

Future<bool> hasInternet()async{
  final conRes = await Connectivity().checkConnectivity();
  List<ConnectivityResult> options = [
    ConnectivityResult.mobile,
    ConnectivityResult.wifi,
    ConnectivityResult.vpn
  ];
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
  List<DateTime> dateValues = const [],
  bool justShow = false,
  Function? onConfirm,
  bool buttonIsCalender = false,
  CalendarDatePicker2Type calendarType = CalendarDatePicker2Type.single
}) {
  dateValues = List.from(dateValues.map((e) => e.toDate()));
  const colorAmber = Color(0xFFC16A03);
  // const colorAmberDark = Color(0xFF583305);
  const colorAmberDark = Color(0xFF6D4919);
  const arrowSize = 15.0;
  const dayTextStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.w700);
  final weekendTextStyle = TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w600);
  String translatedSickText = AppLocalizations.of(context)!.statisticsSick;
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
    firstDate: DateTime(2023, 1, 1),
    lastDate: DateTime(DateTime.now().year + 2, 12, 31),
    calendarViewMode: CalendarDatePicker2Mode.scroll,
    disableMonthPicker: false,
    gapBetweenCalendarAndButtons: 0,
    daySplashColor: Colors.transparent,
    // buttonPadding: justShow? const EdgeInsets.only(right: 100) : null,
    dayTextStyle: dayTextStyle,
    // closeDialogOnOkTapped: !justShow,
    // closeDialogOnCancelTapped: !justShow,
    calendarType: calendarType,
    // calendarType: CalendarDatePicker2Type.range,
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
        if(cnNewWorkout.allWorkoutDates[relevantDate] is List && cnNewWorkout.allWorkoutDates[relevantDate].contains("Sick")){
          cnNewWorkout.allWorkoutDates[relevantDate] = (cnNewWorkout.allWorkoutDates[relevantDate] as List).map((e) => !e.contains("Sick")? e : translatedSickText).toList();
        } else if(cnNewWorkout.allWorkoutDates[relevantDate] == "Sick"){
          cnNewWorkout.allWorkoutDates[relevantDate] = translatedSickText;
        }
        String dayText = cnNewWorkout.allWorkoutDates[relevantDate] is List
            ? cnNewWorkout.allWorkoutDates[relevantDate].contains(translatedSickText)
              ?"$translatedSickText + ${cnNewWorkout.allWorkoutDates[relevantDate].length - 1}"
              :"${cnNewWorkout.allWorkoutDates[relevantDate].length} workouts"
            : cnNewWorkout.allWorkoutDates[relevantDate];
        dayWidget = Container(
          decoration: decoration,
          child: Center(
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                if(dateValues.contains(date.toDate()))
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: colorAmber.withOpacity(0.2)
                    ),
                  ),
                Text(
                  MaterialLocalizations.of(context).formatDecimal(date.day),
                  style: textStyle,
                ),
                /// Workout Name as Label
                Padding(
                    padding: const EdgeInsets.only(top: 26.5, left: 2, right: 2),
                    child: OverflowSafeText(
                        dayText,
                        maxLines: 1,
                        // fontSize: 5,
                        textAlign: TextAlign.center,
                        minFontSize: cnNewWorkout.allWorkoutDates[relevantDate] is List? 8 : null,
                        style: TextStyle(
                            color: ((isSelected?? false) || (dateValues.contains(date.toDate())))
                                ? Colors.white
                                : dayText.contains(translatedSickText)
                                ? colorAmberDark
                                : colorAmber,
                          fontWeight: FontWeight.w600
                        )
                    )
                ),
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
        dialogSize: const Size(325, 700),
        borderRadius: BorderRadius.circular(15),
        value: dateValues.isNotEmpty
          ? dateValues
          : calendarType == CalendarDatePicker2Type.single
            ? [DateTime.now()]
            : [DateTime.now(), DateTime.now()],
          dialogBackgroundColor: Theme.of(context).cardColor
      );
      if (values != null && onConfirm != null) {
        onConfirm(values);
      }
    },
    child: getCalendarChild(
        context: context,
        dateValues: dateValues,
        calendarType: calendarType,
        buttonIsCalender: buttonIsCalender
    )
  );
}

Widget getCalendarChild({
  required BuildContext context,
  required List<DateTime> dateValues,
  required CalendarDatePicker2Type calendarType,
  required bool buttonIsCalender,
}){
  if(buttonIsCalender){
    return const Icon(
        Icons.calendar_month,
        size: 30,
        color: Colors.white
    );
  }
  if(calendarType == CalendarDatePicker2Type.single){
    return Text(
      DateFormat('EEEE d. MMMM', Localizations.localeOf(context).languageCode).format(dateValues.firstOrNull ?? DateTime.now()),
      style: const TextStyle(
        fontSize: 18,
      ),
    );
  }
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "${DateFormat('EEEE d. MMMM', Localizations.localeOf(context).languageCode).format(dateValues.firstOrNull ?? DateTime.now())} -",
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
      const SizedBox(height: 5,),
      Text(
        DateFormat('EEEE d. MMMM', Localizations.localeOf(context).languageCode).format(dateValues.lastOrNull ?? DateTime.now()),
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
    ],
  );
}

Future getExplainExerciseGroups(BuildContext context) async{

  PageController pageViewControllerGroups = PageController();
  TextStyle tStyle = const TextStyle(
      color: Colors.white,
      fontSize: 19.0
  );
  await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context){
        List<Widget> pages = [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.t1GroupExplanation,
                style: tStyle,
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.t1GroupExplanation2,
                style: tStyle,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  AppLocalizations.of(context)!.t1GroupExplanation3,
                  style: tStyle
              )
            ],
          ),
        ];

        final pageCountGroups = pages.length;

        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
              maxWidth:MediaQuery.of(context).size.width,
            ),
            child: Scaffold(
              body: Container(
                color: Theme.of(context).primaryColor,
                child: SafeArea(
                  top: false,
                  left: false,
                  right: false,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Stack(
                      children: [
                        PageView(
                          controller: pageViewControllerGroups,
                          children: pages,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: PageIndicator(
                            controller: pageViewControllerGroups,
                            count: pageCountGroups,
                            size: 8,
                            layout: PageIndicatorLayout.WARM,
                            activeColor: activeColor,
                            scale: 0.65,
                            space: 10,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
  );

  pageViewControllerGroups.dispose();
}

Widget iconSyncMultipleDevices = const Stack(
    alignment: Alignment.center,
    children: [
      Icon(
        Icons.cloud,
        color: Colors.white,
      ),
      Padding(
        padding: EdgeInsets.only(top: 1),
        child: Center(
          child: Icon(
            Icons.sync,
            size: 16,
            color: Colors.black,
          ),
        ),
      ),
    ]
);

Widget getCloudOptionsColumn({
  required CnConfig cnConfig,
  required BuildContext context,
  required Function refresh
}){
  return
    Column(
      children: [
        /// Connect with Cloud
        CupertinoListTile(
          leading: const Icon(
            Icons.cloud_done,
            color: Colors.white
          ),
          trailing: CupertinoSwitch(
              value: cnConfig.connectWithCloud,
              activeColor: activeColor,
              onChanged: (value)async{
                if(Platform.isAndroid){
                  HapticFeedback.selectionClick();
                }
                if(!value){
                  await cnConfig.revokeConnectCloud();
                }
                cnConfig.setConnectWithCloud(value);
                refresh();
              }
          ),
          title: Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: OverflowSafeText(
                    maxLines: 1,
                    Platform.isAndroid
                        ? AppLocalizations.of(context)!.settingsConnectGoogleDrive
                        : AppLocalizations.of(context)!.settingsConnectiCloud,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                if(!cnConfig.connectWithCloud)
                  const SizedBox(width: 15),
                if(cnConfig.connectWithCloud)
                  FutureBuilder(
                      future: Platform.isAndroid? cnConfig.signInGoogleDrive() : cnConfig.checkIfICloudAvailable(),
                      builder: (context, connected){
                        if(!connected.hasData){
                          return Center(
                            child: SizedBox(
                                height: 15,
                                width: 15,
                                child: CupertinoActivityIndicator(
                                    radius: 8.0,
                                    color: Colors.amber[800]
                                ),
                                // child: CircularProgressIndicator(strokeWidth: 2,)
                            ),
                          );
                        }
                        return Icon(
                          cnConfig.account != null || (cnConfig.isICloudAvailable?? false)
                              ? Icons.check_circle
                              : Icons.close,
                          size: 15,
                          color: cnConfig.account != null || (cnConfig.isICloudAvailable?? false)
                              ? Colors.green
                              : Colors.red,
                        );
                      }
                  )
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
            firstChild: Column(
              children: [

                /// Save Backup in Cloud
                CupertinoListTile(
                  leading: const Icon(
                    Icons.cloud_upload,
                    color: Colors.white,
                  ),
                  trailing: CupertinoSwitch(
                      value: cnConfig.saveBackupCloud,
                      activeColor: activeColor,
                      onChanged: (value) async{
                        if(Platform.isAndroid){
                          HapticFeedback.selectionClick();
                          // if(!value){
                          //   cnConfig.account = null;
                          // }
                        }
                        cnConfig.setSaveBackupCloud(value);
                        refresh();
                      }
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: OverflowSafeText(
                            maxLines: 1,
                            Platform.isAndroid
                                ? AppLocalizations.of(context)!.settingsSaveBackupsGoogleDrive
                                : AppLocalizations.of(context)!.settingsSaveBackupsiCloud,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// Sync Multiple Devices
                CupertinoListTile(
                  leading: iconSyncMultipleDevices,
                  trailing: CupertinoSwitch(
                      value: cnConfig.syncMultipleDevices,
                      activeColor: activeColor,
                      onChanged: (value)async{
                        if(Platform.isAndroid){
                          HapticFeedback.selectionClick();
                        }
                        cnConfig.setSyncMultipleDevices(value);
                        refresh();
                      }
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: OverflowSafeText(
                            maxLines: 1,
                            AppLocalizations.of(context)!.settingsSyncMultipleDevices,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            secondChild: const Row(),
            crossFadeState: cnConfig.showMoreSettingCloud
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300)
        )
      ],
    );
}

Widget getActionSheetCancelButton (BuildContext context, {String? text, Function? onPressed}){
  onPressed = onPressed?? (){};
  const Color kDialogColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xCCF2F2F2),
    darkColor: Color(0xBF1E1E1E),
  );
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Container(
      color: CupertinoDynamicColor.resolve(kDialogColor, context),
      child: CupertinoActionSheetAction(
        /// This parameter indicates the action would be a default
        /// default behavior, turns the action's text to bold text.
        isDefaultAction: true,
        onPressed: () {
          onPressed!();
          Navigator.pop(context);
        },
        child: Text(text?? AppLocalizations.of(context)!.cancel, style: cupButtonTextStyle),
      ),
    ),
  );
}

Future showDialogMinuteSecondPicker({
    required BuildContext context,
    Duration initialTimeDuration = const Duration(),
    Function(Duration)? onConfirm
}) {
  Duration newDuration = const Duration();
  return showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => ClipRRect(
      borderRadius: const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
      child: Container(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          bottom: true,
          top: false,
          child: Container(
            height: onConfirm != null? 275 : 222,
            padding: const EdgeInsets.only(top: 0.0),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if(onConfirm != null)
                  Row(
                    children: [
                      CupertinoButtonText(
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          text: AppLocalizations.of(context)!.cancel
                      ),
                      const Spacer(),
                      CupertinoButtonText(
                          onPressed: (){
                            Navigator.of(context).pop();
                            onConfirm(newDuration);
                          },
                          text: AppLocalizations.of(context)!.save
                      ),
                    ],
                  ),
                CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.ms,
                  initialTimerDuration: initialTimeDuration,
                  onTimerDurationChanged: (Duration duration) {
                    HapticFeedback.selectionClick();
                    newDuration = duration;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget getDialogCantChangeCategory(BuildContext context){
  return standardDialog(
    context: context,
    maxWidth: 400,
    widthFactor: 0.6,
    maxHeight: 680,
    child: Center(child: Text(AppLocalizations.of(context)!.panelWoChangeExerciseCategory, textAlign: TextAlign.center,)),
  );
}

Widget getBackupDialogWelcomeScreen({required BuildContext context}){
  return Padding(
    padding: const EdgeInsets.only(right: 15),
    child: Column(
      children: [

        /// Save Backup Automatic
        CupertinoListTile(
          leading: const Icon(
            Icons.sync,
            color: Colors.white
          ),
          title: OverflowSafeText(
              maxLines: 1,
              AppLocalizations.of(context)!.settingsBackupSaveAutomatic,
              style: const TextStyle(color: Colors.white)
          ),
        ),
        Padding(padding: const EdgeInsets.only(left: 30) ,child: Text(AppLocalizations.of(context)!.settingsBackupSaveAutomaticExplanation)),
        const SizedBox(height: 15),

        /// Connect with Cloud
        CupertinoListTile(
          leading: const Icon(
            Icons.cloud_done,
            color: Colors.white,
          ),
          title: OverflowSafeText(
              maxLines: 1,
              Platform.isAndroid
                  ? AppLocalizations.of(context)!.settingsConnectGoogleDrive
                  : AppLocalizations.of(context)!.settingsConnectiCloud,
              style: const TextStyle(color: Colors.white)
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(Platform.isAndroid
                ? AppLocalizations.of(context)!.settingsConnectGoogleDriveExplanation
                : AppLocalizations.of(context)!.settingsConnectiCloudExplanation
            )
        ),
        const SizedBox(height: 15),

        /// Save Backups in Cloud
        CupertinoListTile(
          leading: const Icon(
            Icons.cloud_upload,
            color: Colors.white,
          ),
          title: OverflowSafeText(
              maxLines: 1,
              Platform.isAndroid
                  ? AppLocalizations.of(context)!.settingsSaveBackupsGoogleDrive
                  : AppLocalizations.of(context)!.settingsSaveBackupsiCloud,
              style: const TextStyle(color: Colors.white)
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(Platform.isAndroid
                ? AppLocalizations.of(context)!.settingsSaveBackupsGoogleDriveExplanation
                : AppLocalizations.of(context)!.settingsSaveBackupsiCloudExplanation
            )
        ),
        const SizedBox(height: 15),

        /// Sync multiple Devices
        CupertinoListTile(
          leading: iconSyncMultipleDevices,
          title: OverflowSafeText(
              maxLines: 1,
              AppLocalizations.of(context)!.settingsSyncMultipleDevices,
              style: const TextStyle(color: Colors.white)
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(Platform.isAndroid
                ? AppLocalizations.of(context)!.settingsSyncMultipleDevicesExplanationGoogleDrive
                : AppLocalizations.of(context)!.settingsSyncMultipleDevicesExplanationiCloud,
            )
        ),
        const SizedBox(height: 15),
      ],
    ),
  );
}

Offset getWidgetPosition(GlobalKey key) {
  Offset position = const Offset(0, 0);
  // WidgetsBinding.instance.addPostFrameCallback((_) {
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      position = renderBox.localToGlobal(Offset.zero);
    }
  // });
  return position;
}

// Offset getWidgetPosition(GlobalKey key) {
//   Offset position = const Offset(0, 0);
//   // // WidgetsBinding.instance.addPostFrameCallback((_) {
//   // final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
//   // if (renderBox != null) {
//   //   position = renderBox.localToGlobal(Offset.zero);
//   // }
//   // // });
//   // print(position);
//   // return position;
//   final renderObject = key.currentContext?.findRenderObject();
//   final translation = renderObject?.getTransformTo(null).getTranslation();
//   if(translation != null && renderObject?.paintBounds != null){
//     position = Offset(translation.x, translation.y);
//   }
//   print(position);
//   return position;
// }

Size getWidgetSize(GlobalKey key){
  Size size = const Size(0, 0);
  // WidgetsBinding.instance.addPostFrameCallback((_) {
    final RenderBox? renderBox =
    key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      size = renderBox.size;
    }
  // });
  return size;
}

Widget getRowButton({
  Key? key,
  required BuildContext context,
  required double minusWidth,
  required Function() onPressed,
  IconData icon = Icons.add,
  Color? color,
  double height = 40
}){
  color = color?? Colors.amber[800];
  return SizedBox(
    height: height,
    child: Row(
      children: [
        SizedBox(width: minusWidth),
        Expanded(
          child: CupertinoButton(
            padding: EdgeInsets.zero,
              key: key,
              alignment: Alignment.center,
              color: Theme.of(context).cardColor,
              onPressed: onPressed,
              child: Icon(
                icon,
                size: 20,
                color: color,
              )
          ),
        ),
        SizedBox(width: minusWidth)
      ],
    ),
  );
}

void blockUserInput(BuildContext context, {int duration = 1000}) {
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => Positioned.fill(
      child: AbsorbPointer(
        child: Container(
          color: Colors.black.withOpacity(0.0),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);

  Future.delayed(Duration(milliseconds: duration), () {
    overlayEntry.remove();
  });
}