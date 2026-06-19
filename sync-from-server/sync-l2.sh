#!/usr/bin/env bash
# Sync the canonical OP Stack L2 (chain 20260619) as a follower node.
# canonical: Nova sequencer · genesis 0x563326cd…086784 · L1 = Sepolia
#   bash sync-l2.sh        (needs ssh access to lab server for binaries+config, or build op-geth/op-node)
set -euo pipefail
SRV="${SRV:-oracle-school@141.11.156.4}"
NOVA_PEER="/ip4/141.11.156.4/tcp/9227/p2p/16Uiu2HAmHdqUpiFA4y9ftVzNvoDPUvuAkFr6irdWP8zjCN2ZNqVa"
mkdir -p l2 && cd l2

# 1) binaries + canonical config (จาก server; หรือ build op-geth/op-node เอง)
[ -f op-geth ] || scp "$SRV":/home/oracle-school/op-stack/op-geth/build/bin/geth ./op-geth
[ -f op-node ] || scp "$SRV":/home/oracle-school/op-stack/op-node ./op-node
[ -f genesis.json ] || scp "$SRV":/home/oracle-school/op-stack/genesis-l2-20260619.json ./genesis.json
[ -f rollup.json ]  || scp "$SRV":/home/oracle-school/op-stack/rollup.json ./rollup.json
chmod +x op-geth op-node
[ -f jwt.txt ] || openssl rand -hex 32 > jwt.txt

# 2) op-geth (execution) — init (genesis hash ต้อง = 0x563326cd…086784) + run
[ -d data/geth ] || ./op-geth --datadir ./data init genesis.json
nohup ./op-geth --datadir ./data --networkid 20260619 \
  --http --http.addr 127.0.0.1 --http.port 8545 --http.api eth,net,web3,engine \
  --authrpc.addr 127.0.0.1 --authrpc.port 8551 --authrpc.jwtsecret jwt.txt --authrpc.vhosts "*" \
  --port 30303 --nodiscover --syncmode full --maxpeers 0 --rollup.disabletxpoolgossip=true \
  > op-geth.log 2>&1 & sleep 5

# 3) op-node (rollup) — derive จาก L1 Sepolia + peer Nova sequencer
nohup ./op-node \
  --l1=https://sepolia.drpc.org \
  --l1.beacon=https://ethereum-sepolia-beacon-api.publicnode.com --l1.trustrpc \
  --l2=http://127.0.0.1:8551 --l2.jwt-secret=jwt.txt \
  --rollup.config=rollup.json --syncmode=consensus-layer \
  --p2p.static="$NOVA_PEER" --p2p.listen.tcp=9222 --p2p.listen.udp=9222 \
  --rpc.addr=127.0.0.1 --rpc.port=8547 > op-node.log 2>&1 &

echo "🍺 syncing chain 20260619 — verify:"
echo "  cast chain-id    --rpc-url http://127.0.0.1:8545   # → 20260619"
echo "  cast block-number --rpc-url http://127.0.0.1:8545  # → ไล่ตาม Nova (เมื่อ batcher post batch ลง L1)"
echo "  เทียบ canonical: cast block-number --rpc-url http://141.11.156.4:9545"
