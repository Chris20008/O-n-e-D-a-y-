import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService{
  final FirebaseAuth _firebase_auth = FirebaseAuth.instance;

  /// Stream listen to auth state changes
  Stream<User?> authStateChanges() => _firebase_auth.authStateChanges();

  /// Get User Email
  String? getUserEmail() => _firebase_auth.currentUser?.email;

  /// Apple Login Method
  Future<UserCredential?> signInWithApple() async{
    try{
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes:[
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName
        ]
      );

      final oAuthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode
      );

      return await _firebase_auth.signInWithCredential(oAuthCredential);
    }
    catch(e){
      print("Error during sign in with apple");
      return null;
    }
  }

  /// Logout
  Future<void> signOut() async{
    _firebase_auth.signOut();
  }
}