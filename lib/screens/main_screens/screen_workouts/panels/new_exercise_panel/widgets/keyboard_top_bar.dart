// if(!tutorialIsRunning /*&& Platform.isIOS*/ && MediaQuery.of(context).viewInsets.bottom > 100 && currentIndexFocus >= 0)
//   KeyboardTopBar(
//     key: cnHomepage.keyKeyboardTopBar,
//     onPressedLeft: (){
//       int delay = 500;
//
//       if(currentIndexWeightOrAmount == 0){
//         currentIndexFocus -= 1;
//         currentIndexWeightOrAmount = 1;
//       } else{
//         currentIndexWeightOrAmount = 0;
//       }
//       if(currentIndexFocus == 0 && currentIndexWeightOrAmount == 0){
//         delay = 50;
//         insetsBottom = 0;
//       }
//
//       if(currentIndexFocus < 0){
//         FocusManager.instance.primaryFocus?.unfocus();
//         return;
//       }
//
//       if (currentIndexFocus < cnNewExercise.exercise.sets.length) {
//         FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[currentIndexFocus][currentIndexWeightOrAmount]);
//         onTapField(currentIndexFocus, insetsBottom, currentIndexWeightOrAmount, scrollDelay: delay);
//       } else {
//         FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[currentIndexFocus-1][1]);
//         addSet();
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[currentIndexFocus][0]);
//           onTapField(currentIndexFocus, insetsBottom, 0, scrollDelay: delay);
//         });
//       }
//     },
//     onPressedRight: (){
//       int delay = 500;
//
//       if(currentIndexWeightOrAmount == 0){
//         currentIndexWeightOrAmount = 1;
//       } else{
//         currentIndexWeightOrAmount = 0;
//         currentIndexFocus += 1;
//       }
//       if(currentIndexFocus == 0 && currentIndexWeightOrAmount == 0){
//         delay = 50;
//         insetsBottom = 0;
//       }
//
//       if (currentIndexFocus < cnNewExercise.exercise.sets.length) {
//         FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[currentIndexFocus][currentIndexWeightOrAmount]);
//         onTapField(currentIndexFocus, insetsBottom, currentIndexWeightOrAmount, scrollDelay: delay);
//       }
//       else{
//         FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[currentIndexFocus-1][1]);
//         addSet();
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           FocusScope.of(context).requestFocus(cnNewExercise.focusNodes[currentIndexFocus][0]);
//           onTapField(currentIndexFocus, insetsBottom, 0, scrollDelay: delay);
//         });
//       }
//
//     },
//   )