#!/bin/sh
set -e

# ✅ Ensure isolate temp dir exists
mkdir -p /tmp/isolate
chmod 777 /tmp/isolate
export PISTON_TEMPDIR=/tmp/isolate

# ✅ Ensure runtime downloads exist (auto download at runtime)
echo "🌍 Starting dynamic runtime system..."
echo "No static packages used — runtimes will be downloaded on first use."

# ✅ Start API
exec node src/index.js
