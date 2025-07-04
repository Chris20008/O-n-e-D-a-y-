import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/cupertino_button_text.dart';

void cupertinoAlertDialogCustom({
  required BuildContext context,
  required String header,
  required Widget body,
  String cancel = "No",
  String destructive = "Yes",
  required Function actionDestructive,
  bool Function()? validator
}) {
  // late OverlayEntry overlayEntry;
  // overlayEntry = OverlayEntry(
  //   builder: (context) => Positioned.fill(
  //     child: Container(
  //         width: double.maxFinite,
  //         height: double.maxFinite,
  //         color: Colors.black.withValues(alpha: 0.3),
  //         child: Scaffold(
  //           resizeToAvoidBottomInset: false,
  //           backgroundColor: Colors.transparent,
  //           body: Center(
  //             child: Container(
  //               width: 280,
  //               // height: 120,
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFF282828),
  //                 borderRadius: BorderRadius.circular(15),
  //               ),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Padding(
  //                     padding: const EdgeInsets.all(10),
  //                     child: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         Text(header, style: const TextStyle(fontWeight: FontWeight.w700), textScaler: const TextScaler.linear(1.1),),
  //                         const SizedBox(height: 10,),
  //                         body,
  //                       ],
  //                     ),
  //                   ),
  //                   const SizedBox(height: 5,),
  //                   Container(height: 0.5, width: double.maxFinite, color: const Color(0XFF3d3d3d)),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                     crossAxisAlignment: CrossAxisAlignment.end,
  //                     children: [
  //                       Expanded(
  //                         child: CupertinoButtonText(
  //                             padding: EdgeInsets.zero,
  //                             text: cancel,
  //                             onPressed: overlayEntry.remove
  //                         ),
  //                       ),
  //                       Container(width: 0.5, color: const Color(0XFF3d3d3d), height: 44),
  //                       Expanded(
  //                         child: CupertinoButtonText(
  //                             text: destructive,
  //                             textColor: CupertinoColors.destructiveRed,
  //                             onPressed: () async{
  //                               if(validator != null){
  //                                 final validated = validator();
  //                                 if(validated != true){
  //                                   return;
  //                                 }
  //                               }
  //                               overlayEntry.remove();
  //                               await actionDestructive();
  //                             }
  //                         ),
  //                       )
  //                     ],
  //                   )
  //                 ],
  //               ),
  //             ),
  //           ),
  //         )
  //     ),
  //   ),
  // );

  showDialog(
      context: context,
      builder: (context) => Container(
          width: double.maxFinite,
          height: double.maxFinite,
          // color: Colors.black.withValues(alpha: 0.8),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Center(
              child: Container(
                margin: EdgeInsets.only(bottom: 50),
                width: 280,
                // height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF282828),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(header, style: const TextStyle(fontWeight: FontWeight.w700), textScaler: const TextScaler.linear(1.1),),
                          const SizedBox(height: 10,),
                          body,
                        ],
                      ),
                    ),
                    const SizedBox(height: 5,),
                    Container(height: 0.5, width: double.maxFinite, color: const Color(0XFF3d3d3d)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: CupertinoButtonText(
                              padding: EdgeInsets.zero,
                              text: cancel,
                              onPressed: Navigator.of(context).pop,
                              // onPressed: overlayEntry.remove
                          ),
                        ),
                        Container(width: 0.5, color: const Color(0XFF3d3d3d), height: 44),
                        Expanded(
                          child: CupertinoButtonText(
                              text: destructive,
                              textColor: CupertinoColors.destructiveRed,
                              onPressed: () async{
                                if(validator != null){
                                  final validated = validator();
                                  if(validated != true){
                                    return;
                                  }
                                }
                                // overlayEntry.remove();
                                Navigator.of(context).pop();
                                await actionDestructive();
                              }
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
      )
  );

  // Navigator.of(context, rootNavigator: true).overlay?.insert(overlayEntry);
}