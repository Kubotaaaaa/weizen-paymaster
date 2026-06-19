#!/usr/bin/env bash
# Otterscan block explorer สำหรับ chain 20260619 (เสิร์ฟ static build ชี้ไปที่ anvil RPC)
# anvil 1.7.x รองรับ ots_* namespace (Otterscan API level 8) แล้ว → ไม่ต้องใช้ erigon/docker
set -euo pipefail

RPC="${RPC:-http://127.0.0.1:8545}"
OTS_VER="${OTS_VER:-2.6.1}"
DIR="${DIR:-./otterscan}"
SERVE_PORT="${SERVE_PORT:-5100}"

mkdir -p "$DIR" && cd "$DIR"
if [ ! -f index.html ]; then
  echo "⬇️  downloading Otterscan $OTS_VER static build…"
  curl -L "https://github.com/otterscan/otterscan/releases/download/v${OTS_VER}/otterscan-${OTS_VER}.tar.gz" -o ots.tgz
  tar xzf ots.tgz && rm ots.tgz
fi

# config: ชี้ explorer ไปที่ RPC ของ chain เรา
cat > config.json <<JSON
{
  "erigonURL": "${RPC}",
  "beaconAPI": "",
  "assetsURLPrefix": "",
  "experimental": false,
  "branding": { "siteName": "Weizen Otterscan", "networkTitle": "ARRA Oracle Blockchain 20260619" }
}
JSON

echo "🔭 Otterscan → $RPC  ·  open http://127.0.0.1:${SERVE_PORT}"
exec python3 -m http.server "$SERVE_PORT"
