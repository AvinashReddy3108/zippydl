#!/bin/bash
# @Description: zippyshare.com file batch download script
# @Author: Live2x
# @URL: live2x.com
# @Version: 1.0
# @Date: 2014/10/27
# @Usage: sh zippy.sh filelist.txt

if [ -s filelist.txt ]; then

    i=1
    sum=`sed -n '$=' filelist.txt`

    while read line
    do
        arr[$i]="$line"
        i=`expr $i + 1`
    done < filelist.txt

    i=1
    for i in `seq $sum` ;do 
      sh zippyshare.sh ${arr[i]}
    done
else
    touch filelist.txt
    echo "Can't find download link."
    exit 1;
fi
