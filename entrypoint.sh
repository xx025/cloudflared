#!/bin/sh
set -eu

if [ -z "${TUNNEL_TOKEN:-}" ]; then
  echo "TUNNEL_TOKEN is required. Create a Cloudflare Tunnel and paste its token into Back4App environment variables." >&2
  exit 1
fi

METRICS_PORT="${PORT:-8080}"
TUNNEL_METRICS="${TUNNEL_METRICS:-0.0.0.0:${METRICS_PORT}}"

exec cloudflared tunnel \
  --no-autoupdate \
  --metrics "$TUNNEL_METRICS" \
  run \
  --token "$TUNNEL_TOKEN"
