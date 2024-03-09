import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StandardPopUp extends StatefulWidget {

  const StandardPopUp({
    super.key
  });

  @override
  State<StandardPopUp> createState() => _StandardPopUpState();
}

class _StandardPopUpState extends State<StandardPopUp> {

  late CnStandardPopUp cnStandardPopUp;

  @override
  Widget build(BuildContext context) {
    cnStandardPopUp = Provider.of<CnStandardPopUp>(context);

    // if(!cnStandardPopUp.isVisible){
    //   return const SizedBox();
    // }

    final size = MediaQuery.of(context).size;

    return AnimatedCrossFade(
        firstChild: Container(),
        secondChild: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size.width,
              height: size.height,
              color: Colors.black.withOpacity(0.5),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10.0,
                  sigmaY: 10.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: 300.0,
                      maxHeight: 200
                  ),
                  child: Container(
                      width: size.width*0.65,
                      color: Colors.grey[800]!.withOpacity(0.6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SingleChildScrollView(child: cnStandardPopUp.child),
                          ),
                          SizedBox(
                            height: 40,
                            child: Row(
                              children: [
                                Expanded(
                                    child: ElevatedButton(
                                        onPressed: cnStandardPopUp.confirm,
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Colors.grey[800]!.withOpacity(0.6)),
                                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
                                        ),
                                        child: const Text("Ok")
                                    )
                                ),
                                Expanded(
                                    child: ElevatedButton(
                                        onPressed: cnStandardPopUp.cancel,
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all(Colors.grey[800]!.withOpacity(0.6)),
                                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
                                        ),
                                        child: const Text("Cancel")
                                    )
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                  ),
                ),
              ),
            ),
          ],
        ),
        crossFadeState: !cnStandardPopUp.isVisible?
        CrossFadeState.showFirst:
        CrossFadeState.showSecond,
        duration: const Duration(milliseconds: 200)
    );

    // return Stack(
    //   alignment: Alignment.center,
    //   children: [
    //     Container(
    //       width: size.width,
    //       height: size.height,
    //       color: Colors.black.withOpacity(0.5),
    //     ),
    //     ClipRRect(
    //       borderRadius: BorderRadius.circular(15),
    //       child: BackdropFilter(
    //         filter: ImageFilter.blur(
    //           sigmaX: 10.0,
    //           sigmaY: 10.0,
    //         ),
    //         child: ConstrainedBox(
    //           constraints: const BoxConstraints(
    //             maxWidth: 300.0,
    //             maxHeight: 200
    //           ),
    //           child: Container(
    //             width: size.width*0.65,
    //             color: Colors.grey[800]!.withOpacity(0.6),
    //             child: Column(
    //               mainAxisSize: MainAxisSize.min,
    //               mainAxisAlignment: MainAxisAlignment.start,
    //               children: [
    //                 Padding(
    //                   padding: const EdgeInsets.all(20.0),
    //                   child: SingleChildScrollView(child: cnStandardPopUp.child),
    //                 ),
    //                 SizedBox(
    //                   height: 40,
    //                   child: Row(
    //                     children: [
    //                       Expanded(
    //                           child: ElevatedButton(
    //                               onPressed: cnStandardPopUp.confirm,
    //                               style: ButtonStyle(
    //                                 backgroundColor: MaterialStateProperty.all(Colors.grey[800]!.withOpacity(0.6)),
    //                                 shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
    //                               ),
    //                               child: const Text("Ok")
    //                           )
    //                       ),
    //                       Expanded(
    //                           child: ElevatedButton(
    //                               onPressed: cnStandardPopUp.cancel,
    //                               style: ButtonStyle(
    //                                   backgroundColor: MaterialStateProperty.all(Colors.grey[800]!.withOpacity(0.6)),
    //                                   shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
    //                               ),
    //                               child: const Text("Cancel")
    //                           )
    //                       ),
    //                     ],
    //                   ),
    //                 )
    //               ],
    //             )
    //           ),
    //         ),
    //       ),
    //     ),
    //   ],
    // );
  }
}

class CnStandardPopUp extends ChangeNotifier {
  bool isVisible = false;
  Function? onConfirm;
  Function? onCancel;
  Widget child = const SizedBox();

  void open({required Widget child, Function? onConfirm, Function? onCancel}){
    this.onConfirm = onConfirm;
    this.onCancel = onCancel;
    this.child = child;
    isVisible = true;
    refresh();
  }

  void confirm(){
    if(onConfirm != null){
      onConfirm!();
    }
    clear();
  }

  void cancel(){
    if(onCancel != null){
      onCancel!();
    }
    clear();
  }


  void clear(){
    isVisible = false;
    onConfirm = null;
    onCancel = null;
    child = const SizedBox();
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}
