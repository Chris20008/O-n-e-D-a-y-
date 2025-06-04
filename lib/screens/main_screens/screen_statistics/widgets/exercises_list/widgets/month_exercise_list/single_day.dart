import 'package:fitness_app/main.dart';
import 'package:fitness_app/objects/exercise.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/util/config.dart';
import 'package:fitness_app/util/objectbox/ob_exercise.dart';
import 'package:fitness_app/widgets/exercise_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';
import '../../../../../../../../../util/backup_helper/backup_functions.dart';
import '../../exercises_list.dart';


class SingleDay extends StatelessWidget {

  final ExerciseWithDate exercise;

  const SingleDay({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final maxWeight = max(exercise.exercise.sets.map((s) => s.weightAsTrimmedDouble?? 0))?? 0;
    final CnNewExercisePanel cnNewExercisePanel = context.read<CnNewExercisePanel>();
    final CnScreenStatistics cnScreenStatistics = context.read<CnScreenStatistics>();
    final CnConfig cnConfig = context.read<CnConfig>();
    final ObExercise obEx = exercise.exercise.toObExercise(withId: true);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 40),
      child: GestureDetector(
        onLongPress: (){
          final originalName = exercise.exercise.name;
          cnNewExercisePanel.openPanel(
              exercise: exercise.exercise,
              onConfirm: (Exercise ex){
                final ob = ex.toObExercise(withId: true);
                /// Update Exercise when new and previous are not the same
                if(ob.getHash() != obEx.getHash()){
                  objectbox.exerciseBox.put(ob);
                  cnScreenStatistics.refresh();
                  saveCurrentData(cnConfig);
                }
              },
              validator: ({
                required BuildContext context,
                required String? value,
                required CnNewExercisePanel cnNewExercise
              }){
                if(originalName != cnNewExercise.exercise.name){
                  return "Du kannst den Namen in dieser Ansicht nicht bearbeiten";
                }
                return null;
              },
              context: context
          );
        },
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: ()async{
            await showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (context){

              return ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.2,
                    maxWidth:MediaQuery.of(context).size.width,
                  ),
                  child: Scaffold(
                    body: Container(
                      color: Theme.of(context).primaryColor,
                      height: double.maxFinite,
                      width: double.maxFinite,
                      child: SafeArea(
                        top: false,
                        left: false,
                        right: false,
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat("d. MMMM yyyy", Localizations.localeOf(context).languageCode).format(exercise.date),
                                textScaler: const TextScaler.linear(1.2),
                              ),
                              const SizedBox(height: 10,),
                              ExerciseRow(
                                exercise: exercise.exercise,
                                shrinkWrap: true,
                                child: const SizedBox(),
                              ),
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
          },
          sizeStyle: CupertinoButtonSize.small,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withValues(alpha: 0.075),
            ),
            child: Row(
              children: [
                Expanded(
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          DateFormat("dd MMM yy", Localizations.localeOf(context).languageCode).format(exercise.date),
                          style: const TextStyle(
                              fontWeight: FontWeight.w300,
                              color: Colors.white
                          ),
                        )
                    )
                ),
                Expanded(
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "${maxWeight.toString()} kg",
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white
                          ),
                        )
                    )
                ),
                // const Spacer()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
