#!/bin/sh

read -p $'\e[31mSearch query\e[0m :' query
echo "Scraping ......"
echo ""
sleep 1
clear
echo "=== Showing results for $query ==="
echo ""

function jsonArrayToTable(){
     jq -r '(["Channel","Duration","Views","Uploaded","Title","Link"] | (., map(length*"-"))), (.[] | [.Channel, .Duration,.Views,.Uploaded,.Title,.Link]) | @tsv' | column -t -s $'\t'  
}

python ~/.local/bin/sYT.py -q "$query";
cat ~/data.json | jsonArrayToTable |fzf --prompt="Find :" --cycle --height 20 --reverse | awk '{print $NF}'|xargs -t -I {} mpv "{}"
rm -rf ~/argparse ~/json ~/os ~/requests ~/urllib.parse ~/data.json
