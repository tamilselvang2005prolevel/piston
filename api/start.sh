#!/bin/sh
echo "✅ Starting Piston API Server..."

# Make sure isolate has temp dir
mkdir -p /tmp/isolate
chmod 777 /tmp/isolate
export PISTON_TEMPDIR=/tmp/isolate

# Run API
node src/index.js
