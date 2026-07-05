import 'package:flutter/material.dart';
import 'home.dart';

// Warna tema diambil dari mockup (gui/img) — biru tua + aksen.
const kPrimary = Color(0xFF1E2A8A);
const kAccent = Color(0xFF2D3BC4);
const kBg = Color(0xFFF3F4FB);

void main() => runApp(const DogEmotionApp());

class DogEmotionApp extends StatelessWidget {
  const DogEmotionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog Emotion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
        scaffoldBackgroundColor: kBg,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
