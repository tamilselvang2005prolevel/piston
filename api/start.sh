#!/bin/bash
set -e

echo "=========================================="
echo "🚀 Starting Piston API container..."
echo "=========================================="

mkdir -p /piston
echo "🌍 Starting dynamic runtime system..."
echo "🔄 Runtimes will download automatically when first used..."

# Correct runtime URLs (Engineer-Man official)
declare -A RUNTIMES
RUNTIMES=(
  ["python"]="https://github.com/engineer-man/piston/releases/download/pkgs/python-3.12.0.pkg.tar.gz"
  ["javascript"]="https://github.com/engineer-man/piston/releases/download/pkgs/node-18.15.0.pkg.tar.gz"
  ["java"]="https://github.com/engineer-man/piston/releases/download/pkgs/java-15.0.2.pkg.tar.gz"
  ["c"]="https://github.com/engineer-man/piston/releases/download/pkgs/gcc-10.2.0.pkg.tar.gz"
  ["cpp"]="https://github.com/engineer-man/piston/releases/download/pkgs/gcc-10.2.0.pkg.tar.gz"
)

mkdir -p /piston/packages

for lang in "${!RUNTIMES[@]}"; do
  url="${RUNTIMES[$lang]}"
  file="/piston/packages/${lang}.pkg.tar.gz"
  echo "⬇️  Downloading $lang runtime..."
  curl -fsSLk "$url" -o "$file" || echo "⚠️  Failed to download $lang runtime, skipping..."
done

echo "🚀 Starting API server..."
node src/index.js
