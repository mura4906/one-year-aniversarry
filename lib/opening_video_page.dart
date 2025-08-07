// Flutterアプリ: Memory Quest
// 思い出の場所を巡る謎解き体験アプリ（改良版）

import 'package:flutter/material.dart';
import 'package:one_year_aniversarry/start_page.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

// オープニング映像ページ
class OpeningVideoPage extends StatefulWidget {
  const OpeningVideoPage({super.key});

  @override
  _OpeningVideoPageState createState() => _OpeningVideoPageState();
}

class _OpeningVideoPageState extends State<OpeningVideoPage> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoReady = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    // 実際のアプリでは、アセットフォルダに動画ファイルを配置
    // ここではダミーの動画プレーヤーを作成
    try {
      _videoPlayerController =
          VideoPlayerController.asset('assets/opening.mp4');
      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: 16 / 9,
        allowFullScreen: false,
        allowMuting: false,
        showControls: false,
      );

      _videoPlayerController!.addListener(() {
        if (_videoPlayerController!.value.position >=
            _videoPlayerController!.value.duration) {
          _navigateToStartPage();
        }
      });

      setState(() {
        _isVideoReady = true;
      });
    } catch (e) {
      // 動画ファイルが見つからない場合は直接スタートページへ
      _navigateToStartPage();
    }
  }

  void _navigateToStartPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const StartPage()),
    );
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _isVideoReady && _chewieController != null
            ? Chewie(controller: _chewieController!)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite,
                    size: 80,
                    color: Colors.pink[300],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Memory Quest',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.pink[300]!),
                  ),
                ],
              ),
      ),
    );
  }
}
