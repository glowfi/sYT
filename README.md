# sYT

> search,watch and download YouTube videos from terminal without youtube API or just use as youtube downloader.

## Description

-   [syt.py](https://github.com/glowfi/sYT/blob/main/sYT.py) scrapes youtube data and returns json (Can be used as a seperate library to get info about youtube videos).
-   [sYT.sh](https://github.com/glowfi/sYT/blob/main/sYT.sh) parses the output from [sYT.py](https://github.com/glowfi/sYT/blob/main/sYT.py).

## Dependencies

-   python 3.5+ (For scrapping data)
-   fzf or dmenu (For menu)
-   mpv (For playing video)
-   yt-dlp (For downloading videos)
-   aria2c (For downloading videos)
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

### ONLY WATCH VIDEOS
Example 1: sYT.sh -p "fzf"       [Watch videos with fzf as provider]
Example 2: sYT.sh -p "dmenu"     [Watch videos with dmenu as provider]


#### DOWNLOAD BY SEARCHING VIDEOS
Note : For downloading -d flag must be given as true for downloading searched videos.

-p    | --provider      Fzf or Dmenu
-d    | --download      Download searched video (true or false) [Only download do not play the video]
-ml   | --multilink     Download multiple youtube videos fzf as provider.

Example 1: sYT.sh -d  "true" -p "fzf"            [Download single searched videos with fzf as provider]
Example 2: sYT.sh -d  "true" -p "fzf" -ml "true" [Download multiple searched videos with fzf as provider]


#### DOWNLOAD BY PASSING LINKS AS ARGUMENTS
Note : For downloading videos directly by passing link as arguments.

-dl   | --dlink         Download any youtube video with a single link dmenu as provider.
-fl   | --flink         Download any youtube video with a single link fzf as provider.
-flm  | --flinkmulti    Download any youtube video with multiple link fzf as provider.
-mav  | --mergeaudvid   Merge audio and video with fzf as provider.

Example 1: sYT.sh -fl  "https://youtube.com/abcdef" -p "fzf" [Pass the link as argument if u want to uses fzf]

Example 2: sYT.sh -flm "https://youtube.com/abc https://youtube.com/345" -p "fzf" [Pass multi link as argument if u want to uses fzf]

Note :  Dmenu will ask you to paste the link in the prompt.Pass true or false for dl

Example 3: sYT.sh -p "dmenu" -dl "true" [Dmenu supports only single link]

Example 4: sYT.sh -d "true" -mav "true"

-h   | --help          Prints help

```

**NOTE**

**Try creating an alias in your shell as sYT (not sh\*t) for this program**
