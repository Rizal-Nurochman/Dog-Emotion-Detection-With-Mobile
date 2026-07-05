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

## Struktur
```
data/raw · data/splits   data mentah & hasil split
notebooks/               EDA + training (Colab GPU)
src/                     data_prep, models, train, evaluate
models/                  .keras + model_final.tflite
reports/figures          grafik acc/loss, confusion matrix
gui/                     app Flutter
configs/config.yaml      semua hyperparameter
```

## Cara jalan
1. `pip install -r requirements.txt`
2. `python src/data_prep.py`   # dedup + split stratified 80/10/10
3. Training via `notebooks/` di Colab.

## Link GitHub
<!-- isi setelah push -->
