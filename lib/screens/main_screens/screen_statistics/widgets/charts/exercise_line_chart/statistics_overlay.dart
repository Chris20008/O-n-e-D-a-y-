import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../screen_statistics.dart';

class StatisticsOverlay extends StatelessWidget {
  const StatisticsOverlay({super.key});

  @override
  Widget build(BuildContext context) {

    CnScreenStatistics cnScreenStatistics = context.read<CnScreenStatistics>();

    bool showAvgWeightPerSetLine = context.select<CnScreenStatistics, bool>((cn) => cn.showAvgWeightPerSetLine);
    bool showOneRepMax = context.select<CnScreenStatistics, bool>((cn) => cn.showOneRepMax);
    bool showSickDays = context.select<CnScreenStatistics, bool>((cn) => cn.showSickDays);

    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 8,
                width: 12,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: cnScreenStatistics.gradientColors.first
                ),
              ),
              const SizedBox(width: 10),
              Text(AppLocalizations.of(context)!.statisticsMaxWeight, textScaler: const TextScaler.linear(0.8))
            ],
          ),
          if(showAvgWeightPerSetLine)
            Row(
              children: [
                Container(
                  height: 8,
                  width: 12,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: cnScreenStatistics.gradientColors2.first
                  ),
                ),
                const SizedBox(width: 10),
                Text(AppLocalizations.of(context)!.filterAvgMovWeightHead, textScaler: const TextScaler.linear(0.8))
              ],
            ),
          if(showOneRepMax)
            Row(
              children: [
                Container(
                  height: 8,
                  width: 12,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: cnScreenStatistics.gradientColors3.first
                  ),
                ),
                const SizedBox(width: 10),
                const Text("1RM", textScaler: TextScaler.linear(0.8))
              ],
            ),
          if(showSickDays)
            Row(
              children: [
                Container(
                  height: 8,
                  width: 12,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: cnScreenStatistics.gradientColors4.first
                  ),
                ),
                const SizedBox(width: 10),
                Text(AppLocalizations.of(context)!.statisticsSick, textScaler: const TextScaler.linear(0.8))
              ],
            ),
        ],
      ),
    );
  }
}
