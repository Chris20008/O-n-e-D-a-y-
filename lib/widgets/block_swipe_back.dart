import 'package:flutter/cupertino.dart';

class BlockSwipeBack extends StatelessWidget {
  final Widget? child;
  final bool doBlock;
  final bool withPadding;

  const BlockSwipeBack({
    super.key,
    this.child,
    this.doBlock = true,
    this.withPadding = false
  });

  @override
  Widget build(BuildContext context) {
    if(!doBlock){
      return child?? const SizedBox();
    }

    if(withPadding){
      return Stack(
        // alignment: Alignment.center,
        children: [
          child?? const SizedBox(),
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: MetaData(
                metaData: "blockSwipeBack",
                behavior: HitTestBehavior.translucent,
                child: SizedBox(height: double.maxFinite, width: double.maxFinite,)
            ),
          ),
        ],
      );
    }

    return MetaData(
        metaData: "blockSwipeBack",
        behavior: HitTestBehavior.opaque,
        child: child?? const SizedBox(height: double.maxFinite, width: double.maxFinite,)
    );
  }
}
