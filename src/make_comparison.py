"""Grafik komparasi CNN vs MobileNetV2 untuk laporan.
Angka diambil dari classification_report kedua notebook (test set, 386 gambar).
Jalankan: python src/make_comparison.py
"""
from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np

OUT = Path("reports/figures")
OUT.mkdir(parents=True, exist_ok=True)

# macro-avg dari classification_report (lihat notebooks/train_*.ipynb)
METRICS = ["Accuracy", "Precision", "Recall", "F1-Score"]
CNN   = [0.655, 0.658, 0.655, 0.655]
MNET  = [0.904, 0.904, 0.903, 0.904]

# per-kelas F1 untuk analisis confusion matrix
CLASSES = ["angry", "happy", "relaxed", "sad"]
CNN_F1  = [0.674, 0.650, 0.611, 0.686]
MNET_F1 = [0.873, 0.919, 0.904, 0.918]


def grouped_bar(labels, a, b, title, fname, ylabel="Score"):
    x = np.arange(len(labels))
    w = 0.38
    fig, ax = plt.subplots(figsize=(8, 5))
    b1 = ax.bar(x - w / 2, a, w, label="CNN scratch", color="#6baed6")
    b2 = ax.bar(x + w / 2, b, w, label="MobileNetV2", color="#fd8d3c")
    ax.set_ylabel(ylabel)
    ax.set_title(title)
    ax.set_xticks(x, labels)
    ax.set_ylim(0, 1.0)
    ax.legend()
    ax.grid(axis="y", ls="--", alpha=0.4)
    for bars in (b1, b2):
        ax.bar_label(bars, fmt="%.3f", padding=2, fontsize=8)
    fig.tight_layout()
    fig.savefig(OUT / fname, dpi=120, bbox_inches="tight")
    print("tersimpan:", OUT / fname)


grouped_bar(METRICS, CNN, MNET,
            "Komparasi Metrik: CNN vs MobileNetV2 (Test Set)",
            "model_comparison.png")
grouped_bar(CLASSES, CNN_F1, MNET_F1,
            "F1-Score per Kelas: CNN vs MobileNetV2",
            "f1_per_class.png", ylabel="F1-Score")
