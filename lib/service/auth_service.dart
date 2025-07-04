import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/service/sync_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../util/constants.dart';

class AuthService{
  final FirebaseAuth _firebase_auth = FirebaseAuth.instance;

  /// Stream listen to auth state changes
  Stream<User?> authStateChanges() => _firebase_auth.authStateChanges();

  /// Get User Email
  String? getUserEmail() => _firebase_auth.currentUser?.email;

  /// Get User Id
  String? getUid() => _firebase_auth.currentUser?.uid;

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
      pr("Error during sign in with apple");
      return null;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebase_auth.signInWithCredential(credential);
    } catch (e) {
      pr("Error during sign in with Google: $e");
      return null;
    }
  }

  /// Logout
  Future<void> signOut() async{
    await _firebase_auth.signOut();
    if(Platform.isAndroid){
      await GoogleSignIn().signOut();
    }
  }

  Future<bool> deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null) {
        await user.delete();
        await CnSyncManager.database?.deleteAllData();
        await signOut();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      if (e.toString().contains('requires-recent-login')) {
        /// If needed reauthenticate
        pr("ERROR: Bitte erneut anmelden, bevor du deinen Account löschen kannst. : $e");
        final reauthentication = Platform.isAndroid?  await AuthService().signInWithGoogle() : await AuthService().signInWithApple();
        if(reauthentication != null){
          return await deleteAccount();
        }
        return false;
      } else {
        pr("ERROR: $e");
        return false;
      }
    } catch (e) {
      pr("ERROR: $e");
      return false;
    }
    return false;
  }
}