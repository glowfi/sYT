#!/bin/sh

read -p $'\e[31mSearch query\e[0m :' query
echo "Scraping ......"
echo ""
echo "=== Showing results for $query ==="
echo ""

function jsonArrayToTable(){
     jq -r '(.[0] | ([keys[] | .] |(., map(length*"-")))), (.[] | ([keys[] as $k | .[$k]])) | @tsv' | column -t -s $'\t'   
}

python ~/.local/bin/sYT.py -q "$query";
cat ~/.cache/data.json | jsonArrayToTable |fzf --cycle -i --height 20 --reverse | awk '{print $NF}'|xargs -t -I {} mpv "https://youtube.com{}"
