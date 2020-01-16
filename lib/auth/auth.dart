import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  // this is an interface, remember Java
  Future<String> signInWithEmailAndPassword(String email, String password);

  Future<String> createUserWithEmailAndPassword(String email, String password);

  Future<FirebaseUser> createUserWithEmailAndPasswordReturnUser(
      String email, String password);

  Future<String> currentUser();

  Future<void> signOut();

  Future<String> currentUserEmail();
}

class Auth implements BaseAuth {
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    FirebaseUser user = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  Future<String> createUserWithEmailAndPassword(
      String email, String password) async {
    FirebaseUser user = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  Future<FirebaseUser> createUserWithEmailAndPasswordReturnUser(
      String email, String password) async {
    FirebaseUser user = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return user;
  }

  Future<String> currentUser() async {
    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      return user.uid;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String> currentUserEmail() async {
    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      return user.email;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> signOut() async {
    return FirebaseAuth.instance.signOut();
  }
}
