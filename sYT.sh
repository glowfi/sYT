#!/bin/sh

# Progress bar
function progress ()
{    
    # Start Scraping data
    BLUE='\033[0;34m'
    echo ""
    echo -e "$BLUE Scraping ......"
    echo ""
    sleep 1
    clear

    # Start populating results
    ORANGE='\033[0;33m'
    echo -e "$ORANGE === Showing results for $query ==="
    echo ""
}

# Pretty print data functions
function jsonArrayToTable(){
     jq -r '(["Channel","Duration","Views","Uploaded","Title","Link"] | (., map(length*"-"))), (.[] | [.Channel, .Duration,.Views,.Uploaded,.Title,.Link]) | @tsv' | column -t -s $'\t'  
}

# Pretty print data functions dmenu
function jsonArrayToTabled(){
    tab_space="\t"
    jq -r '.[]| "\(.Channel)'"$tab_space"'|\(.Duration)'"$tab_space"'|\(.Views)'"$tab_space"'|\(.Uploaded)'"$tab_space"'|\(.Title)'"$tab_space"'|\(.Link)"' | column -t -s $'\t'
}

# Commadn args
provider="fzf"
download="false"
flink=""
flinkmulti=""
dlink="false"
multilink=""
mav=""

usage()
{
cat << EOF

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
EOF
}

while [[ $# > 0 ]]
do
        case "$1" in

                -p|--provider)
                        provider="$2"
                        shift
                        ;;

                -d|--download)
                        download="$2"
                        shift
                        ;;
                -dl|--dlink)
                        dlink="$2"
                        shift
                        ;;
                -fl|--flink)
                        flink="$2"
                        shift
                        ;;
                -flm|--flinkmulti)
                        flinkmulti="$2"
                        shift
                        ;;
                -ml|--multilink)
                        multilink="$2"
                        shift
                        ;;
                -mav|--mergeaudvid)
                        mav="$2"
                        shift
                        ;;

                --help|*)
                        usage
                        exit 1
                        ;;
        esac
        shift
done

if [[ "$provider" = "dmenu" ]]; then
    if [[ "$dlink" = "true" ]]; then
        # Get video link
        dlink=$(echo >/dev/null |dmenu -p "Paste video link with ctrl+shift+y :" -nb "#32302f" -nf "#bbbbbb" -sb "#458588" -sf "#eeeeee")
        # Check if any link given
        if [[ "$dlink" != "" ]]; then
            yt-dlp -F "$dlink" | sed '3,$!d' | dmenu -l 20 -p "Choose :" -nb "#32302f" -nf "#bbbbbb" -sb "#458588" -sf "#eeeeee"  | awk '{print $1}' | xargs -t -I {} yt-dlp -f {} --external-downloader aria2c --external-downloader-args "-j 16 -x 16 -s 16 -k 1M" "$dlink"
            notify-send "Started Downloading ..."
        else 
            notify-send "No link Given"
        fi

    else
        # Read user query
        query=$(echo >/dev/null |dmenu -p "Search query :" -nb "#32302f" -nf "#bbbbbb" -sb "#458588" -sf "#eeeeee")

        # Get data
        if [[ "$query" ]]; then
            python ~/.local/bin/sYT.py -q "$query";
            if [[ "$download" = "false" ]]; then
            cat ~/data.json | jsonArrayToTabled |dmenu -l 20 -p "Find:" -i -nb "#32302f" -nf "#bbbbbb" -sb "#458588" -sf "#eeeeee" | awk '{print $NF}' | sed '1s/^.//' |xargs -t -I {} mpv "{}"
            else
                link=$(cat ~/data.json | jsonArrayToTabled |dmenu -l 20 -p "Find:" -i -nb "#32302f" -nf "#bbbbbb" -sb "#458588" -sf "#eeeeee" | awk '{print $NF}' | sed '1s/^.//')
                yt-dlp -F "$link" | sed '3,$!d' | dmenu -l 20 -p "Choose :" -nb "#32302f" -nf "#bbbbbb" -sb "#458588" -sf "#eeeeee" | awk '{print $1}' | xargs -t -I {} yt-dlp -f {} --external-downloader aria2c --external-downloader-args "-j 16 -x 16 -s 16 -k 1M" "$link"
            fi
        fi
    fi

