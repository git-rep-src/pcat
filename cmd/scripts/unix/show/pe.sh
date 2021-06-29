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
LIST_FOLDERS=$(
array\
 "/root"\
 "/var/mail/root"\
 "/var/spool/mail/root"
)
READ_FILES=$(
array\
 "/etc/passwd"\
 "/etc/shadow"\
 "/etc/httpd/logs/access_log"\
 "/etc/httpd/logs/access.log"\
 "/etc/httpd/logs/error_log"\
 "/etc/httpd/logs/error.log"\
 "/var/log/apache2/access_log"\
 "/var/log/apache2/access.log"\
 "/var/log/apache2/error_log"\
 "/var/log/apache2/error.log"\
 "/var/log/apache/access_log"\
 "/var/log/apache/access.log"\
 "/var/log/auth.log"\
 "/var/log/chttp.log"\
 "/var/log/cups/error_log"\
 "/var/log/dpkg.log"\
 "/var/log/faillog"\
 "/var/log/httpd/access_log"\
 "/var/log/httpd/access.log"\
 "/var/log/httpd/error_log"\
 "/var/log/httpd/error.log"\
 "/var/log/lastlog"\
 "/var/log/lighttpd/access.log"\
 "/var/log/lighttpd/error.log"\
 "/var/log/lighttpd/lighttpd.access.log"\
 "/var/log/lighttpd/lighttpd.error.log"\
 "/var/log/messages"\
 "/var/log/secure"\
 "/var/log/syslog"\
 "/var/log/wtmp"\
 "/var/log/xferlog"\
 "/var/log/yum.log"\
 "/var/run/utmp"\
 "/var/webmin/miniserv.log"\
 "/var/www/logs/access_log"\
 "/var/www/logs/access.log"
)
WRITE_FILES=$(
array\
 "/etc/passwd"\
 "/etc/shadow"\
 "/etc/group"\
 "/etc/hosts"\
 "/etc/crontab"\
 "/etc/sysctl.conf"\
 "/etc/ssh/ssh_config"\
 "/etc/ssh/sshd_config"\
 "/etc/resolv.conf"\
 "/etc/syslog.conf"\
 "/etc/chttp.conf"\
 "/etc/apache2/apache2.conf"\
 "/etc/lighttpd.conf"\
 "/etc/httpd/conf/httpd.conf"\
 "/etc/cups/cupsd.confcda"\
 "/etc/inetd.conf"\
 "/opt/lampp/etc/httpd.conf"\
 "/etc/samba/smb.conf"\
 "/etc/openldap/ldap.conf"\
 "/etc/ldap/ldap.conf"\
 "/etc/exports"\
 "/etc/auto.master"\
 "/etc/auto_master"\
 "/etc/fstab"\
 "/etc/dhcpcd.conf"\
 "/etc/dnsmasq.conf"\
 "/etc/fuse.conf"\
 "/etc/gai.conf"\
 "/etc/healthd.conf"\
 "/etc/host.conf"\
 "/etc/i3status.conf"\
 "/etc/krb5.conf"\
 "/etc/ld.so.conf"\
 "/etc/libao.conf"\
 "/etc/locale.conf"\
 "/etc/logrotate.conf"\
 "/etc/ltrace.conf"\
 "/etc/makepkg.conf"\
 "/etc/mdadm.conf"\
 "/etc/mke2fs.conf"\
 "/etc/mkinitcpio.conf"\
 "/etc/modules.conf"\
 "/etc/mpd.conf"\
 "/etc/netconfig"
)
xml "OPEN" "DATA type='show' name='pe' namemax='11'"
xml "OPEN" "FILES"
if [ "$1" = "bsd" ]; then
    RET=$(find / -perm -4000 -type f -exec ls -lT {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
else
    RET=$(find / -perm -4000 -type f -printf '%M %u %g %p\n' 2>/dev/null)
fi
if [ -n "$RET" ]; then
    xml "SUID" "$RET"
else
    xml "SUID" "N/A"
fi
if [ "$1" = "bsd" ]; then
    RET=$(find / -perm -2000 -type f -exec ls -lT {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
else
    RET=$(find / -perm -2000 -type f -printf '%M %u %g %p\n' 2>/dev/null)
fi
if [ -n "$RET" ]; then
    xml "SGID" "$RET"
else
    xml "SGID" "N/A"
fi
if [ "$1" = "bsd" ]; then
    RET=$(find / -perm -1000 -type f -exec ls -lT {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10;\
          find / -perm -1000 -type d -exec ls -lTd {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
else
    RET=$(find / -perm -1000 -printf '%M %u %g %p\n' 2>/dev/null)
fi
if [ -n "$RET" ]; then
    xml "SBIT" "$RET"
else
    xml "SBIT" "N/A"
fi
i=0
while [ "$i" -lt 3 ]; do
    FOLDER=$(printf '%s\n' "$LIST_FOLDERS" | array_nth "$i")
    RET=$(test -d "$FOLDER" 2>/dev/null)
    if [ $? -eq 0 ]; then
        if [ "$1" = "bsd" ]; then
            RET=$(find "$FOLDER" -maxdepth 1 -type d -exec ls -lTd {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
        else
            RET=$(find "$FOLDER" -maxdepth 1 -type d -printf '%M %u %g %p\n' 2>/dev/null)
        fi
        if [ $? -eq 0 ]; then
            if [ -n "$RET" ]; then
                TMP="$TMP$RET: Yes"
                BOOL="TRUE"
            fi
        else
            if [ -n "$RET" ]; then
                TMP="$TMP$RET: No"
                BOOL="TRUE"
            fi
        fi
    fi
    i=$(( i + 1 ))
done
if [ "$BOOL" = "FALSE" ]; then
    xml "LIST" "N/A"
else
    xml "LIST" "$TMP"
    BOOL="FALSE"
fi
TMP=""
i=0
while [ "$i" -lt 36 ]; do
    FILE=$(printf '%s\n' "$READ_FILES" | array_nth "$i")
    RET=$(test -e "$FILE" 2>/dev/null)
    if [ $? -eq 0 ]; then
        RET=$(test -r "$FILE" 2>/dev/null)
        if [ $? -eq 0 ]; then
            if [ "$1" = "bsd" ]; then
                RET=$(find "$FILE" -type f -exec ls -lT {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
            else
                RET=$(find "$FILE" -type f -printf '%M %u %g %p\n' 2>/dev/null)
            fi
            if [ -n "$RET" ]; then
                TMP="$TMP$RET: Yes\n"
                BOOL="TRUE"
            fi
        else
            if [ "$1" = "bsd" ]; then
                RET=$(find "$FILE" -type f -exec ls -lT {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
            else
                RET=$(find "$FILE" -type f -printf '%M %u %g %p\n' 2>/dev/null)
            fi
            if [ -n "$RET" ]; then
                TMP="$TMP$RET: No\n"
                BOOL="TRUE"
            fi
        fi
    fi
    i=$(( i + 1 ))
done
if [ "$BOOL" = "FALSE" ]; then
    xml "READ" "N/A"
else
    xml "READ" "$TMP"
    BOOL="FALSE"
fi
TMP=""
i=0
while [ "$i" -lt 44 ]; do
    FILE=$(printf '%s\n' "$WRITE_FILES" | array_nth "$i")
    RET=$(test -e "$FILE" 2>/dev/null)
    if [ $? -eq 0 ]; then
        RET=$(test -w "$FILE" 2>/dev/null)
        if [ $? -eq 0 ]; then
            if [ "$1" = "bsd" ]; then
                RET=$(find "$FILE" -type f -exec ls -lT {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
            else
                RET=$(find "$FILE" -type f -printf '%M %u %g %p\n' 2>/dev/null)
            fi
            if [ -n "$RET" ]; then
                TMP="$TMP$RET: Yes\n"
                BOOL="TRUE"
            fi
        else
            if [ "$1" = "bsd" ]; then
                RET=$(find "$FILE" -type f -exec ls -lT {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
            else
                RET=$(find "$FILE" -type f -printf '%M %u %g %p\n' 2>/dev/null)
            fi
            if [ -n "$RET" ]; then
                TMP="$TMP$RET: No\n"
                BOOL="TRUE"
            fi
        fi
    fi
    i=$(( i + 1 ))
done
if [ "$BOOL" = "FALSE" ]; then
    xml "WRITE" "N/A"
else
    xml "WRITE" "$TMP"
    BOOL="FALSE"
fi
TMP=""
RET=$(test -x /tmp 2>/dev/null)
if [ $? -eq 0 ]; then
    if [ "$1" = "bsd" ]; then
        RET=$(find /tmp -maxdepth 0 -type d -exec ls -lTd {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
    else
        RET=$(find /tmp -maxdepth 0 -type d -printf '%M %u %g %p\n' 2>/dev/null)
    fi
    if [ -n "$RET" ]; then
        TMP="$TMP$RET: Yes\n"
        BOOL="TRUE"
    fi
else
    if [ "$1" = "bsd" ]; then
        RET=$(find /tmp -maxdepth 0 -type d -exec ls -lTd {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
    else
        RET=$(find /tmp -maxdepth 0 -type d -printf '%M %u %g %p\n' 2>/dev/null)
    fi
    if [ -n "$RET" ]; then
        TMP⁼"$TMP$RET: No\n"
        BOOL="TRUE"
    fi
fi
if [ "$BOOL" = "FALSE" ]; then
    xml "EXEC" "N/A"
else
    xml "EXEC" "$TMP"
    BOOL="FALSE"
fi
if [ "$1" = "bsd" ]; then
    RET=$(find / ! -path "*/proc/*" ! -path "*/sys/*" ! -path "*/dev/*" -perm -2 ! -type l -type f -exec ls -lT {} \; 2>/dev/null\
          | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10;\
          find / ! -path "*/proc/*" ! -path "*/sys/*" ! -path "*/dev/*" -perm -2 ! -type l -type d -exec ls -lTd {} \; 2>/dev/null\
          | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
else
    RET=$(find / ! -path "*/proc/*" ! -path "*/sys/*" ! -path "*/dev/*" -perm -2 ! -type l -printf '%M %u %g %p\n' 2>/dev/null)
fi
if [ -n "$RET" ]; then
    xml "WORLD-WRITE" "$RET"
else
    xml "WORLD-WRITE" "No"
fi
if [ "$1" = "bsd" ]; then
    RET=$(find / ! -path "*/proc/*" ! -path "/sys/*" \( -perm -0002 -a ! -perm -1000 \) -type d -exec ls -lTd {} \; 2>/dev/null\
          | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
else
    RET=$(find / ! -path "*/proc/*" ! -path "/sys/*" \( -perm -0002 -a ! -perm -1000 \) -type d -printf '%M %u %g %p\n' 2>/dev/null)
fi
if [ -n "$RET" ]; then
    xml "WORLD-EXEC" "$RET"
else
    xml "WORLD-EXEC" "No"
fi
if [ "$1" = "bsd" ]; then
    RET=$(find / ! -path "*/proc/*" ! -path "/sys/*" -nouser -nogroup -type l -exec ls -lT {} \; 2>/dev/null\
          | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
else
    RET=$(find / ! -path "*/proc/*" ! -path "/sys/*" -nouser -nogroup -type l -printf '%M %u %g %p\n' 2>/dev/null)
fi
if [ -n "$RET" ]; then
    xml "UNOWNED" "$RET"
else
    xml "UNOWNED" "No"
fi
xml "CLOSE" "FILES"
xml "OPEN" "CRON"
TMP=""
if [ "$1" = "bsd" ]; then
    RET=$(find /etc/anacrontab -type f -exec ls -lT {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
else
    RET=$(find /etc/anacrontab -type f -printf '%M %u %g %p\n' 2>/dev/null)
fi
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    TMP=$RET
    RET=$(cat /etc/anacrontab 2>/dev/null | grep -v -E "#|^$")
    if [ -n "$RET" ] && [ $? -eq 0 ]; then
        xml "ANACRONTAB" "$TMP\n\n$RET\n\n"
    else
        xml "ANACRONTAB" "$TMP"
    fi
else
    xml "ANACRONTAB" "No"
fi
if [ "$1" = "bsd" ]; then
    RET=$(find /etc/crontab -type f -exec ls -lT {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
else
    RET=$(find /etc/crontab -type f -printf '%M %u %g %p\n' 2>/dev/null)
fi
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    TMP=$RET
    RET=$(cat /etc/crontab 2>/dev/null | grep -v -E "#|^$")
    if [ -n "$RET" ] && [ $? -eq 0 ]; then
        xml "CRONTAB" "$TMP\n\n$RET\n\n"
    else
        xml "CRONTAB" "$TMP"
    fi
else
    xml "CRONTAB" "No"
fi
if [ "$1" = "bsd" ]; then
    RET=$(find /etc/cron.d -type d -exec ls -lTd {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
else
    RET=$(find /etc/cron.d -type d -printf '%M %u %g %p\n' 2>/dev/null)
fi
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    TMP=$RET
    for FILE in /etc/cron.d/*; do
        if [ "$1" = "bsd" ]; then
            RET=$(find "$FILE" -type f -exec ls -lT {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
        else
            RET=$(find "$FILE" -type f -printf '%M %u %g %p\n' 2>/dev/null)
        fi
        if [ $? -eq 0 ]; then
            if [ "$BOOL" = "FALSE" ]; then
                TMP1="$TMP\n\n$RET"
            else
                TMP1="$TMP$RET"
            fi
            RET=$(cat "$FILE" 2>/dev/null | grep -v -E "#|^$")
            if [ -n "$RET" ] && [ $? -eq 0 ]; then
                xml "CRON.D" "$TMP1\n\n$RET\n\n"
            else
                xml "CRON.D" "$TMP1"
            fi
            BOOL="TRUE"
        else
            xml "CRON.D" "$TMP"
        fi
    done
else
    xml "CRON.D" "No"
fi
if [ "$1" = "bsd" ]; then
    RET=$(find /etc/cron.hourly -type f -exec ls -lT {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
else
    RET=$(find /etc/cron.hourly -type f -printf '%M %u %g %p\n' 2>/dev/null)
fi
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "HOURLY" "$RET"
else
    xml "HOURLY" "No"
fi
if [ "$1" = "bsd" ]; then
    RET=$(find /etc/cron.daily -type f -exec ls -lT {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
else
    RET=$(find /etc/cron.daily -type f -printf '%M %u %g %p\n' 2>/dev/null)
fi
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "DAILY" "$RET"
else
    xml "DAILY" "No"
fi
if [ "$1" = "bsd" ]; then
    RET=$(find /etc/cron.weekly -type f -exec ls -lT {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
else
    RET=$(find /etc/cron.weekly -type f -printf '%M %u %g %p\n' 2>/dev/null)
fi
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "WEEKLY" "$RET"
else
    xml "WEEKLY" "No"
fi
if [ "$1" = "bsd" ]; then
    RET=$(find /etc/cron.monthly -type f -exec ls -lT {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
else
    RET=$(find /etc/cron.monthly -type f -printf '%M %u %g %p\n' 2>/dev/null)
fi
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    xml "MONTHLY" "$RET"
else
    xml "MONTHLY" "No"
fi
if [ "$1" = "bsd" ]; then
    RET=$(find /etc/cron.allow -type f -exec ls -lT {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
else
    RET=$(find /etc/cron.allow -type f -printf '%M %u %g %p\n' 2>/dev/null)
fi
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    TMP=$RET
    RET=$(cat /etc/cron.allow 2>/dev/null | grep -v -E "#|^$")
    if [ -n "$RET" ] && [ $? -eq 0 ]; then
        xml "ALLOW" "$TMP\n\n$RET\n\n"
    else
        xml "ALLOW" "$TMP"
    fi
else
    xml "ALLOW" "No"
fi
if [ "$1" = "bsd" ]; then
    RET=$(find /etc/cron.deny -type f -exec ls -lT {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
else
    RET=$(find /etc/cron.deny -type f -printf '%M %u %g %p\n' 2>/dev/null)
fi
if [ -n "$RET" ] && [ $? -eq 0 ]; then
    TMP=$RET
    RET=$(cat /etc/cron.deny 2>/dev/null | grep -v -E "#|^$")
    if [ -n "$RET" ] && [ $? -eq 0 ]; then
        xml "DENY" "$TMP\n\n$RET\n\n"
    else
        xml "DENY" "$TMP"
    fi
else
    xml "DENY" "No"
fi
xml "CLOSE" "CRON"
xml "OPEN" "SSH"
RET=$(grep "PermitRootLogin " /etc/ssh/sshd_config 2>/dev/null | grep -v "#" | awk '{print $2}')
if [ "$RET" = "Yes" ] || [ "$RET" = "yes" ]; then
    xml "ROOT-LOGIN" "Yes"
else
    xml "ROOT-LOGIN" "No"
fi
if [ "$1" = "bsd" ]; then
    RET=$(find / \( -name "*id_dsa*" -o -name "*id_rsa*" -o -name "*dsa_key*" -o -name "*rsa_key*"\
          -o -name "known_hosts" -o -name "authorized_hosts" -o -name "authorized_keys" \) -type f -exec ls -lT {} \; 2>/dev/null\
          | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
else
    RET=$(find / \( -name "*id_dsa*" -o -name "*id_rsa*" -o -name "*dsa_key*" -o -name "*rsa_key*"\
          -o -name "known_hosts" -o -name "authorized_hosts" -o -name "authorized_keys" \) -type f -printf '%M %u %g %p\n' 2>/dev/null)
fi
if [ -n "$RET" ]; then
    xml "KEYS" "$RET"
else
    xml "KEYS" "No"
fi
xml "CLOSE" "SSH"
xml "OPEN" "CREDENTIALS"
if [ "$1" = "bsd" ]; then
    RET=$(find / -maxdepth 4 \( -name "*.txt" -o -name "*.conf" -o -name "*.xml" -o -name "*.yml" -o -name "*.html" -o -name "*.js"\
          -o -name "*.php" -o -name "*.db" -o -name ".bash_history" \) -type f\
          -exec grep -E -l -i -s -q 'pass=|pwd=|login=|luser=|username=|pw=|passw=|passwd=|password=|pass:|user:|username:|password:|login:' {} 2>/dev/null \;\
          -exec ls -lT {} \; 2>/dev/null | sed 's/\( \)*/\1/g' | cut -d " " -f1,3-4,10)
else
    RET=$(find / -maxdepth 4 \( -name "*.txt" -o -name "*.conf" -o -name "*.xml" -o -name "*.yml" -o -name "*.html" -o -name "*.js"\
          -o -name "*.php" -o -name "*.db" -o -name ".bash_history" \) -type f\
          -exec grep -E -l -i -s -q 'pass=|pwd=|login=|luser=|username=|pw=|passw=|passwd=|password=|pass:|user:|username:|password:|login:' {} 2>/dev/null \;\
          -printf '%M %u %g %p\n')
fi
if [ -n "$RET" ]; then
    xml "NONE" "$RET"
else
    xml "NONE" "No"
fi
xml "CLOSE" "CREDENTIALS"
xml "CLOSE" "DATA"
printf %b "$BUF [CMD-EOF]"
