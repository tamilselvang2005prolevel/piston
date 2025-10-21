#!/bin/sh
echo "✅ Directories ready. Starting Piston..."

# Ensure packages directory exists
mkdir -p /api/packages
chmod -R 777 /api/packages

# Start API
exec node src/index.js
