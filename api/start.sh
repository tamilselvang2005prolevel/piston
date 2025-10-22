#!/bin/sh
set -e

# ✅ Setup isolate
mkdir -p /tmp/isolate
chmod 777 /tmp/isolate
export PISTON_TEMPDIR=/tmp/isolate

# ✅ Setup data directory (Render-safe)
if [ ! -d "/piston" ]; then
  echo "📁 Creating /piston data directory..."
  mkdir -p /piston
  chmod 777 /piston
fi

export DATA_DIRECTORY=/piston

echo "🌍 Starting dynamic runtime system..."
echo "🔄 Will download runtimes automatically when used..."

# ✅ Preload base runtimes (optional, speeds up first requests)
node src/index.js &

# Give it a few seconds to start
sleep 3

# ✅ Trigger automatic runtime registration by calling the API locally
echo "⚙️ Registering runtimes..."
curl -X POST http://localhost:10000/api/v2/packages/install -H "Content-Type: application/json" -d '{"language": "python"}' || true
curl -X POST http://localhost:10000/api/v2/packages/install -H "Content-Type: application/json" -d '{"language": "c"}' || true
curl -X POST http://localhost:10000/api/v2/packages/install -H "Content-Type: application/json" -d '{"language": "cpp"}' || true
curl -X POST http://localhost:10000/api/v2/packages/install -H "Content-Type: application/json" -d '{"language": "java"}' || true
curl -X POST http://localhost:10000/api/v2/packages/install -H "Content-Type: application/json" -d '{"language": "javascript"}' || true

# ✅ Keep service alive
wait
