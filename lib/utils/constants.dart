//const String whiteBoardRouteName = '/whiteboard';
//const String homePageRouteName = '/home_page';

import 'package:flutter/material.dart';

const String appTitle = 'Arwun';

// FireStore Collection - Videos
const String videosCollection = 'Videos';
const String previewsCollection = 'Previews';
const String nameKey = 'Name';
const String durationKey = 'Duration';
const String thumbnailUrlKey = 'ThumbnailUrl';
const String videoUrlKey = 'VideoUrl';
const String timeKey = 'Time';
const String emailIDKey = 'EmailID';

// Settings
const Duration maxVideoLength = Duration(minutes: 2);
const Duration videoPreviewTime = Duration(seconds: 2);
const Color whiteBoardBrushColor = Colors.black;
const Color whiteBoardBackgroundColor = Colors.white;
const double whiteBoardBrushSize = 3.0;
const double whiteBoardEraserSize = 20.0;
const int maxPages = 10;
const List<Color> penColors = [Colors.black, Colors.green];

const String recordingStarted = 'Started';
const String recordingStopped = 'Stopped';
const String recordingCancelled = 'Cancelled';
const String signedInSuccessfully = 'Signed_In_Successfully';
const String signInFailed = 'Sign_In_Failed';
const String videoExtension = '.mp4';
const String videoExtensionIOS = '.MOV';
const String previewExtension = '.png';
