// Flutterアプリ: Memory Quest
// 思い出の場所を巡る謎解き体験アプリ（改良版）

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';



// ミッションの種類を定義
enum MissionType {
  quiz,
  photo,
  location,
  puzzle,
}


class Mission {
  final MissionType type;
  final String title;
  final String clue;
  final String question;
  final String correctAnswer;
  final List<String> options;
  final String? locationHint;
  final double? targetLatitude;
  final double? targetLongitude;

  Mission({
    required this.type,
    required this.title,
    required this.clue,
    required this.question,
    required this.correctAnswer,
    required this.options,
    this.locationHint,
    this.targetLatitude,
    this.targetLongitude,
  });
}

class MissionDetailPage extends StatefulWidget {
  final Mission mission;
  final bool isCompleted;
  final VoidCallback onCompleted;
  final VoidCallback onNext;
  final bool isLastMission;

  const MissionDetailPage({super.key, 
    required this.mission,
    required this.isCompleted,
    required this.onCompleted,
    required this.onNext,
    required this.isLastMission,
  });

  @override
  _MissionDetailPageState createState() => _MissionDetailPageState();
}

class _MissionDetailPageState extends State<MissionDetailPage> {
  String? _selectedAnswer;
  String _feedback = '';
  bool _isCorrect = false;
  bool _hasAnswered = false;
  bool _hintShown = false;
  File? _capturedImage;
  bool _isNearLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeState();
    if (widget.mission.type == MissionType.location) {
      _checkLocation();
    }
  }

  @override
  void didUpdateWidget(covariant MissionDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mission.title != oldWidget.mission.title) {
      _initializeState();
      if (widget.mission.type == MissionType.location) {
        _checkLocation();
      }
    }
  }

  void _initializeState() {
    _selectedAnswer = null;
    _feedback = '';
    _isCorrect = false;
    _hasAnswered = false;
    _hintShown = false;
    _capturedImage = null;
    _isNearLocation = false;

    if (widget.isCompleted) {
      _isCorrect = true;
      _hasAnswered = true;
      _feedback = '正解！🎉\n素敵な思い出ですね！';
      if (widget.mission.type == MissionType.photo) {
        _capturedImage = File('dummy_photo_path'); // ダミー
      }
    }
  }

  Future<void> _checkLocation() async {
    if (widget.mission.targetLatitude == null ||
        widget.mission.targetLongitude == null) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.mission.targetLatitude!,
        widget.mission.targetLongitude!,
      );

      setState(() {
        _isNearLocation = distance <= 100; // 100m以内
      });
    } catch (e) {
      print('位置情報の取得に失敗: $e');
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _capturedImage = File(photo.path);
        _isCorrect = true;
        _hasAnswered = true;
        _feedback = '📸 素敵な写真が撮れました！\n思い出がまた一つ増えましたね！';
      });
      widget.onCompleted();
    }
  }

  void _checkAnswer() {
    setState(() {
      _hasAnswered = true;
      if (_selectedAnswer == widget.mission.correctAnswer) {
        _isCorrect = true;
        _feedback = '正解！🎉\n素敵な思い出ですね！';
        widget.onCompleted();
      } else {
        _isCorrect = false;
        _feedback = 'ちがうみたい...もう一度考えてみて！';
      }
    });
  }

  void _resetAnswer() {
    setState(() {
      _selectedAnswer = null;
      _feedback = '';
      _hasAnswered = false;
      _isCorrect = false;
    });
  }

  void _showHint() {
    setState(() {
      _hintShown = true;
      _feedback =
          '💡 ヒント: ${widget.mission.locationHint ?? "正解は「${widget.mission.correctAnswer}」です！"}';
    });
  }

  Widget _buildMissionContent() {
    switch (widget.mission.type) {
      case MissionType.quiz:
        return _buildQuizMission();
      case MissionType.photo:
        return _buildPhotoMission();
      case MissionType.location:
        return _buildLocationMission();
      case MissionType.puzzle:
        return _buildPuzzleMission();
    }
  }

  Widget _buildQuizMission() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.mission.question,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        ...widget.mission.options.map((option) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: RadioListTile<String>(
              title: Text(option, style: const TextStyle(fontSize: 16)),
              value: option,
              groupValue: _selectedAnswer,
              onChanged: _hasAnswered
                  ? null
                  : (value) {
                      setState(() {
                        _selectedAnswer = value;
                      });
                    },
              activeColor: Colors.pink[400],
            ),
          );
        }),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedAnswer != null && !_isCorrect
                    ? _checkAnswer
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[400],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('答え合わせ'),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: !_hasAnswered && !_hintShown ? _showHint : null,
              icon: const Icon(Icons.lightbulb_outline, size: 18),
              label: const Text('ヒント'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                textStyle: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoMission() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.mission.question,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        if (_capturedImage != null)
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _capturedImage!,
                fit: BoxFit.cover,
              ),
            ),
          )
        else
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt,
                  size: 60,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 10),
                Text(
                  '写真を撮影してください',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _takePhoto,
          icon: const Icon(Icons.camera_alt),
          label: const Text('📸 写真を撮る'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink[400],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationMission() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.mission.question,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _isNearLocation ? Colors.green[50] : Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isNearLocation ? Colors.green : Colors.orange,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                _isNearLocation ? Icons.location_on : Icons.location_off,
                size: 40,
                color: _isNearLocation ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 10),
              Text(
                _isNearLocation ? '🎉 目的地に到着！' : '📍 目的地に向かって移動中...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      _isNearLocation ? Colors.green[700] : Colors.orange[700],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.mission.locationHint ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isNearLocation
              ? () {
                  setState(() {
                    _isCorrect = true;
                    _hasAnswered = true;
                    _feedback = '🎉 目的地に到着しました！\n素敵な思い出の場所ですね！';
                  });
                  widget.onCompleted();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink[400],
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          child: const Text('到着確認'),
        ),
      ],
    );
  }

  Widget _buildPuzzleMission() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple[200]!),
          ),
          child: Column(
            children: [
              Icon(
                Icons.psychology,
                size: 40,
                color: Colors.purple[400],
              ),
              const SizedBox(height: 10),
              Text(
                '🧩 謎解きチャレンジ 🧩',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.mission.question,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            hintText: '答えを入力してください',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.pink[400]!),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _selectedAnswer = value;
            });
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed:
                    _selectedAnswer != null && _selectedAnswer!.isNotEmpty
                        ? _checkAnswer
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[400],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('答え合わせ'),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: !_hasAnswered && !_hintShown ? _showHint : null,
              icon: const Icon(Icons.lightbulb_outline, size: 18),
              label: const Text('ヒント'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                textStyle: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.pink[50]!, Colors.white],
                ),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.mission.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.mission.clue,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildMissionContent(),
          if (_hasAnswered &&
              !_isCorrect &&
              widget.mission.type == MissionType.quiz)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: ElevatedButton(
                onPressed: _resetAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('もう一度挑戦'),
              ),
            ),
          if (_feedback.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isCorrect
                    ? Colors.green[50]
                    : _hintShown && !_hasAnswered
                        ? Colors.blue[50]
                        : Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isCorrect
                      ? Colors.green
                      : _hintShown && !_hasAnswered
                          ? Colors.blue
                          : Colors.orange,
                  width: 1,
                ),
              ),
              child: Text(
                _feedback,
                style: TextStyle(
                  fontSize: 18,
                  color: _isCorrect
                      ? Colors.green[800]
                      : _hintShown && !_hasAnswered
                          ? Colors.blue[800]
                          : Colors.orange[800],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (_isCorrect)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: widget.onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: Text(widget.isLastMission ? '結果を見る' : '次へ'),
              ),
            ),
        ],
      ),
    );
  }
}
