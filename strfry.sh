#!/usr/bin/env bash
set -Eeuo pipefail

: ${ROUTER:=''}
: ${STREAMS:=''}
: ${COMPACT:=''}

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

config="/etc/strfry.conf"
template="/etc/strfry.conf.default"

# Check if config file is not a directory
if [ -d "$config" ]; then

    echo "The bind $config maps to a file that does not exist!"
    exit 1

fi

if [ ! -f "$config" ]; then

  if [ ! -f "$template" ]; then
    echo "Your /etc directory does not contain a valid strfry.conf file!"
    exit 1
  fi

  cp "$template" "$config"

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
