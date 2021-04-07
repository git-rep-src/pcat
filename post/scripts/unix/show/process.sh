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
get_process () {
    printf %b "Z2V0X3Byb2Nlc3MgKCkgewogICAgUFNPVVQ9JChwcyAtLW5vLWhlYWRlcnMgLWVvIHVzZXIscGlk"\
              "LHBwaWQsY29tbWFuZCx2c2l6ZSxyc3MgfCBncmVwIC1FdiAnIDAgKzAkJyB8IHNvcnQgLW4gLWsy"\
              "KQogICAgd2hpbGUgcmVhZCBMSU5FOyBkbwogICAgICAgIExJTkU9YGVjaG8gIiRMSU5FIiB8IHNl"\
              "ZCAtZSBzL1w+L1xcXFxcXD4vZ2AKICAgICAgICBQUk9DRVNTPSggJExJTkUgKQogICAgICAgIFBJ"\
              "RD0ke1BST0NFU1NbMV19CiAgICAgICAgT1dORVJbIiRQSUQiXT0ke1BST0NFU1NbMF19CiAgICAg"\
              "ICAgcFBJRFsiJFBJRCJdPSR7UFJPQ0VTU1syXX0KICAgICAgICBjb21tYW5kWyIkUElEIl09IiQo"\
              "ZWNobyAiJExJTkUiIHwgYXdrICd7IGZvcihpID0gNDsgaSA8PSAoTkYgLSAyKTsgaSsrKSB7cHJp"\
              "bnRmICIlcyAiLCRpfSB9JykiCiAgICAgICAgQ0hJTERSRU5bJHtwUElEWyIkUElEIl19XT0iJHtD"\
              "SElMRFJFTlske3BQSURbJFBJRF19XX0gJFBJRCIKICAgIGRvbmUgPDwgRU9GCiAgICAkUFNPVVQK"\
              "RU9GCiAgICBnZXRfdHJlZSAiJHByb2MiICIiCn0KZ2V0X3RyZWUgKCkgewogICAgSUQ9JDEKICAg"\
              "IGlmIFsgLW4gIiRJRCIgXTsgdGhlbgogICAgICAgZWNobyAiJHtjb21tYW5kWyRJRF19IiIoIiIk"\
              "e09XTkVSWyRJRF19IiIpIgogICAgZmkKICAgIGlmIFsgLXogIiR7Q0hJTERSRU5bJElEXX0iIF07"\
              "IHRoZW4KICAgICAgICByZXR1cm4KICAgIGVsc2UKICAgICAgICBmb3IgQ0hJTEQgaW4gJHtDSElM"\
              "RFJFTlskSURdfTsgZG8KICAgICAgICAgICAgaWYgWyAiJENISUxEIiA9ICIkKGVjaG8gIiR7Q0hJ"\
              "TERSRU5bJHtwUElEWyRDSElMRF19XX0iIHwgYXdrICd7cHJpbnQgJE5GfScpIiBdOyB0aGVuCiAg"\
              "ICAgICAgICAgICAgICBpZiBbIC16ICIkSUQiIF07IHRoZW4KICAgICAgICAgICAgICAgICAgICBw"\
              "cmludGYgJWIgIiQyICDilIzilIAiCiAgICAgICAgICAgICAgICBlbHNlIAogICAgICAgICAgICAg"\
              "ICAgICAgIHByaW50ZiAlYiAiJDLilJTilIAiCiAgICAgICAgICAgICAgICBmaQogICAgICAgICAg"\
              "ICAgICAgVE1QPSIkMiAgIgogICAgICAgICAgICBlbHNlCiAgICAgICAgICAgICAgICBpZiBbIC16"\
              "ICIkSUQiIF07IHRoZW4KICAgICAgICAgICAgICAgICAgICBwcmludGYgJWIgIiQy4pSM4pSAIgog"\
              "ICAgICAgICAgICAgICAgZWxzZSAKICAgICAgICAgICAgICAgICAgICBwcmludGYgJWIgIiQy4pSc"\
              "4pSAIgogICAgICAgICAgICAgICAgZmkKICAgICAgICAgICAgICAgIFRNUD0iJDLilIIgIgogICAg"\
              "ICAgICAgICBmaQogICAgICAgICAgICBnZXRfdHJlZSAiJENISUxEIiAiJFRNUCIKICAgICAgICBk"\
              "b25lCiAgICBmaQp9CmdldF9wcm9jZXNzIDI+L2Rldi9udWxsCg==" | base64 -d | /bin/bash
}
xml "OPEN" "DATA name='process' maxlen='3'"
xml "OPEN" "USERS"
if [ "$1" = "bsd" ]; then
    RET=$(ps afxco user,pid,command 2>/dev/null | grep -Ev ' 0 +0$')
    if [ -n "$RET" ] && [ $? -eq 0 ]; then
        xml "NONE" "$RET"
    else
        xml "NONE" "n/a"
    fi
else
    RET=$(get_process 2>/dev/null)
    if [ -n "$RET" ] && [ $? -eq 0 ]; then
        xml "NONE" "$RET"
    else
        xml "NONE" "n/a"
    fi
fi
xml "CLOSE" "USERS"
if [ "$1" = "linux" ]; then
    xml "OPEN" "SERVICES"
    RET=$(ls -l /sbin/init 2>/dev/null)
    if [ -n "$RET" ] && [ $? -eq 0 ]; then
        if echo "$RET" | grep -q "systemd"; then
            RET=$(systemctl list-units --type service --state running 2>/dev/null | sed -n '/UNIT/,/^$/p')
        elif echo "$RET" | grep -q "upstart"; then
            RET=$(initctl list 2>/dev/null)
        elif echo "$RET" | grep -q "runit"; then
            RET=$(sv service list 2>/dev/null)
        elif echo "$RET" | grep -q "sysv"; then
            RET=$(service --status-all 2>/dev/null | grep + | cut " " -f6)
        elif echo "$RET" | grep -q "init"; then
            RET=$(initctl list 2>/dev/null)
        else
            RET=""
        fi
    else
        RET=""
    fi
    if [ -n "$RET" ] && [ $? -eq 0 ]; then
        xml "NONE" "$RET"
    else
        xml "NONE" "n/a"
    fi
    xml "CLOSE" "SERVICES"
fi
xml "CLOSE" "DATA"
printf %b "$BUF [POST-EOS]"
