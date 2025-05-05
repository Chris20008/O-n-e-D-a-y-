import 'package:fitness_app/objects/exercise.dart';
import 'package:fitness_app/screens/other_screens/screen_running_workout/screen_running_workout.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/widgets/set_type_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SetRow extends StatefulWidget {
  final CnRunningWorkout cnRunningWorkout;
  final dynamic item;
  final dynamic groupedExerciseKey;
  final int index;

  const SetRow({
    super.key,
    required this.cnRunningWorkout,
    required this.item,
    required this.groupedExerciseKey,
    required this.index,
  });

  @override
  State<SetRow> createState() => _SetRowState();

}

class _SetRowState extends State<SetRow>{
  final double _heightOfSetRow = 30;
  final double _widthOfTextField = 55;
  final double _setPadding = 5;
  late int index;
  late dynamic item;
  late dynamic groupedExerciseKey;
  late CnRunningWorkout cnRunningWorkout;
  bool showMask = true;

  @override
  Widget build(BuildContext context) {
    index = widget.index;
    item = widget.item;
    groupedExerciseKey = widget.groupedExerciseKey;
    cnRunningWorkout = widget.cnRunningWorkout;

    NamedSet? tempSet;
    Widget? child;

    if(item is NamedSet){
      tempSet = item;
    }
    else{
      item = item as GroupedSet;
      String linkName = groupedExerciseKey.split("_").first;
      Exercise ex = (cnRunningWorkout.groupedExercises[linkName] as GroupedExercise).getExercise(cnRunningWorkout.selectedIndexes[linkName]!)!;
      tempSet = item.getSet(ex.name);
    }
    if(tempSet == null){
      return const SizedBox();
    }

    NamedSet set = tempSet;

    /// Each Set
    final TextEditingController weightController = set.weightController;
    final TextEditingController amountController = set.amountController;

    Exercise? templateEx = cnRunningWorkout.workoutTemplateModifiable.exercises.where((ex) => ex.name == set.ex.name).firstOrNull;

    if(templateEx == null){
      return const SizedBox();
    }

    SingleSet? templateSet = templateEx.sets[set.index];

    final double viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;

    child = Padding(
      padding: EdgeInsets.only(bottom: _setPadding, top: _setPadding),
      child: SizedBox(
        width: double.maxFinite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// Set
            SetTypeSelector(
                index: set.index,
                newEx: set.ex,
                width: _widthOfTextField,
                onConfirm: (){
                  cnRunningWorkout.cache();
                  setState((){});
                }
            ),

            /// Button to copy templates data
            getButtonInsertTemplatesData(newSet: set.set, templateSet: templateSet, templateEx: templateEx, indexSet: set.index, weightController: weightController, amountController: amountController),

            /// Weight and Amount
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  /// Weight
                  SizedBox(
                    width: _widthOfTextField,
                    height: _heightOfSetRow,
                    child: Center(
                      child:
                      // showMask?
                      // GestureDetector(
                      //   onTap: (){
                      //     setState(() {
                      //       showMask = false;
                      //     });
                      //     WidgetsBinding.instance.addPostFrameCallback((_) {
                      //       set.focusNodeWeight.requestFocus();
                      //     });
                      //   },
                      //   child: Container(
                      //     // color: Colors.blue,
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(8),
                      //       border: Border.all(
                      //           color: const Color(0xff848383),
                      //           width: 1
                      //       ),
                      //     ),
                      //   ),
                      // ) :
                      TextField(
                        focusNode: set.focusNodeWeight,
                        key: set.weightKey,
                        keyboardAppearance: Brightness.dark,
                        maxLength: (weightController.text.contains("."))? 6 : 4,
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: false
                        ),
                        controller: weightController,
                        onTap: (){
                          weightController.selection =  TextSelection(baseOffset: 0, extentOffset: weightController.value.text.length);
                          cnRunningWorkout.currentIndexFocus = index;
                          cnRunningWorkout.currentIndexWeightOrAmount = 0;
                          onTapField(viewInsetsBottom, set: set, context: context);
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            // isDense: true,
                            counterText: "",
                            contentPadding: const EdgeInsets.symmetric(horizontal: 0 ,vertical: 0.0),
                            hintFadeDuration: const Duration(milliseconds: 200),
                            hintText: (templateSet.weightAsTrimmedDouble?? "").toString(),
                            hintStyle: getTextStyleForTextField(
                                templateSet.weightAsTrimmedDouble.toString(),
                                color: Colors.white.withValues(alpha: 0.15),
                                sizeSmall: false
                            )
                        ),
                        style: getTextStyleForTextField(weightController.text, sizeSmall: false),
                        onChanged: (value){
                          value = value.trim();
                          if(value.isNotEmpty){
                            value = validateDoubleTextInput(value);
                            final newValue = double.tryParse(value);
                            set.set.weight = newValue;
                            if(newValue == null){
                              weightController.clear();
                            } else{
                              weightController.text = value;
                            }
                          }
                          else{
                            set.set.weight = null;
                          }
                          cnRunningWorkout.cache();
                          setState((){});
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 12,),

                  /// Amount
                  SizedBox(
                    width: _widthOfTextField,
                    height: _heightOfSetRow,
                    child: Center(
                      child:
                      // showMask?
                      // GestureDetector(
                      //   onTap: (){
                      //     setState(() {
                      //       showMask = false;
                      //     });
                      //     WidgetsBinding.instance.addPostFrameCallback((_) {
                      //       set.focusNodeAmount.requestFocus();
                      //     });
                      //   },
                      //   child: Container(
                      //     // color: Colors.blue,
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(8),
                      //       border: Border.all(
                      //           color: const Color(0xff848383),
                      //           width: 1
                      //       ),
                      //     ),
                      //   ),
                      // ) :
                      TextField(
                        focusNode: set.focusNodeAmount,
                        key: set.amountKey,
                        keyboardAppearance: Brightness.dark,
                        maxLength: set.ex.categoryIsReps()? 3 : 8,
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: false,
                            signed: false
                        ),
                        controller: amountController,
                        onTap: (){
                          amountController.selection =  TextSelection(baseOffset: 0, extentOffset: amountController.value.text.length);
                          cnRunningWorkout.currentIndexFocus = index;
                          cnRunningWorkout.currentIndexWeightOrAmount = 1;
                          onTapField(viewInsetsBottom, set: set, context: context);
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            // isDense: true,
                            counterText: "",
                            contentPadding: const EdgeInsets.symmetric(horizontal: 0 ,vertical: 0.0),
                            hintText: templateEx.categoryIsReps()? "${templateSet.amount?? ""}" : templateSet.amountAsTime,
                            hintStyle: getTextStyleForTextField(
                                templateEx.categoryIsReps()? "${templateSet.amount?? ""}" : templateSet.amountAsTime?? "",
                                sizeSmall: false,
                                color: Colors.white.withValues(alpha: 0.15),
                            )
                        ),
                        style: getTextStyleForTextField(amountController.text, sizeSmall: false),
                        onChanged: (value){
                          value = value.trim();
                          /// For Reps
                          if(set.ex.categoryIsReps()){
                            if(value.isNotEmpty){
                              final newValue = int.tryParse(value);
                              set.set.amount = newValue;
                              if(newValue == null){
                                amountController.clear();
                              }
                              if(value.length == 1){
                                setState((){});
                              }
                            }
                            else{
                              set.set.amount = null;
                              setState((){});
                            }
                          }
                          /// For Time
                          else{
                            List result = parseTextControllerAmountToTime(value);
                            if(result[0] <= 0){
                              amountController.text = "";
                              set.set.amount = null;
                            } else{
                              amountController.text = result[1];
                              set.set.amount = result[0];
                            }
                            setState((){});
                          }
                          cnRunningWorkout.cache();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if(set.ex.sets.length > 1 && cnRunningWorkout.contentIsActive){
      child = Listener(
        onPointerDown: (details){
          /// When controller is opened disable canPop
          if(set.slidableController.animation.value != 0){
            cnRunningWorkout.canPop = false;
            cnRunningWorkout.refresh();
          }
        },
        onPointerMove: (details){
          /// When swiping left and popping is enabled
          if(details.delta.dx < 0 && cnRunningWorkout.canPop){
            cnRunningWorkout.canPop = false;
            cnRunningWorkout.refresh();
          }
        },
        onPointerUp: (details){
          /// ReEnable popping
          if(!cnRunningWorkout.canPop){
            cnRunningWorkout.canPop = true;
            cnRunningWorkout.refresh();
          }
        },
        child: Slidable(
            key: set.slidableKey,
            controller: set.slidableController,
            endActionPane: ActionPane(
              extentRatio: 0.3,
              motion: const ScrollMotion(),
              dismissible: DismissiblePane(
                  onDismissed: () {
                    dismiss(set);
                  }),
              children: [
                SlidableAction(
                  flex:10,
                  onPressed: (BuildContext context){
                    dismiss(set);
                  },
                  backgroundColor: const Color(0xFFA12D2C),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                ),
              ],
            ),
            child: child
        ),
      );
    }

    // return SizedBox();

    return child;
  }

  void dismiss(NamedSet set){
    cnRunningWorkout.removeSpecificSetFromExercise(set);
    cnRunningWorkout.refresh();
    cnRunningWorkout.cache();
  }

  Future onTapField(double insetsBottom,{
    required NamedSet set,
    required BuildContext context
  }) async{

    // await Future.delayed(Duration(milliseconds: 200));

    // final position = getWidgetPosition(set.weightKey);
    //
    //
    // final value = Platform.isAndroid? 80 : 100;
    // final height = MediaQuery.of(context).size.height;
    // // final relativeHeight = height - MediaQuery.of(context).viewInsets.bottom;
    // final relativeHeight = height - 291;
    // // double factor = (relativeHeight - 90) / relativeHeight;
    // double factor = (relativeHeight - value) / height;
    //
    // if(position.dy + value > relativeHeight){
    //   print("Do Scroll");
    //   await Future.delayed(const Duration(milliseconds: 10), () async{
    //     // final factor = Platform.isAndroid? 0.8 : 0.84;
    //     await Scrollable.ensureVisible(
    //         set.weightKey.currentContext!,
    //         duration: const Duration(milliseconds: 300),
    //         curve: Curves.easeInOut,
    //         alignment: factor
    //     );
    //     onTapField(insetsBottom, set:set, context:context);
    //   });
    // }
  }

  Widget getButtonInsertTemplatesData({
    required SingleSet newSet,
    required SingleSet? templateSet,
    required Exercise? templateEx,
    required int indexSet,
    required TextEditingController? weightController,
    required TextEditingController? amountController
  }){

    String getText(){
      if(templateEx == null || templateSet == null){
        return "";
      }
      switch (templateEx.category){
        case 1:
          return templateSet.weight != null && templateSet.amount != null? "${templateSet.weightAsTrimmedDouble?? ""} kg x ${templateSet.amount?? ""}" : "";
        case 2:
          return templateSet.weight != null && templateSet.amount != null? "${templateSet.weightAsTrimmedDouble?? ""} km in ${templateSet.amountAsTime?? ""}" : "";
        case 3:
          return templateSet.weight != null && templateSet.amount != null? "${templateSet.weightAsTrimmedDouble?? ""} kg for ${templateSet.amountAsTime?? ""}" : "";
        default:
          return "";
      }
    }

    final weightTextIsEmpty = weightController?.text.isEmpty?? false;
    final amountTextIsEmpty = amountController?.text.isEmpty?? false;

    return Expanded(
        flex: 2,
        child: IgnorePointer(
          ignoring: !(weightTextIsEmpty &&
              amountTextIsEmpty &&
              templateSet?.weight != null &&
              templateSet?.amount != null),
          child: SizedBox(
            height: _heightOfSetRow,
            child: ElevatedButton(
              style: ButtonStyle(
                  shadowColor: WidgetStateProperty.all(Colors.transparent),
                  surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                  backgroundColor: WidgetStateProperty.all(Colors.transparent),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
              ),
              onPressed: (){
                if(templateSet == null || templateEx == null){
                  return;
                }
                if(templateSet.weight != null &&
                    templateSet.amount != null &&
                    weightTextIsEmpty &&
                    amountTextIsEmpty
                ){
                  vibrateConfirm();
                  weightController?.text = (templateSet.weightAsTrimmedDouble?? "").toString();
                  newSet.weight = templateSet.weight;
                  if(templateEx.categoryIsReps()){
                    amountController?.text = templateSet.amount!.toString();
                  }
                  else{
                    amountController?.text = templateSet.amountAsTime.toString();
                  }
                  newSet.amount = templateSet.amount;
                  cnRunningWorkout.cache();
                  setState((){});
                } else{
                  FocusManager.instance.primaryFocus?.unfocus();
                }
              },
              child: Center(
                child: OverflowSafeText(
                  maxLines: 1,
                  getText(),
                  style: TextStyle(
                      color: (weightTextIsEmpty &&
                          amountTextIsEmpty)
                          ?Colors.white
                          : Colors.white.withValues(alpha: 0.2)
                  ),
                ),
              ),
            ),
          ),
        )
    );
  }
}
