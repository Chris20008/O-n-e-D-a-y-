import 'dart:ui';

import 'package:fitness_app/widgets/spotify_bar.dart';
import 'package:flutter/foundation.dart';
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

    // print("--------- REBUILD ---------");
    // print(cnBackgroundImage.colorFirstChild);
    // print(cnBackgroundImage.colorSecondChild);
    // print(cnBackgroundImage.firstChild);

    cnBackgroundImage = Provider.of<CnBackgroundImage>(context);

    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      decoration: BoxDecoration(
          gradient:  LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              // colors: [
              //   Colors.black54,
              //   Colors.black38,
              // ]
              colors: [
                // (cnBackgroundImage.songColors[cnBackgroundImage.currentTrackName]?? cnBackgroundImage.defaultColors)[1],
                // (cnBackgroundImage.songColors[cnBackgroundImage.currentTrackName]?? cnBackgroundImage.defaultColors)[0],
                cnBackgroundImage.colorSecondChild?? Colors.black38,
                cnBackgroundImage.colorFirstChild?? Colors.black54,
              ]
          )
      ),
      // color: cnBackgroundImage.colorFirstChild,
      child: Container(
        decoration: const BoxDecoration(
            gradient:  LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Colors.black38,
                  Colors.black54,
                ]
                // colors: [
                //   cnBackgroundImage.colorFirstChild?? Colors.black54,
                //   cnBackgroundImage.colorSecondChild?? Colors.black38,
                // ]
            )
        ),
      ),
    );
    // return Stack(
    //   children: [
    //     AnimatedCrossFade(
    //       firstChild: Container(
    //         color: cnBackgroundImage.colorFirstChild,
    //         // color: Colors.green,
    //       ),
    //       secondChild:Container(
    //         color: cnBackgroundImage.colorSecondChild,
    //         // color: Colors.red,
    //       ),
    //       crossFadeState: cnBackgroundImage.firstChild?
    //       CrossFadeState.showFirst :
    //       CrossFadeState.showSecond,
    //       duration: const Duration(milliseconds: 200),
    //     ),
    //     // Container(
    //     //   decoration: BoxDecoration(
    //     //       gradient: LinearGradient(
    //     //           begin: Alignment.topCenter,
    //     //           end: Alignment.bottomCenter,
    //     //           colors: [
    //     //             Colors.black.withOpacity(0.3),
    //     //             Colors.black.withOpacity(0.6),
    //     //           ]
    //     //       )
    //     //   ),
    //     // )
    //   ],
    // );


    // return ClipRRect(
    //   child: ImageFiltered(
    //       imageFilter: ImageFilter.blur(
    //         sigmaX: 500.0,
    //         sigmaY: 500.0,
    //       ),
    //       child: Stack(
    //           children: [
    //             if (cnSpotifyBar.isConnected) cnSpotifyBar.lastImage,
    //             // Container(
    //             //   height: double.maxFinite,
    //             //   width: double.maxFinite,
    //             //   color: Colors.black.withOpacity(0.6),
    //             // )
    //           ]
    //       )
    //   ),
    // );


    // return Container(
    //   decoration: BoxDecoration(
    //       gradient: LinearGradient(
    //           begin: Alignment.topRight,
    //           end: Alignment.bottomLeft,
    //           colors: [
    //             const Color(0xff84490b),
    //             Colors.black.withOpacity(0.9),
    //           ]
    //       )
    //   ),
    // );


    // return FutureBuilder(
    //   future: getBlurredImage(cnSpotifyBar),
    //     builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
    //     Widget child;
    //       // if (snapshot.hasData) {
    //       //   child = snapshot.data!;
    //       // } else {
    //         child = Container(
    //           decoration: BoxDecoration(
    //             gradient: LinearGradient(
    //                 begin: Alignment.topRight,
    //                 end: Alignment.bottomLeft,
    //                 colors: [
    //                   const Color(0xff84490b),
    //                   Colors.black.withOpacity(0.9),
    //                 ]
    //             )
    //           ),
    //         );
    //       // }
    //       return ClipRRect(child: child);
    //     }
      // child: ImageFiltered(
      //     imageFilter: ImageFilter.blur(
      //       sigmaX: 50.0,
      //       sigmaY: 50.0,
      //     ),
      //     child: Stack(
      //         children: [
      //           if (cnSpotifyBar.isConnected) cnSpotifyBar.lastImage,
      //           // Container(
      //           //   height: double.maxFinite,
      //           //   width: double.maxFinite,
      //           //   color: Colors.black.withOpacity(0.6),
      //           // )
      //         ]
      //     )
      // ),
    // );
  }
  //
  // static Future<Widget> getBlurredImage(CnSpotifyBar cn)async{
  //   return await compute(computeBlurredImage, cn.lastImage);
  // }
  //
  // static Widget computeBlurredImage(Image im){
  //   print("________________calc blur________________");
  //   return ImageFiltered(
  //       imageFilter: ImageFilter.blur(
  //         sigmaX: 200.0,
  //         sigmaY: 200.0,
  //         tileMode: TileMode.decal
  //       ),
  //       child: Stack(
  //           children: [
  //             im
  //           ]
  //       )
  //   );
  // }

}

class CnBackgroundImage extends ChangeNotifier {
  Color? colorFirstChild;
  Color? colorSecondChild;
  bool isRefreshing = false;
  bool firstChild = true;
  String currentImageUri = "";
  String currentTrackName = "";
  Map<String, List<Color>> songColors = {};
  List<Color> defaultColors = [Colors.black, Colors.white];

  setColor(Color c, Color c2){
    // this.currentTrackName = currentTrackName;
    // songColors[currentTrackName] = [c, c2];
    colorFirstChild = c;
    colorSecondChild = c2;
    refresh();
  }

  // setOnlyTrackName(String currentTrackName){
  //   this.currentTrackName = currentTrackName;
  //   refresh();
  // }

  // setColor(Color? c){
  //   if(c != colorFirstChild && c!= colorSecondChild && !isRefreshing){
  //     isRefreshing = true;
  //     if(firstChild){
  //       colorSecondChild = c;
  //       firstChild = false;
  //     } else{
  //       colorFirstChild = c;
  //       firstChild = true;;
  //     }
  //     // refresh();
  //     Future.delayed(const Duration(milliseconds: 1500),(){
  //       isRefreshing = false;
  //     });
  //   }
  // }

  void refresh(){
    // print("refresh called");
    notifyListeners();
  }
}