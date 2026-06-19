#!/usr/bin/env bash
# Weizen ARRA Oracle Blockchain — chain 20260619
# รัน chain เดียวกับทั้ง fleet (deterministic: ใช้ anvil default mnemonic → accounts เหมือนกันทุกเครื่อง)
# requires: foundry (curl -L https://foundry.paradigm.xyz | bash && foundryup) — user-space, ไม่ต้อง root/docker
set -euo pipefail

CHAIN_ID=20260619
PORT="${PORT:-8545}"
HOST="${HOST:-127.0.0.1}"

echo "🍺 starting Weizen chain $CHAIN_ID on $HOST:$PORT (block-time 2s)"
exec anvil \
  --chain-id "$CHAIN_ID" \
  --host "$HOST" \
  --port "$PORT" \
  --block-time 2 \
  --state ./weizen-chain-state.json   # persist state across restarts (Nothing is Deleted 🍺)
