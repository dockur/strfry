#!/usr/bin/env bash
set -Eeuo pipefail

: ${ROUTER:=''}
: ${STREAMS:=''}
: ${COMPACT:=''}

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

if [ ! -f "/etc/strfry.conf" ]; then
  cp /etc/strfry.conf.default /etc/strfry.conf
fi

cd /app

if [[ "$COMPACT" == [Yy1]* ]]; then

  db="./strfry-db/data.mdb"
  lock="./strfry-db/lock.mdb"

  if [ -f "$db" ]; then
    ./strfry compact - > "$db.compacted"
    [ -f "$lock" ] && rm -f "$lock"
    mv -f "$db.compacted" "$db"
  else
    echo "Error: database file $db not found.."
  fi

fi

./strfry relay &
PID=$!

if [ -f "$ROUTER" ]; then
  sleep 2
  ./strfry router "$ROUTER" &
fi

if [[ "$ROUTER" == [Yy1]* ]]; then
  sleep 2
  ./strfry router /etc/strfry-router.conf &
fi

for i in $(echo "$STREAMS" | sed "s/,/ /g")
do
  if [[ -n "$i" ]]; then
    sleep 2
    ./strfry stream wss://$i --dir down 2> /dev/null &
  fi
done

wait "$PID"
