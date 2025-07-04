import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// The scale based on the height of the button
const _googleIconSizeScale = 28 / 44;

/// A `Sign in with Google` button
class SignInWithGoogleButton extends StatelessWidget {
  const SignInWithGoogleButton({
    super.key,
    required this.onPressed,
    this.text = 'Sign in with Google',
    this.height = 44,
    this.style = SignInWithGoogleButtonStyle.black,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.iconAlignment = IconAlignment.center,
  });

  /// The callback that is be called when the button is pressed.
  final VoidCallback? onPressed;

  /// The text to display next to the Google logo.
  ///
  /// Defaults to `Sign in with Google`.
  final String text;

  /// The height of the button.
  ///
  /// This defaults to `44` according to Google's guidelines.
  final double height;

  /// The style of the button.
  ///
  /// Supported options are in line with Google's guidelines.
  ///
  /// This defaults to [SignInWithGoogleButtonStyle.black].
  final SignInWithGoogleButtonStyle style;

  /// The border radius of the button.
  ///
  /// Defaults to `8` pixels.
  final BorderRadius borderRadius;

  /// The alignment of the Google logo inside the button.
  ///
  /// This defaults to [IconAlignment.center].
  final IconAlignment iconAlignment;

  /// Returns the background color of the button based on the current [style].
  Color get _backgroundColor {
    switch (style) {
      case SignInWithGoogleButtonStyle.black:
        return Colors.black;
      case SignInWithGoogleButtonStyle.white:
      case SignInWithGoogleButtonStyle.whiteOutlined:
        return Colors.white;
    }
  }

  /// Returns the contrast color to the [_backgroundColor] derived from the current [style].
  ///
  /// This is used for the text and logo color.
  Color get _contrastColor {
    switch (style) {
      case SignInWithGoogleButtonStyle.black:
        return Colors.white;
      case SignInWithGoogleButtonStyle.white:
      case SignInWithGoogleButtonStyle.whiteOutlined:
        return Colors.black;
    }
  }

  /// The decoration which should be applied to the inner container inside the button
  ///
  /// This allows to customize the border of the button
  Decoration? get _decoration {
    switch (style) {
      case SignInWithGoogleButtonStyle.black:
      case SignInWithGoogleButtonStyle.white:
        return null;

      case SignInWithGoogleButtonStyle.whiteOutlined:
        return BoxDecoration(
          border: Border.all(width: 1, color: _contrastColor),
          borderRadius: borderRadius,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // per Google's guidelines
    final fontSize = height * 0.43;

    final textWidget = Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        inherit: false,
        fontSize: fontSize,
        color: _contrastColor,
        fontFamily: '.SF Pro Text',
        letterSpacing: -0.41,
      ),
    );

    final googleIcon = Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 5),
        child: SizedBox(
          width: height*0.7,
          height: height*0.7,
          child: Image.asset("lib/assets/settings_icons/google_logo.png"),
        ),
      ),
    );

    var children = <Widget>[];

    switch (iconAlignment) {
      case IconAlignment.center:
        children = [
          googleIcon,
          Flexible(
            child: textWidget,
          ),
        ];
        break;
      case IconAlignment.left:
        children = [
          googleIcon,
          Expanded(
            child: textWidget,
          ),
          SizedBox(
            width: _googleIconSizeScale * height,
          ),
        ];
        break;
    }

    return SizedBox(
      height: height,
      child: SizedBox.expand(
        child: CupertinoButton(
          borderRadius: borderRadius,
          padding: EdgeInsets.zero,
          color: _backgroundColor,
          onPressed: onPressed,
          child: Container(
            decoration: _decoration,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

enum SignInWithGoogleButtonStyle {
  /// A black button with white text
  black,

  /// A white button with black text
  white,

  /// A white button which has a black outline
  whiteOutlined,
}

/// This controls the alignment of the Google Logo on the [SignInWithGoogleButton]
enum IconAlignment {
  /// The icon will be centered together with the text
  center,

  /// The icon will be on the left side, while the text will be centered accordingly
  left,
}
