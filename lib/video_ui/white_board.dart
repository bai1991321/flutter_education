import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:painter/painter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:education_app/model/video.dart';
import 'package:education_app/video_ui/white_board_helper.dart';
import 'package:education_app/utils/constants.dart';
import 'package:education_app/utils/app_colors.dart';

class WhiteBoard extends StatefulWidget {
  final String emailID;
  final double screenHeight;

  WhiteBoard(this.emailID, this.screenHeight);

  @override
  _WhiteBoardState createState() => _WhiteBoardState();
}

class _WhiteBoardState extends State<WhiteBoard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool isRecordingStarted = false;
  var platform = const MethodChannel('video_scribing');
  var channel = BasicMessageChannel<String>('video_scribing', StringCodec());
  Timer _timer;
  String filePath, previewFilePath;
  Duration duration;
  bool isHighResEnabled = true, isLandscape = false;

  DateTime _startedTime, _stoppedTime;
  int _currentPage = 0;

  final PageController _pageController = new PageController();
  List<GlobalKey> _whiteboardKeys = [];
  List<PainterController> _controllers = [];

  Color _penColor = Colors.black;
  bool inEraserMode = false;

  @override
  void initState() {
    super.initState();

    channel.setMessageHandler((String message) {
      _handleMessageFromNative(message);
    });

    for (int i = 0; i < maxPages; i++) {
      _controllers.add(_newController());
      _whiteboardKeys.add(GlobalKey());
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  PainterController _newController() {
    PainterController controller = PainterController();
    controller.thickness = whiteBoardBrushSize;
    controller.backgroundColor = whiteBoardBackgroundColor;
    controller.drawColor = whiteBoardBrushColor;
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return WillPopScope(
      onWillPop: () {
        if (isRecordingStarted) {
          _stoppedTime = DateTime.now();
          platform.invokeMethod('stopRecording');
        } else
          return Future.value(true);
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          child: OrientationBuilder(
            builder: (context, orientation) {
              isLandscape = orientation == Orientation.landscape;
              return Stack(
                alignment: Alignment.bottomRight,
                children: <Widget>[
                  _buildWhiteBoard(),
                  _buildPreviousPageButton(),
                  FittedBox(
                    child: isRecordingStarted
                        ? _buildStopRecordingButton()
                        : _buildStartRecordingAndResButtons(),
                  ),
                  Platform.isIOS
                      ? IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: () {
                            if (isRecordingStarted) {
                              _stoppedTime = DateTime.now();
                              platform.invokeMethod('stopRecording');
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        )
                      : Container(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  PageView _buildWhiteBoard() {
    return PageView(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      onPageChanged: (position) {
        if (mounted)
          setState(() {
            _currentPage = position;
          });
      },
      children: _buildWhiteBoardPages(),
    );
  }

  List<RepaintBoundary> _buildWhiteBoardPages() {
    List<RepaintBoundary> _pages = [];
    for (int i = 0; i < maxPages; i++) {
      _pages.add(
        RepaintBoundary(
          key: _whiteboardKeys[i],
          child: Painter(_controllers[i]),
        ),
      );
    }
    return _pages;
  }

  Padding _buildPreviousPageButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 16.0),
      child: _currentPage != 0
          ? _buildSmallButton(
              heroTag: 'previous_page',
              iconPath: 'assets/up_arrow.png',
              alignment: Alignment.topRight,
              onTap: () {
                _pageController.animateToPage(
                  _currentPage - 1,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.linear,
                );
              },
            )
          : Container(),
    );
  }

  Container _buildHighResSwitch(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 24.0),
      child: SafeArea(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'High Res',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                  fontFamily: 'novabold'
              ),
              textAlign: TextAlign.center,
            ),
            CupertinoSwitch(
              value: isHighResEnabled,
              onChanged: (value) {
                if (mounted)
                  setState(() {
                    isHighResEnabled = !isHighResEnabled;
                  });
              },
              activeColor: const Color(AppColors.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartRecordingAndResButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          _buildHighResSwitch(context),
          _buildStartRecordingButton(),
          _buildSmallButton(
            heroTag: 'eraser',
            iconPath: 'assets/eraser.png',
            highlighted: inEraserMode,
            alignment: Alignment.bottomRight,
            onTap: () {
              if (mounted) {
                setState(() {
                  inEraserMode = !inEraserMode;
                });
                _onEraserTapped();
              }
            },
          ),
          _buildSmallButton(
            heroTag: 'pen_color',
            iconPath: 'assets/whiteboard_pen.png',
            iconColor: _penColor,
            alignment: Alignment.bottomRight,
            onTap: _switchPenColor,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: _currentPage != maxPages - 1
                ? _buildSmallButton(
                    heroTag: 'next_page',
                    iconPath: 'assets/arrow_down.png',
                    alignment: Alignment.bottomRight,
                    onTap: () {
                      _pageController.animateToPage(
                        _currentPage + 1,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.linear,
                      );
                    },
                  )
                : Container(),
          ),
        ],
      ),
    );
  }

  Container _buildStartRecordingButton() {
    return Container(
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.only(bottom: 16.0, left: 10.0),
      child: FloatingActionButton(
        onPressed: () {
          var map = <String, dynamic>{
            "isHighResEnabled": isHighResEnabled,
            "isLandscape": isLandscape,
          };
          if (Platform.isAndroid) {
            platform.invokeMethod('startRecording', map);
          } else if (Platform.isIOS) {
            platform.invokeMethod('startRecording', map);
          }
        },
        backgroundColor: Colors.red,
        shape: CircleBorder(
          side: BorderSide(width: 2.0, color: Colors.black.withOpacity(0.5)),
        ),
        child: Container(),
      ),
    );
  }

  Container _buildSmallButton({
    @required String heroTag,
    @required String iconPath,
    @required Alignment alignment,
    @required GestureTapCallback onTap,
    Color iconColor = Colors.black,
    bool highlighted = false,
  }) {
    return Container(
      padding: EdgeInsets.only(bottom: 5.0),
      alignment: alignment,
      margin: EdgeInsets.only(bottom: 16.0, left: 10.0),
      child: FloatingActionButton(
        heroTag: heroTag,
        mini: true,
        onPressed: onTap,
        backgroundColor:
            highlighted ? Colors.grey.withOpacity(0.7) : Colors.white,
        shape: CircleBorder(
          side: BorderSide(
            width: 2.0,
            color: highlighted
                ? Colors.grey.withOpacity(0.6)
                : Colors.black.withOpacity(0.5),
          ),
        ),
        child: Image.asset(
          iconPath,
          fit: BoxFit.contain,
          width: 16.0,
          height: 16.0,
          color: iconColor,
        ),
      ),
    );
  }

  Widget _buildStopRecordingButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 16.0),
          child: FloatingActionButton(
              onPressed: () {
                _stoppedTime = DateTime.now();
                platform.invokeMethod('stopRecording');
              },
              backgroundColor: Colors.white,
              shape: CircleBorder(
                side: BorderSide(
                  width: 2.0,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              child: Icon(
                Icons.stop,
                color: Colors.black,
              )),
        ),
        _buildSmallButton(
          heroTag: 'eraser',
          iconPath: 'assets/eraser.png',
          highlighted: inEraserMode,
          alignment: Alignment.bottomRight,
          onTap: () {
            if (mounted) {
              setState(() {
                inEraserMode = !inEraserMode;
              });
              _onEraserTapped();
            }
          },
        ),
        _buildSmallButton(
          heroTag: 'pen_color',
          iconPath: 'assets/whiteboard_pen.png',
          iconColor: _penColor,
          alignment: Alignment.bottomRight,
          onTap: _switchPenColor,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: _currentPage != maxPages - 1
              ? _buildSmallButton(
                  heroTag: 'next_page',
                  iconPath: 'assets/arrow_down.png',
                  alignment: Alignment.bottomRight,
                  onTap: () {
                    _pageController.animateToPage(
                      _currentPage + 1,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.linear,
                    );
                  },
                )
              : Container(),
        ),
      ],
    );
  }

  _switchPenColor() {
    for (int i = 0; i < penColors.length; i++) {
      if (_penColor == penColors[i]) {
        if (i == penColors.length - 1 && mounted) {
          setState(() {
            _penColor = penColors[0];
          });
        } else if (mounted) {
          setState(() {
            _penColor = penColors[i + 1];
          });
        }
        break;
      }
    }

    if (!inEraserMode) {
      for (int i = 0; i < maxPages; i++) {
        _controllers[i].drawColor = _penColor;
      }
    }
  }

  _onEraserTapped() {
    if (inEraserMode) {
      for (int i = 0; i < maxPages; i++) {
        _controllers[i].drawColor = Colors.white;
        _controllers[i].thickness = whiteBoardEraserSize;
      }
    } else {
      for (int i = 0; i < maxPages; i++) {
        _controllers[i].drawColor = _penColor;
        _controllers[i].thickness = whiteBoardBrushSize;
      }
    }
  }

  Future<Null> _uploadFile(File file, String videoDuration) async {
    //_showUploadingDialog();
    File previewFile = Platform.isIOS
        ? File(previewFilePath)
        : File(file.path.replaceAll(videoExtension, previewExtension));
    if (!previewFile.existsSync()) {
      Navigator.pop(context);

      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Unable to process video. Please try again!')));
      return;
    }

    final StorageReference videoRef = FirebaseStorage()
        .ref()
        .child(videosCollection)
        .child(filePath.substring(filePath.lastIndexOf("/") + 1));
    final StorageUploadTask videoUploadTask = videoRef.putFile(file);

    await videoUploadTask.onComplete;
    String videoUrl = await videoRef.getDownloadURL();

    String name = filePath.substring(filePath.lastIndexOf("/") + 1);
    final StorageReference previewRef = FirebaseStorage()
        .ref()
        .child(previewsCollection)
        .child(name.replaceAll(
            Platform.isIOS ? videoExtensionIOS : videoExtension,
            previewExtension));
    final StorageUploadTask previewUploadTask = previewRef.putFile(previewFile);

    await previewUploadTask.onComplete;
    String previewURL = await previewRef.getDownloadURL();

    await Firestore.instance.collection(videosCollection).document().setData(
          Video(
            name: name,
            duration: videoDuration,
            thumbnailUrl: previewURL,
            videoUrl: videoUrl,
            time: DateTime.now(),
            emailID: widget.emailID,
          ).toMap(),
        );

    Navigator.pop(context);
  }

  void _showUploadingDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return WillPopScope(
          onWillPop: () {},
          child: buildUploadingDialog(),
        );
      },
    );
  }

  _takeScreenshot() async {
    try {
      RenderRepaintBoundary boundary =
          _whiteboardKeys[_currentPage].currentContext.findRenderObject();
      ui.Image image = await boundary.toImage();
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      File preview;
      if (Platform.isIOS) {
        Directory directory = await getTemporaryDirectory();
        preview = File(directory.path + '/thumbnail.png');
        previewFilePath = preview.path;
      } else {
        preview = File(filePath.replaceAll(videoExtension, previewExtension));
      }

      preview.writeAsBytes(pngBytes);
    } catch (e) {
      print(e);
    }
  }

  _handleMessageFromNative(String message) async {
    if (mounted)
      setState(() {
        if (message == recordingStarted) {
          _startedTime = DateTime.now();
          // Stop recording after 5 minutes if not stopped already
          _timer = Timer(
            maxVideoLength,
            () {
              if (_timer != null) {
                _stoppedTime = DateTime.now();
                platform.invokeMethod('stopRecording');
              }
            },
          );
          Timer(
            videoPreviewTime,
            () {
              if (mounted && isRecordingStarted) {
                _takeScreenshot();
              }
            },
          );
          isRecordingStarted = true;
        } else if (message == recordingStopped) {
          if (_stoppedTime == null) _stoppedTime = DateTime.now();
          String videoDuration = _calculateVideoDuration();

          _timer?.cancel();
          _timer = null;
          isRecordingStarted = false;

          if (Platform.isIOS) {
            FilePicker.getFilePath(type: FileType.VIDEO).then((path) {
              filePath = path;
              if (filePath != null) _uploadFile(File(filePath), videoDuration);
            });
          } else {
            if (filePath != null) _uploadFile(File(filePath), videoDuration);
          }
        } else if (message.contains("FileName:")) {
          filePath = message.substring(message.indexOf(":") + 1);
        } else if (message == recordingCancelled) {
          _stoppedTime = DateTime.now();

          _timer?.cancel();
          _timer = null;
          isRecordingStarted = false;

          Navigator.pop(context);
        }
      });
  }

  String _calculateVideoDuration() {
    duration = _stoppedTime.difference(_startedTime);
    int minutes = duration.inMinutes;
    int seconds;

    if (duration.inMinutes == 0) {
      seconds = duration.inSeconds;
    } else {
      seconds = duration.inSeconds % duration.inMinutes;
    }

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
