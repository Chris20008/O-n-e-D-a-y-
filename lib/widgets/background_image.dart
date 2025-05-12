import 'dart:ui';

import 'package:fitness_app/widgets/spotify_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BackgroundColor extends StatefulWidget {
  const BackgroundColor({super.key});

  @override
  State<BackgroundColor> createState() => _BackgroundColorState();
}

class _BackgroundColorState extends State<BackgroundColor> {

  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  late CnBackgroundColor cnBackgroundColor;

  @override
  Widget build(BuildContext context) {

    cnBackgroundColor = Provider.of<CnBackgroundColor>(context);

    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      decoration: BoxDecoration(
          gradient:  LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                cnBackgroundColor.colorSecondChild?? Colors.black38,
                cnBackgroundColor.colorFirstChild?? Colors.black54,
              ]
          )
      ),
      // color: cnBackgroundColor.colorFirstChild,
      child: Container(
        decoration: const BoxDecoration(
            gradient:  LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Colors.black38,
                  Colors.black54,
                ]
            )
        ),
      ),
    );
  }
}

class CnBackgroundColor extends ChangeNotifier {
  Color? colorFirstChild;
  Color? colorSecondChild;
  bool isRefreshing = false;
  bool firstChild = true;
  String currentImageUri = "";
  String currentTrackName = "";
  Map<String, List<Color>> songColors = {};
  List<Color> defaultColors = [Colors.black, Colors.white];

  setColor(Color c, Color c2){
    colorFirstChild = c;
    colorSecondChild = c2;
    refresh();
  }

  void refresh(){
    notifyListeners();
  }
}