#!/usr/bin/env bash

# zippyshare.com batch downloader
# Usage: ./zippydl.sh url (or) ./zippydl.sh url-list.txt
# Requires: aria2, curl, grep, awk
# Credits: AvinashReddy3108, TheGlockMisc, ffluegel

if [ -z "${1}" ]; then
    echo "usage: ${0} url"
    echo "batch usage: ${0} url-list.txt"
    echo "url-list.txt is a file that contains one zippyshare.com url per line"
    exit
fi

trap 'exit' SIGINT; trap 'exit' SIGTERM

function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }
function downloader() { aria2c --content-disposition-default-utf8=true --continue=true --summary-interval=0 --download-result=hide --console-log-level=warn --max-connection-per-server=16 --min-split-size=1M --split=8 --connect-timeout=30 --retry-wait=2 "$@"; }

function zippyget() {
    baseDomain=$(echo "${url}" | awk -F[/:] '{print $4}')

    rawData=$(curl -sL --connect-timeout 5 --max-time 10 --retry 5 --retry-delay 0 --retry-max-time 15 "${url}")

    salt=$(echo "$rawData" | grep "document.getElementById('dlbutton').href" | grep -oP '\([0-9](.*?)\)' | awk '{print "$("$0")"}')
    [ -z "$salt" ] && local status='fail' || local status='pass'

    secret="$(eval echo "$salt")"; sauce=$(echo "$rawData" | grep "document.getElementById('dlbutton').href")

    d=$(echo "$sauce" | awk -F['"'] '{print $2}'); suffix=$(echo "$sauce" | awk -F['"'] '{print $4}')

    dl="https://${baseDomain}${d}${secret}${suffix}"; filename="$(urldecode "$(echo "$suffix" | sed 's|/||g')")"
    result=("$status" "$dl" "$filename"); echo "${result[@]}"
}

if [ -f "${1}" ]; then
    links=()
    while IFS="\n" read -r link || [[ "$link" ]]; do
        [[ $link == *"zippyshare.com"* ]] && links+=("$link")
    done < "${1}"

    tmp="$(mktemp)"

    current=0; total=${#links[@]}
    for url in "${links[@]}"; do
        current=$((current + 1))
        echo -ne "Processing [$current/$total], please wait.."\\r
        dl=($(zippyget "${url}"))
        [ "${dl[0]}" != 'pass' ] && echo "Could not fetch direct URL from '${url}', maybe the file does not exist?" && continue || echo -ne "${dl[1]}\n out=${dl[2]}\n" >> "$tmp"
    done

    downloader --input-file="$tmp"
else
    url="${1}"; dl=($(zippyget "${url}"));
    [ "${dl[0]}" != 'pass' ] && echo "Could not download from '${url}', maybe the file does not exist?" && exit 1 || downloader "${dl[1]}" --out="$(urldecode "${dl[2]}")"
fi

echo -e "\033[1K"
