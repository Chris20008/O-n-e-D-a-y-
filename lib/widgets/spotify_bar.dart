import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:fitness_app/assets/custom_icons/my_icons.dart';
import 'dart:io' show Platform;

import '../main.dart';
import 'background_image.dart';

class SpotifyBar extends StatefulWidget {
  const SpotifyBar({super.key});

  @override
  State<SpotifyBar> createState() => _SpotifyBarState();
}

class _SpotifyBarState extends State<SpotifyBar> {
  late CnSpotifyBar cnSpotifyBar;
  final width = WidgetsBinding.instance.window.physicalSize.width;
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  late CnBackgroundImage cnBackgroundImage = Provider.of<CnBackgroundImage>(context, listen: false);
  double paddingLeftRight = 5;

  @override
  Widget build(BuildContext context) {
    print("Rebuild SPOTIFY BAR");
    cnSpotifyBar = Provider.of<CnSpotifyBar>(context);
    // final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
              padding: EdgeInsets.only(left:paddingLeftRight, right: paddingLeftRight, bottom: 3),
              child: AnimatedCrossFade(
                secondCurve: cnSpotifyBar.isConnected? Curves.easeInOutQuint : Curves.easeInExpo,
                // secondCurve: Curves.fastOutSlowIn,
                // secondCurve: Curves.fastLinearToSlowEaseIn,
                //   sizeCurve: Curves.easeInOutBack,
                sizeCurve: Curves.easeInOut,
                  firstChild: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Colors.black.withOpacity(0.8),
                      height: 54,
                      // width: constraints.maxWidth,
                      // width: size.width - paddingLeftRight*2,
                      width: width - paddingLeftRight*2,
                      child: Consumer<PlayerStateStream>(
                        builder: (context, playerStateStream, _) {
                          return StreamBuilder<PlayerState>(
                              stream: playerStateStream.stream,
                              builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot){
                                final data = snapshot.data;
                                if(data != null && data.track?.imageUri.raw != cnSpotifyBar.data?.track?.imageUri.raw){
                                  cnSpotifyBar.imageGotUpdated = true;
                                }
                                cnSpotifyBar.data = data?? cnSpotifyBar.data;
                                return cnSpotifyBar.data == null?
                                GestureDetector(
                                    onTap: cnSpotifyBar.connectToSpotify,
                                    child: Container(
                                      height: 54,
                                      width: double.maxFinite,
                                      color: Colors.transparent,
                                    )
                                ) :
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: cnSpotifyBar.spotifyImageWidget(cnBackgroundImage)
                                    ),
                                    const Spacer(flex:1),
                                    IconButton(
                                        iconSize: 30,
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                          // shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                                        ),
                                        onPressed: () async{
                                          cnSpotifyBar.skipPrevious();
                                        },
                                        icon: Icon(
                                          Icons.skip_previous,
                                          color: Colors.amber[800],
                                        )
                                    ),
                                    const Spacer(flex:1),
                                    IconButton(
                                        iconSize: 30,
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                        ),
                                        onPressed: () async{
                                          cnSpotifyBar.data!.isPaused? cnSpotifyBar.resume() : cnSpotifyBar.pause();
                                        },
                                        icon: Icon(
                                          cnSpotifyBar.data!.isPaused? Icons.play_arrow : Icons.pause,
                                          color: Colors.amber[800],
                                        )
                                    ),
                                    const Spacer(flex:1),
                                    IconButton(
                                        iconSize: 30,
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                        ),
                                        onPressed: () async{
                                          cnSpotifyBar.skipNext(); //.then((value) => setState(() => {}));
                                        },
                                        icon: Icon(
                                          Icons.skip_next,
                                          color: Colors.amber[800],
                                        )
                                    ),
                                    const Spacer(flex:6),
                                    IconButton(
                                        iconSize: 20,
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                        ),
                                        onPressed: () async{
                                          cnSpotifyBar.disconnect();
                                        },
                                        icon: Icon(
                                          Icons.cancel,
                                          color: Colors.amber[800],
                                        )
                                    ),
                                  ],
                                );
                              }
                          );
                        }
                      ),
                    ),
                  ),
                  secondChild: SizedBox(
                    height: 54,
                    width: 54,
                    child: IconButton(
                        iconSize: 25,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.transparent),
                          // shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                        ),
                        onPressed: () async{
                          cnSpotifyBar.connectToSpotify();
                        },
                        icon: Icon(
                          MyIcons.spotify,
                          color: Colors.amber[800],
                        )
                    ),
                  ),
                  crossFadeState: cnSpotifyBar.isConnected?
                  CrossFadeState.showFirst :
                  CrossFadeState.showSecond,
                  duration: Duration(milliseconds: cnSpotifyBar.animationTimeSpotifyBar),
                  layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: <Widget>[
                        Positioned(
                          key: bottomChildKey,
                          // left: 0.0,
                          // top: 0.0,
                          // right: 0.0,
                          bottom: 0,
                          child: bottomChild,
                        ),
                        Positioned(
                          key: topChildKey,
                          // left: 0.0,
                          // top: 0.0,
                          // right: 0.0,
                          // bottom: 0,
                          // right: 0,
                          child: topChild,
                        ),
                      ],
                    );
                  },
              )
          ),
        ),
      ),
    );
  }
}

class CnSpotifyBar extends ChangeNotifier {
  bool isConnected = false;
  int animationTimeSpotifyBar = 250;
  bool isTryingReconnect = false;
  bool isTryingToConnect = false;
  bool isRebuilding = false;
  String accessToken = "";
  PlayerState? data;
  bool imageGotUpdated = false;
  late Image lastImage;
  Color? mainColor;
  int waitCounter = 0;

