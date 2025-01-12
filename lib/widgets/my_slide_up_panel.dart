import 'dart:io';

import 'package:fitness_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MySlideUpPanel extends StatefulWidget {
  final PanelController? controller;
  final PanelState defaultPanelState;
  final double? maxHeight;
  final double? minHeight;
  final bool isDraggable;
  final BorderRadiusGeometry borderRadius;
  final Color? color;
  final void Function(double)? onPanelSlide;
  final Widget? panel;
  final bool backdropEnabled;
  final Color backdropColor;
  final Widget Function(ScrollController)? panelBuilder;
  final double backdropOpacity;
  final String? animationControllerName;
  final String? descendantAnimationControllerName;

  const MySlideUpPanel({
    super.key,
    this.controller,
    this.defaultPanelState = PanelState.CLOSED,
    this.maxHeight,
    this.minHeight,
    this.isDraggable = true,
    this.borderRadius = const BorderRadius.only(topRight: Radius.circular(25), topLeft: Radius.circular(25)),
    this.color,
    this.onPanelSlide,
    this.panel,
    this.backdropEnabled = false,
    this.backdropColor = Colors.black,
    this.panelBuilder,
    this.backdropOpacity = 0.5,
    this.animationControllerName,
    this.descendantAnimationControllerName
  });

  @override
  State<MySlideUpPanel> createState() => _MySlideUpPanelState();
}

class _MySlideUpPanelState extends State<MySlideUpPanel> with TickerProviderStateMixin{
  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  AnimationController? descendantAnimationController;
  AnimationController? descendantAnimationController2;
  final maxTopPadding = -45;
  late Color color = widget.color?? Theme.of(context).primaryColor;

  @override
  void initState() {
    super.initState();
    if(widget.descendantAnimationControllerName != null){
      descendantAnimationController = cnHomepage.animationControllers[widget.descendantAnimationControllerName!];
    }
    if(widget.animationControllerName != null){
      cnHomepage.animationControllers[widget.animationControllerName!] = animationController;
      if(descendantAnimationController != null){
        // print("Put ${widget.animationControllerName!}2");
        cnHomepage.animationControllers["${widget.animationControllerName!}2"] = descendantAnimationController!;
      }
    }
    // print("Try receive ${widget.descendantAnimationControllerName!}2");
    if(widget.descendantAnimationControllerName != null){
      descendantAnimationController2 = cnHomepage.animationControllers["${widget.descendantAnimationControllerName}2"];
    }
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   cnHomepage.animationControllers.remove(widget.animationControllerName);
  //   cnHomepage.animationControllers.remove(widget.descendantAnimationControllerName);
  //   cnHomepage.animationControllers.remove("${widget.descendantAnimationControllerName}2");
  // }

  onPanelSlide(double value){
    if(descendantAnimationController != null){
      descendantAnimationController!.value = value*0.5;
    }
    if(descendantAnimationController2 != null){
      // print("Descendant 2 != null");
      descendantAnimationController2!.value = 0.5 + value*0.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget panel = LayoutBuilder(
        builder: (context, constraints){
          final maxHeight = constraints.maxHeight - (Platform.isAndroid? 50 : 70);
          return SlidingUpPanel(
              controller: widget.controller,
              defaultPanelState: widget.defaultPanelState,
              maxHeight: (widget.maxHeight?? maxHeight).clamp(0, maxHeight),
              minHeight: widget.minHeight?? 0,
              isDraggable: widget.isDraggable,
              borderRadius: widget.borderRadius,
              color: color,
              onPanelSlide: (value){
                onPanelSlide(value);
                if(widget.onPanelSlide != null){
                  widget.onPanelSlide!(value);
                }
              },
              panel: widget.panel,
              panelBuilder: widget.panelBuilder,
              backdropEnabled: widget.backdropEnabled,
              backdropColor: widget.backdropColor,
              backdropOpacity: widget.backdropOpacity
          );
        }
    );

    if(widget.animationControllerName != null){
      return AnimatedBuilder(
          animation: animationController,
          builder: (context, child){
            double scale = 1.0 - (animationController.value * (Platform.isAndroid? 0.15 : 0.2));
            double topPadding = animationController.value*maxTopPadding*2;
            topPadding = topPadding > 0 ? 0 : topPadding;
            if(topPadding < maxTopPadding){
              topPadding = maxTopPadding - (topPadding - maxTopPadding);
            }
            double opacity = animationController.value;
            /// Scales the opacity from 0 -> 0.5 when animationController is between 0 - 0.5
            /// And back from 0.5 - > 0 when animationController is between 0.5 - 1
            /// We do that, because on exercise panel the backdropEnabled is True, so we don't
            /// need this anymore when exercise panel is opened because it would become to dark
            /// with backdrop AND this AnimatedBuilder together
            opacity = opacity > 0.5 ? 1 - opacity : opacity;
            opacity = opacity * 0.5;
            return Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 0),
                  transform: Matrix4.translationValues(0, topPadding, 0),
                  child: Transform.scale(
                    scale: scale,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(30 -  (scale*10-9)*25),
                        child: Container(
                            child: child
                        )
                    ),
                  ),
                ),
                if(animationController.value > 0)
                  IgnorePointer(
                      ignoring: opacity > 0 ? false : true,
                      child: Container(
                        color: Colors.black.withOpacity(opacity),
                      )
                  )
              ],
            );
          },
          child: panel,
      );
    }

    return panel;
  }
}
