import 'dart:io';
import 'dart:math';

import 'package:fitness_app/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/time.dart';
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
  // final Widget Function(ScrollController)? panelBuilder;
  final double backdropOpacity;
  final String? animationControllerName;
  final String? descendantAnimationControllerName;
  // final ScrollController? scrollControllerInnerList;
  final bool isTouchingListView;
  final bool bounce;
  final Widget Function(
      BuildContext context,
      Widget Function({
        ScrollPhysics physics,
        EdgeInsets padding,
        bool shrinkWrap,
        Widget? child,
        List<Widget>? children,
        required ScrollController controller,
      })
      )? panelBuilder;

  const MySlideUpPanel({
    super.key,
    this.controller,
    this.defaultPanelState = PanelState.CLOSED,
    this.maxHeight,
    this.minHeight,
    this.isDraggable = true,
    this.borderRadius = const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
    this.color,
    this.onPanelSlide,
    this.panel,
    this.backdropEnabled = false,
    this.backdropColor = Colors.black,
    // this.panelBuilder,
    this.backdropOpacity = 0.5,
    this.animationControllerName,
    this.descendantAnimationControllerName,
    // this.scrollControllerInnerList,
    this.isTouchingListView = false,
    this.panelBuilder,
    this.bounce = true
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
  final maxTopPadding = Platform.isAndroid? -45 : -52;
  late Color color = widget.color?? Theme.of(context).primaryColor;
  double overScrollOffset = 0;
  late PanelController panelController = widget.controller?? PanelController();
  double pointerStartPositionPanelDrag = 0;
  double initialPanelPosition = 0;
  int startPositionScrollController = 0;
  bool panelDragRunning = false;
  ScrollController? scrollController;
  bool bounceAllowed = false;
  double underScrollOffset = 0;
  bool isScrolling = false;
  PointerMoveEvent lastPointerMoveEvent = const PointerMoveEvent();

  bool isTouchingListView = false;

  @override
  void initState() {

    print("INIT My Slide Panel");
    super.initState();
    if(widget.descendantAnimationControllerName != null){
      descendantAnimationController = cnHomepage.animationControllers[widget.descendantAnimationControllerName!];
    }
    if(widget.animationControllerName != null){
      cnHomepage.animationControllers[widget.animationControllerName!] = animationController;
      if(descendantAnimationController != null){
        cnHomepage.animationControllers["${widget.animationControllerName!}2"] = descendantAnimationController!;
      }
    }
    if(widget.descendantAnimationControllerName != null){
      descendantAnimationController2 = cnHomepage.animationControllers["${widget.descendantAnimationControllerName}2"];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(scrollController != null && scrollController!.hasClients){
        scrollController?.addListener(() {
          if(scrollController!.offset > 30 || scrollController!.offset < -15){
            isScrolling = true;
          }
          else{
            isScrolling = false;
          }
        });
      }
    });

    if(widget.panelBuilder == null){
      bounceAllowed = true && widget.bounce;
    }
  }

  onPanelSlide(double value){
    if(descendantAnimationController != null){
      descendantAnimationController!.value = value*0.5;
    }
    if(descendantAnimationController2 != null){
      descendantAnimationController2!.value = 0.5 + value*0.5;
    }
  }

  void removeOverScrollOffset(){
    if(overScrollOffset == 0){
      return;
    }
    Future.delayed(const Duration(milliseconds: 10), (){
      setState(() {
        overScrollOffset = overScrollOffset * 0.8;
        if((overScrollOffset).abs() > 0.1 && !panelDragRunning){
          removeOverScrollOffset();
        } else{
          overScrollOffset = 0;
        }
      });
    });
  }

  Widget myListView({
    ScrollPhysics? physics = const BouncingScrollPhysics(),
    EdgeInsets padding = EdgeInsets.zero,
    bool shrinkWrap = true,
    Widget? child,
    List<Widget>? children,
    required ScrollController controller,
  }){
    assert((child != null) ^ (children != null), "Either child or children must be given. They can't be both null or not null at the same time");
    scrollController = controller;
    bounceAllowed = true && widget.bounce;
    return Listener(
      onPointerDown: (details){
        isTouchingListView = controller.position.maxScrollExtent > 0;
      },
      onPointerUp: (details){
        isTouchingListView = false;
      },
      child: children != null
          ? ListView(
              controller: controller,
              physics: physics,
              shrinkWrap: shrinkWrap,
              padding: padding,
              children: children,
            )
          : SingleChildScrollView(
            controller: controller,
            physics: physics,
            // shrinkWrap: shrinkWrap,
            padding: padding,
            child: child,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Build Whole My Slide Panel");
    Widget panel = LayoutBuilder(
        builder: (context, constraints){
          final maxHeight = constraints.maxHeight - (Platform.isAndroid? 50 : 70);
          double panelHeight = ((widget.maxHeight?? maxHeight) + overScrollOffset).clamp(0, maxHeight + overScrollOffset);
          return Listener(
            onPointerDown: (details){
              if(!bounceAllowed){
                return;
              }
              initialPanelPosition = panelController.panelPosition;
              pointerStartPositionPanelDrag = details.position.dy;
              if(scrollController != null &&
                  scrollController!.hasClients
              ){
                startPositionScrollController = scrollController!.offset.toInt();
              }
            },
            onPointerMove: (details) {
              if(!bounceAllowed){
                return;
              }

              // print("");
              // print(scrollController!.offset);
              // print(initialPanelPosition);
              // print(!isScrolling);

              /// Bounce
              if ((panelController.panelPosition > 0.99 || panelDragRunning) &&
                  !isTouchingListView
              ){
                // print("BOUNCE");
                setState(() {
                  double value =  pointerStartPositionPanelDrag - details.position.dy;
                  value = pow(value, 0.5) * 1.0;
                  value = value;
                  panelDragRunning = true;
                  overScrollOffset = ((value > 0) ? value : 0).clamp(0, 14) * 0.7;
                });
              }


              /// Drag panel while touching list View
              else if(scrollController != null &&
                  scrollController!.offset <= 0 &&
                  initialPanelPosition > 0.1
              ){
                if(!isScrolling && startPositionScrollController < 10){
                  lastPointerMoveEvent = details;
                  print("Jump one");
                  underScrollOffset = (underScrollOffset - details.delta.dy).clamp(-panelHeight+1, 0);
                  final panelPosition = (panelHeight + underScrollOffset) / panelHeight;
                  panelController.animatePanelToPosition(panelPosition, duration: const Duration(milliseconds: 0));
                  if (underScrollOffset < 0){
                    scrollController!.jumpTo(0);
                  }
                }

                /// Necessary to prevent panel closing when user swipes horizontal for slidable gestures
                if(panelController.isPanelOpen && details.delta.dy < 0 && (scrollController!.offset).abs() < 1){
                  print("Jump two");
                  scrollController!.jumpTo(-details.delta.dy);
                }
              }
              else{
                // print("ELSE");
                panelDragRunning = false;
                removeOverScrollOffset();
                underScrollOffset = 0;
              }
            },
            onPointerUp: (details) {
              if(!bounceAllowed){
                return;
              }
              // setState(() {
              // print("--------------------------------- RESET SCROLLING");
              isScrolling = false;
              startPositionScrollController = 0;
              panelDragRunning = false;
              removeOverScrollOffset();
              if(underScrollOffset < 0){
                underScrollOffset = 0;
                final th = Platform.isAndroid? 6 : 1.3;
                if(lastPointerMoveEvent.delta.dy > th
                    && MediaQuery.of(context).viewInsets.bottom <= 0
                ){
                  panelController.animatePanelToPosition(0, duration: const Duration(milliseconds: 150)).then((value) => initialPanelPosition = 0);
                }
                else{
                  panelController.animatePanelToPosition(1, duration: const Duration(milliseconds: 200)).then((value) => initialPanelPosition = 1);
                }
              }
            },
            child: SlidingUpPanel(
                controller: panelController,
                defaultPanelState: widget.defaultPanelState,
                maxHeight: panelHeight,
                minHeight: widget.minHeight?? 0,
                // isDraggable: widget.isDraggable, /// && !panelDragRunning,
                borderRadius: widget.borderRadius,
                color: color,
                parallaxOffset: 0.9,
                onPanelSlide: (value){
                  onPanelSlide(value);
                  if(widget.onPanelSlide != null){
                    widget.onPanelSlide!(value);
                  }
                },
                panel: widget.panel?? widget.panelBuilder!(context, myListView),
                // panelBuilder: widget.panelBuilder,
                backdropEnabled: widget.backdropEnabled,
                backdropColor: widget.backdropColor,
                backdropOpacity: widget.backdropOpacity
            ),
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
