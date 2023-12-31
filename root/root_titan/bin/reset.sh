#!/bin/sh
echo "[reset.sh] start"

. /sbin/start-function

startUserRestore $1
if [ ! -e /etc/.oebuild ];then startUserSettings; fi

echo "[reset.sh] end"