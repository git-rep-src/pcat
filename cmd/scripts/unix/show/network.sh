# os:0
# raw:0
# one:1
# out:1
export LC_ALL=C
TMP=""
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
array () {
  for i in "$@" ; do
    printf '%s\n' "$i" | array_element_encode
  done
}
array_nth () {
  printf '%d' "$1" >/dev/null 2>&1 \
    && awk -v i="$1" '
        BEGIN { code=1 }
        NR == i + 1 { print $0; code=0 }
        END { exit code }
      ' \
    | array_element_decode
}
array_element_encode() {
  sed 's/%/%25/g' | sed -e :a -e '$!N; s/\n/%0A/; ta'
}
array_element_decode() {
  sed -e 's/%0[aA]//g' -e 's/%25/%/g'
}
PORTS=$(
array\
 21\
 22\
 23\
 25\
 53\
 80\
 110\
 143\
 443\
 993\
 995\
 3306\
 8080\
 9050
)
xml "OPEN" "DATA type='show' name='network' namemax='7'"
xml "OPEN" "PUBLIC"
if [ "$1" = "bsd" ]; then
    RET=$(fetch --no-verify-peer --no-verify-hostname -qo- https://ipinfo.io/json 2>/dev/null | tr "," "\n" | tr -d '{"}')
else 
    RET=$(which wget 2>/dev/null)
    if [ $? -eq 0 ]; then
        RET=$(wget -T 25 -q -O - ipinfo.io/json 2>/dev/null | tr "," "\n" | tr -d '{"}')
    else
        RET=$(which curl 2>/dev/null)
        if [ $? -eq 0 ]; then
            RET=$(curl --connect-timeout 25 -s ipinfo.io/json 2>/dev/null | tr "," "\n" | tr -d '{"}')
        fi
    fi
fi
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    IP=$(echo "$RET" | grep -m 1 -E "ip" | cut -d ":" -f2- | sed -e 's/^[[:space:]]*//')
    if [ -n "$IP" ] && [ $? -eq 0 ]; then
        xml "IP" "$IP"
    else
        xml "IP" "N/A"
    fi
    CITY=$(echo "$RET" | grep -E "city" | cut -d ":" -f2- | sed -e 's/^[[:space:]]*//')
    if [ -n "$CITY" ] && [ $? -eq 0 ]; then
        xml "CITY" "$CITY"
    else
        xml "CITY" "N/A"
    fi
    REGION=$(echo "$RET" | grep -E "region" | cut -d ":" -f2- | sed -e 's/^[[:space:]]*//')
    if [ -n "$REGION" ] && [ $? -eq 0 ]; then
        xml "REGION" "$REGION"
    else
        xml "REGION" "N/A"
    fi
    COUNTRY=$(echo "$RET" | grep -E "country" | cut -d ":" -f2- | sed -e 's/^[[:space:]]*//')
    if [ -n "$COUNTRY" ] && [ $? -eq 0 ]; then
        xml "COUNTRY" "$COUNTRY"
    else
        xml "COUNTRY" "N/A"
    fi
else
    xml "IP" "N/A"
    xml "CITY" "N/A"
    xml "REGION" "N/A"
    xml "COUNTRY" "N/A"
fi
xml "CLOSE" "PUBLIC"
xml "OPEN" "LOCAL"
if [ "$1" = "bsd" ]; then
    RET=$(which ifconfig 2>/dev/null)
    if [ $? -eq 0 ]; then
        RET=$(ifconfig 2>/dev/null | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sed -n 1p)
    fi
else
    RET=$(which ip 2>/dev/null)
    if [ $? -eq 0 ]; then
        RET=$(ip a s 2>/dev/null | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
    else
        RET=$(which ifconfig 2>/dev/null)
        if [ $? -eq 0 ]; then
            RET=$(ifconfig 2>/dev/null | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sed -n 1p)
        fi
    fi
fi
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "IP" "$RET"
else
    xml "IP" "N/A"
fi
if [ "$1" = "bsd" ]; then
    RET=$(which netstat 2>/dev/null)
    if [ $? -eq 0 ]; then
        TMP="netstat"
    fi
else
    RET=$(which ss 2>/dev/null)
    if [ $? -eq 0 ]; then
        TMP="ss"
    else
        RET=$(which netstat 2>/dev/null)
        if [ $? -eq 0 ]; then
            TMP="netstat"
        fi
    fi
fi
if [ -n "$TMP" ]; then
    if echo "$TMP" | grep -q "ss"; then
        RET=$(ss -4Hnl 2>/dev/null | grep LISTEN | sed 's/\s\s*/ /g' | cut -d " " -f5)
    else
        if [ "$1" = "bsd" ]; then
            RET=$(netstat -4anp tcp udp 2>/dev/null | grep LISTEN | sed 's/\( \)*/\1/g' | cut -d " " -f4)
        else
            RET=$(netstat -4tuln 2>/dev/null | grep LISTEN | sed 's/\s\s*/ /g' | cut -d " " -f4)
        fi
    fi
    if [ -n "$RET" ] && [ $? -eq 0 ]; then
        i=0
        while [ "$i" -lt 14 ]; do
            PORT=$(printf '%s\n' "$PORTS" | array_nth "$i")
            OUT=$(echo "$RET" | grep -w "$PORT")
            if [ -n "$OUT" ]; then
                OPEN="$OPEN$OUT (open)\n"
            fi
            i=$(( i + 1 ))
        done
    fi
    if [ -n "$OPEN" ]; then
        xml "PORTS" "$OPEN"
    else
        xml "PORTS" "*:* (closed)\n"
    fi
else
    xml "PORTS" "N/A"
fi
if [ "$1" = "bsd" ]; then
    if echo "$TMP" | grep -q "netstat"; then
        RET=$(netstat -4rn 2>/dev/null | grep default | sed 's/\( \)*/\1/g' | cut -d " " -f2)
    else
        RET=""
    fi
else
    RET=$(which ip 2>/dev/null)
    if [ $? -eq 0 ]; then
        RET=$(ip r s 2>/dev/null | grep -Eo 'default via ([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')
    else
        RET=$(which route 2>/dev/null)
        if [ $? -eq 0 ]; then
            RET=$(route -n 2>/dev/null | grep 'UG[ \t]' | awk '{print $2}')
        fi
    fi
fi
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "GATEWAY" "$RET"
else
    xml "GATEWAY" "N/A"
fi
RET=$(grep -E -v "(^#.*|^$)" /etc/resolv.conf 2>/dev/null | grep "nameserver" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "DNS" "$RET"
else
    xml "DNS" "N/A"
fi
xml "CLOSE" "LOCAL"
xml "OPEN" "SOCKETS"
if [ -n "$TMP" ]; then
    if echo "$TMP" | grep -q "ss"; then
        RET=$(ss -tan 2>/dev/null)
    else
        if [ "$1" = "bsd" ]; then
            RET=$(netstat -4anp tcp 2>/dev/null)
        else
            RET=$(netstat -tan 2>/dev/null)
        fi
    fi
    if [ -n "$RET" ] && [ $? -eq 0 ]; then
        xml "TCP" "$RET"
    else
        xml "TCP" "N/A"
    fi
    if echo "$TMP" | grep -q "ss"; then
        RET=$(ss -uan 2>/dev/null)
    else
        if [ "$1" = "bsd" ]; then
            RET=$(netstat -4anp udp 2>/dev/null)
        else
            RET=$(netstat -uan 2>/dev/null)
        fi
    fi
    if [ -n "$RET" ] && [ $? -eq 0 ]; then
        xml "UDP" "$RET"
    else
        xml "UDP" "N/A"
    fi
else
    xml "TCP" "N/A"
    xml "UDP" "N/A"
fi
xml "CLOSE" "SOCKETS"
xml "CLOSE" "DATA"
printf %b "$BUF [CMD-EOF]"
