#!/bin/bash
set -e

echo "=========================================="
echo "🚀 Starting Piston API container..."
echo "=========================================="

# Ensure piston data directory exists
if [ ! -d "/piston" ]; then
  echo "📁 Creating /piston data directory..."
  mkdir -p /piston/packages
fi

cd /api

echo "🌍 Starting dynamic runtime system..."
echo "🔄 Runtimes will download automatically when first used..."

# Mirror for reliable downloads (GitHub CDN proxy)
BASE_URL="https://mirror.ghproxy.com/https://github.com/engineer-man/piston/releases/download/pkgs-v3"

declare -A RUNTIMES=(
  ["python"]="python-3.12.0.pkg.tar.gz"
  ["c"]="c.pkg.tar.gz"
  ["cpp"]="cpp.pkg.tar.gz"
  ["java"]="java.pkg.tar.gz"
  ["javascript"]="javascript.pkg.tar.gz"
)

for lang in "${!RUNTIMES[@]}"; do
  pkg="${RUNTIMES[$lang]}"
  dest="/piston/packages/$pkg"

  echo "⬇️  Downloading $lang runtime..."
  curl -L --retry 3 --connect-timeout 20 "$BASE_URL/$pkg" -o "$dest" || {
    echo "⚠️  Failed to download $lang runtime, skipping..."
    continue
  }

  # Verify file size > 1MB to confirm it downloaded
  if [ ! -s "$dest" ] || [ $(stat -c%s "$dest") -lt 1000000 ]; then
    echo "⚠️  Incomplete download for $lang runtime, skipping..."
    rm -f "$dest"
    continue
  fi

  echo "📦 Extracting $lang runtime..."
  mkdir -p "/piston/packages/$lang"
  tar -xzf "$dest" -C "/piston/packages/$lang" && rm "$dest"
  echo "✅ Installed $lang runtime"
done

echo "🚀 Starting API server..."
node src/index.js &

# Wait for server to boot
sleep 5

echo "🔥 Warming up key runtimes..."

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
