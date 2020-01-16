import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

abstract class FacebookSignIn {
  // this is an interface, remember Java
  Future<FirebaseUser> signIn(FacebookLogin facebookSignIn);

  Future<Null> signOut(FacebookLogin facebookSignIn);
}

class FacebookAuth implements FacebookSignIn {
  Future<FirebaseUser> signIn(facebookSignIn) async {
    final FacebookLoginResult result =
        await facebookSignIn.logInWithReadPermissions(['email']);

    FirebaseUser user = await FirebaseAuth.instance
        .signInWithFacebook(accessToken: result.accessToken.token);

    ProviderDetails userInfo = new ProviderDetails(
        user.providerId, user.uid, user.displayName, user.photoUrl, user.email);

    List<ProviderDetails> providerData = new List<ProviderDetails>();
    providerData.add(userInfo);

    UserInfoDetails userInfoDetails = new UserInfoDetails(
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

  Future<Null> signOut(facebookSignIn) async {
    await facebookSignIn.logOut();
    print('Signed out from facebook');
  }
}

class UserInfoDetails {
  UserInfoDetails(this.providerId, this.uid, this.displayName, this.photoUrl,
      this.email, this.isAnonymous, this.isEmailVerified, this.providerData);

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

  // Check anonymous
  final bool isAnonymous;

  //Check if email is verified
  final bool isEmailVerified;

  //Provider Data
  final List<ProviderDetails> providerData;
}

class ProviderDetails {
  final String providerId;

  final String uid;

  final String displayName;

  final String photoUrl;

  final String email;

  ProviderDetails(
      this.providerId, this.uid, this.displayName, this.photoUrl, this.email);
}
