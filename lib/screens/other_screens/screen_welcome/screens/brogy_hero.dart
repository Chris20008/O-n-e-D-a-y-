import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:fitness_app/widgets/custom_navigator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screen_welcome.dart';

class BrogyHero extends StatefulWidget {

  final String? tag;
  final String? pathCloud;

  const BrogyHero({super.key, this.tag, this.pathCloud});

  @override
  State<BrogyHero> createState() => _BrogyHeroState();
}

class _BrogyHeroState extends State<BrogyHero> {

  Duration duration = const Duration(milliseconds: 400);

  final Widget brogyWelcome = SizedBox(height: 180, child: Image.asset("lib/assets/pictures/welcome_brogy.png"));
  late final Widget brogyCloud = SizedBox(height: 180, child: Image.asset(widget.pathCloud?? "lib/assets/pictures/brogy_connect_cloud.png"));
  late final Widget brogyCloudNoAccount = SizedBox(height: 180, child: Image.asset(widget.pathCloud?? (Platform.isAndroid? "lib/assets/pictures/brogy_google_drive.png" : "lib/assets/pictures/brogy_icloud.png")));
  // final Widget brogyCloud = SizedBox(height: 180, child: Image.asset("lib/assets/pictures/brogy_connect_cloud.png"));
  final Widget brogySpotify = SizedBox(height: 180, child: Image.asset("lib/assets/pictures/brogy_spotify.png"));
  final Widget brogyHealth = SizedBox(height: 180, child: Image.asset("lib/assets/pictures/brogy_health.png"));

  @override
  Widget build(BuildContext context) {

    return Hero(
        flightShuttleBuilder: (flightContext, animation, direction, fromContext, toContext) {

          String? newRoute = CustomNavigator.of(context).observer.currentRouteName;
          String? previousRoute = CustomNavigator.of(context).observer.previousRouteName;
          final bool? poppingInProgress = ModalRoute.of(context)?.popGestureInProgress;
          if(poppingInProgress?? false){
            newRoute = CustomNavigator.of(context).observer.parentRouteName;
            previousRoute = CustomNavigator.of(context).observer.currentRouteName;
          }

          return Stack(
              alignment: Alignment.center,
              children: [

                fadeInOut(
                  child: brogyWelcome,
                  newRoute: newRoute,
                  previousRoute: previousRoute,
                  thisRoute: WelcomeRoute.welcomeLanguage.value,
                  previousRouteName: [null],
                  nextRouteName: [WelcomeRoute.connectCloud.value, WelcomeRoute.connectCloudWithoutAccount.value],
                ),

                fadeInOut(
                  child: brogyCloud,
                  newRoute: newRoute,
                  previousRoute: previousRoute,
                  thisRoute: WelcomeRoute.connectCloud.value,
                  previousRouteName: [WelcomeRoute.welcomeLanguage.value],
                  nextRouteName: [WelcomeRoute.connectSpotify.value],
                ),

                fadeInOut(
                  child: brogyCloudNoAccount,
                  newRoute: newRoute,
                  previousRoute: previousRoute,
                  thisRoute: WelcomeRoute.connectCloudWithoutAccount.value,
                  previousRouteName: [WelcomeRoute.welcomeLanguage.value],
                  nextRouteName: [WelcomeRoute.connectSpotify.value],
                ),

                fadeInOut(
                  child: brogySpotify,
                  newRoute: newRoute,
                  previousRoute: previousRoute,
                  thisRoute: WelcomeRoute.connectSpotify.value,
                  previousRouteName: [WelcomeRoute.connectCloud.value, WelcomeRoute.connectCloudWithoutAccount.value],
                  nextRouteName: [WelcomeRoute.connectHealth.value],
                ),

                fadeInOut(
                  child: brogyHealth,
                  newRoute: newRoute,
                  previousRoute: previousRoute,
                  thisRoute: WelcomeRoute.connectHealth.value,
                  previousRouteName: [WelcomeRoute.connectSpotify.value],
                  nextRouteName: [null],
                ),
              ]
          );
        },
      transitionOnUserGestures: true,
      tag: widget.tag?? "brogyWelcome",
      child: Stack(
        alignment: Alignment.center,
        children: [

          AnimatedOpacity(
              opacity: CustomNavigator.of(context).observer.currentRouteName == WelcomeRoute.welcomeLanguage.value? 1 : 0,
              duration: duration,
              child: brogyWelcome
          ),

          AnimatedOpacity(
              opacity: CustomNavigator.of(context).observer.currentRouteName == WelcomeRoute.connectCloud.value? 1 : 0,
              duration: duration,
              child: brogyCloud
          ),

          AnimatedOpacity(
              opacity: CustomNavigator.of(context).observer.currentRouteName == WelcomeRoute.connectCloudWithoutAccount.value? 1 : 0,
              duration: duration,
              child: brogyCloudNoAccount
          ),

          AnimatedOpacity(
              opacity: CustomNavigator.of(context).observer.currentRouteName == WelcomeRoute.connectSpotify.value? 1 : 0,
              duration: duration,
              child: brogySpotify
          ),

          AnimatedOpacity(
              opacity: CustomNavigator.of(context).observer.currentRouteName == WelcomeRoute.connectHealth.value? 1 : 0,
              duration: duration,
              child: brogyHealth
          ),
        ]
      )
    );
  }

  Widget fadeInOut({
    required Widget child,
    required String? newRoute,
    required String? previousRoute,
    required String? thisRoute,
    required List<String?> previousRouteName,
    required List<String?> nextRouteName,
  }){

    if(newRoute == thisRoute && previousRouteName.contains(previousRoute)){
      return child.fadeInRight(
          duration: duration,
          animate: true,
      );
    }

    if(newRoute == thisRoute && nextRouteName.contains(previousRoute)){
      return child.fadeInLeft(
          duration: duration,
          animate: true
      );
    }

    if(nextRouteName.contains(newRoute) && previousRoute == thisRoute){
      return child.fadeOutLeft(
          duration: duration,
          animate: true
      );
    }

    if(previousRoute == thisRoute){
      return child.fadeOutRight(
          duration: duration,
          animate: true
      );
    }

    return const SizedBox();
  }
}