# os:1
# raw:1
# one:1
# out:0
python -c "import pty; pty.spawn('/bin/sh')"
if uname -o | grep -qi linux; then exec script /dev/null; fi
