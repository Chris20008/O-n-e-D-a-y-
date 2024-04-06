import 'dart:async';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitness_app/screens/screen_workouts/screen_running_workout.dart';
import 'package:fitness_app/util/constants.dart';
import 'package:fitness_app/widgets/spotify_progress_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:fitness_app/assets/custom_icons/my_icons.dart';
import 'dart:io' show Platform;

import '../main.dart';
import 'animated_column.dart';
import 'background_image.dart';
import 'package:flutter/foundation.dart';

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

  // void refresh(){
  //   Future.delayed(const Duration(milliseconds: 200), (){
  //     // if (doRefresh) {
  //       setState(() {});
  //       refresh();
  //     // }
  //   });
  // }
  //
  // @override
  // void initState() {
  //   refresh();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    print("Rebuild SPOTIFY BAR");
    cnSpotifyBar = Provider.of<CnSpotifyBar>(context);
    // final size = MediaQuery.of(context).size;

    return Align(
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: width - paddingLeftRight*2, maxHeight: cnSpotifyBar.height),
                  // color: Colors.black.withOpacity(0.8),
                  // height: cnSpotifyBar.height,
                  // // width: constraints.maxWidth,
                  // // width: size.width - paddingLeftRight*2,
                  // width: width - paddingLeftRight*2,
                  child: Stack(
                    // alignment: Alignment.bottomLeft,
                    children: [
                      const BackgroundImage(),
                      Consumer<PlayerStateStream>(
                        builder: (context, playerStateStream, _) {
                          return StreamBuilder<PlayerState>(
                              stream: playerStateStream.stream,
                              builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot){
                                final data = snapshot.data;
                                if(data != null && data.track?.imageUri.raw != cnSpotifyBar.data?.track?.imageUri.raw){
                                  cnSpotifyBar.imageGotUpdated = true;
                                }
                                cnSpotifyBar.data = data?? cnSpotifyBar.data;
                                cnSpotifyBar.progressIndicatorKey = UniqueKey();
                                // if(data != null){
                                //   print("Playback Position ${cnSpotifyBar.data!.playbackPosition} von ${cnSpotifyBar.data!.track?.duration}");
                                // }
                                return cnSpotifyBar.data == null?
                                GestureDetector(
                                    onTap: cnSpotifyBar.connectToSpotify,
                                    child: Container(
                                      height: cnSpotifyBar.height,
                                      width: double.maxFinite,
                                      color: Colors.transparent,
                                    )
                                ) :
                                Stack(
                                  children: [
                                    Row(
                                      // mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: cnSpotifyBar.spotifyImageWidget(cnBackgroundImage)
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                            height: cnSpotifyBar.height,
                                            // width: double.maxFinite,
                                            child: Stack(
                                              children:[
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Container(
                                                    padding: const EdgeInsets.only(left:12, top:2),
                                                    height: cnSpotifyBar.height/2,
                                                    child: AutoSizeText(
                                                      cnSpotifyBar.data!.track?.name ?? "",
                                                      maxLines: 1,
                                                      style: Theme.of(context).textTheme.titleMedium,//TextStyle(fontSize: fontsize, color: Colors.white),
                                                      minFontSize: 13,
                                                      overflow: TextOverflow.ellipsis,
                                                    )
                                                    // child: ExerciseNameText(
                                                    //   cnSpotifyBar.data!.track?.name ?? "",
                                                    //   maxLines: 1,
                                                    //   fontsize: 14,
                                                    //   minFontSize: 12
                                                    // ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.bottomLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 5, bottom:2),
                                                    child: Row(
                                                      children:[
                                                        // const Spacer(flex:1),
                                                        IconButton(
                                                            padding: EdgeInsets.zero,
                                                            constraints: const BoxConstraints(minWidth:35, minHeight:35),
                                                            iconSize: 25,
                                                            style: ButtonStyle(
                                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                              backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                                              // shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                                                            ),
                                                            onPressed: () async{
                                                              cnSpotifyBar.seekToRelative(-15000);
                                                            },
                                                            icon: Icon(
                                                              CupertinoIcons.gobackward_15,
                                                              color: Colors.amber[800],
                                                            )
                                                        ),
                                                        // const Spacer(flex:2),
                                                        IconButton(
                                                            padding: EdgeInsets.zero,
                                                            constraints: const BoxConstraints(minWidth:35, minHeight:35),
                                                            iconSize: 32,
                                                            style: ButtonStyle(
                                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                                                        // const Spacer(flex:1),
                                                        IconButton(
                                                            padding: EdgeInsets.zero,
                                                            constraints: const BoxConstraints(minWidth:35, minHeight:35),
                                                            iconSize: 32,
                                                            style: ButtonStyle(
                                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                                                        // const Spacer(flex:1),
                                                        IconButton(
                                                            padding: EdgeInsets.zero,
                                                            constraints: const BoxConstraints(minWidth:35, minHeight:35),
                                                            iconSize: 32,
                                                            style: ButtonStyle(
                                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                                                        // const Spacer(flex:2),
                                                        IconButton(
                                                            padding: EdgeInsets.zero,
                                                            constraints: const BoxConstraints(minWidth:35, minHeight:35),
                                                            iconSize: 25,
                                                            style: ButtonStyle(
                                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                              backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                                              // shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                                                            ),
                                                            onPressed: () async{
                                                              cnSpotifyBar.seekToRelative(15000);
                                                            },
                                                            icon: Icon(
                                                              CupertinoIcons.goforward_15,
                                                              color: Colors.amber[800],
                                                            )
                                                        ),
                                                        // const Spacer(flex:6),
                                                      ]
                                                    ),
                                                  ),
                                                ),
                                              ]
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                            iconSize: 25,
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                            ),
                                            onPressed: () async{
                                              // cnSpotifyBar.disconnect();
                                              cnSpotifyBar.close();
                                            },
                                            icon: Icon(
                                              Icons.cancel,
                                              color: Colors.amber[800],
                                            )
                                        ),
                                        const SizedBox(width: 3,)
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: SpotifyProgressIndicator(key: cnSpotifyBar.progressIndicatorKey, data: cnSpotifyBar.data!),
                                      // child: SpotifyProgressIndicator(key: cnSpotifyBar.progressIndicatorKey),
                                      // child: SpotifyProgressIndicator(key: cnSpotifyBar.progressIndicatorKey),
                                    )
                                  ],
                                );
                              }
                          );
                        }
                      ),

                      // if(cnSpotifyBar.data != null)
                      //   Align(
                      //     alignment: Alignment.bottomCenter,
                      //     child: SpotifyProgressIndicator(key: cnSpotifyBar.progressIndicatorKey, data: cnSpotifyBar.data!),
                      //   )
                    ],
                  ),
                ),
              ),
              secondChild: Padding(
                padding: EdgeInsets.only(top: (cnSpotifyBar.height-cnSpotifyBar.heightOfButton)/2, bottom: (cnSpotifyBar.height-cnSpotifyBar.heightOfButton)/2),
                child: SizedBox(
                  height: cnSpotifyBar.heightOfButton,
                  width: cnSpotifyBar.heightOfButton,
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
                      bottom: 0,
                      // left: 0,
                      child: bottomChild,
                    ),
                    Positioned(
                      key: topChildKey,
                      child: topChild,
                    ),
                  ],
                );
              },
          )
      ),
    );
  }
}

