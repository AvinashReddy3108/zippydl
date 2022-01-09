#!/usr/bin/env bash

# zippyshare.com batch downloader
# Usage: ./zippyshare.sh url (or) ./zippyshare.sh url-list.txt
# Requires: aria2c, curl, grep, awk
# Credits: AvinashReddy3108, TheGlockMisc, ffluegel

if [ -z "${1}" ]; then
    echo "usage: ${0} url"
    echo "batch usage: ${0} url-list.txt"
    echo "url-list.txt is a file that contains one zippyshare.com url per line"
    exit
fi

trap 'exit' SIGINT
trap 'exit' SIGTERM

function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }
function pepper() { x="$1"; n="$(( x % 2 ))"; b="$(( x % 3 ))"; z="$x"; }

function zippydownload() {
    baseDomain=$(echo "${url}" | awk -F[/:] '{print $4}')
    rawData=$(curl -L "${url}")

    salt=$(echo "$rawData" | grep -E "var b =" | sed 's/^.*=[[:space:]]//g;s/%.*//g')
    [ -z "$salt" ] && ( echo "Could not download file from ${url}"; exit 1 )

    pepper "$salt"; secret="$(( n + b + z ))"

    sauce=$(echo "$rawData" | grep "document.getElementById('dlbutton').href")
    d=$(echo "$sauce" | awk -F['"'] '{print $2}'); suffix=$(echo "$sauce" | awk -F['"'] '{print $4}')

    dl="https://${baseDomain}${d}${secret}${suffix}"

    # Custom destination filename
    [ -n "${outputName}" ] && filename="${outputName}" || filename=$(echo "$suffix" | tr -d '/')

    echo -e "[downloading] $(urldecode "$dl") -> $(urldecode "$filename")"

    # Start download file
    aria2c \
    --content-disposition-default-utf8=true --continue=true \
    --summary-interval=0 --download-result=hide --console-log-level=warn \
    --max-connection-per-server=16 --min-split-size=1M --split=8 \
    --connect-timeout=30 --retry-wait=2 \
    "${dl}" --out="$(urldecode "${filename}")"

    echo -e "\033[1K"
}

if [ -f "${1}" ]; then
    links=()
    while IFS="\n" read -r link || [[ "$link" ]]; do
        [[ $link == *"zippyshare.com"* ]] && links+=("$link")
    done < "${1}"

    current=0; total=${#links[@]}
    for url in "${links[@]}"; do
        current=$((current + 1))
        echo "Downloading [$current/$total], please wait.."; zippydownload "${url}"
    done
else
    url="${1}"; outputName="${2}"
    zippydownload "${url}" "${outputName}"
fi
