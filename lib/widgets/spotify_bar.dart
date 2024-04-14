import 'dart:async';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitness_app/screens/screen_workouts/screen_running_workout.dart';
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
import 'package:fitness_app/util/constants.dart';

import '../main.dart';
import 'animated_column.dart';
import 'background_image.dart';
import 'package:flutter/foundation.dart';

class SpotifyBar extends StatefulWidget {
  const SpotifyBar({super.key});

  @override
  State<SpotifyBar> createState() => _SpotifyBarState();
}

class _SpotifyBarState extends State<SpotifyBar> with WidgetsBindingObserver {
  late CnSpotifyBar cnSpotifyBar;
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  late CnBackgroundImage cnBackgroundImage = Provider.of<CnBackgroundImage>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  // double width = 350;
  double paddingLeftRight = 5;
  Map<String, double> widths = {
    "portrait": 0,
    "landscape": 0
  };
  late bool isFirstScreen = ModalRoute.of(context)?.settings.name == "/";

  @override
  void initState() {
    super.initState();
    // Future.delayed(const Duration(milliseconds:100), (){
    //   late bool isFirstScreen = ModalRoute.of(context)?.settings.name == "/";
    //   cnSpotifyBar.isFirstScreen = isFirstScreen;
    // });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
   if(state == AppLifecycleState.resumed) {
     cnSpotifyBar.refresh();
   }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final orientation = MediaQuery.of(context).orientation;

    // if(cnSpotifyBar.width == 0){
    //   widths[orientation.name] = (widths[orientation.name] == 0
    //   ? MediaQuery.of(context).size.width
    //   : widths[orientation.name])!;
    //   cnSpotifyBar.width = widths[orientation.name]!;
    // }
    if (orientation != Orientation.landscape) {
      // print("ORIENTATION NOW LANDSCAPE");
      widths["landscape"] = (widths["landscape"] == 0
          ? MediaQuery.of(context).size.height
          : widths["landscape"])!;
      cnSpotifyBar.width = widths["landscape"]!;
    }
    else {
      // print("ORIENTATION NOW PORTRAIT");
      widths["portrait"] = (widths["portrait"] == 0
          ? MediaQuery.of(context).size.height
          : widths["portrait"])!;
      cnSpotifyBar.width = widths["portrait"]!;
    }
    print("WIDTH NOW: ${cnSpotifyBar.width}");
  }

