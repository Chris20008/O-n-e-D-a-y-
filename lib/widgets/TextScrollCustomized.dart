import "package:flutter/material.dart";
import "package:text_scroll/text_scroll.dart";

class TextScrollCustomized extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int? numberOfReps;
  final int pauseBetween;
  final TextScrollMode mode;

  const TextScrollCustomized({
    required this.text,
    super.key,
    this.style,
    this.numberOfReps = 3,
    this.pauseBetween = 2000,
    this.mode = TextScrollMode.endless
  });

  @override
  State<TextScrollCustomized> createState() => _TextScrollCustomized();
}

class _TextScrollCustomized extends State<TextScrollCustomized> {
  String? previousText;
  late Key key = UniqueKey();

  @override
  Widget build(BuildContext context) {

    if(previousText != widget.text){
      previousText = widget.text;
      key = UniqueKey();
      Future.delayed(const Duration(milliseconds: 150), (){
        if(context.mounted){
          setState(() {
            key = UniqueKey();
          });
        }
      });
    }

    return SizedBox(
      key: widget.key,
      child: TextScroll(
        key: key,
        " ${widget.text} ",
        style: widget.style,
        mode: widget.mode,
        pauseBetween: Duration(milliseconds: widget.pauseBetween),
        velocity: const Velocity(pixelsPerSecond: Offset(25, 0)),
        delayBefore: const Duration(milliseconds: 1000),
        pauseOnBounce: const Duration(milliseconds: 1000),
        numberOfReps: widget.numberOfReps,
        fadedBorder: true,
        fadeBorderVisibility: FadeBorderVisibility.auto,
        fadeBorderSide: FadeBorderSide.both,
        fadedBorderWidth: 0.03,
        intervalSpaces: 15,
      ),
    );
  }
}
