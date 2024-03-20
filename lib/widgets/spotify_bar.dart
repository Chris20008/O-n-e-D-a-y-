import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:fitness_app/assets/custom_icons/my_icons.dart';

import '../main.dart';

class SpotifyBar extends StatefulWidget {
  const SpotifyBar({super.key});

  @override
  State<SpotifyBar> createState() => _SpotifyBarState();
}

class _SpotifyBarState extends State<SpotifyBar> {
  late ImageUri? currentTrackImageUri;
  late CnSpotifyBar cnSpotifyBar;
  final width = WidgetsBinding.instance.window.physicalSize.width;
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
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 40.0,
                        sigmaY: 40.0,
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.4),
                        height: 54,
                        // width: constraints.maxWidth,
                        // width: size.width - paddingLeftRight*2,
                        width: width - paddingLeftRight*2,
                        child: Consumer<PlayerStateStream>(
                          builder: (context, playerStateStream, _) {
                            return StreamBuilder<PlayerState>(
                                stream: playerStateStream.stream,
                                builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot){
                                  var track = snapshot.data?.track;
                                  currentTrackImageUri = track?.imageUri;
                                  // if(snapshot.data == null && cnSpotifyBar.isConnected){
                                  //   cnSpotifyBar.delayedReconnect();
                                  // }
                                  return snapshot.data == null?
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
                                          child: spotifyImageWidget(currentTrackImageUri?? ImageUri("None"))
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
                                            snapshot.data!.isPaused? cnSpotifyBar.resume() : cnSpotifyBar.pause();
                                          },
                                          icon: Icon(
                                            snapshot.data!.isPaused? Icons.play_arrow : Icons.pause,
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
                        // child: StreamBuilder<PlayerState>(
                        //   stream: SpotifySdk.subscribePlayerState(),
                        //   builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot){
                        //     var track = snapshot.data?.track;
                        //     currentTrackImageUri = track?.imageUri;
                        //     if(snapshot.data == null && cnSpotifyBar.isConnected){
                        //       cnSpotifyBar.delayedReconnect();
                        //     }
                        //     return snapshot.data == null?
                        //     GestureDetector(
                        //         onTap: cnSpotifyBar.connectToSpotify,
                        //         child: Container(
                        //           height: 54,
                        //           width: double.maxFinite,
                        //           color: Colors.transparent,
                        //         )
                        //     ) :
                        //     Row(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         Padding(
                        //             padding: const EdgeInsets.all(5),
                        //             child: spotifyImageWidget(currentTrackImageUri?? ImageUri("None"))
                        //         ),
                        //         const Spacer(flex:1),
                        //         IconButton(
                        //             iconSize: 30,
                        //             style: ButtonStyle(
                        //               backgroundColor: MaterialStateProperty.all(Colors.transparent),
                        //               // shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                        //             ),
                        //             onPressed: () async{
                        //               cnSpotifyBar.skipPrevious();
                        //             },
                        //             icon: Icon(
                        //               Icons.skip_previous,
                        //               color: Colors.amber[800],
                        //             )
                        //         ),
                        //         const Spacer(flex:1),
                        //         IconButton(
                        //             iconSize: 30,
                        //             style: ButtonStyle(
                        //               backgroundColor: MaterialStateProperty.all(Colors.transparent),
                        //             ),
                        //             onPressed: () async{
                        //               snapshot.data!.isPaused? cnSpotifyBar.resume() : cnSpotifyBar.pause();
                        //             },
                        //             icon: Icon(
                        //               snapshot.data!.isPaused? Icons.play_arrow : Icons.pause,
                        //               color: Colors.amber[800],
                        //             )
                        //         ),
                        //         const Spacer(flex:1),
                        //         IconButton(
                        //             iconSize: 30,
                        //             style: ButtonStyle(
                        //               backgroundColor: MaterialStateProperty.all(Colors.transparent),
                        //             ),
                        //             onPressed: () async{
                        //               cnSpotifyBar.skipNext(); //.then((value) => setState(() => {}));
                        //             },
                        //             icon: Icon(
                        //               Icons.skip_next,
                        //               color: Colors.amber[800],
                        //             )
                        //         ),
                        //         const Spacer(flex:6),
                        //         IconButton(
                        //             iconSize: 20,
                        //             style: ButtonStyle(
                        //               backgroundColor: MaterialStateProperty.all(Colors.transparent),
                        //             ),
                        //             onPressed: () async{
                        //               cnSpotifyBar.disconnect();
                        //             },
                        //             icon: Icon(
                        //               Icons.cancel,
                        //               color: Colors.amber[800],
                        //             )
                        //         ),
                        //       ],
                        //     );
                        //   },
                        // ),
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

  Widget spotifyImageWidget(ImageUri image) {
    return FutureBuilder(
        future: SpotifySdk.getImage(
          imageUri: image,
          dimension: ImageDimension.xSmall,
        ),
        builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
          if (snapshot.hasData) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.memory(
                snapshot.data!,
                height: 44,
                width: 44,
                gaplessPlayback: true,
              ),
            );
          }
          else{
            return ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Container(
                height: 44,
                width: 44,
                color: (Colors.grey[850]?? Colors.black).withOpacity(0.2)
              ),
            );
          }
        }
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
  // final stream = SpotifySdk.subscribePlayerState();
  // late AsyncSnapshot<PlayerState> snapshot;
  // late BuildContext parentContext;

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
      // accessToken = accessToken.isEmpty? await SpotifySdk.getAccessToken(clientId: "6911043ee364484fb270f70844bdb38f", redirectUrl: "fitness-app://spotify-callback") : accessToken;
      // print("ACCES TOKEN: $accessToken");
      isConnected = await SpotifySdk.connectToSpotifyRemote(clientId: "6911043ee364484fb270f70844bdb38f", redirectUrl: "fitness-app://spotify-callback");
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