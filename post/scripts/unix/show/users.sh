BUF=""
RET=""
TMP=""
USERNAME=""
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
xml "OPEN" "DATA name='users' maxlen='6'"
xml "OPEN" "EFFECTIVE"
RET=$(id -un 2>/dev/null)
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    USERNAME=$RET
else
    RET=$(who 2>/dev/null | awk '{print $1}')
    if [ -n "$RET" ] && [ $? -eq 0 ]; then
        USERNAME=$RET
    fi
fi
if [ -n "$USERNAME" ]; then
    xml "NAME" "$USERNAME"
else
    xml "NAME" "N/A"
fi
RET=$(id -ur 2>/dev/null)
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "UID" "$RET"
else
    xml "UID" "N/A"
fi
RET=$(id -gn 2>/dev/null)
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    TMP=$RET
    xml "GROUP" "$RET"
else
    xml "GROUP" "N/A"
fi
if [ -n "$TMP" ]; then
    RET=$(id -Gn 2>/dev/null | sed "s/$TMP //g")
else
    RET=$(id -Gn 2>/dev/null)
fi
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "SGROUP" "$RET"
else
    xml "SGROUP" "N/A"
fi
if [ -n "$USERNAME" ]; then
    RET=$(awk -F: '($1 == "'"$USERNAME"'") {print $7}' /etc/passwd 2>/dev/null)
    if [ -n "$RET" ] && [ $? -eq 0 ]; then
        xml "SHELL" "$RET"
    else
        xml "SHELL" "N/A"
    fi
else
    xml "SHELL" "N/A"
fi
if [ -n "$USERNAME" ]; then
    RET=$(grep -v -E "^#" /etc/passwd 2>/dev/null | awk -F: '$3 == 0 {print $1}')
    if [ -n "$RET" ] && [ $? -eq 0 ]; then
        if echo "$RET" | grep -q "$USERNAME"; then
            xml "ROOT" "Yes"
            BOOL="TRUE"
        else
            RET=$(id -u 2>/dev/null)
            if [ "$RET" = "0" ] && [ $? -eq 0 ]; then
                xml "ROOT" "Yes (using su or sudo)"
                BOOL="TRUE"
            else
                xml "ROOT" "No"
            fi
        fi
    else
        xml "ROOT" "N/A"
    fi
else
    xml "ROOT" "N/A"
fi
if [ "$BOOL" = "TRUE" ]; then
    xml "SUDO" " "
else
    if [ -n "$USERNAME" ]; then
        sudo -K >/dev/null 2>&1
        RET=$(sudo -nu "$USERNAME" sudo -nv 2>&1)
        if echo "$RET" | grep -q "sudo:"; then
            RET=$(sudo -n ls >/dev/null 2>&1)
            if [ $? -eq 0 ]; then
                xml "SUDO" "Yes (no password)"
            else
                xml "SUDO" "Yes (password)"
            fi
        elif echo "$RET" | grep -q "Sorry"; then
            xml "SUDO" "Yes (limited)"
        else
            xml "SUDO" "No"
        fi
    else
        xml "SUDO" "N/A"
    fi
fi
if [ -n "$USERNAME" ]; then
    RET=$(awk -v FS=':' -v var="$USERNAME" '($1 == var) {print $6}' "/etc/passwd" 2>/dev/null)
    if [ -n "$RET" ] && [ $? -eq 0 ]; then
        xml "HOME" "$RET"
    else
        xml "HOME" "N/A"
    fi
else
    xml "HOME" "N/A"
fi
RET=$(echo "$PATH" 2>/dev/null)
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "PATH" "$RET"
else
    xml "PATH" "N/A"
fi
RET=$(env 2>/dev/null | grep -v 'LESSOPEN\|LESSCLOSE\|LS_COLORS\|OLDPWD\|USER\|PWD\|HOME\|SHELL\|LOGNAME\|PATH\|COLORTERM\|/usr/bin/env' | sed -r 's/=/: /')
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "ENV" "$RET"
else
    xml "ENV" "N/A"
fi
xml "CLOSE" "EFFECTIVE"
TMP=$(cat /etc/login.defs 2>/dev/null | grep "^UID_MIN" | sed 's/\s\+/,/g' | cut -d "," -f2)
if [ -z "$TMP" ] || [ $? -ne 0 ]; then
    TMP=1000
fi
RET=$(awk -v var="$TMP" -F: '($3 >= var) && ($1 != "nobody") {print "<NAME>"$1"</NAME>\n" "<SHELL>"$7"</SHELL>\n"}' /etc/passwd 2>/dev/null)
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "NORMAL" "$RET"
else
    xml "OPEN" "NORMAL"
    xml "NONE" "N/A"
    xml "CLOSE" "NORMAL"
fi
RET=$(grep -v -E "^#" /etc/passwd 2>/dev/null | awk -F: '$3 == 0 {print "<NAME>"$1"</NAME>\n" "<SHELL>"$7"</SHELL>\n"}')
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "ROOT" "$RET"
else
    xml "OPEN" "ROOT"
    xml "NONE" "N/A"
    xml "CLOSE" "ROOT"
fi
RET=$(awk -v var="$TMP" -F: '($3 < var) {print "<NAME>"$1"</NAME>\n" "<SHELL>"$7"</SHELL>\n"}' /etc/passwd 2>/dev/null)
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "SYSTEM" "$RET"
else
    xml "OPEN" "SYSTEM"
    xml "NONE" "N/A"
    xml "CLOSE" "SYSTEM"
fi
xml "OPEN" "LOGGED-ON"
RET=$(who -H 2>/dev/null)
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "NONE" "$RET"
else
    xml "NONE" "N/A"
fi
xml "CLOSE" "LOGGED-ON"
xml "CLOSE" "DATA"
printf %b "$BUF [POST-EOS]"
