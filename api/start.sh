#!/bin/bash

echo "=========================================="
echo "🚀 Starting Piston API container..."
echo "=========================================="

# Prepare environment
mkdir -p /piston /tmp/isolate
export DATA_DIRECTORY=/piston
export PISTON_TEMP_DIR=/tmp/isolate

echo "🌍 Starting dynamic runtime system..."
echo "🔄 Runtimes will download automatically when first used..."

# ================================
# 🧩 Download runtimes (safe mode)
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
  echo "⬇️  Downloading $lang runtime..."
  
  wget -q "$RUNTIME_URL/$pkg" -O "/tmp/$pkg"
  if [ $? -ne 0 ]; then
    echo "⚠️  Failed to download $lang runtime, skipping..."
    continue
  fi

  mkdir -p /piston/packages
  tar -xzf "/tmp/$pkg" -C /piston/packages/ || echo "⚠️  Failed to extract $lang"
  rm -f "/tmp/$pkg"
  
  echo "✅ Installed $lang runtime"
done

# ================================
# 🚀 Start API
# ================================
echo "🚀 Starting API server..."
node src/index.js &
API_PID=$!

# Give time for server to boot
sleep 8

# ================================
# ⚙️ Warm up runtimes
# ================================
echo "🔥 Warming up key runtimes..."
for lang in python c cpp java javascript; do
  echo "⚙️  Warming up $lang..."
  curl -s -X POST http://127.0.0.1:10000/api/v2/execute \
    -H "Content-Type: application/json" \
    -d "{\"language\":\"$lang\",\"version\":\"latest\",\"files\":[{\"content\":\"print('warmup')\"}]}" \
    > /dev/null 2>&1 || echo "⚠️  Warmup failed for $lang"
done

echo "✅ Warmup complete. Piston API ready on port 10000."
echo "=========================================="

wait $API_PID
