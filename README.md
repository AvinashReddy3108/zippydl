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
./zippyshare.sh https://www12.zippyshare.com/v/3456789/file.html  
```

zippyshare.sh uses `wget` with the `--continue` flag, which skips over completed files and attempts to  resume partially downloaded files.

### Requirements: `coreutils`, `grep`, `sed`, `awk`, **`wget`**
