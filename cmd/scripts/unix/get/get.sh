# os:0
# raw:0
# one:1
# out:1
export LC_ALL=C
URL=""
BOOL="FALSE"
BUF=""
xml()
{
    if [ "$1" = "OPEN" ]; then
        BUF="$BUF<$2>"
    elif [ "$1" = "CLOSE" ]; then
        BUF="$BUF</$2>"
    else
        BUF="$BUF<$1>$2</$1>"
    fi
}
xml "OPEN" "DATA type='get' name='get'"
xml "OPEN" "GET"
if [ "$1" = "bsd" ]; then
    if [ "$2" = "tools" ]; then
        URL="https://github.com/git-rep-src/pcat-packages/blob/master/tools/bsd/tools.tar.gz?raw=true"
        DIR="$3/tools"
    elif [ "$2" = "exploits" ]; then
        URL="https://github.com/git-rep-src/pcat-packages/blob/master/exploits/unix/exploits.tar.gz?raw=true"
        DIR="$3/exploits"
    fi
    $(fetch --no-verify-peer --no-verify-hostname -qo- "$URL" 2>/dev/null | tar -xzf- -C "$3")
    if [ -d "$DIR" ]; then
        BOOL="TRUE"
    fi
else
    if [ "$2" = "tools" ]; then
        URL="https://github.com/git-rep-src/pcat-packages/blob/master/tools/linux/tools.tar.gz?raw=true"
    elif [ "$2" = "exploits" ]; then
        URL="https://github.com/git-rep-src/pcat-packages/blob/master/exploits/unix/exploits.tar.gz?raw=true"
    fi
    $(wget --no-check-certificate --max-redirect 100 -qO- "$URL" 2>/dev/null | tar -xz -C "$3")
    if [ $? -eq 0 ]; then
        BOOL="TRUE"
    else
        $(curl -sL "$URL" 2>/dev/null | tar -xz -C "$3")
        if [ $? -eq 0 ]; then
            BOOL="TRUE"
        fi
    fi
fi
if [ "$BOOL" = "TRUE" ]; then
    xml "STATUS" "SUCCESS"
else
    xml "STATUS" "FAIL"
fi
xml "CLOSE" "GET"
xml "CLOSE" "DATA"
printf %b "$BUF [CMD-EOF]"
