import hashlib
import shutil
import random
from pathlib import Path
import yaml

CONFIG  = yaml.safe_load(Path("configs/config.yaml").read_text())
RAW_DIR = Path(CONFIG["data"]["raw_dir"])
OUT_DIR = Path(CONFIG["data"]["splits_dir"])
CLASSES = CONFIG["data"]["classes"]
RATIO   = CONFIG["data"]["split"]
SEED    = CONFIG["seed"]

def file_hash(path: Path) -> str:
  data = path.read_bytes()
  return hashlib.md5(data).hexdigest()

def build_blacklist():
  hash_classes = {}   
  for cls in CLASSES:
    for img in sorted((RAW_DIR / cls).iterdir()):
      if img.is_file():
        hash_classes.setdefault(file_hash(img), set()).add(cls)
   
  blacklist = {h for h, classes in hash_classes.items() if len(classes) > 1}
  return blacklist

def collect_unique(blacklist):
  unique = {}
  dup_count = 0
  conflict_count = 0
  for cls in CLASSES:
    seen = set()
    files = []
    for img in sorted((RAW_DIR / cls).iterdir()):
      if not img.is_file():
        continue
      h = file_hash(img)
      if h in blacklist:    
        conflict_count += 1
        continue
      if h in seen:               
        dup_count += 1
        continue
      seen.add(h)
      files.append(img)
    unique[cls] = files
  return unique, dup_count, conflict_count

def split_and_copy(unique):
  random.seed(SEED)

  for cls, files in unique.items():
    random.shuffle(files)
    n = len(files)
    n_train = int(n * RATIO["train"])
    n_val   = int(n * RATIO["val"])
    parts = {
      "train": files[:n_train],
      "val":   files[n_train:n_train + n_val],
      "test":  files[n_train + n_val:],
    }
    for split_name, split_files in parts.items():
      dest = OUT_DIR / split_name / cls
      dest.mkdir(parents=True, exist_ok=True)
      for img in split_files:
        shutil.copy(img, dest / img.name)
    print(f"{cls:8s}: {n:4d} unik -> train {len(parts['train'])} / "
       f"val {len(parts['val'])} / test {len(parts['test'])}")
    
def verify():
  hash_to_splits = {}
  for split_name in ("train", "val", "test"):
    for cls in CLASSES:
      folder = OUT_DIR / split_name / cls
      files = list(folder.iterdir())
      assert len(files) > 0, f"KOSONG: {folder}"
      for img in files:
        h = file_hash(img)
        hash_to_splits.setdefault(h, set()).add(split_name)
  leaks = [h for h, s in hash_to_splits.items() if len(s) > 1]
  assert not leaks, f"LEAKAGE! {len(leaks)} gambar muncul di >1 split"
  print(f"\nOK. {len(hash_to_splits)} gambar unik, 0 bocor lintas split.")

def find_cross_class_dupes():
  hash_to_files = {}
  for cls in CLASSES:
    for img in sorted((RAW_DIR / cls).iterdir()):
        if img.is_file():
            hash_to_files.setdefault(file_hash(img), []).append(img)
  for h, files in hash_to_files.items():
    classes_of = {f.parent.name for f in files}
    if len(classes_of) > 1:       
      print("KONFLIK:", [str(f) for f in files])

if __name__ == "__main__":
  blacklist = build_blacklist()
  unique, dup, conflict = collect_unique(blacklist)
  print(f"duplikat dibuang: {dup} | konflik label dibuang: {conflict} file\n")
  split_and_copy(unique)
  verify()