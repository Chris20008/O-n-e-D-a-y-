import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class KeyboardTopBar extends StatelessWidget {
  final Function? onPressedLeft;
  final Function? onPressedRight;
  final String textLeft;
  final String textRight;

  const KeyboardTopBar({
    super.key,
    this.onPressedLeft,
    this.onPressedRight,
    textLeft,
    textRight
  }) : textLeft = textLeft?? "Back", textRight= textRight?? "Next";

  @override
  Widget build(BuildContext context) {
    String textLeftFinal = textLeft != "Back"? textLeft : AppLocalizations.of(context)!.welcomeBack;
    String textRightFinal = textRight != "Next"? textRight : AppLocalizations.of(context)!.welcomeNext;
    return Positioned(
      left: 0,
      right: 0,
      bottom: MediaQuery.of(context).viewInsets.bottom,
      child: GestureDetector(
        onTap: (){}, /// Empty Gesture Detector to override higher Gesture Detector
        child: Container(
          height: 40,
          color: const Color(0XFF333335),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                  padding: const EdgeInsets.only(top: 5, bottom: 5, left: 23, right: 23),
                  onPressed: (){
                    if(onPressedLeft != null){
                      onPressedLeft!();
                    }
                  },
                  child: Text(
                      textLeftFinal,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      textScaler: const TextScaler.linear(1.1)
                  )
              ),
              CupertinoButton(
                  padding: const EdgeInsets.only(top: 5, bottom: 5, right: 23, left: 23),
                  onPressed: (){
                    if(onPressedRight != null){
                      onPressedRight!();
                    }
                  },
                  child: Text(
                      textRightFinal,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      textScaler: const TextScaler.linear(1.1)
                  )
              )
            ],
          ),
        ),
      ),
    );
  }

  // @override
  // State<KeyboardTopBar> createState() => _KeyboardTopBarState();
}

// class _KeyboardTopBarState extends State<KeyboardTopBar> {
//   late String textLeft;
//   late String textRight;
//
//   @override
//   void initState() {
//     textLeft = widget.textLeft != "Back"? widget.textLeft : AppLocalizations.of(context)!.welcomeBack;
//     textRight = widget.textRight != "Next"? widget.textRight : AppLocalizations.of(context)!.welcomeNext;
//     super.initState();
//   }
//
//
// }
