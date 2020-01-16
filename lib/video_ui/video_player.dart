import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final int position;

  VideoPlayerPage(this.videoUrl, this.position);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController _controller;
  ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
    
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });

    chewieController = ChewieController(
      videoPlayerController: _controller,
      aspectRatio: _controller.value.aspectRatio,
      autoPlay: true,
      looping: true,
      materialProgressColors: new ChewieProgressColors(
                        playedColor: Theme.of(context).primaryColor,
                        handleColor: Theme.of(context).primaryColor,
                        backgroundColor: Colors.grey,
                        bufferedColor: Colors.white,
                      )
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller.value.isPlaying) _controller.pause();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'Preview${widget.position}',
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Center(
              child: _controller.value.initialized
                  ? Chewie(controller: chewieController,)
                  : CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
