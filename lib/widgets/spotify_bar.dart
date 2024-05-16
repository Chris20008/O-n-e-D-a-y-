import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitness_app/widgets/spotify_progress_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:fitness_app/assets/custom_icons/my_icons.dart';
import 'dart:io' show Platform;
import 'package:fitness_app/util/constants.dart';
import '../main.dart';
import '../screens/other_screens/screen_running_workout/animated_column.dart';
import '../screens/other_screens/screen_running_workout/screen_running_workout.dart';
import 'background_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpotifyBar extends StatefulWidget {
  const SpotifyBar({super.key});

  @override
  State<SpotifyBar> createState() => _SpotifyBarState();
}

class _SpotifyBarState extends State<SpotifyBar> with WidgetsBindingObserver {
// class _SpotifyBarState extends State<SpotifyBar>{
  late CnSpotifyBar cnSpotifyBar = cnSpotifyBar = Provider.of<CnSpotifyBar>(context);
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  late CnBackgroundImage cnBackgroundImage = Provider.of<CnBackgroundImage>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  double paddingLeftRight = 5;
  Map<String, double> widths = {
    "portrait": 0,
    "landscape": 0
  };
  // late bool isFirstScreen = ModalRoute.of(context)?.settings.name == "/";

  @override
  void initState() {
    super.initState();
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
    late Orientation orientation;
    /// Using MediaQuery directly inside didChangeMetrics return the previous frame values.
    /// To receive the latest values after orientation change we need to use
    /// WidgetsBindings.instance.addPostFrameCallback() inside it
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        orientation = MediaQuery.of(context).orientation;
      });
      if(cnSpotifyBar.width == 0){
        initWidths();
      }
      else if (orientation == Orientation.landscape) {
        cnSpotifyBar.width = widths["landscape"]!;
      }
      else {
        cnSpotifyBar.width = widths["portrait"]!;
      }
    });
  }

  void initWidths(){
    final orientation = MediaQuery.of(context).orientation;
    if(orientation == Orientation.portrait){
      widths[Orientation.portrait.name] = MediaQuery.of(context).size.width;
      widths[Orientation.landscape.name] = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.bottom - MediaQuery.of(context).padding.top;
    } else{
      widths[Orientation.portrait.name] = MediaQuery.of(context).size.height;
      widths[Orientation.landscape.name] = MediaQuery.of(context).size.width - MediaQuery.of(context).padding.left - MediaQuery.of(context).padding.right;
    }
    cnSpotifyBar.width = widths[orientation.name]!;
  }

  @override
  Widget build(BuildContext context) {
    if(cnSpotifyBar.width == 0){
      initWidths();
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
                  child: Stack(
                    children: [
                      const BackgroundImage(),
                      if(cnSpotifyBar.data == null)
                        GestureDetector(
                            onTap: cnSpotifyBar.connectToSpotify,
                            child: Container(
                              height: cnSpotifyBar.height,
                              width: double.maxFinite,
                              color: Colors.transparent,
                            )
                        )
                      else
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
                        )
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
  bool tryStayConnected = false;
  String accessToken = "";
  // bool imageGotUpdated = false;
  Image? lastImage;
  List<Color?> currentColorPair = [];
  // int waitCounter = 0;
  double height = 60;
  double width = 0;
  double heightOfButton = 54;
  late CnAnimatedColumn cnAnimatedColumn;
  // late CnRunningWorkout cnRunningWorkout;
  Key progressIndicatorKey = UniqueKey();
  Key futureKey = UniqueKey();
  bool justClosed = false;
  // bool isFirstScreen = true;
  bool isHandlingControlAction = false;
  String currentTrackName = "";
  // bool isVisible = true;

  late StreamSubscription<PlayerState> _subscription;
  late StreamSubscription<ConnectionStatus> _subscriptionConnectionStatus;
  PlayerState? data;
  // late PlayerState _currentPlayerState;

  CnSpotifyBar(BuildContext context){
    cnAnimatedColumn = Provider.of<CnAnimatedColumn>(context, listen: false);
  }

  void _subscribeToPlayerState() {
    _subscription = SpotifySdk.subscribePlayerState().listen((playerState) {
      data = playerState;
      if(data?.isPaused ?? false){
        if(!tryStayConnected){
          tryStayConnected = true;
          keepConnectedWhenPaused();
        }
      } else{
        tryStayConnected = false;
      }
      progressIndicatorKey = UniqueKey();
      notifyListeners();
    });
    _subscriptionConnectionStatus = SpotifySdk.subscribeConnectionStatus().listen((connectionStatus){
      if(!connectionStatus.connected){
        disconnect();
      }
    });
  }

  // PlayerState? get currentPlayerState => _currentPlayerState;

  // void setVisibility(bool isVisible){
  //   this.isVisible = isVisible;
  //   refresh();
  // }

  @override
  void dispose() {
    _subscription.cancel();
    _subscriptionConnectionStatus.cancel();
    super.dispose();
  }

  Widget spotifyImageWidget(CnBackgroundImage cn) {
    if(data?.track?.name == currentTrackName){
      return ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: lastImage?? const SizedBox(),
      );
    }

    ImageUri image = data?.track?.imageUri?? ImageUri("None");
    futureKey = UniqueKey();
    return FutureBuilder(
        key: futureKey,
        future: SpotifySdk.getImage(
          imageUri: image,
          dimension: ImageDimension.xSmall,
        ),
        builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
          // print("GET IMAGE");
          if (snapshot.hasData) {
            currentTrackName = data?.track?.name?? "";
            lastImage = Image.memory(
              snapshot.data!,
              // height: 1000,
              height: height-10,
              width: height-10,
              gaplessPlayback: true,
              fit: BoxFit.fitHeight,
            );
            setMainColor(lastImage!.image, cn);
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
    currentColorPair = await compute(computeColor, paletteGenerator);
    cn.setColor(currentColorPair[0]?? Colors.white, currentColorPair[1]?? Colors.black);
  }

  static Future<List<Color>> computeColor(PaletteGenerator paletteGenerator)async{
    final color = paletteGenerator.lightVibrantColor?.color??
        paletteGenerator.lightMutedColor?.color??
        paletteGenerator.darkVibrantColor?.color??
        Colors.white;
    final color2 = paletteGenerator.dominantColor?.color??
        paletteGenerator.darkVibrantColor?.color??
        paletteGenerator.lightMutedColor?.color??
        paletteGenerator.lightVibrantColor?.color??
        Colors.black;

    return [color, color2];
  }

  Future connectToSpotify() async{
    if(justClosed){
      isConnected = true;
      justClosed = false;
      refresh();
      Future.delayed(Duration(milliseconds: animationTimeSpotifyBar), (){
        cnAnimatedColumn.refresh();
      });
      return;
    }

    if(isTryingToConnect || !(await hasInternet())) {
      return;
    }

    isTryingToConnect = true;
    try{
      if(Platform.isAndroid){
        isConnected = await SpotifySdk.connectToSpotifyRemote(clientId: dotenv.env["SPOTIFY_CLIENT_ID"]!, redirectUrl: "fitness-app://spotify-callback");
      }
      else{
        accessToken = accessToken.isEmpty? await SpotifySdk.getAccessToken(clientId: dotenv.env["SPOTIFY_CLIENT_ID"]!, redirectUrl: "spotify-ios-quick-start://spotify-login-callback").timeout(const Duration(seconds: 5), onTimeout: () => throw new TimeoutException("Timeout, do disconnect")) : accessToken;
        isConnected = await SpotifySdk.connectToSpotifyRemote(clientId: dotenv.env["SPOTIFY_CLIENT_ID"]!, redirectUrl: "spotify-ios-quick-start://spotify-login-callback", accessToken: accessToken).timeout(const Duration(seconds: 5), onTimeout: () => throw new TimeoutException("Timeout, do disconnect"));
      }
      if(isConnected){
        _subscribeToPlayerState();
      }
    }on Exception catch (_) {
      accessToken = "";
      isTryingToConnect = false;
    }
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
        // Future.delayed(const Duration(milliseconds: 150), (){
        //   refresh();
        // })
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
        // Future.delayed(const Duration(milliseconds: 150), (){
        //   refresh();
        // })
      });
      // await SpotifySdk.skipNext();
    } on Exception catch (_) {}
    isHandlingControlAction = false;
  }

  Future<void> pause() async {
    if(isHandlingControlAction) return;

    isHandlingControlAction = true;
    try {
      await SpotifySdk.pause().timeout(const Duration(seconds: 1), onTimeout: () => throw TimeoutException("Timeout, do disconnect")).then((value) => {
        // Future.delayed(const Duration(milliseconds: 150), (){
        //   refresh();
        // })
      });
      // if(!tryStayConnected){
      //   tryStayConnected = true;
      //   keepConnectedWhenPaused();
      // }
      // await SpotifySdk.pause();
    } on Exception catch (_) {
      if(Platform.isAndroid){
        if(await hasInternet()){
          accessToken = "";
          isTryingToConnect = false;
          isConnected = false;
          justClosed = false;
          connectToSpotify().then((value) => pause());
        } else{
          await disconnect();
          // tryStayConnected = false;
        }
      }
    }
    isHandlingControlAction = false;
  }

  Future<void> resume() async {
    if(isHandlingControlAction) return;

    isHandlingControlAction = true;
    try {
      await SpotifySdk.resume().timeout(const Duration(seconds: 1), onTimeout: () => throw new TimeoutException("Timeout, do disconnect")).then((value) => {
        // Future.delayed(const Duration(milliseconds: 150), (){
        //   refresh();
        // })
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
          // Future.delayed(const Duration(milliseconds: 150), (){
          //   refresh();
          // })
        });
      } on Exception catch (_) {
      }
    }
    else{
      try {
        final currentData = await SpotifySdk.getPlayerState();
        if(currentData != null){
          await SpotifySdk.seekTo(positionedMilliseconds: currentData.playbackPosition + milliseconds).then((value) => ());/// refresh());
        }
      } on Exception catch (_) {
      }
    }
  }

  void close(){
    isConnected = false;
    justClosed = true;
    refresh();
    Future.delayed(Duration(milliseconds: animationTimeSpotifyBar), ()async{
      cnAnimatedColumn.refresh();
    });
  }

  Future<void> keepConnectedWhenPaused() async{
    if(Platform.isAndroid){
      await Future.delayed(const Duration(seconds: 1), (){});
      if (isConnected && (data?.isPaused?? false) && tryStayConnected){
        await pause();
        keepConnectedWhenPaused();
      } else{
        tryStayConnected = false;
      }
    } else{
      tryStayConnected = false;
    }
  }

  Future<void> disconnect() async {
    try {
      isConnected = false;
      justClosed = false;
      accessToken = "";
      refresh();
      Future.delayed(Duration(milliseconds: animationTimeSpotifyBar), ()async{
        await SpotifySdk.disconnect().timeout(const Duration(seconds: 1), onTimeout: () => throw TimeoutException("Timeout while disconnecting"));
        cnAnimatedColumn.refresh();
        _subscription.cancel();
        _subscriptionConnectionStatus.cancel();
      });
    } on Exception catch (_) {
      cnAnimatedColumn.refresh();
      _subscription.cancel();
      _subscriptionConnectionStatus.cancel();
    }
  }

  void refresh()async{
    if(!isRebuilding){
      isRebuilding = true;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 50), (){
        isRebuilding = false;
      });
    }
    // notifyListeners();
  }
}