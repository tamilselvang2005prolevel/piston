#!/bin/bash
set -e

echo "=========================================="
echo "🚀 Starting Piston API container..."
echo "=========================================="

# Create the main data directory if missing
if [ ! -d "/piston" ]; then
  echo "📁 Creating /piston data directory..."
  mkdir -p /piston
fi

echo "🌍 Starting dynamic runtime system..."
echo "🔄 Will download runtimes automatically when used..."

# Start API in background
node src/index.js &

# Give server a few seconds to boot
sleep 8

echo "🔥 Starting runtime warmup..."

declare -a LANGS=("python" "c" "cpp" "java" "javascript")

for lang in "${LANGS[@]}"; do
  echo "⚙️  Warming up $lang..."
  curl -s -X POST http://localhost:10000/api/v2/execute \
    -H "Content-Type: application/json" \
    -d "{\"language\": \"$lang\", \"version\": \"latest\", \"files\": [{\"name\": \"main.$lang\", \"content\": \"print('hello')\"}]}" || true
done

echo "✅ Warmup finished."
wait
