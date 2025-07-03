import 'package:flutter/material.dart';

class PanelHeader extends StatelessWidget {

  final String text;

  const PanelHeader({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      color: Theme.of(context).primaryColor,
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(text,textScaler: const TextScaler.linear(1.4), textAlign: TextAlign.center,),
      )
    );
  }
}
