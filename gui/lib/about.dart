import 'package:flutter/material.dart';
import 'main.dart' show kPrimary;

/// Halaman About: menjelaskan tujuan & cara kerja project deteksi emosi anjing.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'About',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _Header(),
            SizedBox(height: 24),
            _Section(
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              body:
                  'Dog Emotion Detection adalah aplikasi yang mengklasifikasikan '
                  'emosi anjing dari sebuah foto ke dalam empat kelas: angry, '
                  'happy, relaxed, dan sad. Cukup ambil foto atau pilih dari '
                  'album, lalu aplikasi menampilkan emosi beserta tingkat '
                  'keyakinannya.',
            ),
            _Section(
              icon: Icons.psychology_outlined,
              title: 'Cara Kerja',
              body:
                  'Aplikasi menjalankan model deep learning MobileNetV2 yang '
                  'dilatih dengan teknik transfer learning, lalu dikonversi ke '
                  'format TensorFlow Lite (.tflite) agar berjalan langsung di '
                  'perangkat (on-device) tanpa memerlukan koneksi internet.',
            ),
            _Section(
              icon: Icons.dataset_outlined,
              title: 'Dataset & Model',
              body:
                  'Model dilatih pada ribuan citra anjing berlabel 4 emosi. '
                  'Dua metode dibandingkan (CNN scratch vs MobileNetV2), dan '
                  'MobileNetV2 dipilih sebagai model final karena akurasinya '
                  'paling tinggi (±90%).',
            ),
            _Section(
              icon: Icons.school_outlined,
              title: 'Konteks',
              body:
                  'Aplikasi ini dikembangkan sebagai proyek UAS Praktikum '
                  'Machine Learning 2026.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: const [
          CircleAvatar(
            radius: 40,
            backgroundColor: kPrimary,
            child: Icon(Icons.pets, color: Colors.white, size: 40),
          ),
          SizedBox(height: 12),
          Text(
            'DOG EMOTION DETECTION',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text('angry · happy · relaxed · sad',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _Section({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimary, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(color: Colors.grey.shade700, height: 1.5),
          ),
        ],
      ),
    );
  }
}
