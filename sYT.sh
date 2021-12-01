#!/bin/sh

read -p "Search : " query
echo "Scraping ......"
echo ""
echo ""

function jsonArrayToTable(){
     jq -r '(.[0] | ([keys[] | .] |(., map(length*"-")))), (.[] | ([keys[] as $k | .[$k]])) | @tsv' | column -t -s $'\t'   
}

python ~/.local/bin/sYT.py -q "$query";
cat ~/.cache/data.json | jsonArrayToTable |fzf --height 20 --reverse | awk '{print $NF}'|xargs -t -I {} mpv "https://youtube.com{}"
