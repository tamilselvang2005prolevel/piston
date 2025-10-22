#!/bin/bash
set -e

echo "=========================================="
echo "🚀 Starting Piston API container..."
echo "=========================================="

# Ensure directories exist
mkdir -p /piston /tmp/isolate

echo "🌍 Starting dynamic runtime system..."
echo "🔄 Runtimes will download automatically when first used..."

# Export required environment variables
export DATA_DIRECTORY=/piston
export PISTON_TEMP_DIR=/tmp/isolate

# Start the API server in background
node src/index.js &

# Give it a few seconds to boot
sleep 10

# Verify API endpoint and download runtimes dynamically
echo "🔥 Warming up key runtimes..."

declare -a LANGS=("python" "c" "cpp" "java" "javascript")

for lang in "${LANGS[@]}"; do
  echo "⚙️  Warming up $lang..."
  curl -s -X POST http://127.0.0.1:10000/api/v2/execute \
    -H "Content-Type: application/json" \
    -d "{\"language\":\"$lang\",\"version\":\"latest\",\"files\":[{\"content\":\"print('warmup')\"}]}" \
    || echo "⚠️  Warmup failed for $lang"
done

echo "✅ Warmup finished. Piston API is live."
echo "=========================================="

wait
