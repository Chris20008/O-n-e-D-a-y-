import 'package:fitness_app/screens/main_screens/screen_statistics/widgets/header_screen_statistics/exercise_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../functions/open_filter_pop_up.dart';
import '../../screen_statistics.dart';

class HeaderScreenStatistics extends StatelessWidget {
  const HeaderScreenStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    CnScreenStatistics cnScreenStatistics = context.read<CnScreenStatistics>();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                color: Colors.white,
                onPressed: () => openFilterPopUp(
                    context: context,
                    cnScreenStatistics: cnScreenStatistics
                ),
                icon: const Icon(
                  Icons.filter_list,
                )
            ),
            IconButton(
              // color: Colors.amber[200]!,
                color: Colors.white,
                onPressed: () => cnScreenStatistics.openSettingsPanel(),
                icon: const Icon(
                  Icons.settings,
                )
            ),
          ],
        ),
        const Center(
          child: ExerciseSelector(),
        ),
      ],
    );
  }
}
