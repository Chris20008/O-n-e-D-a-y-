import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoButtonText extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final TextAlign textAlign;
  final EdgeInsets padding;

  const CupertinoButtonText({
    Key? key,
    required this.text,
    required this.onPressed,
    this.textColor,
    this.textAlign = TextAlign.center,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return CupertinoButton(
      onPressed: onPressed,
      padding: padding,
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          color: textColor?? Colors.amber[800]?? const Color(0xFFFF9A19)
        ),
      ),
    );
  }
}