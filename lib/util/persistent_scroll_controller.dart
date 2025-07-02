import 'package:flutter/widgets.dart';

class PersistentScrollController {
  ScrollController controller;
  double _lastOffset;

  PersistentScrollController({
    double initialOffset = 0.0
  })
      : _lastOffset = initialOffset,
        controller = ScrollController(initialScrollOffset: initialOffset){
   controller.addListener(_listener);
  }

  // ScrollController get controller => _controller;

  void _listener(){
    if (controller.hasClients) {
      _lastOffset = controller.offset;
    }
  }

  void resume() {
    if (!controller.hasClients) {
      controller.dispose();
      controller = ScrollController(initialScrollOffset: _lastOffset);
      controller.addListener(_listener);
    }
  }

  void dispose() {
    controller.dispose();
  }

  double get offset => controller.hasClients ? controller.offset : _lastOffset;
}
