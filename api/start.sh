#!/bin/sh
# --- Render-safe writable setup ---
mkdir -p /tmp/isolate
chmod 777 /tmp/isolate
export PISTON_TEMPDIR=/tmp/isolate
export DATA_DIRECTORY=/tmp/isolate
export data_directory=/tmp/isolate

# --- Start the main entrypoint ---
exec node /api/src/index.js
