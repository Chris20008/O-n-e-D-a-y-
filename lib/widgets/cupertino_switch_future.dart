import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../util/constants.dart';

class CupertinoSwitchFuture extends StatefulWidget {

  final bool initialState;
  final Future<bool> Function() future;
  final Function(bool) onSwitch;
  final CupertinoSwitchFirstLoad futureOnFirstLoad;

  const CupertinoSwitchFuture({
    super.key,
    required this.initialState,
    required this.future,
    required this.onSwitch,
    this.futureOnFirstLoad = CupertinoSwitchFirstLoad.ifTrue
  });

  @override
  State<CupertinoSwitchFuture> createState() => _CupertinoSwitchFutureState();
}

class _CupertinoSwitchFutureState extends State<CupertinoSwitchFuture> {

  Key futureKey = UniqueKey();
  late bool currentState = widget.initialState;
  late bool targetState = currentState;
  late bool doFuture = widget.futureOnFirstLoad == CupertinoSwitchFirstLoad.ifTrue && currentState
      || widget.futureOnFirstLoad == CupertinoSwitchFirstLoad.ifFalse && !currentState
      || widget.futureOnFirstLoad == CupertinoSwitchFirstLoad.always;

  Future<bool> skipFutureFirstLoad() async{
    doFuture = true;
    return currentState;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        key: futureKey,
        future: doFuture? widget.future() : skipFutureFirstLoad(),
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
          if(connected.data == true && !currentState && targetState){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 50), (){
                if(targetState){
                  currentState = targetState;
                  setState(() {});
                }
              });
            });
          }
          else if(connected.data == false && targetState){
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
                widget.onSwitch(value);
                setState(() {});
              }
          );
        }
    );
  }
}


enum CupertinoSwitchFirstLoad{
  always,
  none,
  ifTrue,
  ifFalse;
}