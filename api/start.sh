#!/bin/bash
set -e

echo "=========================================="
echo "🚀 Starting Piston API container..."
echo "=========================================="

# Ensure directories exist
mkdir -p /piston /tmp/isolate

echo "🌍 Starting dynamic runtime system..."
echo "🔄 Runtimes will download automatically when first used..."
export DATA_DIRECTORY=/piston
export PISTON_TEMP_DIR=/tmp/isolate

# ================================
# 🔧 Install runtimes automatically
# ================================
echo "📦 Fetching core runtimes from Engineer-Man GitHub..."
RUNTIME_URL="https://github.com/engineer-man/piston/releases/download/pkgs-v3"

declare -A RUNTIMES=(
  ["python"]="python-3.12.0.pkg.tar.gz"
  ["c"]="gcc-10.2.0.pkg.tar.gz"
  ["cpp"]="gcc-10.2.0.pkg.tar.gz"
  ["java"]="java-15.0.2.pkg.tar.gz"
  ["javascript"]="node-18.15.0.pkg.tar.gz"
)

mkdir -p /piston/packages

for lang in "${!RUNTIMES[@]}"; do
  pkg="${RUNTIMES[$lang]}"
  if [ ! -d "/piston/packages/$lang" ]; then
    echo "⬇️  Downloading $lang runtime..."
    wget -q "$RUNTIME_URL/$pkg" -O "/tmp/$pkg"
    tar -xzf "/tmp/$pkg" -C /piston/packages/
    rm "/tmp/$pkg"
    echo "✅ Installed $lang runtime"
  else
    echo "✔️  $lang runtime already exists"
  fi
done

# ================================
# 🚀 Start API
# ================================
node src/index.js &
sleep 10

# ================================
# ⚙️ Warm up
# ================================
echo "🔥 Warming up key runtimes..."
for lang in python c cpp java javascript; do
  echo "⚙️  Warming up $lang..."
  curl -s -X POST http://127.0.0.1:10000/api/v2/execute \
    -H "Content-Type: application/json" \
    -d "{\"language\":\"$lang\",\"version\":\"latest\",\"files\":[{\"content\":\"print('warmup')\"}]}" \
    || echo "⚠️  Warmup failed for $lang"
done

echo "✅ Warmup finished. Piston API is live."
echo "=========================================="
wait
