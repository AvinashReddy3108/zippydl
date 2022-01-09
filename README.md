## zippyshare.sh
### bash script for downloading zippyshare files

##### Download single file from zippyshare

```bash
./zippyshare.sh url
```

##### Batch-download files from URL list (url-list.txt must contain one zippyshare.com url per line)

```bash
./zippyshare.sh url-list.txt
```

##### Example:

```bash
./zippyshare.sh https://www3.zippyshare.com/v/CDCi2wVT/file.html
```

zippyshare.sh uses `aria2c` with the `--continue=true` flag, which skips over completed files and attempts to resume partially downloaded files.

### Requirements: `aria2c`, `curl`, `grep`, `awk`
