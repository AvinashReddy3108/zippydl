#!/bin/bash
# @Description: zippyshare.com file download script
# @Author: Live2x
# @URL: live2x.com
# @Version: 1.0.20150120
# @Date: 2015/01/20
# @Usage: sh zippyshare.sh filename


if [ -z "$1" ]; then
    echo usage: $0 filename
    exit
fi

if [ -f "$1" ]; then
  rm -rf $1
fi

if [ -f "cookie.txt" ]; then
  rm -rf cookie.txt
fi

wget -O info.txt $1 --cookies=on --keep-session-cookies --save-cookies=cookie.txt --quiet

if [ -f "cookie.txt" ]; then 
    jsessionid=`cat cookie.txt | grep "JSESSIONID" | cut -f7`
    #echo "JSESSIONID="$jsessionid
else
    echo "can't find cookie file"
    exit
fi

if [ -f "info.txt" ]; then
    #a=`cat info.txt | grep "var a =" | cut -d'=' -f2 | cut -d';' -f1 | grep -o "[^ ]\+\(\+[^ ]\+\)*"`
    x1=`cat info.txt | grep "var a =" | cut -d'=' -f2 | cut -d';' -f1 | cut -d'%' -f1 | grep -o "[^ ]\+\(\+[^ ]\+\)*"`
    x2=`cat info.txt | grep "var a =" | cut -d'=' -f2 | cut -d';' -f1 | cut -d'%' -f2 | grep -o "[^ ]\+\(\+[^ ]\+\)*"`
    #echo "a="$x1%$x2

    #filename=`cat info.txt | grep "property=\"og:title\"" | cut -d'"' -f4 | grep -o "[^ ]\+\(\+[^ ]\+\)*"`
    filename=`cat info.txt | grep "b+18" | head -n 1 | cut -d'/' -f5 | cut -d'"' -f1`
    #echo "filename="$filename
    if [ -z $filename ]; then
      filename=`cat info.txt | grep "/d/" | cut -d'/' -f5 | cut -d'"' -f1`
    fi
    
reffer=`cat info.txt | grep "property=\"og:url\"" | cut -d'"' -f4 | grep -o "[^ ]\+\(\+[^ ]\+\)*"`
    #echo "reffer="$reffer

    server=`echo "$reffer" | cut -d'/' -f3`
    #echo "server="$server

    id=`echo "$reffer" | cut -d'/' -f5`
    #echo "id="$id
else
    echo "can't find info file"
    exit
fi

if [ $x1 == $x2 ]; then
  if [ $x1 -gt 0 ]; then
    a=$[(x1+3)]
    x1=`cat info.txt | grep $a | head -n 1 | cut -d'%' -f2 | cut -d';' -f1`
    b=$[(a%x1)*(a%3)]
  fi
else
  a=$[(x1%x2)]
fi
#echo "a="$a

x=`cat info.txt | grep "/d/" | head -n 1 | cut -d'/' -f4 | cut -d'+' -f2 | cut -d'+' -f1`
if [ "$x" != "a" ]; then
  x=`cat info.txt | grep "/d/" | head -n 1 | cut -d'/' -f4 | cut -d'+' -f2-3`
  a=$[x]
  #a=$[x-1]
  #echo -e "\033[31m Zippyshare.com algorithm changed, please update script! \033[0m"
  #exit
fi 

dl="http://"$server"/d/"$id"/"$a"/"$filename
#echo $dl

agent="Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36"

echo -ne "\033[33m $filename download start...      \033[0m"
wget -c -O $filename $dl \
--referer='$reffer' \
--cookies=off --header "Cookie: JSESSIONID=$jsessionid" \
--user-agent='$agent' \
--progress=dot \
2>&1 \
| grep --line-buffered "%" | sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b\b\b\b[\033[36m%4s\033[0m ]", $2)}'
echo -ne "\b\b\b\b\b\b\b"
echo -e "[\033[32m Done \033[0m]"

rm -rf cookie.txt
rm -rf info.txt

if [ -s $filename ]; then
    echo -e "\033[32m Download success! \033[0m"
else
    rm -rf ${filename}
    echo -e "\033[31m Download error! \033[0m"
fi
