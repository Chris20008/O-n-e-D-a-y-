// import 'package:flutter/cupertino.dart';
//
// class BlockSwipeBack extends StatelessWidget {
//   final Widget child;
//   final bool doBlock;
//
//   const BlockSwipeBack({
//     super.key,
//     required this.child,
//     this.doBlock = true
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if(!doBlock){
//       return child;
//     }
//     return GestureDetector(
//       onHorizontalDragStart: (_) {},
//       behavior: HitTestBehavior.translucent,
//       child: child,
//     );
//   }
// }
