import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BlockGesture extends StatelessWidget {
  final Widget? child;
  final bool doBlock;
  final bool withPadding;
  final String tag;

  const BlockGesture({
    super.key,
    this.child,
    this.doBlock = true,
    this.withPadding = false,
    this.tag = "blockSwipeBack"
  });

  @override
  Widget build(BuildContext context) {
    if(!doBlock){
      return child?? const SizedBox();
    }

    if(withPadding){
      return Stack(
        children: [
          child?? const SizedBox(),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: MetaData(
                  metaData: tag,
                  behavior: HitTestBehavior.translucent,
                  child: const SizedBox()
              ),
            ),
          ),
        ],
      );
    }

    return MetaData(
        metaData: tag,
        behavior: HitTestBehavior.opaque,
        child: child?? const SizedBox(height: double.maxFinite, width: double.maxFinite,)
    );
  }
}
