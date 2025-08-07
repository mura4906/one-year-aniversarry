// Flutterアプリ: Memory Quest
// 思い出の場所を巡る謎解き体験アプリ（改良版）

import 'package:flutter/material.dart';
import 'package:one_year_aniversarry/chat_page.dart';
import 'package:one_year_aniversarry/completion_page.dart';
import 'package:one_year_aniversarry/mission_page.dart';
import 'package:shared_preferences/shared_preferences.dart';





class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int currentMissionIndex = 0;
  List<bool> completedMissions = [];

  final List<Mission> missions = [
    // 待ち合わせ場所の謎解きミッション
    Mission(
      type: MissionType.puzzle,
      title: '💕 最初の出会いの場所 💕',
      clue:
          '私たちが初めて出会った場所...\n\n💭 ヒント:\n• 駅の近くにある\n• 大きな時計がある\n• 待ち合わせの定番スポット\n• 名前には「中央」が含まれる',
      question: 'この場所の名前を3文字で答えてください',
      correctAnswer: '中央口',
      options: ['中央口', '東口', '西口', '南口'],
      locationHint: '駅の中央口広場で待ち合わせ',
    ),

    // 写真ミッション
    Mission(
      type: MissionType.photo,
      title: '📸 思い出の写真を撮ろう 📸',
      clue: 'ここで撮った写真が一番思い出深い...',
      question: 'この場所で2人で写真を撮ってください！',
      correctAnswer: 'photo_taken',
      options: [],
      locationHint: '駅前の記念碑の前で',
    ),

    // クイズミッション
    Mission(
      type: MissionType.quiz,
      title: '🍽️ 最初のデートの場所 🍽️',
      clue: 'ここで食べたものは？',
      question: '〇〇レストランで何を注文した？',
      correctAnswer: 'オムライス',
      options: ['オムライス', 'パスタ', 'ハンバーグ', 'カレー'],
    ),

    // 場所移動ミッション
    Mission(
      type: MissionType.location,
      title: '🌸 桜並木の公園へ 🌸',
      clue: '春に行った花見の場所',
      question: '指定された場所に行ってください',
      correctAnswer: 'park_location',
      options: [],
      locationHint: '桜並木公園のベンチ',
      targetLatitude: 35.6762, // 実際の座標に変更
      targetLongitude: 139.6503,
    ),

    // 写真ミッション
    Mission(
      type: MissionType.photo,
      title: '📸 桜の写真を撮ろう 📸',
      clue: 'この桜並木で撮った写真が一番綺麗だった...',
      question: '桜並木で2人で写真を撮ってください！',
      correctAnswer: 'sakura_photo',
      options: [],
      locationHint: '桜並木のベンチの前で',
    ),

    // クイズミッション
    Mission(
      type: MissionType.quiz,
      title: '☕ お気に入りのカフェ ☕',
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
      completedMissions = missions
          .map((mission) =>
              prefs.getBool('completed_${missions.indexOf(mission)}') ?? false)
          .toList();
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
      MaterialPageRoute(
          builder: (context) => CompletionPage(onRestart: _resetGame)),
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
        title: Text('💕 ミッション ${currentMissionIndex + 1}/${missions.length}'),
        backgroundColor: Colors.pink[400],
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: currentMissionIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goToPreviousMission,
              )
            : null,
        actions: [
          if (completedMissions.isNotEmpty &&
              completedMissions[currentMissionIndex])
            const Icon(Icons.check_circle, color: Colors.white),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink[50]!, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (currentMissionIndex + 1) / missions.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[400]!),
                  minHeight: 8,
                ),
              ),
            ),
            Expanded(
              child: MissionDetailPage(
                mission: missions[currentMissionIndex],
                isCompleted: completedMissions.isNotEmpty
                    ? completedMissions[currentMissionIndex]
                    : false,
                onCompleted: _onMissionCompleted,
                onNext: _goToNextMission,
                isLastMission: currentMissionIndex == missions.length - 1,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatPage()),
          );
        },
        backgroundColor: Colors.pink[400],
        child: const Icon(Icons.chat),
      ),
    );
  }
}
