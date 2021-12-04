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

# Execute script

if [[ "$1" ]]; then

    # Read user query
    query=$(echo >/dev/null |dmenu -p "Search query :" -nb "#32302f" -nf "#bbbbbb" -sb "#477D6F" -sf "#eeeeee")

    # Get data
    if [[ "$query" ]]; then
    python ~/.local/bin/sYT.py -q "$query";
    cat ~/data.json | jsonArrayToTabled |dmenu -l 20 -p "Find:" -i -nb "#32302f" -nf "#bbbbbb" -sb "#477D6F" -sf "#eeeeee" | awk '{print $NF}' | sed '1s/^.//' |xargs -t -I {} mpv "{}"
    fi

    
else 
    # Read user query
    read -p $'\e[31mSearch query\e[0m :' query

    # Show progress 
    progress

    # Get data
    python ~/.local/bin/sYT.py -q "$query";
    cat ~/data.json | jsonArrayToTable |fzf --prompt="Find :" --cycle --height 20 --reverse | awk '{print $NF}'|xargs -t -I {} mpv "{}"
fi

# Cleanup
clear
rm -rf ~/argparse ~/json ~/os ~/requests ~/urllib.parse ~/data.json
