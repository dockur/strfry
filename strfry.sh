#!/usr/bin/env bash
set -Eeuo pipefail

: "${ROUTER:=}"
: "${STREAMS:=}"
: "${COMPACT:=}"

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

config="/etc/strfry.conf"
template="/etc/strfry.conf.default"

prepareConfig() {

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
}

compactDatabase() {
  local db lock

  if [[ "$COMPACT" != [Yy1]* ]]; then
    return 0
  fi

  db="./strfry-db/data.mdb"
  lock="./strfry-db/lock.mdb"

  if [ -f "$db" ]; then

    if ! ./strfry compact - > "$db.compacted"; then
      echo "Error: failed to compact database."
      rm -f "$db.compacted"
      return 1
    fi

    if [ -f "$lock" ] && ! rm -f "$lock"; then
      echo "Error: failed to remove database lock file."
      rm -f "$db.compacted"
      return 1
    fi

    if ! mv -f "$db.compacted" "$db"; then
      echo "Error: failed to replace database with compacted copy."
      rm -f "$db.compacted"
      return 1
    fi

  else
    echo "Error: database file $db not found.."
    return 1
  fi

  return 0
}

startRelay() {
  ./strfry relay &
  PID=$!
}

startRouter() {

  if [ -f "$ROUTER" ]; then
    sleep 2
    ./strfry router "$ROUTER" &
  fi

  if [[ "$ROUTER" == [Yy1]* ]]; then
    sleep 2
    ./strfry router /etc/strfry-router.conf &
  fi
}

startStreams() {
  local i

  for i in $(echo "$STREAMS" | sed "s/,/ /g")
  do
    if [[ -n "$i" ]]; then
      sleep 2
      ./strfry stream wss://$i --dir down 2> /dev/null &
    fi
  done
}

prepareConfig

cd /app

compactDatabase || exit 1

startRelay
startRouter
startStreams

wait "$PID"
