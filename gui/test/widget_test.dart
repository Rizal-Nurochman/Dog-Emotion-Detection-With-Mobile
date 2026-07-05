// Smoke test: home tampil dengan judul & tombol scan.
import 'package:flutter_test/flutter_test.dart';

import 'package:gui/main.dart';

void main() {
  testWidgets('Home shows title and scan prompt', (tester) async {
    await tester.pumpWidget(const DogEmotionApp());
    await tester.pump();

    expect(find.text('Dog Emotion'), findsOneWidget);
    expect(find.text('Deteksi Sekarang'), findsOneWidget);
  });
}
