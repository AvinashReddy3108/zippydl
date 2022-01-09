## zippydl
### bash script for downloading zippyshare files

##### Download single file from zippyshare

```bash
./zippydl.sh url
```

##### Batch-download files from URL list (url-list.txt must contain one zippyshare.com url per line)

```bash
./zippydl.sh url-list.txt
```

##### Example:

```bash
./zippydl.sh https://www3.zippyshare.com/v/CDCi2wVT/file.html
```

zippydl uses `aria2c` with the `--continue=true` flag, which skips over completed files and attempts to resume partially downloaded files.

### Requirements: `aria2`, `curl`, `grep`, `awk`
