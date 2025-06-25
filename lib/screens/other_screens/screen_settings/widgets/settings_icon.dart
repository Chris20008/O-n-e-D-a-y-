import 'package:flutter/cupertino.dart';

class SettingsIcon extends StatelessWidget {
  final String iconPath;

  const SettingsIcon({
    super.key,
    required this.iconPath
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: const Color(0xcc4e4e4e), width: 0.7),
          borderRadius: BorderRadius.circular(6)
        ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset("lib/assets/settings_icons/$iconPath"),
      ),
    );
  }
}
