import 'package:fitness_app/screens/main_screens/screen_statistics/widgets/charts/sz_controller.dart';
import 'package:flutter/cupertino.dart';

class SzWrapper extends StatefulWidget {
  final Widget Function(BuildContext context) childBuilder;
  final SZController szController;

  const SzWrapper({
    super.key,
    required this.childBuilder,
    required this.szController
  });

  @override
  State<SzWrapper> createState() => _SzWrapperState();
}

class _SzWrapperState extends State<SzWrapper> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints){
          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (PointerDownEvent details) => widget.szController.pointerDown(details),
            onPointerMove: (PointerMoveEvent details) => widget.szController.pointerMove(details, constraints),
            onPointerUp: (PointerUpEvent details) => widget.szController.pointerUp(details),
            child: ValueListenableBuilder(
              valueListenable: widget.szController.state,
              builder: (_, state, __) {
                return Stack(
                  children: [
                    // StatisticsOverlay(),
                    widget.childBuilder(context)
                  ],
                );
              }
            ),
          );
        }
    );
  }
}
