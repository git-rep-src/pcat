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
        URL="https://dev-files.blender.org/file/download/bwdp5reejwpkuh5i2oak/PHID-FILE-nui3bpuan4wdvd7yzjrs/sample.tar.gz"
    else
        URL="https://dev-files.blender.org/file/download/bwdp5reejwpkuh5i2oak/PHID-FILE-nui3bpuan4wdvd7yzjrs/sample.tar.gz"
    fi
    $(fetch --no-verify-peer --no-verify-hostname -qo- "$URL" 2>/dev/null | tar -xzf- -C "$3")
    if [ $? -eq 0 ]; then
        BOOL="TRUE"
    fi
else
    if [ "$2" = "tools" ]; then
        URL="https://dev-files.blender.org/file/download/bwdp5reejwpkuh5i2oak/PHID-FILE-nui3bpuan4wdvd7yzjrs/sample.tar.gz"
    else
        URL="https://dev-files.blender.org/file/download/bwdp5reejwpkuh5i2oak/PHID-FILE-nui3bpuan4wdvd7yzjrs/sample.tar.gz"
    fi
    $(wget -qO- "$URL" 2>/dev/null | tar -xz -C "$3")
    if [ $? -eq 0 ]; then
        BOOL="TRUE"
    else
        $(curl -s "$URL" 2>/dev/null | tar -xz -C "$3")
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
