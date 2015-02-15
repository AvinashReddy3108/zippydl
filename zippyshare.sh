#!/bin/bash
# @Description: zippyshare.com file download script
# @Author: Live2x
# @URL: live2x.com
# @Version: 1.0.20150216
# @Date: 2015/02/16
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

# Get cookie
if [ -f "cookie.txt" ]; then 
    jsessionid=`cat cookie.txt | grep "JSESSIONID" | cut -f7`
    #echo "JSESSIONID="$jsessionid
else
    echo "can't find cookie file"
    exit
fi

if [ -f "info.txt" ]; then
    # Get url algorithm
    a=`cat info.txt | grep "/d/" | head -n 1 | cut -d'/' -f4 | cut -d'(' -f2 | cut -d')' -f1`

    # Variables string to array
    read -a arr <<<$a

    # Get variable array
    for ((i=0;i<${#arr[@]};i+=2))
    do
      param[(i/2)]=${arr[i]}
    done

    # Number of variable 
    #echo ${#param[@]}

    for ((i=0;i<${#param[@]};i++))
    do

      if [[ ${param[i]} != *[!0-9]* ]]; then
	x = ${param[i]}
      else
        if [[ $i < 3 ]]; then
          x=`cat info.txt | grep "var ${param[i]} =" | head -n 1 | cut -d'=' -f2 | cut -d';' -f1`
        else
          x=`cat info.txt | grep "var ${param[i]} =" | tail -n 1 | cut -d'=' -f2 | cut -d';' -f1`
        fi
      fi

      if [[ $x != *[!0-9]* ]]; then
	vi[i]=$x
      else
        v[i]=$((x))
      fi
    done

    ret=${v[0]}

    for ((i=0;i<${#param[@]};i+=1))
    do
      ret="$ret${arr[2*i+1]}${v[i+1]}"
    done

    a=$((ret))
    #echo "a="$a

    # Get server, filename, id, reffer
    filename=`cat info.txt | grep "/d/" | cut -d'/' -f5 | cut -d'"' -f1`
    #echo "filename="$filename
    
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

if [[ $a != *[!0-9]* ]]; then
  # Build download url
  dl="http://"$server"/d/"$id"/"$a"/"$filename
  #echo $dl

  # Set brower agent
  agent="Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36"

  # Start download file
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

  if [[ -s $filename ]]; then
    echo -e "\033[32m Download success! \033[0m"
  else
    rm -rf ${filename}
    echo -e "\033[31m Download error! \033[0m"
  fi
else
  # Download url error
  echo -e "\033[31m Zippyshare.com algorithm changed, please update script! \033[0m"
fi

rm -rf cookie.txt
rm -rf info.txt
