import 'dart:io';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:collection/collection.dart';
import 'package:fitness_app/main.dart';
import 'package:fitness_app/objects/exercise.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

Widget mySeparator({double heightTop = 20, double heightBottom = 20, double minusWidth = 50, double opacity = 0.4, Color? color}){
  return Column(
    children: [
      SizedBox(height: heightTop),
      Container(
        height: 1,
        width: double.maxFinite - minusWidth,
        // color: const Color(0xFFC16A03).withOpacity(opacity),
          color: (color?? Colors.amber[900])!.withOpacity(opacity)
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
  required Function(dynamic value) onConfirm,
  required BuildContext context
}) {
  return PullDownButton(
    buttonAnchor: PullDownMenuAnchor.start,
    routeTheme: routeTheme,
    itemBuilder: (context) {
      List seatLevels = List.generate(21, (index) => index);
      seatLevels.insert(0, AppLocalizations.of(context)!.clear);
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
  DateTime? dateToShow,
  bool justShow = false,
  Function? onConfirm,
  bool buttonIsCalender = false
}) {
  const colorAmber = Color(0xFFC16A03);
  const colorAmberDark = Color(0xFF583305);
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
        String dayText = cnNewWorkout.allWorkoutDates[relevantDate] is List
            ? cnNewWorkout.allWorkoutDates[relevantDate].contains("Krank")
              ?"Krank + ${cnNewWorkout.allWorkoutDates[relevantDate].length - 1}"
              :"${cnNewWorkout.allWorkoutDates[relevantDate].length} workouts"
            : cnNewWorkout.allWorkoutDates[relevantDate];
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
                        dayText,
                        maxLines: 1,
                        // fontSize: 5,
                        textAlign: TextAlign.center,
                        minFontSize: cnNewWorkout.allWorkoutDates[relevantDate] is List? 8 : null,
                        style: TextStyle(
                            color: (isSelected?? false)
                                ? Colors.white
                                : date.isSameDate(cnNewWorkout.originalWorkout.date) && !justShow
                                ? const Color(0xFFFFD995)
                                : dayText.contains("Krank") ? colorAmberDark : colorAmber)
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
        // dialogSize: const Size(325, 400),
        dialogSize: const Size(325, 700),
        borderRadius: BorderRadius.circular(15),
        value: [dateToShow ?? cnNewWorkout.workout.date!],
        dialogBackgroundColor: Theme.of(context).primaryColor
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
          DateFormat('EEEE d. MMMM', Localizations.localeOf(context).languageCode).format(dateToShow ?? cnNewWorkout.workout.date!),
          style: const TextStyle(
            fontSize: 18,
          ),
    )
  );
}

Widget getExplainExerciseGroups(BuildContext context){
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        AppLocalizations.of(context)!.t3Group,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20.0
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Text(
          AppLocalizations.of(context)!.t3GroupExplanation,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      const SizedBox(height: 15),
      Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
              width: 230,
              child: Image.asset(
                  scale: 0.6,
                  "${pictureAssetPath}Excercise Groups.jpg"
              )
          ),
        ),
      ),
    ],
  );
}

Widget iconSyncMultipleDevices = const Stack(
    alignment: Alignment.center,
    children: [
      Icon(
          Icons.cloud
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
          leading: const Icon(Icons.cloud_done),
          trailing: CupertinoSwitch(
              value: cnConfig.connectWithCloud,
              activeColor: const Color(0xFFC16A03),
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
                  SizedBox(width: 15),
                /// The future "cnConfig.signInGoogleDrive()" is currently not configured for IOS
                /// so calling it will lead to an crash
                /// We have to make sure it is only called on Android!
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
                  leading: const Icon(Icons.cloud_upload),
                  trailing: CupertinoSwitch(
                      value: cnConfig.saveBackupCloud,
                      activeColor: const Color(0xFFC16A03),
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
                      activeColor: const Color(0xFFC16A03),
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



Widget getBackupDialogWelcomeScreen({required BuildContext context}){
  return Column(
    children: [

      /// Save Backup Automatic
      CupertinoListTile(
        leading: const Icon(Icons.sync),
        // title: Text(AppLocalizations.of(context)!.settingsBackupSaveAutomatic, style: const TextStyle(color: Colors.white)),
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
        leading: const Icon(Icons.cloud_done),
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
        leading: const Icon(Icons.cloud_upload),
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
  );
}


























