import 'package:fitness_app/screens/main_screens/screen_statistics/widgets/filter_statistics/widgets/graph_section.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/widgets/filter_statistics/widgets/header.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/widgets/filter_statistics/widgets/other_section.dart';
import 'package:fitness_app/screens/main_screens/screen_statistics/widgets/filter_statistics/widgets/workout_selector_wheel.dart';
import 'package:flutter/material.dart';

class FilterStatistics extends StatelessWidget {
  const FilterStatistics({super.key});

  @override
  Widget build(BuildContext context) {

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: MediaQuery.of(context).size.height*0.6,
        color: Theme.of(context).primaryColor,
        child: Stack(
          children: [
            ListView(
              physics: const BouncingScrollPhysics(),
              children: const [
                SizedBox(height: 50,),

                WorkoutSelectorWheel(),

                GraphSection(),

                OtherSection()
              ],
            ),
            const FilterStatisticsHeader(),
          ],
        ),
      ),
    );
  }
}
