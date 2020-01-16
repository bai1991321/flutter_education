import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class GoogleLogIn {
  // this is an interface, remember Java
  Future<FirebaseUser> signIn(GoogleSignIn googleSignIn);

  Future<Null> signOut(GoogleSignIn googleSignIn);
}

class GoogleAuth implements GoogleLogIn {
  Future<FirebaseUser> signIn(_gSignIn) async {
    GoogleSignInAccount googleSignInAccount = await _gSignIn.signIn();
    GoogleSignInAuthentication authentication =
        await googleSignInAccount.authentication;

    FirebaseUser user = await FirebaseAuth.instance.signInWithGoogle(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken);

    UserInfoDetails userInfo = new UserInfoDetails(
        user.providerId, user.displayName, user.email, user.photoUrl, user.uid);

    List<UserInfoDetails> providerData = new List<UserInfoDetails>();
    providerData.add(userInfo);

    UserDetails details = new UserDetails(
        user.providerId,
        user.uid,
        user.displayName,
        user.photoUrl,
        user.email,
        user.isAnonymous,
        user.isEmailVerified,
        providerData);
    return user;
  }

  Future<Null> signOut(_gSignIn) async {
    await _gSignIn.signOut();
    print('Signed out from Google');
  }
}

class UserDetails {
  final String providerId;

  final String uid;

  final String displayName;

  final String photoUrl;

  final String email;

  final bool isAnonymous;

  final bool isEmailVerified;

  final List<UserInfoDetails> providerData;

  UserDetails(this.providerId, this.uid, this.displayName, this.photoUrl,
      this.email, this.isAnonymous, this.isEmailVerified, this.providerData);
}

class UserInfoDetails {
  UserInfoDetails(
      this.providerId, this.displayName, this.email, this.photoUrl, this.uid);

  /// The provider identifier.
  final String providerId;

  /// The provider’s user ID for the user.
  final String uid;

  /// The name of the user.
  final String displayName;

  /// The URL of the user’s profile photo.
  final String photoUrl;

  /// The user’s email address.
  final String email;
}
