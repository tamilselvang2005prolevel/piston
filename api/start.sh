#!/bin/sh
# --- Render-safe writable setup ---
mkdir -p /tmp/isolate
chmod 777 /tmp/isolate
export PISTON_TEMPDIR=/tmp/isolate

# --- Start the main entrypoint ---
exec /api/src/docker-entrypoint.sh
