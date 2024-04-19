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
  final double _wrapSpacing = 5;

  @override
  Widget build(BuildContext context) {
    cnScreenStatistics  = Provider.of<CnScreenStatistics>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return FutureBuilder(
            future: cnScreenStatistics.getWorkoutsInIntervalSummarized(),
            builder: (context, AsyncSnapshot<Map<String, Map>> workouts){

              if(workouts.hasData){
                List<Widget> children = [];
                final keys = workouts.data!.keys.toList();

                for(MapEntry<String, Map> entry in workouts.data!.entries){
                  final widthFactor = keys.indexOf(entry.key) > 2 ? 1 : 2;
                  children.add(
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: keys.indexOf(entry.key) == 0? 50 : 0),
                      child: GestureDetector(
                        onTap: ()async{

                          await cnScreenStatistics.setSelectedWorkout(entry.key);
                          cnScreenStatistics.refresh();
                        },
                        child: Container(
                          width: constraints.maxWidth / widthFactor - _wrapSpacing,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(15)
                          ),
                          child: Row(
                            children: [
                              Text(
                                  entry.key,
                                  style: TextStyle(
                                    color: entry.key == cnScreenStatistics.selectedWorkout?.name? Colors.amber[800] : null,
                                    fontSize: 20
                                  ),
                              ),
                              const Spacer(),
                              Text(entry.value["counter"].toString())
                            ],
                          ),
                        ),
                      ),
                    )
                  );
                }

                return Wrap(
                    alignment: WrapAlignment.center,
                    runSpacing: _wrapSpacing,
                    spacing: _wrapSpacing,
                    children: children.toList()
                );

                // return Wrap(
                //   verticalDirection: VerticalDirection.up,
                //   alignment: WrapAlignment.center,
                //   runSpacing: 5,
                //   spacing: 5,
                //   children: children.reversed.toList()
                // );

                // return Column(
                //   children: children,
                // );
              }
              return const SizedBox(
                  height: 100,
                  width: 100,
                  child: Center(child: CircularProgressIndicator())
              );
            }
        );
      }
    );
  }
}
