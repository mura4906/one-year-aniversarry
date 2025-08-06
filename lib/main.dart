// Flutterアプリ: Memory Quest
// 思い出の場所を巡る謎解き体験アプリ（改良版）

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MemoryQuestApp());

class MemoryQuestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Quest',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
      ),
      home: StartPage(),
    );
  }
}

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Memory Quest',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                '2人の思い出を辿る冒険へ出かけよう',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GamePage()),
                  );
                },
                child: Text('はじめる'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int currentMissionIndex = 0;
  List<bool> completedMissions = [];
  
  final List<Mission> missions = [
    Mission(
      title: '最初のデートの場所',
      clue: 'ここで食べたものは？',
      question: '〇〇レストランで何を注文した？',
      correctAnswer: 'オムライス',
      options: ['オムライス', 'パスタ', 'ハンバーグ', 'カレー'],
    ),
    Mission(
      title: 'あの桜並木の公園',
      clue: '春に行った花見の場所',
      question: '写真を撮ったベンチの色は？',
      correctAnswer: '赤',
      options: ['赤', '青', '緑', '白'],
    ),
    Mission(
      title: 'お気に入りのカフェ',
      clue: 'いつも窓際の席を選んでたよね',
      question: '2人で一番好きだったケーキは？',
      correctAnswer: 'モンブラン',
      options: ['モンブラン', 'チーズケーキ', 'チョコケーキ', 'イチゴケーキ'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentMissionIndex = prefs.getInt('currentMissionIndex') ?? 0;
      completedMissions = missions.map((mission) => 
        prefs.getBool('completed_${missions.indexOf(mission)}') ?? false
      ).toList();
    });
  }

  Future<void> _saveGameData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentMissionIndex', currentMissionIndex);
    for (int i = 0; i < completedMissions.length; i++) {
      await prefs.setBool('completed_$i', completedMissions[i]);
    }
  }

  void _onMissionCompleted() async {
    setState(() {
      if (currentMissionIndex < completedMissions.length) {
        completedMissions[currentMissionIndex] = true;
      }
    });
    await _saveGameData();
  }

  void _goToNextMission() async {
    if (currentMissionIndex < missions.length - 1) {
      setState(() {
        currentMissionIndex++;
      });
      await _saveGameData();
    } else {
      // 全ミッション完了
      _showCompletionCelebration();
    }
  }

  void _goToPreviousMission() async {
    if (currentMissionIndex > 0) {
      setState(() {
        currentMissionIndex--;
      });
      await _saveGameData();
    }
  }

  void _showCompletionCelebration() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CompletionPage(onRestart: _resetGame)),
    );
  }

  Future<void> _resetGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      currentMissionIndex = 0;
      completedMissions = List.filled(missions.length, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ミッション ${currentMissionIndex + 1}/${missions.length}'),
        backgroundColor: Colors.teal,
        leading: currentMissionIndex > 0
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: _goToPreviousMission,
            )
          : null,
        actions: [
          if (completedMissions.isNotEmpty && completedMissions[currentMissionIndex])
            Icon(Icons.check_circle, color: Colors.white),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (currentMissionIndex + 1) / missions.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
          ),
          Expanded(
            child: MissionDetailPage(
              mission: missions[currentMissionIndex],
              isCompleted: completedMissions.isNotEmpty ? completedMissions[currentMissionIndex] : false,
              onCompleted: _onMissionCompleted,
              onNext: _goToNextMission,
              isLastMission: currentMissionIndex == missions.length - 1,
            ),
          ),
        ],
      ),
    );
  }
}

class Mission {
  final String title;
  final String clue;
  final String question;
  final String correctAnswer;
  final List<String> options;

  Mission({
    required this.title,
    required this.clue,
    required this.question,
    required this.correctAnswer,
    required this.options,
  });
}

class MissionDetailPage extends StatefulWidget {
  final Mission mission;
  final bool isCompleted;
  final VoidCallback onCompleted;
  final VoidCallback onNext;
  final bool isLastMission;

  MissionDetailPage({
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

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  // 親ウィジェットが更新されたときに呼ばれる
  @override
  void didUpdateWidget(covariant MissionDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 新しいミッションが渡された場合に状態をリセット
    if (widget.mission.title != oldWidget.mission.title) {
      _initializeState();
    }
  }

  // 状態を初期化するヘルパーメソッド
  void _initializeState() {
    // 状態をリセット
    _selectedAnswer = null;
    _feedback = '';
    _isCorrect = false;
    _hasAnswered = false;
    _hintShown = false;
    // 完了済みのミッションの場合、正解状態で初期化
    if (widget.isCompleted) {
      _selectedAnswer = widget.mission.correctAnswer;
      _isCorrect = true;
      _hasAnswered = true;
      _feedback = '正解！🎉\n素敵な思い出ですね！';
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
      _feedback = 'ヒント: 正解は「${widget.mission.correctAnswer}」です！';
    });
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.mission.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.mission.clue,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            widget.mission.question,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 20),
          ...widget.mission.options.map((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: RadioListTile<String>(
                title: Text(option, style: TextStyle(fontSize: 16)),
                value: option,
                groupValue: _selectedAnswer,
                onChanged: _hasAnswered ? null : (value) {
                  setState(() {
                    _selectedAnswer = value;
                  });
                },
                activeColor: Colors.teal,
              ),
            );
          }).toList(),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedAnswer != null && !_isCorrect ? _checkAnswer : null,
                  child: Text('答え合わせ'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: !_hasAnswered && !_hintShown ? _showHint : null,
                icon: Icon(Icons.lightbulb_outline, size: 18),
                label: Text('ヒント'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  textStyle: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          if (_hasAnswered && !_isCorrect)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: ElevatedButton(
                onPressed: _resetAnswer,
                child: Text('もう一度挑戦'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          if (_feedback.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isCorrect 
                  ? Colors.green[50] 
                  : _hintShown && !_hasAnswered 
                    ? Colors.blue[50] 
                    : Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
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
                child: Text(widget.isLastMission ? '結果を見る' : '次へ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CompletionPage extends StatelessWidget {
  final VoidCallback onRestart;

  CompletionPage({required this.onRestart});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              Text(
                '🎉 おめでとう！ 🎉',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Memory Quest クリア！',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal[700],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '素敵な思い出を辿る旅、\nお疲れさまでした！',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '💕',
                      style: TextStyle(fontSize: 40),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  onRestart();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => StartPage()),
                    (route) => false,
                  );
                },
                child: Text('もう一度プレイ'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}