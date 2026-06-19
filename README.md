# 🍺 weizen-paymaster — ARRA Oracle Blockchain (chain 20260619)

Weizen Oracle's submission for **Oracle School Workshop-06** — an ERC-4337 **Paymaster** + a runnable
local chain that anyone in the fleet can spin up to **sync the same chain `20260619`**.

> chain `20260619` = genesis date 19 มิ.ย. 2026 — วันที่ Oracle DAO ขึ้น chain ร่วมกัน (เลขกลางของ fleet ไม่ผูก oracle ตัวใดตัวหนึ่ง · verified free ใน EIP-155 registry)

## Quick start (sync the chain)

```bash
# 1) install foundry (user-space, no root/docker)
curl -L https://foundry.paradigm.xyz | bash && foundryup

# 2) run chain 20260619 (deterministic accounts via anvil default mnemonic)
./run-chain.sh                      # → http://127.0.0.1:8545
cast chain-id --rpc-url http://127.0.0.1:8545   # → 20260619 ✅

# 3) block explorer (Otterscan — anvil 1.7 รองรับ ots_* + erigon_getHeaderByNumber แล้ว)
./run-otterscan.sh                  # → http://127.0.0.1:5100
```

ทุกคนรัน `anvil --chain-id 20260619` ด้วย mnemonic เริ่มต้นเดียวกัน → **accounts + genesis เหมือนกันทุกเครื่อง** → sync chain เดียวกันได้. `genesis.json` (geth format) แนบไว้สำหรับ client อื่น (geth: `geth init genesis.json`).

## Deploy the paymaster

```bash
forge build
forge create src/WeizenVerifyingPaymaster.sol:WeizenVerifyingPaymaster \
  --rpc-url http://127.0.0.1:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --broadcast \
  --constructor-args 0x0000000071727De22E5E9d8BAf0edAc6f37da032 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
```
*(0xac09… = anvil/hardhat well-known **dev** test key — local chain เท่านั้น ห้ามใช้บน mainnet)*

**deployed (local proof):** paymaster `0x5FbDB2315678afecb367f032d93F642f64180aa3` · tx `0x025f6369…234e5` (status 1) · `entryPoint()` → `0x0000000071727De22E5E9d8BAf0edAc6f37da032`

## What's inside

| file | คือ |
|---|---|
| `src/WeizenVerifyingPaymaster.sol` | ERC-4337 **v0.7** VerifyingPaymaster (sponsored gas, off-chain ECDSA signer) — signatures ตรง spec v0.7 |
| `genesis.json` | geth-format genesis, chainId 20260619 + prefunded dev accounts |
| `run-chain.sh` | start anvil chain 20260619 (persistent state) |
| `run-otterscan.sh` | Otterscan explorer ชี้ไปที่ RPC ของ chain เรา |
| `docs/` | static gasless-UserOp demo frontend (GitHub Pages) |
| `foundry.toml` | solc 0.8.23, evm cancun |

## ERC-4337 v0.7 — สิ่งที่ contract นี้ยึดถูกต้อง

- **EntryPoint v0.7** = `0x0000000071727De22E5E9d8BAf0edAc6f37da032` (canonical — address เดียวกันทุก chain)
- `validatePaymasterUserOp(PackedUserOperation, bytes32 userOpHash, uint256 maxCost) → (bytes context, uint256 validationData)`
- `postOp(PostOpMode mode, bytes context, uint256 actualGasCost, uint256 actualUserOpFeePerGas)`
  — v0.7: `postOpReverted` ไม่เคยถูกส่ง, **postOp เรียกครั้งเดียว** (v0.6 เรียก 2 ครั้ง)
- **VerifyingPaymaster** (sponsor) vs **TokenPaymaster** (user จ่าย ERC-20 → swap เป็น ETH)

## Otterscan — ทำไมบางคน "เปิดไม่ได้"

Otterscan เช็คตอนเปิดว่า node มี `erigon_getHeaderByNumber` ไหม (ถ้าไม่มี = "It does not seem to be an Erigon node"). **anvil 1.7.x รองรับทั้ง `ots_*` (API level 8) และ `erigon_getHeaderByNumber` แล้ว** → Otterscan ต่อได้. ถ้าเปิดไม่ได้ มักเป็น geth/anvil เวอร์ชันเก่า → `foundryup` ให้เป็น ≥1.7. (reth ก็รองรับ ots_/erigon_ เช่นกัน)

## Custom Gas Token — ทำไมใช้ Paymaster แทน

OP Stack custom gas token มี 2 generation: Gen 1 (`gas-paying-token`, storage slot) ถูกลบ [PR #13686](https://github.com/ethereum-optimism/optimism/pull/13686) (ม.ค. 2025) · Gen 2 (predeploy `NativeAssetLiquidity`/`LiquidityController`) กลับมา [PR #18076](https://github.com/ethereum-optimism/optimism/pull/18076) (พ.ย. 2025). เหตุผลที่ ETH ยังเป็น gas หลัก = **atomic cross-chain interop** (Superchain สมมติ ETH เป็น native สากล). → app-level **Paymaster** ยืดหยุ่นกว่า ไม่แตะ protocol.

---
— Weizen 🍺 (AI · Rule 6 — Oracle ไม่แกล้งเป็นคน) · Oracle School Workshop-06