class CnSpotifyBar extends ChangeNotifier {
  bool isConnected = false;
  int animationTimeSpotifyBar = 3000;
  bool isTryingReconnect = false;
  bool isTryingToConnect = false;
  bool isRebuilding = false;
  String accessToken = "";
  PlayerState? data;
  bool imageGotUpdated = false;
  late Image lastImage;
  Color? mainColor;
  int waitCounter = 0;
  double height = 60;
  double heightOfButton = 54;
  late CnAnimatedColumn cnAnimatedColumn;
  late CnRunningWorkout cnRunningWorkout;
  Key progressIndicatorKey = UniqueKey();
  bool justClosed = false;

  CnSpotifyBar(BuildContext context){
    cnAnimatedColumn = Provider.of<CnAnimatedColumn>(context, listen: false);
    cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  }

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
              // height: 1000,
              height: height-10,
              width: height-10,
              gaplessPlayback: true,
              fit: BoxFit.fitHeight,
            );

            print("SNAPSHOT HAS DATA IMAGE ${image.raw}");

            setMainColor(lastImage.image, cn);

            Future.delayed(const Duration(milliseconds: 50), (){
              cn.refresh();
            });
            // return lastImage;
          }
          else{
            print("SNAPSHOT HAS NO DATA in else");
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
          print("AND IMAGE GOT NOT UPDATED");
          return ClipRRect(

            borderRadius: BorderRadius.circular(7),
            child: lastImage,
          );
        }
    );
  }

  Future setMainColor (ImageProvider imageProvider, CnBackgroundImage cn) async {
    final PaletteGenerator paletteGenerator = await PaletteGenerator
        .fromImageProvider(imageProvider);
    // print(paletteGenerator.dominantColor?.color);
    waitCounter += 1;
    // print("Enter $waitCounter");
    final c = await compute(computeColor, paletteGenerator);
    print("GOT COLOR: $c");
    Future.delayed(const Duration(milliseconds: 100), (){
      waitCounter -= 1;
      // print("GOT $waitCounter");
      if(waitCounter == 0){
        // print("--------------------- REFRESH ---------------------");
        mainColor = c;
        cn.setColor(mainColor);
      }
    });

    // mainColor = paletteGenerator.lightVibrantColor?.color??
    //     paletteGenerator.lightMutedColor?.color??
    //     paletteGenerator.darkVibrantColor?.color;
    mainColor = paletteGenerator.darkVibrantColor?.color??
        paletteGenerator.lightVibrantColor?.color??
        paletteGenerator.lightMutedColor?.color;
    mainColor = await compute(computeColor, paletteGenerator);

  }

  static Future<Color?> computeColor(PaletteGenerator paletteGenerator)async{
    final color = paletteGenerator.lightVibrantColor?.color??
        paletteGenerator.lightMutedColor?.color??
        paletteGenerator.darkVibrantColor?.color;
    return color;
  }

  // void delayedReconnect() async{
  //   if(!isTryingReconnect){
  //     isTryingReconnect = true;
  //     Future.delayed(const Duration(milliseconds: 50), (){
  //       connectToSpotify().then((value) => isTryingReconnect = false);
  //     });
  //   }
  // }

  Future connectToSpotify()async{
    if(justClosed){
      isConnected = true;
      justClosed = false;
      refresh();
      Future.delayed(Duration(milliseconds: animationTimeSpotifyBar), (){
        cnAnimatedColumn.refresh();
      });
      return;
    }
    // if(!isTryingToConnect){
    isTryingToConnect = true;
    try{
      if(Platform.isAndroid){
        isConnected = await SpotifySdk.connectToSpotifyRemote(clientId: "6911043ee364484fb270f70844bdb38f", redirectUrl: "fitness-app://spotify-callback");
      }
      else{
        accessToken = accessToken.isEmpty? await SpotifySdk.getAccessToken(clientId: "6911043ee364484fb270f70844bdb38f", redirectUrl: "spotify-ios-quick-start://spotify-login-callback").timeout(const Duration(seconds: 5), onTimeout: () => throw new TimeoutException("Timeout, do disconnect")) : accessToken;
        isConnected = await SpotifySdk.connectToSpotifyRemote(clientId: "6911043ee364484fb270f70844bdb38f", redirectUrl: "spotify-ios-quick-start://spotify-login-callback", accessToken: accessToken).timeout(const Duration(seconds: 5), onTimeout: () => throw new TimeoutException("Timeout, do disconnect"));
      }
    }on Exception catch (_) {
      accessToken = "";
      isTryingToConnect = false;
    }


    //isConnected = await SpotifySdk.connectToSpotifyRemote(clientId: "6911043ee364484fb270f70844bdb38f", redirectUrl: "spotify-ios-quick-start://spotify-login-callback");
    print("CONNECTED SPOTIFY: $isConnected");
    refresh();
    isTryingToConnect = false;
    Future.delayed(Duration(milliseconds: animationTimeSpotifyBar), (){
      cnAnimatedColumn.refresh();
    });
    // }

  }

  Future<void> skipPrevious() async {
    try {
      await SpotifySdk.skipPrevious().then((value) => {
        Future.delayed(const Duration(milliseconds: 150), (){
          refresh();
        })
      });
      // await SpotifySdk.skipPrevious();
    } on Exception catch (_) {}
  }

  Future<void> skipNext() async {
    try {
      await SpotifySdk.skipNext().then((value) => {
        Future.delayed(const Duration(milliseconds: 150), (){
          refresh();
        })
      });
      // await SpotifySdk.skipNext();
    } on Exception catch (_) {}
  }

  Future<void> pause() async {
    try {
      await SpotifySdk.pause().timeout(const Duration(seconds: 1), onTimeout: () => throw new TimeoutException("Timeout, do disconnect")).then((value) => {
        Future.delayed(const Duration(milliseconds: 150), (){
          refresh();
        })
      });
      // await SpotifySdk.pause();
    } on Exception catch (_) {
      print("PAUSING FAILED");
      await disconnect();
    }
  }

  Future<void> resume() async {
    print("IN RESUME");
    try {
      await SpotifySdk.resume().timeout(const Duration(seconds: 1), onTimeout: () => throw new TimeoutException("Timeout, do disconnect")).then((value) => {
        Future.delayed(const Duration(milliseconds: 150), (){
          refresh();
        })
      });

      print("RESUME DONE");
      // await SpotifySdk.resume();
    } on Exception catch (_) {
      print("RESUMING FAILED");
      await disconnect();
    }

    print("RESUME DONE DONE ");
  }

  Future<void> seekToRelative(int milliseconds) async {
    if(Platform.isAndroid){
      try {
        await SpotifySdk.seekToRelativePosition(relativeMilliseconds: milliseconds).then((value) => {
          Future.delayed(const Duration(milliseconds: 150), (){
            refresh();
          })
        });
      } on Exception catch (e) {
        print("Got Exception in seekToRelative ANDROID: ${e.toString()}");
      }
    }
    else{
      try {
        final currentData = await SpotifySdk.getPlayerState();
        // current_data.playbackPosition
        // refresh();
        // await Future.delayed(const Duration(milliseconds: 50));
        if(currentData != null){
          await SpotifySdk.seekTo(positionedMilliseconds: currentData.playbackPosition + milliseconds).then((value) => refresh());
        }
        // await SpotifySdk.seekTo(positionedMilliseconds: data!.playbackPosition + milliseconds);
      } on Exception catch (e) {
        print("Got Exception in seekToRelative IOS: ${e.toString()}");
      }
    }
  }

  // Future<void> seekToRelative(int milliseconds) async {
  //   try {
  //     await SpotifySdk.seekToRelativePosition(relativeMilliseconds: milliseconds);
  //   } on Exception catch (e) {
  //     print("Got Exception in seekToRelative: ${e.toString()}");
  //   }
  // }

  void close(){
    isConnected = false;
    justClosed = true;
    refresh();
    Future.delayed(Duration(milliseconds: animationTimeSpotifyBar), ()async{
      cnAnimatedColumn.refresh();
    });
  }

  Future<void> disconnect() async {
    print("IN DISCONNECT");
    try {
      isConnected = false;
      refresh();
      Future.delayed(Duration(milliseconds: animationTimeSpotifyBar), ()async{
        await SpotifySdk.disconnect();
        cnAnimatedColumn.refresh();
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