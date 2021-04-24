BUF=""
URL=""
BOOL="FALSE"
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
xml "OPEN" "DATA name='pull'"
xml "OPEN" "PULL"
if [ "$1" = "bsd" ]; then
    if [ "$2" = "tools" ]; then
        URL=""
    else
        URL=""
    fi
    $(fetch --no-verify-peer --no-verify-hostname -qo- "$URL" 2>/dev/null | tar -xzf- -C "$3")
    if [ $? -eq 0 ]; then
        BOOL="TRUE"
    fi
else
    if [ "$2" = "tools" ]; then
        URL="https://github.com/git-rep-src/pcat-packages/blob/master/tools/linux/tools.tar.gz?raw=true"
    else
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
xml "CLOSE" "PULL"
xml "CLOSE" "DATA"
printf %b "$BUF [POST-EOS]"
