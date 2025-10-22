#!/bin/bash
set -e

echo "=========================================="
echo "🚀 Starting Piston API container..."
echo "=========================================="

# Ensure /piston exists
mkdir -p /piston

echo "🌍 Starting dynamic runtime system..."
echo "🔄 Runtimes will download automatically when first used..."

# URLs for runtime tarballs
RUNTIMES=(
    "https://github.com/engineer-man/piston/releases/download/pkgs-v3/python.tar.gz"
    "https://github.com/engineer-man/piston/releases/download/pkgs-v3/javascript.tar.gz"
    "https://github.com/engineer-man/piston/releases/download/pkgs-v3/java.tar.gz"
    "https://github.com/engineer-man/piston/releases/download/pkgs-v3/c.tar.gz"
    "https://github.com/engineer-man/piston/releases/download/pkgs-v3/cpp.tar.gz"
)

mkdir -p /piston/packages

for url in "${RUNTIMES[@]}"; do
    echo "⬇️  Downloading $(basename $url)..."
    curl -fsSLk "$url" -o "/piston/packages/$(basename $url)" || echo "⚠️  Failed to download $(basename $url), skipping..."
done

echo "🚀 Starting API server..."
node src/index.js
