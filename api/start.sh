#!/bin/bash
set -e

echo "=========================================="
echo "🚀 Starting Piston API container..."
echo "=========================================="

# Ensure /piston directory exists
if [ ! -d "/piston" ]; then
  echo "📁 Creating /piston data directory..."
  mkdir -p /piston
fi

cd /api

echo "🌍 Starting dynamic runtime system..."
echo "🔄 Runtimes will download automatically when first used..."

# --- Runtime setup ---
# This uses a mirror-friendly proxy to bypass Render download throttling
RUNTIME_URL="https://gh-proxy.com/https://github.com/engineer-man/piston/releases/download/pkgs-v3"

# Declare runtimes to install
declare -A RUNTIMES=(
  ["python"]="python-3.12.0.pkg.tar.gz"
  ["c"]="c.pkg.tar.gz"
  ["cpp"]="cpp.pkg.tar.gz"
  ["java"]="java.pkg.tar.gz"
  ["javascript"]="javascript.pkg.tar.gz"
)

mkdir -p /piston/packages

# Sequential download (not parallel) to prevent timeout on Render
for lang in "${!RUNTIMES[@]}"; do
  pkg="${RUNTIMES[$lang]}"
  echo "⬇️  Downloading $lang runtime..."
  
  wget -q --retry-connrefused --waitretry=2 --timeout=30 -t 3 "$RUNTIME_URL/$pkg" -O "/piston/packages/$pkg" || {
    echo "⚠️  Failed to download $lang runtime, skipping..."
    continue
  }

  echo "📦 Extracting $lang runtime..."
  tar -xzf "/piston/packages/$pkg" -C /piston/packages && rm "/piston/packages/$pkg"
  echo "✅ Installed $lang runtime"
done

echo "🚀 Starting API server..."
node src/index.js &

sleep 4
echo "🔥 Warming up key runtimes..."

# --- Warmup each language ---
for lang in "${!RUNTIMES[@]}"; do
  echo "⚙️  Warming up $lang..."
  curl -s -X POST http://localhost:10000/api/v2/execute \
    -H "Content-Type: application/json" \
    -d "{\"language\": \"$lang\", \"version\": \"latest\", \"files\": [{\"name\": \"main.$lang\", \"content\": \"print(123)\"}]}" >/dev/null 2>&1 \
  && echo "✅ Warmup successful for $lang" \
  || echo "⚠️ Warmup failed for $lang"
done

echo "✅ Warmup complete. Piston API ready on port 10000."
echo "=========================================="

wait
