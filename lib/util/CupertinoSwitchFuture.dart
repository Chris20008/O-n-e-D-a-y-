import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';

class CupertinoSwitchFuture extends StatefulWidget {

  final bool initialState;
  final Future<bool> Function(bool targetState) future;

  const CupertinoSwitchFuture({
    super.key,
    required this.initialState,
    required this.future
  });

  @override
  State<CupertinoSwitchFuture> createState() => _CupertinoSwitchFutureState();
}

class _CupertinoSwitchFutureState extends State<CupertinoSwitchFuture> {

  Key futureKey = UniqueKey();
  late bool currentState = widget.initialState;
  late bool targetState = currentState;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        key: futureKey,
        future: widget.future(targetState),
        builder: (context, connected){
          if(!connected.hasData){
            return SizedBox(
              height: 15,
              width: 60,
              child: Center(
                child: CupertinoActivityIndicator(
                    radius: 8.0,
                    color: Colors.amber[800]
                ),
              ),
            );
          }
          if(connected.data == true && !currentState){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 50), (){
                currentState = targetState;
                setState(() {});
              });
            });
          } else if(connected.data == false && targetState){
            currentState = false;
            targetState = false;
          }

          return CupertinoSwitch(
              value: currentState,
              activeTrackColor: activeColor,
              onChanged: (value) async{
                if(Platform.isAndroid){
                  HapticFeedback.selectionClick();
                }

                targetState = value;

                if(value){
                  futureKey = UniqueKey();
                } else{
                  currentState = targetState;
                }
                setState(() {});
              }
          );
        }
    );
  }
}
