#!/bin/sh

# --- Safe writable setup for Render ---
mkdir -p /tmp/isolate /tmp/piston
chmod 777 /tmp/isolate /tmp/piston

# Symlink to satisfy Piston's expected /piston directory
if [ ! -e /piston ]; then
  ln -s /tmp/piston /piston
fi

# Export vars (Render-safe)
export DATA_DIRECTORY=/tmp/piston
export PISTON_TEMPDIR=/tmp/isolate

echo "✅ Directories ready. Starting Piston..."

# Start API server
exec node /api/src/index.js
