import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:education_app/model/video.dart';
import 'package:education_app/video_ui/video_player.dart';
import 'package:education_app/utils/constants.dart';

class VideoOptions extends StatefulWidget {
  final Video video;
  final int position;
  final String emailID;

  VideoOptions(this.video, this.position, this.emailID);

  @override
  _VideoOptionsState createState() => _VideoOptionsState();
}

class _VideoOptionsState extends State<VideoOptions> {
  bool _renamingVideo = false, _deletingVideo = false;
  String _newName = '';
  String errorText;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (!_deletingVideo) return Future.value(true);
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
        child:
            _renamingVideo ? _buildRenameVideo() : _buildVideoOptions(context),
      ),
    );
  }

  Column _buildVideoOptions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildVideoOptionTile(
          video: widget.video,
          title: 'Play Video',
          icon: Icons.play_circle_filled,
          onTap: () {
            Navigator.pop(context);
            if (Platform.isAndroid) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return VideoPlayerPage(widget.video.videoUrl, widget.position);
              }));
            } else if (Platform.isIOS) {
              Navigator.push(context, CupertinoPageRoute(builder: (context) {
                return VideoPlayerPage(widget.video.videoUrl, widget.position);
              }));
            }
          },
        ),
        _buildVideoOptionTile(
          video: widget.video,
          title: 'Rename Video',
          icon: Icons.edit,
          onTap: () {
            if (mounted)
              setState(() {
                _renamingVideo = true;
              });
          },
        ),
        _buildVideoOptionTile(
          video: widget.video,
          title: 'Delete Video',
          icon: Icons.delete,
          onTap: () {
            ;
            _deleteVideo(widget.video);
          },
        ),
      ],
    );
  }

  Widget _buildRenameVideo() {
    Orientation orientation = MediaQuery.of(context).orientation;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildRenameVideoTitle(),
          SizedBox(height: 20.0),
          _buildVideoDetails(),
          orientation == Orientation.portrait
              ? SizedBox(height: 20.0)
              : Container(),
          orientation == Orientation.portrait
              ? _buildNewNameTextField()
              : Container(),
          orientation == Orientation.portrait
              ? SizedBox(height: 20.0)
              : Container(),
          orientation == Orientation.portrait
              ? _buildRenameButton()
              : Container(),
        ],
      ),
    );
  }

  Text _buildRenameVideoTitle() {
    return Text(
      'Rename Video',
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).primaryColor.withOpacity(0.8),
      ),
    );
  }

  TextField _buildNewNameTextField() {
    return TextField(
      maxLines: 1,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Enter new name',
        errorText: errorText,
        contentPadding: EdgeInsets.all(15.0),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.8),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.8),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor.withOpacity(0.8),
          ),
        ),
      ),
      cursorColor: Theme.of(context).primaryColor,
      onChanged: (name) {
        _newName = name;
        if (name.isNotEmpty && mounted)
          setState(() {
            errorText = null;
          });
      },
    );
  }

  Row _buildVideoDetails() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Card(
          margin: EdgeInsets.all(0.0),
          child: CachedNetworkImage(
            imageUrl: widget.video.thumbnailUrl,
            width: MediaQuery.of(context).size.width / 3,
            height: MediaQuery.of(context).size.width / 3,
          ),
        ),
        Expanded(
          child: Container(
            height: MediaQuery.of(context).size.width / 3,
            padding: EdgeInsets.only(left: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      widget.video.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      widget.video.time.toIso8601String(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      widget.video.duration,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? Container()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _buildNewNameTextField(),
                          SizedBox(height: 10.0),
                          _buildRenameButton(),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRenameButton() {
    return RaisedButton(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      onPressed: () async {
        if (_newName.isNotEmpty) {
          if (widget.video.name == _newName) {
            if (mounted)
              setState(() {
                errorText = 'Please enter a new name!';
              });
            return;
          }
          int result = await _renameVideo(widget.video, _newName);
          Navigator.pop(context); // Close progress dialog
          switch (result) {
            case 1: // Video with same name already exists
              {
                if (mounted)
                  setState(() {
                    errorText = 'Video with same name alreay exists!';
                  });
                break;
              }
            case 2: // Video renamed successfully
              {
                Navigator.pop(context); // Close bottom sheet
                break;
              }
            case 3: // Error renaming video
              {
                if (mounted)
                  setState(() {
                    errorText = 'Error renaming video, Please try again!';
                  });
                break;
              }
          }
        } else {
          if (mounted)
            setState(() {
              errorText = 'Name must not be empty';
            });
        }
      },
      child: Text(
        'Rename',
        style: TextStyle(color: Colors.white, fontSize: 16.0),
      ),
    );
  }

  ListTile _buildVideoOptionTile({
    @required Video video,
    @required String title,
    @required IconData icon,
    @required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).primaryColor.withOpacity(0.8),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18.0,
          color: Theme.of(context).primaryColor,
        ),
      ),
      onTap: onTap,
    );
  }

  _deleteVideo(Video video) async {
    _deletingVideo = true;
    showDialog(
      context: context,
      builder: (context) {
        return _buildProgressDialog('Deleting video, Please wait...');
      },
    ).then((_) {
      _deletingVideo = false;
    });
    try {
      Query query = Firestore.instance
          .collection(videosCollection)
          .where(nameKey, isEqualTo: video.name);
      DocumentReference reference = (await query
              .where(emailIDKey, isEqualTo: widget.emailID)
              .limit(1)
              .getDocuments())
          .documents[0]
          .reference;

      await reference.delete();

      await FirebaseStorage.instance
          .ref()
          .child(videosCollection)
          .child(video.name)
          .delete();
      await FirebaseStorage.instance
          .ref()
          .child(previewsCollection)
          .child(video.name.replaceAll(
              Platform.isIOS ? videoExtensionIOS : videoExtension,
              previewExtension))
          .delete();

      if (_deletingVideo) Navigator.pop(context);
      Navigator.pop(context);
      _deletingVideo = false;
    } catch (e) {
      print(e);
      Navigator.pop(context);
    }
  }

  Widget _buildProgressDialog(String message) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(30.0),
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        elevation: 0.0,
        color: Colors.black54,
        child: Container(
          margin: EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: SpinKitCircle(color: Colors.white),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  message,
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int> _renameVideo(Video video, String newName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _buildProgressDialog('Renaming video, Please wait...');
      },
    );

    bool isVideoExists = await _isVideoExists(newName);

    if (isVideoExists) {
      return 1;
    } else {
      DocumentReference reference = await _getDocumentReference(video.name);
      video.name = newName;
      await reference.updateData(video.toMap()).catchError((error) {
        return 3;
      });
      return 2;
    }
  }

  Future<DocumentReference> _getDocumentReference(String videoName) async {
    Query query = Firestore.instance
        .collection(videosCollection)
        .where(nameKey, isEqualTo: videoName);

    return (await query.limit(1).getDocuments()).documents[0].reference;
  }

  Future<bool> _isVideoExists(String videoName) async {
    Query query = Firestore.instance
        .collection(videosCollection)
        .where(nameKey, isEqualTo: videoName);

    return (await query.limit(1).getDocuments()).documents.length > 0;
  }
}
