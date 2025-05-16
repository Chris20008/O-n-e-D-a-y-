import 'package:flutter/cupertino.dart';

class ScrollListener extends StatefulWidget {
  final ScrollController controller;
  final double minValue;
  final double maxValue;
  final double minOffset;
  final double? maxOffset;
  final bool inverted;
  final Widget Function(BuildContext context, double value, double percent) builder;

  const ScrollListener({
    super.key,
    required this.controller,
    required this.minValue,
    required this.maxValue,
    this.minOffset = 0,
    this.maxOffset,
    required this.builder,
    this.inverted = false
  }) :
  // Ensure that the value range is valid
        assert(minValue < maxValue,
        'ScrollListener: minValue must be less than maxValue.'),

  // Ensure minOffset is not negative
        assert(minOffset >= 0,
        'ScrollListener: minOffset must be greater than or equal to 0.'),

  // Ensure that maxOffset (if provided) is greater than minOffset
        assert(
        maxOffset == null || minOffset < maxOffset,
        'ScrollListener: minOffset must be less than maxOffset when maxOffset is provided.'),

  // If maxOffset is null, ensure minOffset is still less than maxValue
        assert(
        maxOffset != null || minOffset < maxValue,
        'ScrollListener: minOffset must be less than maxValue when maxOffset is not provided.'),

  // Prevent division by zero in factor calculation
        assert(
        (maxOffset ?? maxValue) - minOffset != 0,
        'ScrollListener: maxOffset - minOffset must not be 0 to avoid division by zero.');

  @override
  State<ScrollListener> createState() => _ScrollListenerState();
}

class _ScrollListenerState extends State<ScrollListener> {

  late final factor = (widget.maxValue-widget.minValue) / ((widget.maxOffset?? widget.maxValue) - widget.minOffset);
  late double value;
  late double percent;

  @override
  void initState() {
    super.initState();
    value = _calcCurrentValue();
    percent = _calcPercent();
    widget.controller.addListener(_listener);
  }

  void _listener(){
    final newValue = _calcCurrentValue();

    if(newValue != value){
      setState(() {
        value = newValue;
        percent = _calcPercent();
      });
    }
  }

  double _calcCurrentValue(){
    final offset = widget.controller.hasClients? widget.controller.position.pixels : widget.controller.initialScrollOffset;
    final currPosition = (offset - widget.minOffset) * factor;
    final tempVal = (widget.maxValue - currPosition).clamp(widget.minValue, widget.maxValue);
    return widget.inverted? widget.maxValue + widget.minValue - tempVal : tempVal;
  }

  double _calcPercent(){
    final tempPercent = (value-widget.minValue) / (widget.maxValue - widget.minValue);
    return tempPercent.clamp(0, 1);
    // return widget.inverted? 1 - tempPercent : tempPercent;
  }

  @override
  void dispose(){
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value, percent);
  }
}
