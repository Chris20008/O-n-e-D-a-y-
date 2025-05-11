import 'package:flutter/material.dart';
import '../screen_statistics.dart';
import '../widgets/filter_statistics/filter_statistics.dart';

void openFilterPopUp({
  required BuildContext context,
  required CnScreenStatistics cnScreenStatistics
}) async{

  cnScreenStatistics.saveCurrentFilterState();

  final result = await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context){
        return const FilterStatistics();
      }
  );

  if(result == true){
    /// ToDo: handling when change selected workout
    /// Update selector and szController?


    /// Without his update teh animation of lines would not happen
    /// ToDo: Why is not animating without this update?
    cnScreenStatistics.szController?.updateGraph();

    await Future.delayed(const Duration(milliseconds: 400));

    // cnScreenStatistics.refreshData(context);
    cnScreenStatistics.refresh();
    cnScreenStatistics.cache();
  } else{
    cnScreenStatistics.restoreLastFilterState();
  }

}