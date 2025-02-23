import 'package:fitness_app/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StandardPopUp extends StatefulWidget {

  const StandardPopUp({
    super.key
  });

  @override
  State<StandardPopUp> createState() => _StandardPopUpState();
}

class _StandardPopUpState extends State<StandardPopUp> with TickerProviderStateMixin {
  late CnStandardPopUp cnStandardPopUp;
  late final AnimationController _controller = AnimationController(
    duration: Duration(milliseconds: cnStandardPopUp.animationTime),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    // curve: Curves.decelerate,
    curve: Curves.easeOutBack
  );

  @override
  Widget build(BuildContext context) {
    cnStandardPopUp = Provider.of<CnStandardPopUp>(context);

    final size = MediaQuery.of(context).size;

    if(cnStandardPopUp.isVisible){
      _controller.forward();
    } else{
      _controller.reverse();
    }

    return Stack(
      key: cnStandardPopUp.key,
      alignment: Alignment.center,
      children: [
        AnimatedCrossFade(
          layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  key: bottomChildKey,
                  child: bottomChild,
                ),
                Positioned(
                  key: topChildKey,
                  child: topChild,
                ),
              ],
            );
          },
            firstChild: const SizedBox(),
            secondChild: GestureDetector(
              onTap: cnStandardPopUp.tapOutside,
              child: Container(
                height: size.height,
                width: size.width,
                color: Colors.black54,
                // color: Colors.transparent,
              ),
            ),
            crossFadeState: !cnStandardPopUp.isVisible?
              CrossFadeState.showFirst:
              CrossFadeState.showSecond,
            duration: Duration(milliseconds: cnStandardPopUp.animationTime),
        ),
        ScaleTransition(
          scale: _animation,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: cnStandardPopUp.maxWidth,
                    maxHeight: cnStandardPopUp.maxHeight
                ),
                child: Container(
                    width: size.width*cnStandardPopUp.widthFactor,
                    color: cnStandardPopUp.color,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: cnStandardPopUp.padding,
                            child: SingleChildScrollView(
                                padding: const EdgeInsets.all(0.0),
                                child: cnStandardPopUp.child
                            ),
                          ),
                          // horizontalGreySpacer,
                          SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                if(cnStandardPopUp.showCancel)
                                  Expanded(
                                      child: CupertinoButton(
                                          onPressed: cnStandardPopUp.cancel,
                                          // style: ButtonStyle(
                                          //     shadowColor: MaterialStateProperty.all(Colors.transparent),
                                          //     surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
                                          //     backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                          //     // backgroundColor: MaterialStateProperty.all(Colors.grey[800]!.withOpacity(0.6)),
                                          //     shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
                                          // ),
                                          child: Text(cnStandardPopUp.cancelText)
                                      )
                                  ),
                                // if(cnStandardPopUp.showCancel)
                                //   verticalGreySpacer,
                                Expanded(
                                    child: CupertinoButton(
                                        onPressed: cnStandardPopUp.confirm,
                                        // style: ButtonStyle(
                                        //     shadowColor: MaterialStateProperty.all(Colors.transparent),
                                        //     surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
                                        //     backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                        //     // backgroundColor: MaterialStateProperty.all(Colors.grey[800]!.withOpacity(0.6)),
                                        //     shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)))
                                        // ),
                                        child: Text(cnStandardPopUp.confirmText, style: cnStandardPopUp.confirmTextStyle)
                                    )
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CnStandardPopUp extends ChangeNotifier {
  Key key = UniqueKey();
  bool isVisible = false;
  Function? onConfirm;
  Function? onCancel;
  Function? onTapOutside;
  Widget child = const SizedBox();
  EdgeInsets padding = const EdgeInsets.all(20);
  String confirmText = "";
  String cancelText = "";
  TextStyle? confirmTextStyle;
  bool jump = true;
  bool showCancel = true;
  bool canConfirm = true;
  Color color = Colors.black;
  int animationTime = 200;
  double widthFactor = 0.65;
  double maxHeight = 300;
  double maxWidth = 600;

  void open({
    required BuildContext context,
    required Widget child,
    Function? onConfirm,
    Function? onCancel,
    EdgeInsets padding = const EdgeInsets.all(20),
    String? confirmText,
    String? cancelText,
    Color? color,
    bool showCancel = true,
    bool canConfirm = true,
    TextStyle? confirmTextStyle,
    double widthFactor = 0.65,
    double maxHeight = 600,
    double maxWidth = 300,
    Function? onTapOutside
  }){
    HapticFeedback.selectionClick();
    jump = true;
    this.onConfirm = onConfirm;
    this.onCancel = onCancel;
    this.onTapOutside = onTapOutside?? onCancel;
    this.child = child;
    this.padding = padding;
    this.confirmText = confirmText?? AppLocalizations.of(context)!.ok;
    this.cancelText = cancelText?? AppLocalizations.of(context)!.cancel;
    this.color = color?? Theme.of(context).primaryColor;
    this.showCancel = showCancel;
    this.canConfirm = canConfirm;
    this.confirmTextStyle = confirmTextStyle;
    this.widthFactor = widthFactor;
    this.maxHeight = maxHeight;
    this.maxWidth = maxWidth;
    refresh();

    Future.delayed(const Duration(milliseconds: 50), (){
      jump = false;
      isVisible = true;
      refresh();
    });
  }

  void confirm(){
    if(!canConfirm){
      return;
    }
    if(onConfirm != null){
      onConfirm!();
    }
    clear();
  }

  void cancel(){
    if(onCancel != null){
      onCancel!();
    }
    clear();
  }

  void tapOutside(){
    if(onTapOutside != null){
      onTapOutside!();
    }
    clear();
  }


  void clear(){
    isVisible = false;
    onConfirm = null;
    onCancel = null;
    HapticFeedback.selectionClick();
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}
