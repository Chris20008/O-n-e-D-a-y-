import 'package:fitness_app/screens/screen_statistics/screen_statistics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OverviewPerInterval extends StatefulWidget {
  const OverviewPerInterval({super.key});

  @override
  State<OverviewPerInterval> createState() => _OverviewPerIntervalState();
}

class _OverviewPerIntervalState extends State<OverviewPerInterval> {
  late CnScreenStatistics cnScreenStatistics;

  @override
  Widget build(BuildContext context) {
    cnScreenStatistics  = Provider.of<CnScreenStatistics>(context);
    print("REBUILD OVERVIEW");

    // final workouts = cnScreenStatistics.getWorkoutsInInterval();

    return FutureBuilder(
        future: cnScreenStatistics.getWorkoutsInIntervalSummarized(),
        builder: (context, AsyncSnapshot<Map<String, Map>> workouts){
          if(workouts.hasData){
            print("SNAPSHOT HAS DATA: ${workouts.data}");
            List<Widget> children = [];
            for(MapEntry<String, Map> entry in workouts.data!.entries){
              children.add(
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: Row(
                      children: [
                        Text(entry.key, style: Theme.of(context).textTheme.titleLarge),
                        const Spacer(),
                        Text(entry.value["counter"].toString())
                      ],
                    ),
                  ),
                )
              );
            }
            return Column(
              children: children,
            );
          }
          return const SizedBox(
              height: 100,
              width: 100,
              child: Center(child: CircularProgressIndicator())
          );
        }
    );

    // return Column(
    //   mainAxisSize: MainAxisSize.min,
    //   children: [
    //     for(Workout w in workouts)
    //   ],
    // );
  }
}
