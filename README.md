# UAS Praktikum ML 2026 — Kelompok XXX

Klasifikasi emosi anjing (4 kelas: angry, happy, relaxed, sad) dengan **2 metode Deep Learning**
yang dibandingkan, lalu model terbaik dideploy ke **GUI mobile** (TFLite + Flutter).

## Dataset
- 3.876 gambar, 4 kelas (praktis seimbang: 931–989 per kelas).
- Sumber label = nama folder di `Final dog dataset/`. (`dataset.csv` diabaikan — path-nya rusak.)

## Metode
| Model | Peran |
|-------|-------|
| CNN scratch | baseline |
| MobileNetV2 (transfer learning) | model final → `.tflite` untuk mobile |

Metrik komparasi: Accuracy, Precision, Recall, F1-Score.

## Hasil Komparasi (test set, 386 gambar)

| Metrik (macro avg) | CNN scratch | MobileNetV2 |
|--------------------|:-----------:|:-----------:|
| Accuracy           | 0.655       | **0.904**   |
| Precision          | 0.658       | **0.904**   |
| Recall             | 0.655       | **0.903**   |
| F1-Score           | 0.655       | **0.904**   |

**MobileNetV2 = model final** (+25% akurasi) → diexport ke `models/model_final.tflite` untuk mobile.

Grafik pendukung di `reports/figures/`:
`{cnn,mobilenet}_training.png` (acc/loss), `{cnn,mobilenet}_confusion.png`,
`model_comparison.png` (4 metrik), `f1_per_class.png`.
Regenerate grafik komparasi: `python src/make_comparison.py`

## Handoff model → GUI
File yang dikirim ke tim GUI: `models/model_final.tflite` + `models/labels.txt`
(keduanya di-`.gitignore`, kirim manual — bukan lewat git).
- Input **224×224×3**, beri piksel **mentah 0..255** (jangan dinormalisasi di app —
  `preprocess_input` MobileNetV2 sudah tertanam di dalam model; kalau dobel → prediksi selalu 1 kelas).
- Output TFLite **sudah softmax** (probabilitas 0..1) → di sisi app cukup `argmax`.
- Urutan label sesuai `labels.txt`: `angry, happy, relaxed, sad`.

## Struktur
```
data/raw · data/splits   data mentah & hasil split
notebooks/               EDA + training (Colab GPU)
src/                     data_prep, make_comparison
models/                  .keras + model_final.tflite + labels.txt
reports/figures          grafik acc/loss, confusion matrix, komparasi
gui/                     app Flutter
configs/config.yaml      semua hyperparameter
```

## Cara jalan
1. `pip install -r requirements.txt`
2. `python src/data_prep.py`   # dedup + split stratified 80/10/10
3. Training via `notebooks/` di Colab.

## Link GitHub
<!-- isi setelah push -->
