import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fitness_app/screens/main_screens/screen_statistics/screen_statistics.dart';

class VerticalScrollWheel extends StatefulWidget {

  final double widthOfChildren;
  final double heightOfChildren;
  final int selectedIndex;
  final List<Widget> children;
  final Function(int index)? onTap;

  const VerticalScrollWheel({
    super.key,
    this.widthOfChildren = 100,
    this.heightOfChildren = 50,
    this.selectedIndex = 0,
    required this.children,
    this.onTap
  });

  @override
  State<VerticalScrollWheel> createState() => _VerticalScrollWheelState();
}

class _VerticalScrollWheelState extends State<VerticalScrollWheel> {

  late final ScrollController _scrollController = ScrollController(initialScrollOffset: widget.selectedIndex*widget.widthOfChildren);
  late int selectedIndex = widget.selectedIndex;
  late CnScreenStatistics cnScreenStatistics = Provider.of<CnScreenStatistics>(context, listen: true);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollController.animateTo(
    //       widget.selectedIndex*widget.widthOfChildren,
    //       duration: const Duration(milliseconds: 150),
    //       curve: Curves.easeInOut
    //   );
    // });
    return RotatedBox(
      quarterTurns: -1,
      child: ListWheelScrollView(
        // physics: const PageScrollPhysics(),
        physics: const BouncingScrollPhysics(),
        diameterRatio: 1.8,
        // clipBehavior: Clip.antiAlias,
        controller: _scrollController,
        itemExtent: widget.widthOfChildren,
        children: List.generate(
          widget.children.length,
              (index) => RotatedBox(
            quarterTurns: 1,
            child: GestureDetector(
              onTap: (){
                setState(() {
                  selectedIndex = index;
                  _scrollController.animateTo(
                      index*widget.widthOfChildren,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInOut
                  );
                  if(widget.onTap != null){
                    widget.onTap!(index);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: index == selectedIndex ? widget.widthOfChildren+10 : widget.widthOfChildren,
                height: index == selectedIndex ? widget.heightOfChildren+10 : widget.heightOfChildren,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: index == selectedIndex ? Color(0xFFC16A03) : Colors.transparent,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10)
                ),
                // child: Text('$index'),
                child: widget.children[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
