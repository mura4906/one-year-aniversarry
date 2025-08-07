// Flutterアプリ: Memory Quest
// 思い出の場所を巡る謎解き体験アプリ（改良版）

import 'package:flutter/material.dart';
import 'package:one_year_aniversarry/firebase_options.dart';
import 'package:one_year_aniversarry/opening_video_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MemoryQuestApp());
}


class MemoryQuestApp extends StatelessWidget {
  const MemoryQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Quest',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const OpeningVideoPage(),
    );
  }
}

