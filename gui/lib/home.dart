import 'package:flutter/material.dart';
import 'main.dart' show kPrimary, kAccent;
import 'camera.dart';
import 'about.dart';

/// Homepage bergaya mockup (Menu.jpeg) + bottom navbar (Navbar.jpeg).
/// Hanya tombol tengah navbar yang aktif → buka kamera.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CameraPage()),
    );
  }

  void _openAbout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AboutPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        title: const Text(
          'Dog Emotion',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          children: [
            _profileCard(),
            const SizedBox(height: 48),
            _scanPrompt(context),
            const SizedBox(height: 40),
            _infoCard(context),
          ],
        ),
      ),
      bottomNavigationBar: _Navbar(
        onScan: () => _openCamera(context),
        onAbout: () => _openAbout(context),
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: kPrimary,
            child: Icon(Icons.pets, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'DOG EMOTION DETECTION',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          const Text(
            'Deteksi Emosi Anjing',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'angry · happy · relaxed · sad',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _scanPrompt(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.photo_camera_outlined, size: 64, color: kPrimary),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _openCamera(context),
          child: const Text(
            'Deteksi Sekarang',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Cara Pakai',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Tekan tombol tengah untuk ambil foto anjing '
            'atau pilih dari album.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => _openCamera(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5B301),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Buka Kamera'),
          ),
        ],
      ),
    );
  }
}

/// Bottom navbar dgn tombol scan mengambang di tengah (mockup Navbar.jpeg).
/// Item lain hanya dekorasi — tidak aktif sesuai permintaan.
class _Navbar extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onAbout;
  const _Navbar({required this.onScan, required this.onAbout});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Color(0x1A000000), blurRadius: 12),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const _NavItem(
                      icon: Icons.home_rounded, label: 'Home', active: true),
                  const SizedBox(width: 64), // ruang tombol tengah
                  _NavItem(
                    icon: Icons.info_outline,
                    label: 'About',
                    onTap: onAbout,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: onScan,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kAccent,
                  border: Border.all(color: const Color(0xFFBBD3FF), width: 6),
                  boxShadow: [
                    BoxShadow(
                      color: kAccent.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;
  const _NavItem({required this.icon, required this.label, this.active = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? kPrimary : Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
