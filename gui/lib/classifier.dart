import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Hasil satu prediksi: label + confidence 0..1.
class Prediction {
  final String label;
  final double confidence;
  const Prediction(this.label, this.confidence);
}

/// Loader + inference model emosi anjing (MobileNetV2, sudah softmax).
/// Spesifikasi & preprocessing wajib sama dgn docs/MODEL_HANDOFF.md.
class Classifier {
  static const _modelAsset = 'assets/model_final.tflite';
  static const _labelsAsset = 'assets/labels.txt';
  static const _size = 224; // input model 224x224

  Interpreter? _interpreter;
  List<String> _labels = const [];

  bool get isReady => _interpreter != null;

  Future<void> load() async {
    if (_interpreter != null) return;
    _interpreter = await Interpreter.fromAsset(_modelAsset);
    final raw = await rootBundle.loadString(_labelsAsset);
    _labels = raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Klasifikasi 1 file gambar. Return prediksi terbaik.
  Future<Prediction> classifyFile(File file) async {
    final interpreter = _interpreter;
    if (interpreter == null) throw StateError('Classifier belum di-load()');

    final decoded = img.decodeImage(await file.readAsBytes());
    if (decoded == null) throw StateError('Gagal decode gambar');

    final resized = img.copyResize(decoded, width: _size, height: _size);

    // Input [1,224,224,3] float32, RGB, normalisasi (p/127.5)-1.0 — lihat §3 handoff.
    final input = List.generate(
      1,
      (_) => List.generate(
        _size,
        (y) => List.generate(_size, (x) {
          final p = resized.getPixel(x, y);
          return [
            (p.r / 127.5) - 1.0,
            (p.g / 127.5) - 1.0,
            (p.b / 127.5) - 1.0,
          ];
        }),
      ),
    );

    final output = List.filled(1 * _labels.length, 0.0)
        .reshape([1, _labels.length]);
    interpreter.run(input, output);

    final scores = (output[0] as List).cast<double>();
    var best = 0;
    for (var i = 1; i < scores.length; i++) {
      if (scores[i] > scores[best]) best = i;
    }
    return Prediction(_labels[best], scores[best]);
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
