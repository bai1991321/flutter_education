import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:education_app/model/video.dart';
import 'package:education_app/utils/app_colors.dart';
import 'package:education_app/utils/constants.dart';
import 'package:education_app/video_ui/video_options.dart';
import 'package:education_app/video_ui/video_player.dart';
import 'package:education_app/video_ui/white_board.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class VideoPage extends StatefulWidget {
  final String name, emailID;

  VideoPage({this.name, this.emailID});

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  PersistentBottomSheetController _bottomSheetController;
  final Firestore fireStore = Firestore.instance;

  @override
  void initState() {
    super.initState();
    fireStore.settings(timestampsInSnapshotsEnabled: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white54.withOpacity(0.95),
      body: NestedScrollView(
        headerSliverBuilder: (context, value) {
          return <Widget>[
            _buildAppBar(),
          ];
        },
        body: StreamBuilder(
          stream: fireStore.collection(videosCollection).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return SpinKitCircle(
                    color: const Color(AppColors.primaryColor));
              default:
                if (!snapshot.hasData || snapshot.data.documents.isEmpty)
                  return _buildNoVideos();
                return OrientationBuilder(
                  builder: (context, orientation) {
                    return _buildVideosGrid(orientation, snapshot);
                  },
                );
            }
          },
        ),
      ),
      floatingActionButtonLocation:
          MediaQuery.of(context).orientation == Orientation.portrait
              ? FloatingActionButtonLocation.centerFloat
              : FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(AppColors.primaryColor),
        onPressed: () {
          _closeVideoOptions();
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return WhiteBoard(
                widget.emailID,
                MediaQuery.of(context).size.height,
              );
            },
          ));
        },
        icon: Icon(Icons.edit),
        label: Text('WhiteBoard'),
      ),
    );
  }

  Container _buildVideosGrid(
      Orientation orientation, AsyncSnapshot<QuerySnapshot> snapshot) {
    return Container(
      padding: EdgeInsets.all(5.0),
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, position) {
                Video video =
                    Video.fromDocument(snapshot.data.documents[position]);
                return _buildVideoPreview(video, position);
              },
              childCount: snapshot.data.documents.length,
            ),
          ),
          SliverToBoxAdapter(child: Container(height: 80.0)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            appTitle,
            style: TextStyle(color: Colors.black, fontFamily: 'novabold'),
          ),
          Text(
            widget.name,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              fontFamily: 'nova',
            ),
          ),
        ],
      ),
      elevation: 0.0,
      backgroundColor: Colors.white54.withOpacity(0.0),
      bottom: PreferredSize(
        child: _buildVideosTitle(),
        preferredSize: Size(double.infinity, 40.0),
      ),
    );
  }

  Center _buildNoVideos() {
    return Center(
      child: Text(
        'No videos available\n\nTap on WhiteBoard to create one',
        style: TextStyle(fontSize: 16.0, fontFamily: 'novabold'),
        textAlign: TextAlign.center,
      ),
    );
  }

  Padding _buildVideosTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Divider(color: Colors.grey.withOpacity(0.5)),
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(
            'Videos',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16.0,
              fontStyle: FontStyle.italic,
              fontFamily: 'nova',
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: Divider(color: Colors.grey.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview(Video video, int position) {
    return GestureDetector(
      onTap: () {
        if (video.emailID == widget.emailID) {
          _bottomSheetController =
              _scaffoldKey.currentState.showBottomSheet((context) {
            return VideoOptions(video, position, widget.emailID);
          })
                ..closed.then((_) {
                  _bottomSheetController = null;
                });
        } else {
          _closeVideoOptions();
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return VideoPlayerPage(video.videoUrl, position);
          }));
        }
      },
      child: Hero(
        tag: 'Preview$position',
        child: Card(
          margin: EdgeInsets.all(10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          elevation: 5.0,
          child: GridTile(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: <Widget>[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          ),
                          image: DecorationImage(
                            image:
                                CachedNetworkImageProvider(video.thumbnailUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(),
                      ),
                      Container(
                        padding: EdgeInsets.all(3.0),
                        child: Text(
                          video.duration,
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'nova'),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Text(
                    video.name,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'novabold',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _closeVideoOptions() {
    if (_bottomSheetController != null) {
      Navigator.pop(context);
    }
  }
}
