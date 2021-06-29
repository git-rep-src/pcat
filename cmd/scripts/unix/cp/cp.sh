# os:0
# raw:0
# one:1
# out:1
export LC_ALL=C
BUF=""
RET=""
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
xml "OPEN" "DATA type='cp' name='cp'"
xml "OPEN" "CP"
xml "FILEPATH" "$3"
if [ "$1" = "bsd" ]; then
    RET=$(uuencode -mr "$2" /dev/stdout | tr -d '\n\r')
    if [ -n "$RET" ] && [ $? -eq 0 ]; then
        xml "SRC" "$RET"
    else
        xml "STATUS" "FAIL"
    fi
else
    RET=$(cat "$2" | base64 -w0 2>/dev/null)
    if [ -n "$RET" ] && [ $? -eq 0 ]; then
        xml "SRC" "$RET"
    else
        xml "STATUS" "FAIL"
    fi
fi
xml "CLOSE" "CP"
xml "CLOSE" "DATA"
printf %b "$BUF [CMD-EOF]"
