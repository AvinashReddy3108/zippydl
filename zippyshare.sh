#!/bin/bash
# @Description: zippyshare.com file download script
# @Author: Live2x
# @URL: live2x.com
# @Version: 1.0.201710111009
# @Date: 2017/10/11
# @Usage: sh zippyshare.sh url

if [ -z "$1" ]; then
    echo usage: $0 url
    echo batch usage: $0 url-list.txt
    echo file "url-list.txt" must have one url per line
    exit
fi

function zippydownload()
{
    if [ -f "cookie.txt" ]; then
      rm -f cookie.txt
    fi

    wget -O info.txt $1 \
    --cookies=on \
    --keep-session-cookies \
    --save-cookies=cookie.txt \
    --quiet

# Get cookie
    if [ -f "cookie.txt" ]; then 
        jsessionid=$(cat cookie.txt | grep "JSESSIONID" | cut -f7)
        #echo "JSESSIONID => "$jsessionid
    else
        echo "can't find cookie file"
        exit
    fi

    if [ -f "info.txt" ]; then
        # Get url algorithm
        algorithm=$(cat info.txt | grep -E "dlbutton(.*)\/d\/(.*)" | head -n 1 | cut -d'/' -f4 | cut -d'(' -f2 | cut -d')' -f1)
        #echo "algorithm => "$algorithm

        a=$(echo $(( ${algorithm} )) )

        # Get server, filename, id, reffer
        filename=$(cat info.txt | grep "/d/" | cut -d'/' -f5 | cut -d'"' -f1 | grep -o "[^ ]\+\(\+[^ ]\+\)*")
        #echo "filename => "$filename
        
        reffer=$(cat info.txt | grep "property=\"og:url\"" | cut -d'"' -f4 | grep -o "[^ ]\+\(\+[^ ]\+\)*")
        #echo "reffer => "$reffer

        server=`echo "$reffer" | cut -d'/' -f3`
        #echo "server => "$server

        id=`echo "$reffer" | cut -d'/' -f5`
        #echo "id => "$id
    else
        echo "can't find info file"
        exit
    fi

# Build download url
    dl="http://"$server"/d/"$id"/"$a"/"$filename
#echo "url => "$dl

# Set brower agent
    agent="Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36"

# Start download file
    echo -ne "\033[33m $filename download start...      \033[0m"
    wget -c -O $filename $dl \
    -q --show-progress \
    --referer='$reffer' \
    --cookies=off --header "Cookie: JSESSIONID=$jsessionid" \
    --user-agent='$agent'
    echo -e "[\033[32m Done \033[0m]"

    if [[ -s $filename ]]; then
        echo -e "\033[32m Download success! \033[0m"
    else
        rm -f ${filename}
        echo -e "\033[31m Download error! \033[0m"
    fi

    rm -f cookie.txt
    rm -f info.txt
}

if [ -f "$1" ]
then
    for line in $(cat "$1" | grep zippyshare\.com ); do zippydownload "${line}"; done
else
    zippydownload "${1}"
fi
