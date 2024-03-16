import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class SpotifyBar extends StatefulWidget {
  const SpotifyBar({super.key});

  @override
  State<SpotifyBar> createState() => _SpotifyBarState();
}

class _SpotifyBarState extends State<SpotifyBar> {
  late ImageUri? currentTrackImageUri;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10.0,
                sigmaY: 10.0,
              ),
              child: Container(
                height: 50,
                width: double.maxFinite,
                color: Colors.black.withOpacity(0.4),
                child: StreamBuilder<PlayerState>(
                  stream: SpotifySdk.subscribePlayerState(),
                  builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot){
                    var track = snapshot.data?.track;
                    currentTrackImageUri = track?.imageUri;

                    return snapshot.data == null? const SizedBox() : Row(
                      children: [
                        spotifyImageWidget(currentTrackImageUri?? ImageUri("None")),
                        const Spacer(flex:1),
                        IconButton(
                            iconSize: 30,
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                            ),
                            onPressed: () async{
                              skipPrevious();
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
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                            ),
                            onPressed: () async{
                              snapshot.data!.isPaused? resume() : pause();
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
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                            ),
                            onPressed: () async{
                              skipNext(); //.then((value) => setState(() => {}));
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
                                // shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                            ),
                            onPressed: () async{
                              disconnect().then((value) => setState(() => {}));
                            },
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.amber[800],
                            )
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
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
            return Image.memory(
              snapshot.data!,
              height: 50,
              width: 50,
              gaplessPlayback: true,
            );
          }
          else{
            return const SizedBox();
          }

          // else if (snapshot.hasError) {
          //   // setStatus(snapshot.error.toString());
          //   return SizedBox(
          //     width: ImageDimension.xSmall.value.toDouble(),
          //     height: ImageDimension.xSmall.value.toDouble(),
          //     // child: const Center(child: Text('Error getting image')),
          //   );
          // } else {
          //   return SizedBox(
          //     width: ImageDimension.xSmall.value.toDouble(),
          //     height: ImageDimension.xSmall.value.toDouble(),
          //     // child: const Center(child: Text('Getting image...')),
          //   );
          // }
        }
      );
    }
}

Future<bool> connectToSpotify()async{
  bool result = await SpotifySdk.connectToSpotifyRemote(clientId: "6911043ee364484fb270f70844bdb38f", redirectUrl: "fitness-app://spotify-callback");
  print("CONNECTED SPOTIFY: $result");
  return result;
}

Future<void> skipPrevious() async {
  try {
    await SpotifySdk.skipPrevious();
  } on PlatformException catch (e) {
    // setStatus(e.code, message: e.message);
  } on MissingPluginException {
    // setStatus('not implemented');
  }
}
Future<void> skipNext() async {
  try {
    await SpotifySdk.skipNext();
  } on PlatformException catch (e) {
    // setStatus(e.code, message: e.message);
  } on MissingPluginException {
    // setStatus('not implemented');
  }
}

Future<void> pause() async {
  try {
    await SpotifySdk.pause();
  } on PlatformException catch (e) {
    // setStatus(e.code, message: e.message);
  } on MissingPluginException {
    // setStatus('not implemented');
  }
}

Future<void> resume() async {
  try {
    await SpotifySdk.resume();
  } on PlatformException catch (e) {
    // setStatus(e.code, message: e.message);
  } on MissingPluginException {
    // setStatus('not implemented');
  }
}

Future<void> disconnect() async {
  try {
    // setState(() {
    //   _loading = true;
    // });
    var result = await SpotifySdk.disconnect();
    // setStatus(result ? 'disconnect successful' : 'disconnect failed');
    // setState(() {
    //   _loading = false;
    // });
  } on PlatformException catch (e) {
    // setState(() {
    //   _loading = false;
    // });
    // setStatus(e.code, message: e.message);
  } on MissingPluginException {
    // setState(() {
    //   _loading = false;
    // });
    // setStatus('not implemented');
  }
}