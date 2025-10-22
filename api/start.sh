#!/bin/sh
set -e

# ✅ Ensure isolate temp dir exists
mkdir -p /tmp/isolate
chmod 777 /tmp/isolate
export PISTON_TEMPDIR=/tmp/isolate

# ✅ Ensure /piston data directory exists (Render-safe)
if [ ! -d "/piston" ]; then
  echo "📁 Creating /piston data directory..."
  mkdir -p /piston
  chmod 777 /piston
fi

# ✅ Set environment variable (used by piston config)
export DATA_DIRECTORY=/piston

echo "🌍 Starting dynamic runtime system..."
echo "No static packages used — runtimes will be downloaded on first use."

# ✅ Start API
exec node src/index.js
