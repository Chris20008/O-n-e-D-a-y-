import 'dart:ui';

import 'package:fitness_app/widgets/spotify_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BackgroundImage extends StatefulWidget {
  const BackgroundImage({super.key});

  @override
  State<BackgroundImage> createState() => _BackgroundImageState();
}

class _BackgroundImageState extends State<BackgroundImage> {

  late CnSpotifyBar cnSpotifyBar = Provider.of<CnSpotifyBar>(context, listen: false);
  late CnBackgroundImage cnBackgroundImage;

  @override
  Widget build(BuildContext context) {
    cnBackgroundImage = Provider.of<CnBackgroundImage>(context);
    return ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: 50.0,
          sigmaY: 50.0,
        ),
        child: Stack(
            children: [
              cnSpotifyBar.lastImage,
              Container(
                height: double.maxFinite,
                width: double.maxFinite,
                color: Colors.black.withOpacity(0.6),
              )
            ]
        )
    );
  }
}

class CnBackgroundImage extends ChangeNotifier {

  void refresh(){
    notifyListeners();
  }
}