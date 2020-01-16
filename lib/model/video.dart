import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/utils/constants.dart';
import 'package:flutter/material.dart';

class Video {
  String duration;
  DateTime time;
  String thumbnailUrl, videoUrl;
  String name;
  String emailID;

  Video({
    @required this.duration,
    @required this.time,
    @required this.thumbnailUrl,
    @required this.videoUrl,
    @required this.name,
    @required this.emailID,
  });

  Video.fromDocument(DocumentSnapshot document)
      : name = document[nameKey],
        duration = document[durationKey],
        thumbnailUrl = document[thumbnailUrlKey],
        videoUrl = document[videoUrlKey],
        time = document[timeKey],
        emailID = document[emailIDKey];

  Map<String, dynamic> toMap() {
    return {
      nameKey: name,
      durationKey: duration,
      thumbnailUrlKey: thumbnailUrl,
      videoUrlKey: videoUrl,
      timeKey: time,
      emailIDKey: emailID,
    };
  }
}
