// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// class StandardPopUp extends StatefulWidget {
//
//   const StandardPopUp({
//     super.key
//   });
//
//   @override
//   State<StandardPopUp> createState() => _StandardPopUpState();
// }
//
// class _StandardPopUpState extends State<StandardPopUp> with TickerProviderStateMixin {
//   late final AnimationController _controller = AnimationController(
//     duration: Duration(milliseconds: cnStandardPopUp.animationTime),
//     vsync: this,
//   );
//   late final Animation<double> _animation = CurvedAnimation(
//     parent: _controller,
//     curve: Curves.decelerate,
//   );
//   late CnStandardPopUp cnStandardPopUp;
//
//   @override
//   Widget build(BuildContext context) {
//     cnStandardPopUp = Provider.of<CnStandardPopUp>(context);
//
//     final size = MediaQuery.of(context).size;
//
//     if(cnStandardPopUp.isVisible){
//       _controller.forward();
//     } else{
//       _controller.reverse();
//     }
//
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         AnimatedCrossFade(
//           layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
//             return Stack(
//               clipBehavior: Clip.none,
//               alignment: Alignment.center,
//               children: <Widget>[
//                 Positioned(
//                   key: bottomChildKey,
//                   child: bottomChild,
//                 ),
//                 Positioned(
//                   key: topChildKey,
//                   child: topChild,
//                 ),
//               ],
//             );
//           },
//           firstChild: const SizedBox(),
//           secondChild: GestureDetector(
//             onTap: (){
//               cnStandardPopUp.cancel();
//               if(MediaQuery.of(context).viewInsets.bottom > 0){
//                 Focus.of(context).unfocus();
//               }
//             },
//             child: BackdropFilter(
//               filter: ImageFilter.blur(
//                 sigmaX: 5.0,
//                 sigmaY: 5.0,
//               ),
//               // blendMode: BlendMode.,
//               child: Container(
//                 height: size.height,
//                 width: size.width,
//                 // color: Colors.black.withOpacity(0.4),
//                 color: Colors.transparent,
//               ),
//             ),
//           ),
//           crossFadeState: !cnStandardPopUp.isVisible?
//           CrossFadeState.showFirst:
//           CrossFadeState.showSecond,
//           duration: Duration(milliseconds: cnStandardPopUp.animationTime),
//         ),
//         AnimatedContainer(
//           alignment: Alignment.center,
//           duration: Duration(milliseconds: cnStandardPopUp.jump? 0 : cnStandardPopUp.animationTime), // Animationsdauer
//           transform: Matrix4.translationValues(!cnStandardPopUp.isVisible && cnStandardPopUp.pos != null? cnStandardPopUp.pos!.dx - size.width/2 : 0, !cnStandardPopUp.isVisible? (cnStandardPopUp.pos?.dy?? size.height) - size.height/2 : 0, cnStandardPopUp.isVisible? 100 : 0),
//           // curve: cnStandardPopUp.isVisible? Curves.decelerate: Curves.easeInBack,
//           child: ScaleTransition(
//             scale: _animation,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(
//                       sigmaX: 30.0,
//                       sigmaY: 30.0,
//                     ),
//                     child: ConstrainedBox(
//                       constraints: const BoxConstraints(
//                           maxWidth: 300.0,
//                           maxHeight: 200
//                       ),
//                       child: Container(
//                           width: size.width*0.65,
//                           color: cnStandardPopUp.color.withOpacity(0.6),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Padding(
//                                 padding: cnStandardPopUp.padding,
//                                 child: SingleChildScrollView(
//                                     padding: const EdgeInsets.all(0.0),
//                                     child: cnStandardPopUp.child
//                                 ),
//                               ),
//                               Container(
//                                 height: 0.5,
//                                 width: double.maxFinite,
//                                 color: Colors.grey[700]!.withOpacity(0.5),
//                               ),
//                               SizedBox(
//                                 height: 40,
//                                 child: Row(
//                                   children: [
//                                     Expanded(
//                                         child: ElevatedButton(
//                                             onPressed: cnStandardPopUp.confirm,
//                                             style: ButtonStyle(
//                                                 shadowColor: MaterialStateProperty.all(Colors.transparent),
//                                                 surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
//                                                 backgroundColor: MaterialStateProperty.all(Colors.transparent),
//                                                 // backgroundColor: MaterialStateProperty.all(Colors.grey[800]!.withOpacity(0.6)),
//                                                 shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
//                                             ),
//                                             child: Text(cnStandardPopUp.confirmText)
//                                         )
//                                     ),
//                                     if(cnStandardPopUp.showCancel)
//                                       Container(
//                                         height: double.maxFinite,
//                                         width: 0.5,
//                                         color: Colors.grey[700]!.withOpacity(0.5),
//                                       ),
//                                     if(cnStandardPopUp.showCancel)
//                                       Expanded(
//                                           child: ElevatedButton(
//                                               onPressed: cnStandardPopUp.cancel,
//                                               style: ButtonStyle(
//                                                   shadowColor: MaterialStateProperty.all(Colors.transparent),
//                                                   surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
//                                                   backgroundColor: MaterialStateProperty.all(Colors.transparent),
//                                                   // backgroundColor: MaterialStateProperty.all(Colors.grey[800]!.withOpacity(0.6)),
//                                                   shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
//                                               ),
//                                               child: Text(cnStandardPopUp.cancelText)
//                                           )
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           )
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class CnStandardPopUp extends ChangeNotifier {
//   bool isVisible = false;
//   Function? onConfirm;
//   Function? onCancel;
//   Widget child = const SizedBox();
//   EdgeInsets padding = const EdgeInsets.all(20);
//   String confirmText = "Ok";
//   String cancelText = "Cancel";
//   Offset? pos;
//   bool jump = true;
//   bool showCancel = true;
//   Color color = Colors.black;
//   int animationTime = 200;
//
//   void open({
//     required Widget child,
//     Function? onConfirm,
//     Function? onCancel,
//     EdgeInsets? padding,
//     String confirmText = "Ok",
//     String cancelText = "Cancel",
//     GlobalKey? animationKey,
//     Color? color,
//     bool showCancel = true
//   }){
//     jump = true;
//     this.onConfirm = onConfirm;
//     this.onCancel = onCancel;
//     this.child = child;
//     this.padding = padding?? const EdgeInsets.all(20);
//     this.confirmText = confirmText;
//     this.cancelText = cancelText;
//     this.color = color?? Colors.black;
//     this.showCancel = showCancel;
//
//     if(animationKey != null){
//       RenderBox? box = animationKey.currentContext?.findRenderObject() as RenderBox;
//       final width = box.size.width;
//       final height = box.size.height;
//       Offset position = box.localToGlobal(Offset.zero);
//       pos = Offset(position.dx + width/2, position.dy + height/2);
//     } else{
//       pos = null;
//     }
//     refresh();
//
//     Future.delayed(const Duration(milliseconds: 50), (){
//       jump = false;
//       isVisible = true;
//       refresh();
//     });
//   }
//
//   void confirm(){
//     if(onConfirm != null){
//       onConfirm!();
//     }
//     clear();
//   }
//
//   void cancel(){
//     if(onCancel != null){
//       onCancel!();
//     }
//     clear();
//   }
//
//
//   void clear(){
//     isVisible = false;
//     onConfirm = null;
//     onCancel = null;
//
//     refresh();
//   }
//
//   void refresh(){
//     notifyListeners();
//   }
// }
