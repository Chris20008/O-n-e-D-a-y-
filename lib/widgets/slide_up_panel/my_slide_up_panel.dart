import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:fitness_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'animation_controller_name.dart';

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
  final double backdropOpacity;
  final AnimationControllerName animationControllerName;
  final AnimationControllerName? descendantAnimationControllerName;
  final bool isTouchingListView;
  final bool bounce;
  final Widget Function(
      BuildContext context,
      PanelListViewBuilder listView
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
    this.backdropOpacity = 0.5,
    required this.animationControllerName,
    this.descendantAnimationControllerName,
    this.isTouchingListView = false,
    this.panelBuilder,
    this.bounce = true,
  });

  @override
  State<MySlideUpPanel> createState() => _MySlideUpPanelState();
}

class _MySlideUpPanelState extends State<MySlideUpPanel> with TickerProviderStateMixin{
  final double minBorderRadius = 15;
  final double maxBorderRadius = Platform.isAndroid? 30 : 50;
  final double minScale = Platform.isAndroid? 0.85 : 0.8;
  final double maxTopPadding = Platform.isAndroid? -40 : -48;

  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  /// Scale
  late final Animation<double> scaleAnim = Tween<double>(begin: 1.0, end: minScale)
      .animate(animationController);

  /// Opacity
  late final Animation<double> opacityAnim = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.25), weight: 0.5),
    TweenSequenceItem(tween: Tween(begin: 0.25, end: 0.0), weight: 0.5),
  ]).animate(animationController);

  /// BorderRadius
  late final borderRadiusAnim = Tween<double>(begin: maxBorderRadius, end: minBorderRadius).animate(
    CurvedAnimation(
      parent: animationController,
      curve: const Interval(
        0.0, 0.5,
        curve: Curves.linear,
      ),
    ),
  );

  /// Top Padding
  late final Animation<double> topPaddingAnim = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: maxTopPadding), weight: 0.5),
    TweenSequenceItem(tween: Tween(begin: maxTopPadding, end: 0.0), weight: 0.5),
  ]).animate(animationController);

  // /// Top Padding
  // late final Animation<double> topPaddingAnim = Tween<double>(begin: 0, end: 0)
  //     .animate(animationController);


  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  AnimationController? descendantAnimationController;
  AnimationController? descendantAnimationController2;
  late Color color = widget.color?? Theme.of(context).primaryColor;
  double overScrollOffset = 0;
  late PanelController panelController = widget.controller?? PanelController();
  ScrollController? scrollController;

  final thresholdVerticalDrag = 0;

  PointerDownEvent initialPointerDownEvent = const PointerDownEvent();
  PointerMoveEvent lastPointerMoveEvent = const PointerMoveEvent();
  Timer? longPressTimer;

  double initialPanelPosition = 0;
  double underScrollOffset = 0;
  double initialScrollControllerPosition = 0;
  double delta = 0;
  bool isScrolling = false;
  bool isTouchingListView = false;
  bool panelDragRunning = false;
  bool bounceAllowed = false;
  bool recognizedLongPress = false;
  bool? isDraggingVertical;

  late Widget Function(BuildContext, PanelListViewBuilder)? currentBuilder = widget.panelBuilder;
  Widget Function(BuildContext, PanelListViewBuilder)? lastBuilder;

  @override
  void initState() {

    super.initState();
    if(widget.descendantAnimationControllerName != null){
      descendantAnimationController = cnHomepage.animationControllers[widget.descendantAnimationControllerName!.value];
    }
    cnHomepage.animationControllers[widget.animationControllerName.value] = animationController;
    if(descendantAnimationController != null){
      cnHomepage.animationControllers["${widget.animationControllerName.value}2"] = descendantAnimationController!;
    }
    if(widget.descendantAnimationControllerName != null){
      descendantAnimationController2 = cnHomepage.animationControllers["${widget.descendantAnimationControllerName!.value}2"];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(scrollController != null && scrollController!.hasClients){
        scrollController?.addListener(_listener);
      }
    });

    if(widget.panelBuilder == null){
      bounceAllowed = true && widget.bounce;
    }
  }

  void _listener(){
    if(!scrollController!.hasClients){
      return;
    }
    if(scrollController!.offset > 30 || scrollController!.offset < -15){
      isScrolling = true;
    }
    else{
      isScrolling = false;
    }
  }

  @override
  void dispose(){
    super.dispose();
    if(scrollController != null && scrollController!.hasClients){
      scrollController?.removeListener(_listener);
    }
    animationController.dispose();
    cnHomepage.animationControllers.remove(widget.animationControllerName.value);
    cnHomepage.animationControllers.remove("${widget.animationControllerName.value}2");
  }

  Future animateScrollControllerToDelta()async{
    double dy = scrollController!.position.pixels;
    if((dy == 0 && delta < 0) || (dy == scrollController!.position.maxScrollExtent && delta > 0)){
      delta = 0;
      return;
    }
    await scrollController?.animateTo((dy + delta).clamp(0, scrollController!.position.maxScrollExtent), duration: const Duration(milliseconds: 10), curve: Curves.linear);
    if(delta != 0){
      await animateScrollControllerToDelta();
    }
  }

  onPanelSlide(double value){
    if(currentBuilder != lastBuilder){
      lastBuilder = currentBuilder;
    }
    if(descendantAnimationController != null){
      descendantAnimationController!.value = value*0.5;
    }
    if(descendantAnimationController2 != null){
      descendantAnimationController2!.value = 0.5 + value*0.5;
    }
    if(value == 0){
      Future.delayed(const Duration(milliseconds: 200), (){
        if(panelController.panelPosition == 0){
          FocusManager.instance.primaryFocus?.unfocus();
        }
      });
    }
  }

  void removeOverScrollOffset(){
    if(overScrollOffset == 0 || !bounceAllowed){
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
    bool autoScroll = true,
    Widget? child,
    List<Widget>? children,
    Widget? Function(BuildContext context, int index)? itemBuilder,
    Widget Function(BuildContext context, int index)? separatorBuilder,
    required ScrollController controller,
    int? itemCount,
    BuildContext? context
  }){
    assert((child != null) ^ (children != null) ^ (itemBuilder != null), "Either child or children or itemBuilder must be given. They can't all be null or not null at the same time");
    assert(itemBuilder == null || itemCount != null, "itemCount must be provided if itemBuilder is provided");

    context = context?? this.context;

    scrollController = controller;
    bounceAllowed = widget.bounce;

    Widget getDynamicListView(){
      if(child != null){
        return SingleChildScrollView(
          controller: controller,
          physics: physics,
          // shrinkWrap: shrinkWrap,
          padding: padding,
          child: child,
        );
      }
      else if(children != null){
        return ListView(
          controller: controller,
          physics: physics,
          shrinkWrap: shrinkWrap,
          padding: padding,
          children: children,
        );
      }
      else if(itemBuilder != null){
        return ListView.separated(
          controller: controller,
            physics: physics,
            shrinkWrap: shrinkWrap,
            padding: padding,
            itemBuilder: itemBuilder,
            separatorBuilder: separatorBuilder?? (context, index){
              return const SizedBox();
            },
            itemCount: itemCount?? 0
        );
      }
      return const SizedBox();
    }

    return Listener(
      onPointerDown: (details){
        isTouchingListView = controller.position.maxScrollExtent > 0;

        /// Recognize Long Press after 500 milliseconds, if the time was not cancelled
        /// This will disable dragging panel and bouncing panel
        longPressTimer = Timer(const Duration(milliseconds: 500), (){
          recognizedLongPress = true;
        });

      },
      onPointerMove: (details){
        /// Recognize long press
        if(longPressTimer?.isActive?? false){
          const th = 5;
          final dx = (details.position.dx - initialPointerDownEvent.position.dx).abs();
          final dy = (details.position.dy - initialPointerDownEvent.position.dy).abs();
          if(dx > th || dy > th) {
            recognizedLongPress = false;
            longPressTimer?.cancel();
          }
        }

        /// do autoScroll while dragging
        if(recognizedLongPress && autoScroll){
          final screenHeight = MediaQuery.of(context!).size.height;
          if(details.position.dy > screenHeight * 0.25 && details.position.dy < screenHeight * 0.9){
            delta = 0;
          }
          else{
            if(details.position.dy < screenHeight * 0.15){
              if(delta == 0){
                delta = -8;
                animateScrollControllerToDelta();
              }
              delta = -8;
            }
            else if(details.position.dy < screenHeight * 0.2){
              if(delta == 0){
                delta = -4;
                animateScrollControllerToDelta();
              }
              delta = -4;
            }
            else if(details.position.dy < screenHeight * 0.25){
              if(delta == 0){
                delta = -2;
                animateScrollControllerToDelta();
              }
              delta = -2;
            }
            else if(details.position.dy > screenHeight * 0.98){
              if(delta == 0){
                delta = 8;
                animateScrollControllerToDelta();
              }
              delta = 8;
            }
            else if(details.position.dy > screenHeight * 0.95){
              if(delta == 0){
                delta = 4;
                animateScrollControllerToDelta();
              }
              delta = 4;
            }
            else if(details.position.dy > screenHeight * 0.9){
              if(delta == 0){
                delta = 2;
                animateScrollControllerToDelta();
              }
              delta = 2;
            }
          }
        }
      },
      onPointerUp: (details){
        isTouchingListView = false;
        recognizedLongPress = false;
        delta = 0;
        longPressTimer?.cancel();
      },
      child: getDynamicListView()
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget panel = LayoutBuilder(
        builder: (context, constraints){
          final maxHeight = constraints.maxHeight - (Platform.isAndroid? 50 : 70);
          double panelHeight = ((widget.maxHeight?? maxHeight) + overScrollOffset).clamp(0, maxHeight + overScrollOffset);
          return Listener(
            onPointerDown: (details){
              // if(!bounceAllowed){
              //   return;
              // }
              initialPanelPosition = panelController.panelPosition;
              initialPointerDownEvent = details;
              if(scrollController != null &&
                  scrollController!.hasClients
              ){
                initialScrollControllerPosition = scrollController!.offset;
              }
            },
            onPointerMove: (details) {
              if(recognizedLongPress){
                return;
              }

              /// Recognize horizontal or vertical drag
              if(isDraggingVertical == null){
                final dx = (details.position.dx - initialPointerDownEvent.position.dx).abs();
                final dy = (details.position.dy - initialPointerDownEvent.position.dy).abs();
                if(dx > thresholdVerticalDrag || dy > thresholdVerticalDrag){
                  if(dx > dy){
                    isDraggingVertical = false;
                  } else{
                    isDraggingVertical = true;
                  }
                }
              }

              /// Bounce
              if ((panelController.panelPosition > 0.99 || panelDragRunning) &&
                  !isTouchingListView &&
                  (isDraggingVertical?? false) &&
                  bounceAllowed
              ){
                setState(() {
                  double value =  initialPointerDownEvent.position.dy - details.position.dy;
                  value = pow(value, 0.5) * 1.0;
                  value = value;
                  panelDragRunning = true;
                  overScrollOffset = ((value > 0) ? value : 0).clamp(0, 14) * 0.7;
                });
              }


              /// Drag panel while touching list View
              else if(scrollController != null &&
                  scrollController!.hasClients &&
                  scrollController!.offset <= 0 &&
                  initialPanelPosition > 0.1 &&
                  (isDraggingVertical?? false)
              ){
                if(!isScrolling && initialScrollControllerPosition < 10){
                  const int smoothStartThreshold = 10;
                  lastPointerMoveEvent = details;
                  underScrollOffset = (underScrollOffset - details.delta.dy).clamp(-panelHeight+1, 0);
                  final double panelPosition = ((panelHeight + underScrollOffset + smoothStartThreshold) / panelHeight).clamp(0, 1);
                  panelController.animatePanelToPosition(panelPosition, duration: const Duration(milliseconds: 0));
                  if (underScrollOffset < 0){
                    scrollController!.jumpTo(0);
                  }
                }
              }
              else{
                panelDragRunning = false;
                removeOverScrollOffset();
                underScrollOffset = 0;
              }
            },
            onPointerUp: (details) {
              isScrolling = false;
              initialScrollControllerPosition = 0;
              panelDragRunning = false;
              isDraggingVertical = null;
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
                borderRadius: widget.borderRadius,
                color: color,
                isDraggable: widget.isDraggable,
                parallaxOffset: 0.9,
                onPanelSlide: (value){
                  onPanelSlide(value);
                  if(widget.onPanelSlide != null){
                    widget.onPanelSlide!(value);
                  }
                },
                panel: ClipRRect(
                  borderRadius: widget.borderRadius,
                  child: ListViewScope(
                      listView: myListView,
                      child: widget.panel?? widget.panelBuilder!(context, myListView)
                  ),
                ),
                backdropEnabled: widget.backdropEnabled,
                backdropColor: widget.backdropColor,
                backdropOpacity: widget.backdropOpacity
            ),
          );
        }
    );

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child){

        final matrix = Matrix4.identity()
          ..translate(0.0, topPaddingAnim.value)
          ..scale(scaleAnim.value);

        return Transform(
          transform: matrix,
          alignment: Alignment.center,
          child: Stack(
            fit: StackFit.expand,
            children: [
              child ?? const SizedBox(),
              if(opacityAnim.value > 0)
                Container(color: Color.fromRGBO(0, 0, 0, opacityAnim.value)),
            ],
          ),
        );
      },
      child: panel,
    );
  }
}

typedef PanelListViewBuilder = Widget Function({
  bool autoScroll,
  Widget? child,
  List<Widget>? children,
  required ScrollController controller,
  Widget? Function(BuildContext, int)? itemBuilder,
  int? itemCount,
  EdgeInsets padding,
  ScrollPhysics physics,
  Widget Function(BuildContext, int)? separatorBuilder,
  bool shrinkWrap,
  BuildContext? context
});

class ListViewScope extends InheritedWidget {
  final PanelListViewBuilder listView;

  const ListViewScope({
    required this.listView,
    required Widget child,
    super.key,
  }) : super(child: child);

  static ListViewScope of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<ListViewScope>();
    assert(result != null, 'FunctionScope not found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ListViewScope oldWidget) =>
      oldWidget.listView != listView;
}