#!/bin/bash
echo "=========================================="
echo "🚀 Starting Piston API container..."
echo "=========================================="

# ✅ Ensure directories exist
mkdir -p /piston
mkdir -p /tmp/piston
mkdir -p /tmp/isolate

echo "🌍 Starting dynamic runtime system..."
echo "🔄 Will download runtimes automatically when used..."

node src/index.js &

sleep 5
echo "🔥 Starting runtime warmup..."

node - <<'EOF'
const fetch = require('node-fetch');
const base = 'http://127.0.0.1:10000/api/v2/piston/execute';
const langs = ['python', 'c', 'cpp', 'java', 'javascript'];

(async () => {
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
      console.log(await res.text());
    } catch (err) {
      console.error(`❌ Warmup failed for ${lang}:`, err.message);
    }
  }
})();
EOF
