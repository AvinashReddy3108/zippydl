## zippyshare.sh
### bash script for downloading zippyshare files

##### Download single file from zippyshare

    sh zippyshare.sh url

##### Batch-download files from URL list:

    sh zippyshare.sh url-list.txt     # url-list.txt must contain one zippyshare.com url per line

Example:

    sh zippyshare.sh http://www12.zippyshare.com/v/3456789/file.html  

zippyshare.sh uses wget with the `--continue` flag which may resume a partially downloaded file. When batch-downloading, wget will skip over completed files, and attempt to resume partially downloaded files.
