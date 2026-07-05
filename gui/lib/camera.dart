import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'classifier.dart';
import 'main.dart' show kPrimary, kAccent;

// Warna & emoji per label untuk kartu hasil.
const _labelStyle = {
  'angry': (Color(0xFFE53935), '😠'),
  'happy': (Color(0xFF43A047), '😄'),
  'relaxed': (Color(0xFF1E88E5), '😌'),
  'sad': (Color(0xFF8E24AA), '😢'),
};

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final _classifier = Classifier();
  final _picker = ImagePicker();
  CameraController? _cam;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await _classifier.load();
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'Tidak ada kamera tersedia');
        return;
      }
      final ctrl = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await ctrl.initialize();
      if (!mounted) return;
      setState(() => _cam = ctrl);
    } catch (e) {
      setState(() => _error = 'Init gagal: $e');
    }
  }

  Future<void> _capture() async {
    final cam = _cam;
    if (cam == null || _busy) return;
    setState(() => _busy = true);
    try {
      final shot = await cam.takePicture();
      await _process(File(shot.path));
    } catch (e) {
      _snack('Gagal ambil foto: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _fromGallery() async {
    if (_busy) return;
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _busy = true);
    try {
      await _process(File(picked.path));
    } catch (e) {
      _snack('Gagal proses gambar: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _process(File file) async {
    final result = await _classifier.classifyFile(file);
    if (!mounted) return;
    _showResult(file, result);
  }

  void _showResult(File file, Prediction p) {
    final style = _labelStyle[p.label] ?? (kPrimary, '🐶');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                file,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(style.$2, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text(
              p.label.toUpperCase(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: style.$1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Keyakinan ${(p.confidence * 100).toStringAsFixed(1)}%',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Selesai'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _cam?.dispose();
    _classifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: _preview()),
          // Tombol back
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          // Kontrol bawah: galeri + shutter
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _roundBtn(Icons.photo_library, _fromGallery),
                    _shutter(),
                    const SizedBox(width: 56), // seimbang dgn galeri
                  ],
                ),
              ),
            ),
          ),
          if (_busy)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _preview() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Pilih dari Album'),
              ),
            ],
          ),
        ),
      );
    }
    final cam = _cam;
    if (cam == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    return CameraPreview(cam);
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white24,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _shutter() {
    return GestureDetector(
      onTap: _capture,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kAccent,
          border: Border.all(color: Colors.white, width: 5),
        ),
        child: const Icon(Icons.pets, color: Colors.white, size: 34),
      ),
    );
  }
}
