import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import '../main.dart';

class SpotifyProgressIndicator extends StatefulWidget {
  final PlayerState? data;
  const SpotifyProgressIndicator({super.key, this.data});
  // const SpotifyProgressIndicator({super.key});

  @override
  State<SpotifyProgressIndicator> createState() => _SpotifyProgressIndicatorState();
}

class _SpotifyProgressIndicatorState extends State<SpotifyProgressIndicator> {
  bool doRefresh = true;
  double? currentWidthPercent;
  int? remainingDuration;


  @override
  void initState() {
    if(widget.data != null){
      currentWidthPercent = (widget.data!.playbackPosition / widget.data!.track!.duration);
    }
    periodicRefresh();
    super.initState();
  }

  void periodicRefresh() async{
    Future.delayed(const Duration(milliseconds: 150), ()async{
      if(doRefresh){
        final data = await SpotifySdk.getPlayerState();
        setState(() {
          if (data != null && !data.isPaused){
            currentWidthPercent = data.playbackPosition / data.track!.duration;
            periodicRefresh();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    doRefresh = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
        builder: (context, constraints){

          return Container(
            height: 1.5,
            width: constraints.maxWidth,
            color: Colors.grey[350],
            child: Align(
              alignment: Alignment.centerLeft,
              child: currentWidthPercent != null
                ?Container(
                  height: 1.5,
                  width: constraints.maxWidth * currentWidthPercent!,
                  color: Colors.amber[800])
                :const SizedBox(),
            ),
          );
        }
    );
  }
}



































// class _SpotifyProgressIndicatorState extends State<SpotifyProgressIndicator> {
//   bool doRefresh = true;
//   double? currentWidthPercent;
//   int? remainingDuration;
//
//
//   @override
//   void initState() {
//     if(widget.data != null){
//       currentWidthPercent = widget.data!.playbackPosition / widget.data!.track!.duration;
//       remainingDuration = widget.data!.track!.duration - widget.data!.playbackPosition;
//       doRefresh = !widget.data!.isPaused;
//       Future.delayed(const Duration(milliseconds: 50), (){
//         if(doRefresh){
//           setState(() {
//             currentWidthPercent = 1;
//             remainingDuration = remainingDuration!;
//           });
//         }
//       });
//     }
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     doRefresh = false;
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return LayoutBuilder(
//       builder: (context, constraints){
//
//         // Widget child = const SizedBox();
//         // if (widget.data != null) {
//         //   double width = widget.data!.playbackPosition / widget.data!.track!.duration * constraints.maxWidth;
//         //   child = Container(
//         //     height: 1.5,
//         //     width: width,
//         //     color: Colors.amber[800],
//         //   );
//         // }
//
//         return Stack(
//           children: [
//             Container(
//               height: 1.5,
//               width: constraints.maxWidth,
//               color: Colors.grey[350],
//               // child: Align(
//               //   alignment: Alignment.centerLeft,
//               //   child: child,
//               // ),
//             ),
//             if(remainingDuration != null && currentWidthPercent != null)
//               AnimatedContainer(
//                 height: 1.5,
//                 width: constraints.maxWidth * currentWidthPercent!,
//                 duration: Duration(milliseconds: remainingDuration!), // Animationsdauer
//                 // transform: Matrix4.translationValues(0, cnNewWorkout.minPanelHeight>0? -(cnNewWorkout.minPanelHeight-cnBottomMenu.maxHeightBottomMenu) : 0, 0),
//                 curve: Curves.linear,
//                 color: Colors.amber[800],
//                 // child: Container(
//                 //   height: 1,
//                 //   width: constraints.maxWidth,
//                 //   color: Colors.grey[350],
//                 //   child: Align(
//                 //     alignment: Alignment.centerLeft,
//                 //     child: child,
//                 //   ),
//                 // ),
//               ),
//           ],
//         );
//
//         // return Consumer<PlayerStateStream>(
//         //     builder: (context, playerStateStream, _) {
//         //       return StreamBuilder(
//         //           stream: playerStateStream.stream,
//         //           builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
//         //             Widget child = const SizedBox();
//         //             if (snapshot.data != null) {
//         //               double width = snapshot.data!.playbackPosition / snapshot.data!.track!.duration * constraints.maxWidth;
//         //               child = Container(
//         //                 height: 1,
//         //                 width: width,
//         //                 color: Colors.amber[800],
//         //               );
//         //             }
//         //             return Container(
//         //               height: 1,
//         //               width: constraints.maxWidth,
//         //               color: Colors.grey[350],
//         //               child: Align(
//         //                 alignment: Alignment.centerLeft,
//         //                 child: child,
//         //               ),
//         //             );
//         //           });
//         //     });
//
//           // child: StreamBuilder(
//           //     stream: SpotifySdk.subscribePlayerState(),
//           //     builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
//           //       Widget child = const SizedBox();
//           //       if (snapshot.data != null) {
//           //         double width = snapshot.data!.playbackPosition / snapshot.data!.track!.duration * constraints.maxWidth;
//           //         child = Container(
//           //           height: 1,
//           //           width: width,
//           //           color: Colors.amber[800],
//           //         );
//           //       }
//           //       return Container(
//           //         height: 1,
//           //         width: constraints.maxWidth,
//           //         color: Colors.grey[350],
//           //         child: Align(
//           //           alignment: Alignment.centerLeft,
//           //           child: child,
//           //         ),
//           //       );
//           //     }
//           // ),
//         // );
//       }
//     );
//   }
// }
