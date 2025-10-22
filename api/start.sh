#!/bin/bash
set -e

echo "=========================================="
echo "🚀 Starting Piston API container..."
echo "=========================================="

# --- Setup writable temp dirs ---
mkdir -p /tmp/isolate /tmp/piston
chmod -R 777 /tmp/isolate /tmp/piston

# --- Handle missing /piston directory (Render-safe) ---
if [ ! -d "/piston" ]; then
  echo "📁 Creating /piston data directory..."
  mkdir -p /piston
  chmod -R 777 /piston
fi

# --- Environment variables ---
export PISTON_TEMPDIR=/tmp/isolate
export DATA_DIRECTORY=/tmp/piston
export data_directory=/tmp/piston

echo "🌍 Starting dynamic runtime system..."
echo "🔄 Will download runtimes automatically when used..."

# --- Start the Piston API ---
node src/index.js &

# Wait for API to start before warmup
sleep 10

echo "🔥 Starting runtime warmup..."

# --- Warmup Script (built-in) ---
node - <<'EOF'
import fetch from "node-fetch";

const API_URL = "http://localhost:10000/api/v2/execute";
const runtimes = [
  { lang: "python", version: "3.10.0", code: "print('Python OK')" },
  { lang: "c", version: "10.2.0", code: '#include <stdio.h>\nint main(){printf("C OK");return 0;}' },
  { lang: "cpp", version: "10.2.0", code: '#include <iostream>\nint main(){std::cout<<"C++ OK";}' },
  { lang: "java", version: "15.0.2", code: 'class Main { public static void main(String[] args){ System.out.println("Java OK"); } }' },
  { lang: "javascript", version: "18.15.0", code: 'console.log("JS OK")' },
];

const warmup = async () => {
  console.log("🚀 Warming up runtimes...");
  for (const rt of runtimes) {
    try {
      const res = await fetch(API_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          language: rt.lang,
          version: rt.version,
          files: [{ name: `main.${rt.lang === "python" ? "py" : rt.lang === "java" ? "java" : rt.lang === "cpp" ? "cpp" : rt.lang === "javascript" ? "js" : "c"}`, content: rt.code }],
        }),
      });
      const out = await res.json();
      console.log(`✅ ${rt.lang.toUpperCase()} ready:`, out.run?.output?.trim() || out.message || "no output");
    } catch (err) {
      console.error(`❌ ${rt.lang} warmup failed:`, err.message);
    }
  }
  console.log("🎉 Warmup complete!");
};

warmup();
EOF

wait
