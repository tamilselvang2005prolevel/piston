#!/bin/bash
set -e

echo "=========================================="
echo "🚀 Starting Piston API container..."
echo "=========================================="

# ✅ Ensure /piston data directory exists
if [ ! -d "/piston" ]; then
  echo "📁 Creating /piston data directory..."
  mkdir -p /piston
fi

echo "🌍 Starting dynamic runtime system..."
echo "🔄 Will download runtimes automatically when used..."

# ✅ Start API in background
node src/index.js &

# Wait for API to boot
sleep 8

echo "🔥 Starting runtime warmup..."

# ✅ Warmup script (CommonJS style)
node - <<'EOF'
const fetch = require('node-fetch');

async function warmup() {
  const base = 'http://localhost:10000/api/v2/piston/execute';
  const langs = ['python', 'c', 'cpp', 'java', 'javascript'];

  for (const lang of langs) {
    console.log(`⚙️  Warming up ${lang}...`);
    try {
      const res = await fetch(base, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          language: lang,
          version: '*',
          files: [{ name: 'main', content: 'print("hi")' }]
        }),
      });
      console.log(`${lang} →`, await res.text());
    } catch (err) {
      console.error(`❌ Warmup failed for ${lang}:`, err.message);
    }
  }
  console.log('✅ Warmup finished.');
}

warmup();
EOF

# ✅ Keep container alive (foreground logs)
wait
