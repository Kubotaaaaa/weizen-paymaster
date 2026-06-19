# Sync chain 20260619 จาก server (geth Clique) — เป็น node จริง ไม่ใช่ RPC-read

> proven: รัน geth 1.13.15 full node บนเครื่องเรา → P2P sync จาก server chain ผ่าน devp2p
> block hash ตรง server เป๊ะ byte-for-byte (replicate จริง) · **ไม่ต้อง ssh เข้า server** (peer ผ่าน P2P port สาธารณะ)

## TL;DR — 3 อย่างที่ทำให้ sync สำเร็จ

1. **geth 1.13.15** เท่านั้น (≥1.14 ตัด Clique → `Fatal: only PoS networks supported`). commit `c5ba367e` ตรงกับ server
2. **genesis ต้องตรงเป๊ะ** (genesis hash match) ไม่งั้น devp2p handshake fail — reconstruct จาก server RPC
3. **peer ผ่าน enode `@<server-ip>:30310`** (server ปิด discovery → ใช้ `admin.addPeer` / static)

## ขั้นตอน

```bash
# 0) geth 1.13.15 (สำหรับ Clique PoA)
curl -sL https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.13.15-c5ba367e.tar.gz | tar xz
sudo cp geth-linux-amd64-1.13.15-c5ba367e/geth /usr/local/bin/geth1315   # หรือวางใน ~/bin

# 1) reconstruct genesis จาก server RPC (script ข้างล่าง) → genesis.json
./reconstruct-genesis.sh http://<SERVER>:8510 > genesis.json

# 2) init + verify genesis hash ต้องตรง server
geth1315 --datadir node init genesis.json     # hash ต้อง = server's genesis hash

# 3) run + peer เข้า server enode (เอาจาก admin_nodeInfo ของ server, แทน 127.0.0.1 ด้วย IP จริง)
ENODE="enode://<server-pubkey>@<SERVER>:30310"
geth1315 --datadir node --networkid 20260619 \
  --port 30355 --authrpc.port 8561 \
  --http --http.port 8547 --http.api eth,net,web3,admin \
  --syncmode full --nodiscover --ipcpath node/geth.ipc &
geth1315 attach --exec "admin.addPeer(\"$ENODE\")" node/geth.ipc

# 4) verify (ควรได้ peerCount=1 + block ตรง + block hash ตรง server)
geth1315 attach --exec 'net.peerCount' node/geth.ipc
geth1315 attach --exec 'eth.blockNumber' node/geth.ipc
```

## proof (Weizen, 2026-06-19)
```
genesis hash : 0xea75f4d0748d15d7094a56c0ba77a5bb0683a98cb7a0db38ddb3ea7caa510512  (= server) ✅
peerCount    : 1  → 141.11.156.4:30310  Geth/v1.13.15-c5ba367e (static)
block 885    : mine = server = 0xe63795278824ebbf6fb3c4ac7cd7c3a76ed66ffb1dccf0666e3d4f3dcfd93086 ✅
```

## OP Stack L2 (เป้าหมายจริง)
chain นี้เป็น geth **Clique** (sovereign L1-style). พอ OP Stack L2 จริงขึ้น (op-deployer apply → genesis.json + rollup.json) → sync ด้วย **op-geth + op-node** วิธีเดียวกัน (`--bootnodes` + rollup config) → ดู `../opstack/SYNC-OPSTACK.md`

— Weizen 🍺 (AI · Rule 6)
