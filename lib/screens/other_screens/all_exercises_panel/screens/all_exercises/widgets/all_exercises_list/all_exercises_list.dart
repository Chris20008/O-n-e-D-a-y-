import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_exercise_panel/new_exercise_panel.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/panels/new_workout_panel/new_workout_panel.dart';
import 'package:fitness_app/screens/other_screens/all_exercises_panel/screens/all_exercises/widgets/all_exercises_list/all_exercises_separator.dart';
import 'package:fitness_app/screens/other_screens/all_exercises_panel/screens/all_exercises/widgets/all_exercises_search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../objects/exercise.dart';
import '../../../../../../../widgets/panel_header_row.dart';
import '../../../../../../../widgets/slide_up_panel/my_slide_up_panel.dart';
import '../../../../all_exercises_panel.dart';

class AllExercisesList extends StatelessWidget {
  const AllExercisesList({super.key});

  @override
  Widget build(BuildContext context) {

    CnAllExercisesPanel cnAllExercisesPanel = context.read<CnAllExercisesPanel>();
    CnNewExercisePanel cnNewExercisePanel = context.read<CnNewExercisePanel>();
    CnNewWorkOutPanel cnNewWorkOutPanel = context.read<CnNewWorkOutPanel>();
    List<TileItem> filteredExercises = context.select<CnAllExercisesPanel, List<TileItem>>((cn) => cn.filteredExercises);

    return Padding(
      padding: const EdgeInsets.only(top: 0.1),
      child: StatefulBuilder(
          builder: (modalContext, setModalState) {
            cnAllExercisesPanel.callBackRefreshAllExercisesList = setModalState;
            return ListViewScope.of(context).listView(
              controller: cnAllExercisesPanel.scrollController,
              padding: EdgeInsets.only(left: 10, right: 25, top: PanelHeaderRow.height, bottom: AllExercisesSearchBar.bottomPadding),
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: filteredExercises.length,
              // itemCount: 100,
              separatorBuilder: (context, index) => const AllExercisesSeparator(),
              itemBuilder: (context, index){
                final isExercise = filteredExercises[index].exercise != null;
                EdgeInsets padding = filteredExercises[index].exercise == null? const EdgeInsets.only(top: 24, left: 20, bottom: 2) : const EdgeInsets.only(top: 13, left: 20, bottom: 13);
                return Padding(
                  padding: EdgeInsets.only(bottom: index == filteredExercises.length-1 ? 80 + MediaQuery.of(context).viewInsets.bottom : 0),
                  child: CupertinoButton(
                    key: index == 0 ? cnAllExercisesPanel.keyFirstListTile : null,
                    pressedOpacity: MediaQuery.of(context).viewInsets.bottom <= 0? 0.4 : 1,
                    padding: EdgeInsets.zero,
                    child: CupertinoListTile(
                        padding: padding,
                        title: Text(
                          filteredExercises[index].name,
                          style: TextStyle(
                              color: isExercise? Colors.white : Colors.grey[600]
                          ),
                          textScaler: TextScaler.linear(isExercise? 1 : 0.8),
                        )
                    ),
                    onPressed: (){
                      if(MediaQuery.of(context).viewInsets.bottom <= 0){
                        cnNewExercisePanel.setExercise(Exercise.copy(filteredExercises[index].exercise!));
                        cnNewExercisePanel.onConfirm = (Exercise exercise){
                          cnNewWorkOutPanel.confirmAddExercise(exercise);
                          cnAllExercisesPanel.closePanel();
                        };
                        cnAllExercisesPanel.navigatorKey?.currentState?.pushNamed('/singleExercise')
                            .then((_) => setModalState((){}));
                      }
                      else{
                        FocusScope.of(context).unfocus();
                      }
                    },
                  ),
                );
              },
            );
          }
      ),
    );
  }
}
