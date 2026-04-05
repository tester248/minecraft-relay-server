#!/bin/sh
set -eu

LISTEN_ADDRESS="${LISTEN_ADDRESS:-0.0.0.0}"
LISTEN_PORT="${PORT:-${LISTEN_PORT:-25565}}"
NET_PROTOCOL="${NET_PROTOCOL:-IPv4}"
TARGET_HOST="${TARGET_HOST:-}"
TARGET_PORT="${TARGET_PORT:-25565}"
VHOSTS="${VHOSTS:-}"
LOG_LEVEL="${LOG_LEVEL:-2}"
REWRITE="${REWRITE:-true}"
PHEADER="${PHEADER:-false}"

if [ -z "$TARGET_HOST" ]; then
    echo "ERROR: TARGET_HOST is required."
    exit 1
fi

if [ -z "$VHOSTS" ]; then
    VHOSTS="$TARGET_HOST"
fi

old_ifs="$IFS"
IFS=','
set -- $VHOSTS
IFS="$old_ifs"

vhosts_joined=""
for host in "$@"; do
    trimmed="$(printf '%s' "$host" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    if [ -z "$trimmed" ]; then
        continue
    fi
    if [ -n "$vhosts_joined" ]; then
        vhosts_joined="$vhosts_joined, "
    fi
    vhosts_joined="$vhosts_joined\"$trimmed\""
done

if [ -z "$vhosts_joined" ]; then
    vhosts_joined="\"$TARGET_HOST\""
fi

mkdir -p /app/config
cat > /app/config/runtime.json <<EOF
{
  "netpriority": {
    "enabled": true,
    "protocol": "$NET_PROTOCOL"
  },
  "log": {
    "filename": "./mcrelay.log",
    "level": $LOG_LEVEL,
    "binary": false
  },
  "listen": {
    "address": "$LISTEN_ADDRESS",
    "port": $LISTEN_PORT
  },
  "proxy": [
    {
      "vhost": [$vhosts_joined],
      "address": "$TARGET_HOST",
      "port": $TARGET_PORT,
      "rewrite": $REWRITE,
      "pheader": $PHEADER
    }
  ]
}
EOF

echo "Starting mcrelay on ${LISTEN_ADDRESS}:${LISTEN_PORT} -> ${TARGET_HOST}:${TARGET_PORT}"
exec /app/mcrelay /app/config/runtime.json
