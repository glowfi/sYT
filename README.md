<div align="center">

# 🎬 sYT

**Search • Watch • Download YouTube videos directly from the terminal**

_No official YouTube API required._

![Shell](https://img.shields.io/badge/interface-terminal-black)
![Python](https://img.shields.io/badge/python-3.5+-blue?logo=python)
![mpv](https://img.shields.io/badge/player-mpv-green)
![yt--dlp](https://img.shields.io/badge/backend-yt--dlp-red)

</div>

---

## ✨ Overview

`sYT` is a lightweight terminal-based YouTube client that lets you:

- 🔎 Search videos
- ▶️ Watch instantly
- ⬇️ Download content
- 🎛 Select quality interactively

All from your terminal — **without using the official YouTube API**.

Designed for keyboard-driven workflows and minimal environments.

---

## 🚀 Features

- API-free YouTube searching
- Terminal-native UI (fzf / dmenu / bemenu)
- Instant playback via `mpv`
- Multi-video downloads
- Quality selection
- Thumbnail preview support
- Multiple scraping algorithms

---

## 🧩 Dependencies

| Tool                 | Purpose           |
| -------------------- | ----------------- |
| Python ≥ 3.5         | scraping logic    |
| ueberzugpp           | image preview     |
| fzf / dmenu / bemenu | interactive menu  |
| jq                   | JSON formatting   |
| mpv                  | video playback    |
| yt-dlp               | stream extraction |
| aria2c               | downloading       |

---

## 📦 Installation

### 1️⃣ Add local bin to PATH

#### POSIX shells (bash / zsh / dash)

```bash
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
```

#### Fish shell

```fish
echo 'set PATH ~/.local/bin $PATH' >> ~/.config/fish/config.fish
```

Restart shell afterwards.

---

### 2️⃣ Install `ueberzugpp`

Install build dependencies:

```bash
libxres openslide cmake chafa libvips libsixel python-opencv
```

Build:

```bash
pip uninstall -y cmake
git clone https://github.com/jstkdng/ueberzugpp.git
cd ueberzugpp
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build .
mv ./ueberzug ./ueberzugpp
```

---

### 3️⃣ Install sYT

```bash
git clone https://github.com/glowfi/sYT
cd sYT

mkdir -p ~/.local/bin
cp sYT.py ~/.local/bin/
cp sYT.sh ~/.local/bin/

chmod +x ~/.local/bin/sYT.py
chmod +x ~/.local/bin/sYT.sh

cd ..
rm -rf sYT
```

---

## 🧠 Algorithms

| Algorithm | Description                                 |
| --------- | ------------------------------------------- |
| `v1`      | Pure web scraping (no dependencies, slower) |
| `v2`      | Invidious API backend (fast, default)       |

---

## ▶️ Usage

### Watch Videos

```bash
sYT.sh -p fzf
sYT.sh -p dmenu
sYT.sh -p bemenu
```

---

### Select Algorithm

```bash
sYT.sh -a v1
sYT.sh -a v2
```

---

### Download via Search

```bash
sYT.sh -d true -p fzf
sYT.sh -d true -p fzf -ml true
```

Options:

| Flag  | Description              |
| ----- | ------------------------ |
| `-p`  | menu provider            |
| `-d`  | download instead of play |
| `-ml` | multi-download           |

---

### Download via Direct Links

Single link:

```bash
sYT.sh -fl "https://youtube.com/abcdef" -p fzf
```

Multiple links:

```bash
sYT.sh -flm "url1 url2" -p fzf
```

dmenu / bemenu prompt mode:

```bash
sYT.sh -p dmenu -dl true
```

Merge audio + video:

```bash
sYT.sh -d true -mav true
```

---

### Help

```bash
sYT.sh -h
```

---

## ⚠️ Notes

- Depends on YouTube frontend changes
- Uses scraping + Invidious instances
- Respect YouTube terms of service

---

## 🤝 Contributing

Improvements and fixes are welcome.

Small focused PRs preferred.

---

## 📄 License

GPL-3.0
