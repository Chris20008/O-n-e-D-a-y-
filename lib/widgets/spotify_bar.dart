import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fitness_app/screens/main_screens/screen_workouts/screen_workouts.dart';
import 'package:fitness_app/util/config.dart';
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
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SpotifyBar extends StatefulWidget {
  const SpotifyBar({super.key});

  @override
  State<SpotifyBar> createState() => _SpotifyBarState();
}

class _SpotifyBarState extends State<SpotifyBar> with WidgetsBindingObserver {
// class _SpotifyBarState extends State<SpotifyBar>{
  late CnSpotifyBar cnSpotifyBar = cnSpotifyBar = Provider.of<CnSpotifyBar>(context);
  late CnHomepage cnHomepage = Provider.of<CnHomepage>(context, listen: false);
  late CnBackgroundColor cnBackgroundColor = Provider.of<CnBackgroundColor>(context, listen: false);
  late CnRunningWorkout cnRunningWorkout = Provider.of<CnRunningWorkout>(context, listen: false);
  late CnAnimatedColumn cnAnimatedColumn = Provider.of<CnAnimatedColumn>(context, listen: false);
  late CnWorkouts cnWorkouts = Provider.of<CnWorkouts>(context, listen: false);
  late CnConfig cnConfig = Provider.of<CnConfig>(context, listen: false);
  Color colorSpotifyButton = Colors.white.withOpacity(0.12);
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
  void didChangeAppLifecycleState(AppLifecycleState state) async{
   if(state == AppLifecycleState.resumed) {
     cnSpotifyBar.refresh();
     cnConfig.isSpotifyInstalled(secondsDelayMilliseconds: 100, context: context);
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
                      const BackgroundColor(),
                      if(cnSpotifyBar.data == null)
                        GestureDetector(
                            onTap: () => cnSpotifyBar.connectToSpotify(context),
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
                                    padding: const EdgeInsets.all(6),
                                    child: GestureDetector(
                                        onTap: (){
                                          /// Opens Spotify directly to the song/album but also starts it from the beginning at first time
                                          // String? uri = cnSpotifyBar.data?.track?.uri;
                                          /// Just opens Spotify
                                          String uri = "spotify:";
                                          // if(uri != null){
                                          openUrl(uri);
                                          HapticFeedback.selectionClick();
                                          // }
                                        },
                                        child: cnSpotifyBar.spotifyImageWidget(cnBackgroundColor)
                                    )
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.only(left: 5, bottom: 4),
                                //   child: Column(
                                //     mainAxisAlignment: MainAxisAlignment.center,
                                //     crossAxisAlignment: CrossAxisAlignment.start,
                                //     children: [
                                //       SizedBox(
                                //         height: cnSpotifyBar.preservedSpaceOpenSpotify,
                                //         child: Row(
                                //           children: [
                                //             Text("Open Spotify", textScaler: TextScaler.linear(0.6)),
                                //             const Icon(
                                //                 MyIcons.spotify,
                                //                 size: 10,
                                //                 color: Color(0xff1ed560)
                                //             ),
                                //           ],
                                //         ),
                                //       ),
                                //       SizedBox(
                                //         height: 2,
                                //       ),
                                //       GestureDetector(
                                //           onTap: (){
                                //             /// Opens Spotify directly to the song/album but also starts it from the beginning at first time
                                //             // String? uri = cnSpotifyBar.data?.track?.uri;
                                //             /// Just opens Spotify
                                //             String uri = "spotify:";
                                //             // if(uri != null){
                                //             openUrl(uri);
                                //             // }
                                //           },
                                //           child: cnSpotifyBar.spotifyImageWidget(cnBackgroundColor)
                                //       )
                                //     ],
                                //   ),
                                // ),
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
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: AutoSizeText(
                                                        cnSpotifyBar.data!.track?.name ?? "",
                                                        maxLines: 1,
                                                        style: Theme.of(context).textTheme.titleMedium,
                                                        minFontSize: 13,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    GestureDetector(
                                                      onTapDown: (details){
                                                        setState(() {
                                                          colorSpotifyButton = Colors.white.withOpacity(0.25);
                                                        });
                                                      },
                                                      onTapCancel: (){
                                                        setState(() {
                                                          colorSpotifyButton = Colors.white.withOpacity(0.12);
                                                        });
                                                      },
                                                      onTap: (){
                                                        /// Opens Spotify directly to the song/album but also starts it from the beginning at first time
                                                        // String? uri = cnSpotifyBar.data?.track?.uri;
                                                        /// Just opens Spotify
                                                        String uri = "spotify:";
                                                        // if(uri != null){
                                                        openUrl(uri);
                                                        HapticFeedback.selectionClick();
                                                        setState(() {
                                                          colorSpotifyButton = Colors.white.withOpacity(0.12);
                                                        });
                                                        // }
                                                      },
                                                      child: Container(
                                                        height: 20,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(20),
                                                          color: colorSpotifyButton,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            SizedBox(width: 2,),
                                                            Text(
                                                                "Open Spotify",
                                                                textScaler: TextScaler.linear(0.8),
                                                                style: Theme.of(context).textTheme.titleSmall
                                                            ),
                                                            Icon(
                                                                MyIcons.spotify,
                                                                size: 14,
                                                                color: Color(0xff1ed560)
                                                            ),
                                                            SizedBox(width: 2,),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 44,)
                                                  ],
                                                )
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 5, bottom:2),
                                              child: Row(
                                                  children:[
                                                    IconButton(
                                                        padding: EdgeInsets.zero,
                                                        constraints: const BoxConstraints(minWidth:36, minHeight:36),
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
                                                        constraints: const BoxConstraints(minWidth:36, minHeight:36),
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
                                                        constraints: const BoxConstraints(minWidth:36, minHeight:36),
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
                                                        constraints: const BoxConstraints(minWidth:36, minHeight:36),
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
                                                        constraints: const BoxConstraints(minWidth:36, minHeight:36),
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
                                                    Expanded(
                                                      child: AutoSizeText(
                                                        textAlign: MediaQuery.of(context).orientation == Orientation.portrait? TextAlign.start : TextAlign.center,
                                                        cnSpotifyBar.data!.track?.artist.name ?? "",
                                                        maxLines: 1,
                                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                            color: Colors.grey[400]
                                                        ),
                                                        minFontSize: 10,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 30,)
                                                  ]
                                              ),
                                            ),
                                          ),
                                        ]
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: SpotifyProgressIndicator(key: cnSpotifyBar.progressIndicatorKey, data: cnSpotifyBar.data!),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                      iconSize: 30,
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                      ),
                                      onPressed: () async{
                                        // cnSpotifyBar.disconnect();
                                        cnSpotifyBar.close();
                                      },
                                      icon: Icon(
                                        Icons.keyboard_arrow_right,
                                        color: Colors.amber[800],
                                      )
                                    // icon: Icon(
                                    //   Icons.cancel,
                                    //   color: Colors.amber[800],
                                    // )
                                  ),
                                  const SizedBox(width: 3,)
                                ],
                              ),
                            )
                            // Align(
                            //   alignment: Alignment.topRight,
                            //   child: Padding(
                            //     padding: const EdgeInsets.all(5.0),
                            //     child: const Icon(
                            //         MyIcons.spotify,
                            //         size: 18,
                            //         color: Color(0xff1ed560)
                            //     ),
                            //   ),
                            // )
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
                        cnSpotifyBar.connectToSpotify(context);
                      },
                      icon: const Icon(
                        MyIcons.spotify,
                        // color: Colors.amber[800],
                        color: Color(0xff1ed560)
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
  double preservedSpaceOpenSpotify = 0;
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
      // SpotifySdk.getPlayerState().then((value) => value.track.uri);
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

  Widget spotifyImageWidget(CnBackgroundColor cn) {
    if(data?.track?.name == currentTrackName){
      return lastImage?? const SizedBox();
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
              height: height-10 - preservedSpaceOpenSpotify,
              width: height-10 - preservedSpaceOpenSpotify,
              gaplessPlayback: true,
              fit: BoxFit.fitHeight,
            );
            setMainColor(lastImage!.image, cn);
          }
          // else if(snapshot.data == null){
          //   lastImage = null;
          // }
          return ClipRRect(
            /// Due to spotify guidelines it is permitted to change the shape of cover art
            /// https://developer.spotify.com/documentation/design#using-our-content
            borderRadius: BorderRadius.circular(0),
            // borderRadius: BorderRadius.circular(7),
            child: lastImage?? Container(
              height: height-10,
              width: height-10,
              color: CupertinoColors.systemFill,
            ),
          );
        }
    );
  }

  Future setMainColor (ImageProvider imageProvider, CnBackgroundColor cn) async {
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

  Future connectToSpotify(context) async{
    if(justClosed){
      isConnected = true;
      justClosed = false;
      progressIndicatorKey = UniqueKey();
      refresh();
      Future.delayed(Duration(milliseconds: animationTimeSpotifyBar), (){
        cnAnimatedColumn.refresh();
      });
      return;
    }

    if(isTryingToConnect) {
      return;
    }
    else if(!await hasInternet()){
      Fluttertoast.cancel();
      Fluttertoast.showToast(
          msg: "Offline",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[800],
          textColor: Colors.white,
          fontSize: 16.0
      );
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
    } catch (e) {
      accessToken = "";
      isTryingToConnect = false;
      if(e.toString().contains("NotLoggedInException")){
        Fluttertoast.cancel();
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.spotifyPleaseLogin,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.SNACKBAR,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[800],
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
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
    } catch (_) {}
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
    } catch (_) {}
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
    } catch (_) {}
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
    } catch (_) {}
    isHandlingControlAction = false;
  }

  // Future<void> reconnectAfterConnectionLoss() async {
  //   accessToken = "";
  //   isTryingToConnect = false;
  //   isConnected = false;
  //   justClosed = false;
  //   await connectToSpotify();
  // }

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
    } catch (_) {
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