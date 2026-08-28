---
theme: seriph
colorSchema: light
background: '#F2F2F2'
title: A Lock Free, Non-blocking, In Line Processing Architecture
info: |
  ## ECSA 2026 Industry Track, Bolzano, Italy
  A Lock Free, Non-blocking, In Line Processing Architecture for
  High Throughput and Regulatory Compliant Blockchain Trading Applications
class: text-center
highlighter: shiki
drawings:
  persist: false
transition: slide-left
mdc: true
css: unocss
---

<div class="brand-bar -m-12 mb-8 p-6 flex justify-center gap-6 items-center">
  <div class="logo-box"><img src="/logos/ul-trim.png" class="h-10" /></div>
  <div class="logo-box"><img src="/logos/maastricht-trim.png" class="h-10" /></div>
  <div class="logo-box"><img src="/logos/lero-trim.png" class="h-10" /></div>
  <div class="logo-box"><img src="/logos/horizon-trim.png" class="h-10" /></div>
</div>

# A Lock Free, Non-blocking, In Line Processing Architecture

### for High Throughput and Regulatory Compliant Blockchain Trading Applications

<div class="mt-6 text-lg">
  <strong>Andrew Le Gear</strong><sup>1</sup> &nbsp; <strong>Jim Buckley</strong><sup>1</sup> &nbsp;
  <strong>Tawny Whatmore</strong><sup>2</sup> &nbsp; <strong>Ashish Sai</strong><sup>3</sup>
</div>

<div class="mt-2 text-sm opacity-70">
  <sup>1</sup>CSIS Department, Lero, University of Limerick, Ireland &nbsp;|&nbsp;
  <sup>2</sup>Horizon Globex Ireland &nbsp;|&nbsp;
  <sup>3</sup>Maastricht University, Netherlands
</div>

<div class="mt-6 text-sm opacity-80">
  andrew.p.legear@ul.ie &nbsp;|&nbsp; ECSA 2026 Industry Track, Bolzano, Italy &nbsp;|&nbsp; Artifact: Zenodo DOI 10.5281/zenodo.21512313
</div>

---
layout: default
---

# Motivation

<v-clicks>

- Regulated DeFi (R-DeFi) needs trading systems that are **simultaneously** high-throughput **and** regulatory compliant<sup class="citation">[1]</sup>.
- Off-chain compliance checks (KYC/AML, trade surveillance) and on-chain settlement pull system design in **opposite directions**<sup class="citation">[2]</sup>.
- Existing blockchain trading architectures are not empirically benchmarked against production-grade throughput and latency targets<sup class="citation">[3]</sup>.

</v-clicks>

<div v-click class="card mt-8">
<strong>Research question:</strong> which architectural pattern maximises throughput while preserving compliance guarantees, under real blockchain constraints (nonce ordering, gas limits, block capacity)?
</div>

<div class="slide-footnote">
[1] D. A. Zetzsche, D. W. Arner, R. P. Buckley, "Decentralized Finance," Journal of Financial Regulation, 2020.<br/>
[2] Financial Action Task Force, "FATF Guidance on Virtual Assets and Virtual Asset Service Providers," 2024.<br/>
[3] M. Bez, G. Fornari, T. Vardanega, "The Scalability Challenge of Ethereum: An Initial Quantitative Analysis," IEEE SOSE, 2019.
</div>

---
layout: default
---

# Approach

<v-clicks>

- Two-layer **hybrid architecture**: off-chain compliance / order layer decoupled from on-chain settlement layer.
- **Ablation study** of five progressively optimised architectural variants, deployed and measured on a **live production trading system**.
- Variants isolate the effect of: asynchronous submission, multi-threading, multi-wallet parallelism, and symbol-level sharding with lock-free coordination.
- Empirical measurement of throughput, latency (avg / P99), and block utilisation under identical load.

</v-clicks>

---
layout: image-right
image: /images/two-layer-model.png
backgroundSize: contain
---

# Two-Layer Hybrid Architecture

Off-chain compliance, matching, and order-book components are decoupled from on-chain settlement — keeping regulatory logic mutable while the ledger stays immutable<sup class="citation">[1]</sup>.

**Five architectural stages studied:**

1. Sequential, blocking, single wallet
2. Asynchronous, single wallet
3. Multi-threaded, asynchronous, single wallet
4. Unsynchronised multi-threaded, multi-wallet
5. **Symbol-sharded, lock-free, multi-wallet (proposed)**

<div class="slide-footnote">
[1] R. Jamithireddy et al., "A Hybrid Blockchain Architecture for Enterprise Adoption," 2025.
</div>

---
layout: default
---

# Key Findings

<v-clicks>