  @override
  Widget build(BuildContext context) {
    print("---------------------- Rebuild SPOTIFY BAR ----------------------");
    cnSpotifyBar = Provider.of<CnSpotifyBar>(context);
    cnSpotifyBar.isFirstScreen = isFirstScreen;
    if(cnSpotifyBar.width == 0){
      cnSpotifyBar.width = MediaQuery.of(context).size.width;
    } else
    if(Platform.isAndroid){
      cnSpotifyBar.width = MediaQuery.of(context).size.width;
    }


    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
          padding: EdgeInsets.only(left:paddingLeftRight, right: paddingLeftRight, bottom: 3),
          child:
          AnimatedCrossFade(
            secondCurve: cnSpotifyBar.isConnected? Curves.easeInOutQuint : Curves.easeInExpo,
            sizeCurve: Curves.easeInOut,
              firstChild: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: cnSpotifyBar.height,
                  width: cnSpotifyBar.width - paddingLeftRight*2,
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

                                // bool isFirstScreen = ModalRoute.of(context)?.settings.name == "/";
                                // bool isFirstScreen = true;
                                if((cnSpotifyBar.isFirstScreen && !cnRunningWorkout.isVisible) || (!cnSpotifyBar.isFirstScreen && cnRunningWorkout.isVisible)){
                                  print("IS FIRST SCREEN: ${cnSpotifyBar.isFirstScreen}");
                                  final data = snapshot.data;
                                  if(data != null && data.track?.imageUri.raw != cnSpotifyBar.data?.track?.imageUri.raw){
                                    cnSpotifyBar.imageGotUpdated = true;
                                  }
                                  cnSpotifyBar.data = data?? cnSpotifyBar.data;
                                  cnSpotifyBar.progressIndicatorKey = UniqueKey();
                                }

                                // final data = snapshot.data;
                                // if(data != null && data.track?.imageUri.raw != cnSpotifyBar.data?.track?.imageUri.raw){
                                //   cnSpotifyBar.imageGotUpdated = true;
                                // }
                                // cnSpotifyBar.data = data?? cnSpotifyBar.data;
                                // cnSpotifyBar.progressIndicatorKey = UniqueKey();
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
                                                      style: Theme.of(context).textTheme.titleMedium,
                                                      minFontSize: 13,
                                                      overflow: TextOverflow.ellipsis,
                                                    )
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
                                                              cnSpotifyBar.skipNext();
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
                                    )
                                  ],
                                );
                              }
                          );
                        }
                      ),
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
  int animationTimeSpotifyBar = 250;
  bool isTryingReconnect = false;
  bool isTryingToConnect = false;
  bool isRebuilding = false;
  String accessToken = "";
  PlayerState? data;
  bool imageGotUpdated = false;
  Image? lastImage;
  Color? mainColor;
  int waitCounter = 0;
  double height = 60;
  double width = 0;
  double heightOfButton = 54;
  late CnAnimatedColumn cnAnimatedColumn;
  // late CnRunningWorkout cnRunningWorkout;
  Key progressIndicatorKey = UniqueKey();
  bool justClosed = false;
  bool isFirstScreen = true;
  bool isHandlingControlAction = false;

  CnSpotifyBar(BuildContext context){
    cnAnimatedColumn = Provider.of<CnAnimatedColumn>(context, listen: false);
    // cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  }

  Widget spotifyImageWidget(CnBackgroundImage cn) {
    ImageUri image = data?.track?.imageUri?? ImageUri("None");
    return FutureBuilder(
        future: SpotifySdk.getImage(
          imageUri: image,
          dimension: ImageDimension.xSmall,
        ),
        builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
          print("GET IMAGE");
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

            // if(cn.currentImageUri != image.raw){
            if(cn.currentImageUri != snapshot.data!.toString() && lastImage != null){
              print("NEW IMAGE WITH TITLE: ${data?.track?.name}");
              cn.currentImageUri = snapshot.data!.toString();
              setMainColor(lastImage!.image, cn);
            }

            // Future.delayed(const Duration(milliseconds: 50), (){
            //   cn.refresh();
            // });
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
          return ClipRRect(

            borderRadius: BorderRadius.circular(7),
            child: lastImage?? const SizedBox(),
          );
        }
    );
  }

  Future setMainColor (ImageProvider imageProvider, CnBackgroundImage cn) async {
    final PaletteGenerator paletteGenerator = await PaletteGenerator
        .fromImageProvider(imageProvider);
    // print(paletteGenerator.dominantColor?.color);
    // waitCounter += 1;
    // print("Enter $waitCounter");
    final c = await compute(computeColor, paletteGenerator);
    print("GOT COLOR: $c");
    // Future.delayed(const Duration(milliseconds: 100), (){
    //   waitCounter -= 1;
      // print("GOT $waitCounter");
      // if(waitCounter == 0){
    print("--------------------- REFRESH ---------------------");
    print("WITH COLOR: $c");
    mainColor = c[0];
    cn.setColor(mainColor, c[1]);
      // }
    // });

    // mainColor = paletteGenerator.lightVibrantColor?.color??
    //     paletteGenerator.lightMutedColor?.color??
    //     paletteGenerator.darkVibrantColor?.color;
    // mainColor = paletteGenerator.darkVibrantColor?.color??
    //     paletteGenerator.lightVibrantColor?.color??
    //     paletteGenerator.lightMutedColor?.color;
    // mainColor = await compute(computeColor, paletteGenerator);

  }

  static Future<List<Color?>> computeColor(PaletteGenerator paletteGenerator)async{
    final color = paletteGenerator.lightVibrantColor?.color??
        paletteGenerator.lightMutedColor?.color??
        paletteGenerator.darkVibrantColor?.color;
    final color2 = paletteGenerator.dominantColor?.color??
        paletteGenerator.darkVibrantColor?.color??
        paletteGenerator.lightMutedColor?.color??
        paletteGenerator.lightVibrantColor?.color;

    return [color, color2];
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
    }on Exception catch (e) {
      print("---------- EXCEPTION --------- ${e.toString()}");
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
    if(isHandlingControlAction) return;

    isHandlingControlAction = true;

    try {
      await SpotifySdk.skipPrevious().then((value) => {
        Future.delayed(const Duration(milliseconds: 150), (){
          refresh();
        })
      });
      // await SpotifySdk.skipPrevious();
    } on Exception catch (_) {}
    isHandlingControlAction = false;
  }

  Future<void> skipNext() async {
    if(isHandlingControlAction) return;

    isHandlingControlAction = true;

    try {
      await SpotifySdk.skipNext().then((value) => {
        Future.delayed(const Duration(milliseconds: 150), (){
          refresh();
        })
      });
      // await SpotifySdk.skipNext();
    } on Exception catch (_) {}
    isHandlingControlAction = false;
  }

  Future<void> pause() async {
    if(isHandlingControlAction) return;

    isHandlingControlAction = true;
    try {
      await SpotifySdk.pause().timeout(const Duration(seconds: 1), onTimeout: () => throw new TimeoutException("Timeout, do disconnect")).then((value) => {
        Future.delayed(const Duration(milliseconds: 150), (){
          refresh();
        })
      });
      // await SpotifySdk.pause();
    } on Exception catch (_) {
      if(await hasInternet()){
        accessToken = "";
        isTryingToConnect = false;
        isConnected = false;
        justClosed = false;
        connectToSpotify().then((value) => pause());
      } else{
        await disconnect();
      }
    }
    isHandlingControlAction = false;
  }

  Future<void> resume() async {
    if(isHandlingControlAction) return;

    isHandlingControlAction = true;
    try {
      await SpotifySdk.resume().timeout(const Duration(seconds: 1), onTimeout: () => throw new TimeoutException("Timeout, do disconnect")).then((value) => {
        Future.delayed(const Duration(milliseconds: 150), (){
          refresh();
        })
      });
      // await SpotifySdk.resume();
    } on Exception catch (_) {
      if(await hasInternet()){
        await reconnectAfterConnectionLoss();
      } else{
        await disconnect();
      }
    }
    isHandlingControlAction = false;
  }

  Future<void> reconnectAfterConnectionLoss() async {
    accessToken = "";
    isTryingToConnect = false;
    isConnected = false;
    justClosed = false;
    await connectToSpotify();
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
      justClosed = false;
      accessToken = "";
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