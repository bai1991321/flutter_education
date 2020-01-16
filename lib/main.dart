import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:education_app/auth/auth.dart';
import 'package:education_app/facebook_sigin/facebook_sigin.dart';
import 'package:education_app/google_signin/google_signin.dart';
import 'package:education_app/ui/splash_screen.dart';
import 'package:education_app/utils/app_colors.dart';
import 'package:education_app/utils/string_constants.dart';

Future<void> main() async {
  // Initialization for firebase app
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'ArwunRealTimeDb',
    options: Platform.isIOS
        ? const FirebaseOptions(
            googleAppID: '1:696220455365:ios:bccbdf97d989fe8a',
            gcmSenderID: '696220455365',
            databaseURL: 'https://educationapp-4362e.firebaseio.com',
            projectID: 'educationapp-4362e',
          )
        : const FirebaseOptions(
            googleAppID: '1:696220455365:android:bccbdf97d989fe8a',
            apiKey: 'AIzaSyBBgqE06QuhLXCZvcE66bCc3ekZVvpj240',
            databaseURL: 'https://educationapp-4362e.firebaseio.com',
            projectID: 'educationapp-4362e',
          ),
  );
  // Initialization for firebase database with bucket path
  final FirebaseStorage storage =
      FirebaseStorage(storageBucket: 'gs://educationapp-4362e.appspot.com/');
  // Initialization for firebase cloud database
  final Firestore fireStore = Firestore(app: app);
  await fireStore.settings(timestampsInSnapshotsEnabled: true);

  runApp(MaterialApp(
      home: MyApp(
    app: app,
    storage: storage,
  )));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  const MyApp({this.app, this.storage});

  final FirebaseApp app;
  final FirebaseStorage storage;

  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase(app: widget.app);
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: StringConstants.appName,
      theme: _buildThemeData(),
      home: SplashScreen(
        auth: new Auth(),
        facebookAuth: new FacebookAuth(),
        googleAuth: new GoogleAuth(),
        storage: widget.storage,
      ),
    );
  }
}

ThemeData _buildThemeData() {
  return new ThemeData(
    primaryColor: const Color(AppColors.primaryColor),
    accentColor: const Color(AppColors.accentColor),
    scaffoldBackgroundColor: Colors.white,
    splashColor: const Color(AppColors.primaryColor),
    backgroundColor: Colors.white,
    cursorColor: const Color(AppColors.primaryColor),
    hintColor: const Color(AppColors.primaryColor),
    primaryColorDark: const Color(AppColors.primaryDarkColor),
    primaryColorLight: const Color(AppColors.accentColor),
    indicatorColor: const Color(AppColors.primaryColor),
    brightness: Brightness.light,
    fontFamily: 'nova',
  );
}
