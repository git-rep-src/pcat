#!/bin/sh

LOGFILE="log_ips.log"

MSG="[`date`] Incoming connection from $PCAT_REMOTE_ADDR:$PCAT_REMOTE_PORT"

echo $MSG >&2
echo $MSG >> $LOGFILE

echo "Yeah, hi."
