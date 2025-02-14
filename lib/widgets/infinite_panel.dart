import 'package:fitness_app/widgets/my_slide_up_panel.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class InfinitePanel extends StatefulWidget {
  final String name;
  final String descendantName;
  final PanelController controller;
  final Widget? child;

  const InfinitePanel({
    super.key,
    this.child,
    required this.name,
    required this.descendantName,
    required this.controller
  });

  @override
  State<InfinitePanel> createState() => _InfinitePanelState();
}

class _InfinitePanelState extends State<InfinitePanel> {
  final PanelController controllerChild = PanelController();
  bool attached = false;
  bool didOpen = false;

  @override
  Widget build(BuildContext context) {

    if(attached && !didOpen){
      didOpen = true;
      Future.delayed(const Duration(milliseconds: 10), (){
        controllerChild.animatePanelToPosition(
            1,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastEaseInToSlowEaseOut
        );
      });
    }

    return Stack(
      children: [
        MySlideUpPanel(
          controller: widget.controller,
          descendantAnimationControllerName: widget.descendantName,
          animationControllerName: widget.name,
          panel: Center(
            child: ElevatedButton(
                onPressed: (){
                  setState(() {
                    attached = true;
                  });

                },
                child: widget.child
            ),
          ),
          onPanelSlide: (position){
            if(attached && didOpen && widget.controller.panelPosition == 0){
              setState(() {
                attached = false;
                didOpen = false;
              });
            }
          },
        ),
        if(attached)
          InfinitePanel(
              name: "${widget.name}A",
              descendantName: widget.name,
              controller: controllerChild
          )
      ],
    );
  }
}
