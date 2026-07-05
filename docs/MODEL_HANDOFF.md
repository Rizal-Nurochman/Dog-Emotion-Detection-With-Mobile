# Handoff Model → Tim GUI

Dokumen ini berisi semua yang dibutuhkan tim GUI untuk mengintegrasikan model
klasifikasi emosi anjing ke aplikasi mobile. Model & angka final dari bagian ML.

## 1. File yang diserahkan

| File | Isi | Cara kirim |
|------|-----|-----------|
| `model_final.tflite` (2.54 MB) | Model terbaik (MobileNetV2, sudah softmax) | **manual** (di-`.gitignore`) |
| `labels.txt` | 4 label, satu per baris | manual / bundle ke app |

Kedua file di-`.gitignore` → **tidak ikut `git clone`**. Minta langsung via chat/drive.
Di app, taruh sebagai asset (mis. Flutter: `assets/model_final.tflite`, `assets/labels.txt`).

## 2. Spesifikasi Model (diverifikasi dari file .tflite)

| | Shape | Dtype | Keterangan |
|--|-------|-------|-----------|
| **Input**  | `[1, 224, 224, 3]` | `float32` | RGB, sudah dinormalisasi (lihat §3) |
| **Output** | `[1, 4]`           | `float32` | Probabilitas per kelas (sudah softmax, jumlah = 1.0) |

Tidak ada kuantisasi di input/output (float32 murni) — jangan perlakukan sebagai model uint8.

## 3. Preprocessing — WAJIB SAMA PERSIS

Kesalahan di sini = model akurat di notebook tapi **ngawur di HP**. Urutan:

1. **Resize** gambar ke **224 × 224** piksel.
2. **Urutan channel RGB** (bukan BGR).
3. **JANGAN normalisasi** — beri piksel **mentah 0..255** (sebagai float).

> **PENTING:** Normalisasi `preprocess_input` MobileNetV2 (`x/127.5 - 1`) **sudah tertanam
> di dalam model `.tflite`** (terlihat sebagai layer `true_divide` & `subtract` di
> `model.summary()`). Jika kamu menormalisasi lagi di sisi app → normalisasi dobel →
> semua gambar runtuh ke satu nilai → **model selalu memprediksi kelas yang sama**.

Contoh (pseudo-Dart):
```dart
// img: piksel 0..255 setelah resize 224x224
final input = List.generate(224, (y) => List.generate(224, (x) {
  final p = img.getPixel(x, y);
  return [
    p.r.toDouble(),   // mentah 0..255, TANPA /127.5-1
    p.g.toDouble(),
    p.b.toDouble(),
  ];
}));
// bentuk akhir tensor: [1, 224, 224, 3]
```

## 4. Output — cara membaca hasil

Output = array 4 probabilitas, **indeks sesuai `labels.txt`**:

| Index | Label   |
|:-----:|---------|
| 0     | angry   |
| 1     | happy   |
| 2     | relaxed |
| 3     | sad     |

Langkah:
1. Ambil `argmax` dari 4 nilai output → indeks kelas prediksi.
2. Map indeks ke label via `labels.txt`.
3. Nilai di indeks itu = **confidence** (0..1) → tampilkan sebagai persen.

**Tidak perlu softmax manual** — sudah dilakukan di dalam model.

```dart
// output: List<double> panjang 4
int best = 0;
for (int i = 1; i < 4; i++) if (output[i] > output[best]) best = i;
final label = labels[best];               // mis. "happy"
final confidence = output[best];          // mis. 0.92 → "92%"
```

## 5. Performa model (ekspektasi realistis)

Test set 386 gambar, akurasi **90.4%**. Per kelas (F1): angry 0.87 · happy 0.92 ·
relaxed 0.90 · sad 0.92. Artinya ~1 dari 10 prediksi bisa salah — pertimbangkan
menampilkan confidence agar user tahu tingkat keyakinan model.

## 6. Checklist integrasi

- [ ] `model_final.tflite` + `labels.txt` masuk ke assets app
- [ ] Resize input ke 224×224, RGB
- [ ] Beri piksel **mentah 0..255** (JANGAN `/127.5-1` — sudah di dalam model)
- [ ] Tensor input berbentuk `[1,224,224,3]` float32
- [ ] Baca output `[1,4]`, `argmax`, map ke label
- [ ] Uji 1 gambar per kelas, cocokkan dengan prediksi notebook sebelum lanjut

Kalau prediksi konsisten salah/ke satu kelas saja → hampir pasti **normalisasi dobel** (§3):
hapus `/127.5-1` di sisi app, beri piksel mentah 0..255.