  Widget spotifyImageWidget(CnBackgroundImage cn) {
    ImageUri image = data?.track?.imageUri?? ImageUri("None");
    return FutureBuilder(
        future: SpotifySdk.getImage(
          imageUri: image,
          dimension: ImageDimension.xSmall,
        ),
        builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
          if (snapshot.hasData) {

            lastImage = Image.memory(
              snapshot.data!,
              height: 1000,
              // height: 44,
              // width: 44,
              gaplessPlayback: true,
              fit: BoxFit.fitHeight,
            );

            // setMainColor(lastImage.image, cn);

            Future.delayed(const Duration(milliseconds: 50), (){
              cn.refresh();
            });
            // return lastImage;
          }
          else{
            print("in else");
            if(imageGotUpdated){
              imageGotUpdated = false;
              return ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Container(
                    height: 300,
                    width: 300,
                    color: (Colors.grey[850]?? Colors.black).withOpacity(0.2)
                ),
              );
            }
            // return lastImage;
          }
          return ClipRRect(

            borderRadius: BorderRadius.circular(7),
            child: lastImage,
          );
        }
    );
  }

  // Future setMainColor (ImageProvider imageProvider, CnBackgroundImage cn) async {
  //   final PaletteGenerator paletteGenerator = await PaletteGenerator
  //       .fromImageProvider(imageProvider);
  //   // print(paletteGenerator.dominantColor?.color);
  //   waitCounter += 1;
  //   // print("Enter $waitCounter");
  //   final c = await compute(computeColor, paletteGenerator);
  //   Future.delayed(const Duration(milliseconds: 100), (){
  //     waitCounter -= 1;
  //     // print("GOT $waitCounter");
  //     if(waitCounter == 0){
  //       // print("--------------------- REFRESH ---------------------");
  //       mainColor = c;
  //       cn.setColor(mainColor);
  //     }
  //   });

    // mainColor = paletteGenerator.lightVibrantColor?.color??
    //     paletteGenerator.lightMutedColor?.color??
    //     paletteGenerator.darkVibrantColor?.color
    //     ;
    // mainColor = await compute(computeColor, imageProvider);
  //
  // }

  // static Future<Color?> computeColor(PaletteGenerator paletteGenerator)async{
  //   final color = paletteGenerator.lightVibrantColor?.color??
  //       paletteGenerator.lightMutedColor?.color??
  //       paletteGenerator.darkVibrantColor?.color;
  //   return color;
  // }

  void delayedReconnect() async{
    if(!isTryingReconnect){
      isTryingReconnect = true;
      Future.delayed(const Duration(milliseconds: 50), (){
        connectToSpotify().then((value) => isTryingReconnect = false);
      });
    }
  }

  Future connectToSpotify()async{
    if(!isTryingToConnect){
      isTryingToConnect = true;

      if(Platform.isAndroid){
        isConnected = await SpotifySdk.connectToSpotifyRemote(clientId: "6911043ee364484fb270f70844bdb38f", redirectUrl: "fitness-app://spotify-callback");
      }
      else{
        accessToken = accessToken.isEmpty? await SpotifySdk.getAccessToken(clientId: "6911043ee364484fb270f70844bdb38f", redirectUrl: "spotify-ios-quick-start://spotify-login-callback") : accessToken;
        try{
          isConnected = await SpotifySdk.connectToSpotifyRemote(clientId: "6911043ee364484fb270f70844bdb38f", redirectUrl: "spotify-ios-quick-start://spotify-login-callback", accessToken: accessToken);
        } on Exception catch (_) {
          accessToken = await SpotifySdk.getAccessToken(clientId: "6911043ee364484fb270f70844bdb38f", redirectUrl: "spotify-ios-quick-start://spotify-login-callback");
          isConnected = await SpotifySdk.connectToSpotifyRemote(clientId: "6911043ee364484fb270f70844bdb38f", redirectUrl: "spotify-ios-quick-start://spotify-login-callback", accessToken: accessToken);
        }
      }

      //isConnected = await SpotifySdk.connectToSpotifyRemote(clientId: "6911043ee364484fb270f70844bdb38f", redirectUrl: "spotify-ios-quick-start://spotify-login-callback");
      print("CONNECTED SPOTIFY: $isConnected");
      refresh();
      isTryingToConnect = false;
    }

  }

  Future<void> skipPrevious() async {
    try {
      await SpotifySdk.skipPrevious().then((value) => refresh());
      // await SpotifySdk.skipPrevious();
    } on Exception catch (_) {}
  }

  Future<void> skipNext() async {
    try {
      await SpotifySdk.skipNext().then((value) => refresh());
      // await SpotifySdk.skipNext();
    } on Exception catch (_) {}
  }

  Future<void> pause() async {
    try {
      await SpotifySdk.pause().then((value) => refresh());
      // await SpotifySdk.pause();
    } on Exception catch (_) {}
  }

  Future<void> resume() async {
    try {
      await SpotifySdk.resume().then((value) => refresh());
      // await SpotifySdk.resume();
    } on Exception catch (_) {}
  }

  Future<void> disconnect() async {
    try {
      isConnected = false;
      refresh();
      Future.delayed(Duration(milliseconds: animationTimeSpotifyBar), ()async{
        await SpotifySdk.disconnect();
      });
    } on Exception catch (_) {}
  }

  void refresh()async{
    if(!isRebuilding){
      print("REFRESH SPOTIFY BAR IN CN SPOTIFY");
      isRebuilding = true;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 50), (){
        isRebuilding = false;
      });
    }
    // notifyListeners();
  }
}