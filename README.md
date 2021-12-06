# sYT

> search and watch YouTube videos from terminal without youtube API or just use as youtube downloader.

## Description

-   [syt.py](https://github.com/glowfi/sYT/blob/main/sYT.py) scrapes youtube data and returns json (Can be used as a seperate library to get info about youtube videos).
-   [sYT.sh](https://github.com/glowfi/sYT/blob/main/sYT.sh) parses the output from [sYT.py](https://github.com/glowfi/sYT/blob/main/sYT.py).

## Dependencies

-   python 3.5+ (For scrapping data)
-   fzf or dmenu (For menu)
-   mpv (For playing video)
-   youtube-dl (For downloading videos)
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

sYT.sh -p "dmenu" -d "true"
sYT.sh -fl "https://youtube.com/abcdef" -p "fzf" [Pass the link as argument if u want to uses fzf]
sYT.sh -dl "true" -p "dmenu" [Dmenu will ask you to paste th elink in the prompt.Pass true or false for dl]


-p    | --provider      Fzf or Dmenu
-d    | --download      Download searched video (true or false) [Only download do not play the video]
-dl   | --dlink         Download any youtube video with a link dmenu as provider.
-fl   | --dlink         Download any youtube video with a link fzf as provider.
-h    | --help          Prints help

```

**NOTE**

**Try creating an alias in your shell as sYT (not sh\*t) for this program**