- **Nonce mechanism** limits naive parallelism to only a **36% throughput gain** — Ethereum's strict per-account nonce ordering is a hard serialisation point<sup class="citation">[1]</sup>.
- Circumventing nonce ordering with multiple wallets **without** careful coordination causes a **9&times; increase in latency** due to lock contention.
- Bottlenecks **migrate**: solving one on-chain constraint exposes a new server-side concurrency crisis.
- Our **lock-free, symbol-sharded** submission model (inspired by the **LMAX Disruptor** HFT architecture<sup class="citation">[2]</sup>) removes contention entirely by partitioning work per trading symbol.

</v-clicks>

<div class="slide-footnote">
[1] K. Hu, Z. Zhou, X. Li, Z. Ren, "Research on Nonce-Pool-Based Acceleration Scheme for Blockchain Transaction Writing," IEEE Access, 2023.<br/>
[2] M. Thompson, D. Farley, M. Barker, P. Gee, A. Stewart, "LMAX Disruptor: High Performance Alternative to Bounded Queues for Exchanging Data Between Concurrent Threads," LMAX Exchange, 2011.
</div>

---
layout: default
---

# Performance Results

<img src="/images/stat1.png" class="mx-auto h-70" />

<div class="text-center mt-6 text-xl">
  <span class="stat-highlight">2.8&times;</span> improvement over conventional design &nbsp;|&nbsp;
  <span class="stat-highlight">125&times;</span> gain over naive baseline &nbsp;|&nbsp;
  <span class="stat-highlight">44%</span> latency reduction at peak throughput
</div>

---
layout: default
---

# Latency &amp; Block Utilisation

<div class="grid grid-cols-2 gap-6">
<div class="text-center">
  <img src="/images/stat2.png" class="mx-auto h-60" />
  <div class="mt-2 text-sm opacity-70">Latency (avg / P99)</div>
</div>
<div class="text-center">
  <img src="/images/stat3.png" class="mx-auto h-60" />
  <div class="mt-2 text-sm opacity-70">Block utilisation</div>
</div>
</div>

---
layout: image-right
image: /images/symbol-sharded-lock-free-model.png
backgroundSize: contain
---

# Symbol-Sharded, Lock-Free Design

Trades are routed by symbol to independent queues and worker threads, each owning a dedicated wallet — removing cross-symbol lock contention entirely, following the LMAX ring-buffer partitioning approach (see Key Findings), and avoiding the cross-shard coordination pitfalls seen in general-purpose blockchain sharding<sup class="citation">[1]</sup>.

<div class="card mt-8">
Achieves <strong>31.19 tx/sec</strong>, the highest throughput across all five studied variants.
</div>

<div class="slide-footnote">
[1] E. Fynn, F. Pedone, "Challenges and Pitfalls of Partitioning Blockchains," IEEE/IFIP DSN-W, 2018.
</div>

---
layout: default
---

# Production System

<v-clicks>

- **Upstream** is Horizon Globex's live platform, running **Architecture 5** (symbol-sharded, lock-free) in production.
- Off-chain server handles order ingestion, KYC/AML, and matching.
- Settlement via permissioned **IBFT 2.0** Ethereum and the `ATS.sol` contract.
- Upstream supports **MERJ**, a tier-one regulated stock exchange, alongside US automated trading system deployments.

</v-clicks>

---
layout: default
---

# Conclusions

<v-clicks>

- A symbol-sharded, lock-free architecture achieves **31.19 tx/sec**, the highest throughput across all five studied variants.
- Naive concurrency fixes (multi-threading, multi-wallet) expose new bottlenecks rather than resolving throughput ceilings.
- Regulatory-compliant, high-throughput blockchain trading is achievable through careful **architectural co-design**, not brute-force parallelism.
- Future work: adaptive sharding and cross-chain generalisation.

</v-clicks>

---
layout: center
class: text-center
---

<div class="brand-bar -m-12 mb-8 p-6 flex justify-center gap-6 items-center">
  <div class="logo-box"><img src="/logos/ul-trim.png" class="h-10" /></div>
  <div class="logo-box"><img src="/logos/maastricht-trim.png" class="h-10" /></div>
  <div class="logo-box"><img src="/logos/lero-trim.png" class="h-10" /></div>
  <div class="logo-box"><img src="/logos/horizon-trim.png" class="h-10" /></div>
</div>

# Thank You

## Questions?

<div class="mt-6 text-sm opacity-80">
  andrew.p.legear@ul.ie &nbsp;|&nbsp; Artifact: Zenodo DOI 10.5281/zenodo.21512313 <br/>
  Code: github.com/HorizonFintex/blockchain-trading-architectures
</div>
