import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

OverlayEntry setLoadingOverlay(BuildContext context){
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => Positioned.fill(
      child: AbsorbPointer(
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: CupertinoActivityIndicator(
              radius: 20.0,
              color: Colors.amber[800]
          )
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);

  return overlayEntry;
}

Future<dynamic> futureWithLoadingOverlay({
  required BuildContext context,
  required Future<dynamic> Function() future
}) async{
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => Positioned.fill(
      child: AbsorbPointer(
        child: Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: CupertinoActivityIndicator(
                radius: 20.0,
                color: Colors.amber[800]
            )
        ),
      ),
    ),
  );

  // Overlay.of(context).insert(overlayEntry);
  Navigator.of(context, rootNavigator: true).overlay?.insert(overlayEntry);

  dynamic result;

  try{
    result = await future();
  } catch (_){}

  overlayEntry.remove();

  return result;
}