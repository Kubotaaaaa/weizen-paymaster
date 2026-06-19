#!/usr/bin/env bash
# 🍺 Ready-to-use: sync canonical OP Stack L2 (chain 20260619) — NO ssh needed, โหลดทุกอย่างจาก GitHub release
# canonical: Nova sequencer · genesis 0x563326cd…086784 · L1 = Sepolia
#   curl -sL https://raw.githubusercontent.com/Kubotaaaaa/weizen-paymaster/main/sync-from-server/sync-l2.sh | bash
set -euo pipefail
REL="https://github.com/Kubotaaaaa/weizen-paymaster/releases/download/ws06-l2-canonical"
PEER="/ip4/141.11.156.4/tcp/9227/p2p/16Uiu2HAmHdqUpiFA4y9ftVzNvoDPUvuAkFr6irdWP8zjCN2ZNqVa"
mkdir -p weizen-l2 && cd weizen-l2

echo "⬇️  download kit (binaries + config) จาก release…"
[ -f op-geth ]      || { curl -sL "$REL/op-geth"  -o op-geth;  chmod +x op-geth; }
[ -f op-node ]      || { curl -sL "$REL/op-node"  -o op-node;  chmod +x op-node; }
[ -f rollup.json ]  || curl -sL "$REL/rollup.json" -o rollup.json
[ -f genesis.json ] || { curl -sL "$REL/genesis.json.gz" -o genesis.json.gz; gunzip -f genesis.json.gz; }
[ -f jwt.txt ]      || openssl rand -hex 32 > jwt.txt

echo "🔧 op-geth init (genesis hash ต้อง = 0x563326cd…086784)"
[ -d data/geth ] || ./op-geth --datadir ./data init genesis.json 2>&1 | grep -iE "hash|fatal" | head -1

echo "🚀 start op-geth (execution :8545)"
nohup ./op-geth --datadir ./data --networkid 20260619 \
  --http --http.addr 127.0.0.1 --http.port 8545 --http.api eth,net,web3,engine \
  --authrpc.addr 127.0.0.1 --authrpc.port 8551 --authrpc.jwtsecret jwt.txt --authrpc.vhosts '*' \
  --port 30303 --nodiscover --syncmode full --maxpeers 0 --rollup.disabletxpoolgossip=true \
  > op-geth.log 2>&1 & sleep 5

echo "🚀 start op-node (rollup — derive L1 Sepolia + peer Nova)"
nohup ./op-node --l1=https://sepolia.drpc.org \
  --l1.beacon=https://ethereum-sepolia-beacon-api.publicnode.com --l1.trustrpc \
  --l2=http://127.0.0.1:8551 --l2.jwt-secret=jwt.txt \
  --rollup.config=rollup.json --syncmode=consensus-layer \
  --p2p.static="$PEER" --p2p.listen.tcp=9222 --p2p.listen.udp=9222 \
  --rpc.addr=127.0.0.1 --rpc.port=8547 > op-node.log 2>&1 &

echo "✅ ขึ้นแล้ว — verify:"
echo "   curl -s -X POST http://127.0.0.1:8545 -H 'content-type:application/json' -d '{\"jsonrpc\":\"2.0\",\"method\":\"eth_blockNumber\",\"params\":[],\"id\":1}'"
echo "   เทียบ canonical: http://141.11.156.4:9545  (block จะไล่ตามเมื่อ batcher post batch)"
