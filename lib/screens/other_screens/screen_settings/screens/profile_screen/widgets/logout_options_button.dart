import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LogoutOptionsButton extends StatelessWidget {

  final String header;
  final String description;
  final Widget leadingIcon;
  final Color buttonColor;
  final Function onPressed;

  const LogoutOptionsButton({
    super.key,
    required this.header,
    required this.description,
    required this.leadingIcon,
    required this.buttonColor,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {

    final buttonWidth = MediaQuery.of(context).size.width * 0.8;
    const buttonHeight = 80.0;

    return CupertinoButton(
      padding: EdgeInsets.zero,
        onPressed: () => onPressed(),
        child: Container(
          height: buttonHeight,
          width: buttonWidth,
          decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(15)
          ),
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              leadingIcon,
              const SizedBox(width: 15,),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        header,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600
                        ),
                        textScaler: const TextScaler.linear(1.1)
                    ),
                    Text(
                        description,
                        style: TextStyle(
                          color: Colors.white54,
                          // fontWeight: FontWeight.w
                        ),
                        textScaler: TextScaler.linear(0.8)
                    )
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }
}
