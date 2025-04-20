import 'package:flutter/cupertino.dart';

class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final int delay;
  final bool doFadeIn;

  const FadeInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = 0,
    this.doFadeIn = true,
  });

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget> {
  late double opacity = widget.doFadeIn? 0.0 : 1;

  @override
  void initState() {
    super.initState();
    if(widget.doFadeIn){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: widget.delay), () {
          if (mounted) {
            setState(() {
              opacity = 1.0;
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: widget.duration,
      curve: Curves.easeInOut,
      child: widget.child,
    );
  }
}
