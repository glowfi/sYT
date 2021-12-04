# sYT

> search and watch YoutTube videos from terminal without youtube API.

## Description

-   [syt.py](https://github.com/glowfi/sYT/blob/main/sYT.py) scrapes youtube data and returns json (Can be used as a seperate library to get info about youtube videos).
-   [sYT.sh](https://github.com/glowfi/sYT/blob/main/sYT.sh) parses the output from [sYT.py](https://github.com/glowfi/sYT/blob/main/sYT.py).

## Dependencies

-   python 3.5+ (For scrapping data)
-   fzf or dmenu (For menu)
-   mpv (For playing video)
-   youtube-dl
-   jq (For formatting json)

## Installation

**INSTALL**

```sh

# INSTALL SCRIPT
git clone https://github.com/glowfi/sYT
cd sYT
mkdir -p ~/.local/bin
cp -r ./sYT.py ~/.local/bin/
cp -r ./sYT.sh ~/.local/bin/
cd ..
rm -rf sYT
chmod +x ~/.local/bin/sYT.py
chmod +x ~/.local/bin/sYT.sh

```

**EXECUTE**

```sh

# RUN SCRIPT IN TERMINAL WITH FZF
~/.local/bin/sYT.sh

# RUN SCRIPT WITH DMENU
~/.local/bin/sYT.sh "dmenu"

```

**NOTE**

**Try creating an alias in your shell as sYT (not sh\*t) for this program**