elif [[ "$provider" = "fzf" ]]; then
    # Check if any link given
    if [[ "$flink" != "" ]]; then
        yt-dlp -F "$flink" | sed '3,$!d' | fzf --prompt="Choose :" --reverse | awk '{print $1}' | xargs -t -I {} yt-dlp -f {} --external-downloader aria2c --external-downloader-args "-j 16 -x 16 -s 16 -k 1M" "$flink"
    elif [[ "$flinkmulti" != "" ]]; then
        my_links=$(echo $flinkmulti | tr " " "\n")
         yt-dlp -f best --external-downloader aria2c --external-downloader-args "-j 16 -x 16 -s 16 -k 1M" $my_links
    else
        # Read user query
        read -p $'\e[31mSearch query\e[0m :' query

        # Show progress 
        progress

        # Get data
        python ~/.local/bin/sYT.py -q "$query";
        if [[ "$download" = "false" ]]; then
            cat ~/data.json | jsonArrayToTable |fzf --prompt="Find :" --cycle --height 20 --reverse | awk '{print $NF}'|xargs -t -I {} mpv "{}"
        else
            if [[ "$mav" == "true" ]]; then
                link=$(cat ~/data.json | jsonArrayToTable |fzf --prompt="Find :" --cycle --height 20 --reverse | awk '{print $NF}' | xargs)
                title=$(yt-dlp --skip-download --get-title --no-warnings "$link" | sed 2d )

                # Get video quality
                yt-dlp -F "$link" | sed '3,$!d' | fzf --prompt="Choose Quality for video:" --reverse | awk '{print $1}' | xargs -t -I {} yt-dlp -f {} --output "my_video_fetched.%(ext)s" --external-downloader aria2c --external-downloader-args "-j 16 -x 16 -s 16 -k 1M" "$link"

                # Get audio quality
                yt-dlp -F "$link" | sed '3,$!d' | fzf --prompt="Choose Quality for audio:" --reverse | awk '{print $1}' | xargs -t -I {} yt-dlp -f {} --output "my_audio_fetched.%(ext)s" --external-downloader aria2c --external-downloader-args "-j 16 -x 16 -s 16 -k 1M" "$link"

                # Merge
                vid=$(find ~ \( ! -regex '.*/\..*' \) -type f -name "my_video_fetched.*")
                aud=$(find ~ \( ! -regex '.*/\..*' \) -type f -name "my_audio_fetched.*")
                echo "$vid"
                echo "$aud"
                ffmpeg -i "$vid" -i "$aud" -map 0:0 -map 1:0 -c:v copy -c:a aac -b:a 256k -shortest "$title".mp4
                rm -rf "$vid"
                rm -rf "$aud"



            elif [[ "$multilink" == "true" ]]; then
                link=$(cat ~/data.json | jsonArrayToTable |fzf -m --prompt="Find :" --cycle --height 20 --reverse | awk '{print $NF}' | xargs)
                my_array=($(echo $link | tr " " "\n"))
                c=1
                for i in "${my_array[@]}"
                    do
                        yt-dlp -F "$i" | sed '3,$!d' | fzf --prompt="Choose Quality for video number $c :" --reverse | awk '{print $1}' | xargs -t -I {} yt-dlp -f {} --external-downloader aria2c --external-downloader-args "-j 16 -x 16 -s 16 -k 1M" "$i"
                        ((c++))
                done
            else
                link=$(cat ~/data.json | jsonArrayToTable |fzf --prompt="Find :" --cycle --height 20 --reverse | awk '{print $NF}')
                yt-dlp -F "$link" | sed '3,$!d' | fzf --prompt="Choose :" --reverse | awk '{print $1}' | xargs -t -I {} yt-dlp -f {} --external-downloader aria2c --external-downloader-args "-j 16 -x 16 -s 16 -k 1M" "$link"
            fi
        fi
    fi
fi

# Cleanup
rm -rf ~/argparse ~/json ~/os ~/requests ~/urllib.parse ~/data.json
