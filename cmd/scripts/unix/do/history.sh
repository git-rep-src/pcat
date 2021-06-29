# os:0
# raw:0
# one:1
# out:1
export LC_ALL=C
HISTORY=""
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
xml "OPEN" "DATA type='do' name='history'"
xml "OPEN" "HISTORY"
if [ "$1" = "bsd" ]; then
    if [ "$2" = "on" ]; then
        # shell: ps -p $$ -ocomm=

        # sh: set history=8000 
        # csh: set history=8000
    elif [ "$2" = "off" ]; then
        # shell: ps -p $$ -ocomm=

        # sh: set history=0 
        # csh: set history=0

        # comprobar si existe el comando 'history'
        # history -c
    else
        xml "STATUS" "FAIL"
    fi
else
    RET=$(echo $HISTFILE 2>/dev/null)
    if [ -n "$RET" ] && [ $? -eq 0 ]; then
        HISTORY="$RET"
    else
        HISTORY="~/.bash_history"
    fi
    if [ "$2" = "on" ]; then
        # shell: ps -p $$ -ocomm=

        # sh: set history=8000 
        # dash: set history=8000
        # bash: set -o history 
        rm -f $HISTORY 2>/dev/null
        $(touch $HISTORY 2>/dev/null)
        if [ $? -ne 0 ]; then
            xml "STATUS" "FAIL"
        fi
    elif [ "$2" = "off" ]; then
        # shell: ps -p $$ -ocomm=

        # sh: set history=0 
        # dash: set history=0
        # bash: set +o history 

        # comprobar si existe el comando 'history'
        # history -c
        $(ln -sf /dev/null $HISTORY 2>/dev/null)
        if [ $? -ne 0 ]; then
            xml "STATUS" "FAIL"
        fi
    else
        xml "STATUS" "FAIL"
    fi
fi
xml "CLOSE" "HISTORY"
xml "CLOSE" "DATA"
printf %b "$BUF [CMD-EOF]"
