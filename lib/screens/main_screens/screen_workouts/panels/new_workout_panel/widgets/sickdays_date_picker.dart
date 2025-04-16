import 'package:flutter/material.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:provider/provider.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

class SickdaysDatePicker extends StatelessWidget {

  const SickdaysDatePicker({
    Key? key
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final CnNewWorkOutPanel cnNewWorkout = Provider.of<CnNewWorkOutPanel>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Dauer", textScaler: TextScaler.linear(1.3),),
              const Spacer(),
              buildCalendarDialogButton(
                  context: context,
                  cnNewWorkout: cnNewWorkout,
                  calendarType: CalendarDatePicker2Type.range,
                  dateValues: [cnNewWorkout.sickDays.startDate, cnNewWorkout.sickDays.endDate],
                  onConfirm: (List<DateTime?>? values){
                    if(values != null) {
                      cnNewWorkout.sickDays.startDate = values.firstOrNull?? cnNewWorkout.sickDays.startDate;
                      cnNewWorkout.sickDays.endDate =  values.lastOrNull?? cnNewWorkout.sickDays.endDate;
                      if (cnNewWorkout.sickDays.startDate.isAfter(cnNewWorkout.sickDays.endDate)) {
                        cnNewWorkout.sickDays.endDate = cnNewWorkout.sickDays.startDate;
                      }
                      cnNewWorkout.refresh();
                    }
                  }
              )
            ],
          ),
        ],
      ),
    );
  }
}