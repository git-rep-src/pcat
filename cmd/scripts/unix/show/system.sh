# os:0
# raw:0
# one:1
# out:1
export LC_ALL=C
TMP=""
BOOL="FALSE"
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
xml "OPEN" "DATA type='show' name='system' namemax='8'"
xml "OPEN" "HOST"
RET=$(hostname 2>/dev/null)
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "NAME" "$RET"
else
    xml "NAME" "N/A"
fi
RET=$(uname -o 2>/dev/null)
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "OS" "$RET"
else
    xml "OS" "N/A"
fi
RET=$(uname -sr 2>/dev/null)
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "KERNEL" "$RET"
else 
    xml "KERNEL" "N/A"
fi
RET=$(uname -m 2>/dev/null)
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "ARCH" "$RET"
else
    xml "ARCH" "N/A"
fi
if [ "$1" = "linux" ]; then
    RET=$(awk '/^NAME=/' /etc/*-release 2>/dev/null | awk -F '=' '{gsub(/"/, "", $2); print $2}' | tr -d "\n")
    if [ -n "$RET" ] && [ $? -eq 0 ]; then
        VERSION=$(awk '/^VERSION=/' /etc/*-release 2>/dev/null | awk -F '=' '{gsub(/"/, "", $2); print $2}')
        if [ -n "$RET" ] && [ $? -eq 0 ]; then
            xml "DISTRO" "$RET $VERSION"
        else
            xml "DISTRO" "$RET"
        fi
    else
        xml "DISTRO" "N/A"
    fi
fi
RET=$(ls -l /sbin/init 2>/dev/null)
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    if echo "$RET" | grep -q "systemd"; then
        TMP="Systemd"
    elif echo "$RET" | grep -q "upstart"; then
        TMP="Upstart"
    elif echo "$RET" | grep -q "runit"; then
        TMP="Runit"
    elif echo "$RET" | grep -q "sysv"; then
        TMP="System V"
    elif echo "$RET" | grep -q "init"; then
        TMP="Init"
    fi
    if [ -n "$TMP" ]; then
        xml "INIT" "$TMP"
    else
        xml "INIT" "N/A"
    fi
else
    xml "INIT" "N/A"
fi
if [ "$1" = "linux" ]; then
    if [ -n "$TMP" ]; then
        if [ "$TMP" = "Systemd" ]; then
            RET=$(systemctl get-default 2>/dev/null)
        else
            RET=$(runlevel 2>/dev/null)
        fi
        if [ -n "$RET" ] && [ $? -eq 0 ]; then
            xml "RUNLEVEL" "$RET"
        else
            xml "RUNLEVEL" "N/A"
        fi
    else
        xml "RUNLEVEL" "N/A"
    fi
fi
if [ "$1" = "bsd" ]; then
    RET=$(dmesg | grep -i vbox 2>/dev/null)
    if [ $? -eq 0 ]; then
        xml "VBOX" "Yes"
    else 
        xml "VBOX" "No"
    fi
else
    RET=$(grep -q "^flags.*hypervisor" /proc/cpuinfo 2>/dev/null)
    if [ $? -eq 0 ]; then
        xml "VBOX" "Yes"
    else 
        xml "VBOX" "No"
    fi
fi
RET=$(grep -i docker /proc/self/cgroup 2>/dev/null)
if [ $? -eq 0 ]; then
    xml "DOCKER" "Yes"
else 
    xml "DOCKER" "No"
fi
RET=$(grep -qa container=lxc /proc/1/environ 2>/dev/null)
if [ $? -eq 0 ]; then
    xml "LXC" "yes"
else 
    xml "LXC" "No"
fi
if [ "$1" = "bsd" ]; then
    RET=$(uptime 2>/dev/null)
else
    RET=$(uptime -p 2>/dev/null)
fi
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "UPTIME" "$RET"
else
    xml "UPTIME" "N/A"
fi
xml "CLOSE" "HOST"
xml "OPEN" "STORAGE"
if [ "$1" = "bsd" ]; then
    RET=$(which df 2>/dev/null)
    if [ $? -eq 0 ]; then
        RET=$(df -ht notmpfs 2>/dev/null)
        if [ -n "$RET" ] && [ $? -eq 0 ]; then
            xml "NONE" "$RET"
        else
            xml "NONE" "N/A"
        fi
    else
        xml "NONE" "N/A"
    fi
else
    RET=$(which lsblk 2>/dev/null)
    if [ $? -eq 0 ]; then
        LC_ALL=
        RET=$(lsblk -fm 2>/dev/null)
        if [ -n "$RET" ] && [ $? -eq 0 ]; then
            xml "NONE" "$RET"
        else
            xml "NONE" "N/A"
        fi
        LC_ALL=C
    else
        RET=$(which df 2>/dev/null)
        if [ $? -eq 0 ]; then
            RET=$(df -hx tmpfs 2>/dev/null)
            if [ -n "$RET" ] && [ $? -eq 0 ]; then
                xml "NONE" "$RET"
            else
                xml "NONE" "N/A"
            fi
        else
            xml "NONE" "N/A"
        fi
    fi
fi
xml "CLOSE" "STORAGE"
xml "OPEN" "DEV"
RET=$(which gcc 2>/dev/null)
if [ $? -eq 0 ]; then
    xml "GCC" "$RET"
else
    xml "GCC" "No"
fi
RET=$(which python 2>/dev/null)
if [ $? -eq 0 ]; then 
    TMP="$RET"
    BOOL="TRUE"
fi
RET=$(which python2 2>/dev/null)
if [ $? -eq 0 ]; then
    if [ "$BOOL" = "TRUE" ]; then
        TMP="$TMP\n$RET"
    else
        TMP="$RET"
        BOOL="TRUE"
    fi
fi
RET=$(which python2.7 2>/dev/null)
if [ $? -eq 0 ]; then
    if [ "$BOOL" = "TRUE" ]; then
        TMP="$TMP\n$RET"
    else
        TMP="$RET"
        BOOL="TRUE"
    fi
fi
RET=$(which python3 2>/dev/null)
if [ $? -eq 0 ]; then
    if [ "$BOOL" = "TRUE" ]; then
        TMP="$TMP\n$RET"
    else
        TMP="$RET"
        BOOL="TRUE"
    fi
fi
RET=$(which python3.6 2>/dev/null)
if [ $? -eq 0 ]; then
    if [ "$BOOL" = "TRUE" ]; then
        TMP="$TMP\n$RET"
    else
        TMP="$RET"
        BOOL="TRUE"
    fi
fi
RET=$(which python3.7 2>/dev/null)
if [ $? -eq 0 ]; then
    if [ "$BOOL" = "TRUE" ]; then
        TMP="$TMP\n$RET"
    else
        TMP="$RET"
        BOOL="TRUE"
    fi
fi
if [ "$BOOL" = "TRUE" ]; then
    xml "PYTHON" "$TMP"
    BOOL="FALSE"
else
    xml "PYTHON" "No"
fi
RET=$(which perl 2>/dev/null)
if [ $? -eq 0 ]; then
    xml "PERL" "$RET"
else
    xml "PERL" "No"
fi
RET=$(which ruby 2>/dev/null)
if [ $? -eq 0 ]; then
    xml "RUBY" "$RET"
else
    xml "RUBY" "No"
fi
xml "CLOSE" "DEV"
xml "OPEN" "TOOLS"
RET=$(which wget 2>/dev/null)
if [ $? -eq 0 ]; then
    xml "WGET" "$RET"
else
    xml "WGET" "No"
fi
RET=$(which curl 2>/dev/null)
if [ $? -eq 0 ]; then
    xml "CURL" "$RET"
else
    xml "CURL" "No"
fi
RET=$(which git 2>/dev/null)
if [ $? -eq 0 ]; then
    xml "GIT" "$RET"
else
    xml "GIT" "No"
fi
RET=$(which ftp 2>/dev/null)
if [ $? -eq 0 ]; then
    xml "FTP" "$RET"
else
    xml "FTP" "No"
fi
RET=$(which telnet 2>/dev/null)
if [ $? -eq 0 ]; then
    xml "TELNET" "$RET"
else
    xml "TELNET" "No"
fi
RET=$(which ssh 2>/dev/null)
if [ $? -eq 0 ]; then 
    TMP="$RET"
    BOOL="TRUE"
fi;
RET=$(which sshd 2>/dev/null)
if [ $? -eq 0 ]; then
    if [ "$BOOL" = "TRUE" ]; then
        TMP="$TMP\n$RET"
    else
        TMP="$RET"
        BOOL="TRUE"
    fi
fi
if [ "$BOOL" = "TRUE" ]; then
    xml "SSH" "$TMP"
    BOOL="FALSE"
else
    xml "SSH" "No"
fi
RET=$(which nc 2>/dev/null)
if [ $? -eq 0 ]; then 
    TMP="$RET"
    BOOL="TRUE"
fi
RET=$(which nc.traditional 2>/dev/null)
if [ $? -eq 0 ]; then
    if [ "$BOOL" = "TRUE" ]; then
        TMP="$TMP\n$RET"
    else
        TMP="$RET"
        BOOL="TRUE"
    fi
fi
RET=$(which nc.openbsd 2>/dev/null)
if [ $? -eq 0 ]; then
    if [ "$BOOL" = "TRUE" ]; then
        TMP="$TMP\n$RET"
    else
        TMP="$RET"
        BOOL="TRUE"
    fi
fi
RET=$(which ncat 2>/dev/null)
if [ $? -eq 0 ]; then
    if [ "$BOOL" = "TRUE" ]; then
        TMP="$TMP\n$RET"
    else
        TMP="$RET"
        BOOL="TRUE"
    fi
fi
RET=$(which netcat 2>/dev/null)
if [ $? -eq 0 ]; then
    if [ "$BOOL" = "TRUE" ]; then
        TMP="$TMP\n$RET"
    else
        TMP="$RET"
        BOOL="TRUE"
    fi
fi
if [ "$BOOL" = "TRUE" ]; then
    xml "NETCAT" "$TMP"
else
    xml "NETCAT" "No"
fi
RET=$(which socat 2>/dev/null)
if [ $? -eq 0 ]; then
    xml "SOCAT" "$RET"
else
    xml "SOCAT" "No"
fi
RET=$(which tcpdump 2>/dev/null)
if [ $? -eq 0 ]; then
    xml "TCPDUMP" "$RET"
else
    xml "TCPDUMP" "No"
fi
RET=$(which nmap 2>/dev/null)
if [ $? -eq 0 ]; then
    xml "NMAP" "$RET"
else
    xml "NMAP" "No"
fi
RET=$(which tar 2>/dev/null)
if [ $? -eq 0 ]; then
    xml "TAR" "$RET"
else
    xml "TAR" "No"
fi
RET=$(which vim 2>/dev/null)
if [ $? -eq 0 ]; then
    xml "VIM" "$RET"
else
    xml "VIM" "No"
fi
RET=$(which vi 2>/dev/null)
if [ $? -eq 0 ]; then
    xml "VI" "$RET"
else
    xml "VI" "No"
fi
xml "CLOSE" "TOOLS"
xml "CLOSE" "DATA"
printf %b "$BUF [CMD-EOF]"
