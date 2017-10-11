#!/bin/bash
# @Description: zippyshare.com file download script
# @Author: Live2x
# @URL: https://github.com/img2tab/zippyshare
# @Version: 1.0.201710111133
# @Date: 2017/10/11
# @Usage: sh zippyshare.sh url

if [ -z "${1}" ]; then
    echo "usage: ${0} url"
    echo "batch usage: ${0} url-list.txt"
    echo "url-list.txt is a file that contains one zippyshare.com url per line"
    exit
fi

function zippydownload()
{
    prefix="$( echo -n "${url}" | cut -c "11,12,31-38" | sed -e 's/[^A-z0-9]//g' )"
    cookiefile="${prefix}-cookie.tmp"
    infofile="${prefix}-info.tmp"

    if [ -f "${cookiefile}" ]; then
      rm -f "${cookiefile}"
    fi

    wget -O "${infofile}" "${url}" \
    --cookies=on \
    --keep-session-cookies \
    --save-cookies="${cookiefile}" \
    --quiet

    # Get cookie
    if [ -f "${cookiefile}" ]; then 
        jsessionid="$( cat "${cookiefile}" | grep "JSESSIONID" | cut -f7)"
    else
        echo "can't find cookie file for ${prefix}"
        exit
    fi

    if [ -f "${infofile}" ]; then
        # Get url algorithm
        algorithm="$( cat "${infofile}" | grep -E "dlbutton(.*)\/d\/(.*)" | head -n 1 | cut -d'/' -f4 | cut -d'(' -f2 | cut -d')' -f1 )"

        a="$( echo $(( ${algorithm} )) )"

        # Get server, filename, id, ref
        filename="$( cat "${infofile}" | grep "/d/" | cut -d'/' -f5 | cut -d'"' -f1 | grep -o "[^ ]\+\(\+[^ ]\+\)*" )"
        
        ref="$( cat "${infofile}" | grep 'property="og:url"' | cut -d'"' -f4 | grep -o "[^ ]\+\(\+[^ ]\+\)*" )"

        server="$( echo "${ref}" | cut -d'/' -f3 )"

        id="$( echo "${ref}" | cut -d'/' -f5 )"
    else
        echo "can't find info file for ${prefix}"
        exit
    fi

    # Build download url
    dl="http://${server}/d/${id}/${a}/${filename}"

    # Set brower agent
    agent="Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36"

    # Start download file
    wget -c -O "${filename}" "${dl}" \
    -q --show-progress \
    --referer="${ref}" \
    --cookies=off --header "Cookie: JSESSIONID=${jsessionid}" \
    --user-agent="${agent}"

    rm -f "${cookiefile}"
    rm -f "${infofile}"
}

if [ -f "${1}" ]
then
    for url in $( cat "${1}" | grep 'zippyshare.com' ); do zippydownload "${url}"; done
else
    url="${1}"
    zippydownload "${url}"
fi
