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
dlink="false"

usage()
{
cat << EOF
usage: sYT.sh -p "dmenu" -d "true"
usage: sYT.sh -fl "https://youtube.com/abcdef" -p "fzf" [Pass the link as argument if u want to uses fzf]
usage: sYT.sh -dl "true" -p "dmenu" [Dmenu will ask you to paste th elink in the prompt.Pass true or false for dl]


-p    | --provider      Fzf or Dmenu
-d    | --download      Download searched video (true or false) [Only download do not play the video]
-dl   | --dlink         Download any youtube video with a link dmenu as provider.
-fl   | --dlink         Download any youtube video with a link fzf as provider.
-h    | --help          Prints help 
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
        dlink=$(echo >/dev/null |dmenu -p "Paste video link with ctrl+shift+y :" -nb "#32302f" -nf "#bbbbbb" -sb "#477D6F" -sf "#eeeeee")
        # Check if any link given
        if [[ "$dlink" != "" ]]; then
            youtube-dl -F "$dlink" | sed '3,$!d' | dmenu -l 20 -p "Choose :" -nb "#32302f" -nf "#bbbbbb" -sb "#477D6F" -sf "#eeeeee"  | awk '{print $1}' | xargs -t -I {} youtube-dl -f {} "$dlink"
        else 
            notify-send "No link Given"
        fi

    else
        # Read user query
        query=$(echo >/dev/null |dmenu -p "Search query :" -nb "#32302f" -nf "#bbbbbb" -sb "#477D6F" -sf "#eeeeee")

        # Get data
        if [[ "$query" ]]; then
            python ~/.local/bin/sYT.py -q "$query";
            if [[ "$download" = "false" ]]; then
            cat ~/data.json | jsonArrayToTabled |dmenu -l 20 -p "Find:" -i -nb "#32302f" -nf "#bbbbbb" -sb "#477D6F" -sf "#eeeeee" | awk '{print $NF}' | sed '1s/^.//' |xargs -t -I {} mpv "{}"
            else
                link=$(cat ~/data.json | jsonArrayToTabled |dmenu -l 20 -p "Find:" -i -nb "#32302f" -nf "#bbbbbb" -sb "#477D6F" -sf "#eeeeee" | awk '{print $NF}' | sed '1s/^.//')
                youtube-dl -F "$link" | sed '3,$!d' | dmenu -l 20 -p "Choose :" -nb "#32302f" -nf "#bbbbbb" -sb "#477D6F" -sf "#eeeeee" | awk '{print $1}' | xargs -t -I {} youtube-dl -f {} "$link"
            fi
        fi
    fi

elif [[ "$provider" = "fzf" ]]; then
    # Check if any link given
    if [[ "$flink" != "" ]]; then
        youtube-dl -F "$flink" | sed '3,$!d' | fzf --prompt="Choose :" --reverse | awk '{print $1}' | xargs -t -I {} youtube-dl -f {} "$flink"
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
            link=$(cat ~/data.json | jsonArrayToTable |fzf --prompt="Find :" --cycle --height 20 --reverse | awk '{print $NF}')
            youtube-dl -F "$link" | sed '3,$!d' | fzf --prompt="Choose :" --reverse | awk '{print $1}' | xargs -t -I {} youtube-dl -f {} "$link"
        fi
    fi
fi

# Cleanup
rm -rf ~/argparse ~/json ~/os ~/requests ~/urllib.parse ~/data.json
