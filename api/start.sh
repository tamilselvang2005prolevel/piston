#!/bin/bash
set -e

echo "=========================================="
echo "🚀 Starting Piston API container..."
echo "=========================================="

# Ensure main directories exist
mkdir -p /piston/packages
cd /piston/packages

echo "🌍 Starting dynamic runtime system..."
echo "🔄 Downloading language runtimes..."

# Use working release URLs
RUNTIMES=(
  "https://github.com/engineer-man/piston/releases/download/pkgs-v3/python.tar.gz"
  "https://github.com/engineer-man/piston/releases/download/pkgs-v3/javascript.tar.gz"
  "https://github.com/engineer-man/piston/releases/download/pkgs-v3/java.tar.gz"
  "https://github.com/engineer-man/piston/releases/download/pkgs-v3/c.tar.gz"
  "https://github.com/engineer-man/piston/releases/download/pkgs-v3/cpp.tar.gz"
)

for url in "${RUNTIMES[@]}"; do
  file=$(basename "$url")
  echo "⬇️  Downloading $file..."
  if curl -fsSL --retry 5 "$url" -o "$file"; then
    tar -xzf "$file" && rm "$file"
  else
    echo "⚠️  Failed to download $file, skipping..."
  fi
done

echo "🚀 Starting API server..."
node src/index.js
