## III. Experimental Methodology

To systematically evaluate the performance of our proposed trading architecture, we designed an incremental ablation study. Ablation studies, originally developed in neuroscience to understand complex biological systems, have become a standard methodology in systems research for isolating the performance impact of individual components [1]. Our approach was to build upon a naive baseline architecture, introducing one key optimization at each stage. This allowed us to precisely isolate and quantify the performance impact of distinct system bottlenecks, from network I/O and blockchain-level nonce contention to server-side resource locking. By observing how each architectural change affected performance, we could empirically validate our hypotheses about the primary constraints in a high-throughput blockchain trading system.

The ablation study methodology is particularly well-suited to our research goals. Rather than attempting to optimize all components simultaneously—which would make it difficult to understand which optimizations actually matter—we systematically remove constraints one at a time. This approach, grounded in established performance evaluation practices [2], allows us to identify which component is the limiting factor at each stage, then address it in the next iteration.

### A. Architectural Configurations

We tested five distinct architectural configurations, each representing a logical step in the evolution from a simple, synchronous system to our proposed lock-free, symbol-sharded design. Each architecture was designed to test a specific hypothesis about system performance, following the principle of isolating one variable at a time [2].

**Architecture 1: Sequential, Synchronous, Single-Wallet (Baseline)**
This architecture represents the most basic implementation. A single thread submits a transaction and waits synchronously for it to be mined and confirmed before submitting the next. Our hypothesis was that this design would be severely limited by the blockchain's block time, establishing a performance floor. This baseline is essential for ablation studies, as it provides the reference point from which all improvements are measured.

**Architecture 2: Sequential, Asynchronous, Single-Wallet**
Here, we decoupled submission from confirmation. The main thread submits transactions to the mempool without waiting, while a separate background thread polls for mining status. We hypothesized that this would provide a substantial throughput increase by removing the block time from the submission loop, thereby isolating the benefit of asynchronous I/O. This step tests whether the primary bottleneck is server-side (application thread blocking) or blockchain-side (mining latency).

**Architecture 3: Multi-Threaded, Asynchronous, Single-Wallet**
This architecture introduces parallelism by having multiple threads submit trades concurrently to a single blockchain wallet. Our hypothesis was that the performance gains would be marginal. Since EVM-based chains require strictly ordered nonces for transactions from a single wallet, we predicted that the wallet itself would become a serialization bottleneck, negating the benefits of multi-threading. This step isolates the impact of blockchain-level constraints on parallelization.

**Architecture 4: Unsynchronized Multi-Threaded, Multi-Wallet**
To overcome the nonce bottleneck, this architecture utilizes a pool of distinct wallets, allowing for true parallel submission. However, threads select wallets without any coordination or awareness of the trade symbol. We hypothesized that this would expose a severe server-side contention issue, leading to high latency as threads compete for shared resources like database locks or cache, even as throughput increases. This step is critical: it demonstrates that removing one bottleneck can reveal a previously hidden bottleneck.

**Architecture 5: Symbol-Sharded, Lock-Free, Multi-Wallet (Proposed)**
This is our proposed novel architecture. It builds upon the multi-wallet design by introducing two key innovations from high-frequency trading: symbol-sharding and lock-free queues. Submissions are partitioned by their trading symbol, and each symbol is assigned to a dedicated, lock-free execution queue. Our hypothesis was that by ensuring trades for a specific symbol are processed sequentially but in parallel with other symbols, this design would maximize throughput while minimizing the latency variance caused by server-side contention.

### B. Performance Metrics

To assess the operational viability of each architecture, we focused on three key metrics that balance raw speed with reliability and efficiency, following established performance evaluation practices [2].

**Overall Throughput (tx/sec):** This measures the rate at which valid transactions are successfully mined and confirmed. It is the primary indicator of system capacity and the ability to handle high-volume market activity.

**Transaction Latency (seconds):** This is the total time from trade submission to final confirmation on the blockchain. We tracked both the **Average** latency and the **P99** (99th percentile) latency. While the average provides a baseline, P99 is critical for understanding worst-case performance and identifying tail latency issues caused by hidden resource contention. Tail latency analysis is a standard technique in systems research for detecting performance anomalies [3].

**Block Utilization (tx/block):** This measures the average number of our transactions packed into each mined block. It serves as a proxy for network efficiency, indicating how effectively the submission architecture is saturating the available block space.

### C. Test Environment

Our test workload consisted of submitting 1,000 atomic trade operations, distributed across ten high-volume equity symbols (AAPL, AMD, AMZN, GOOGL, INTC, META, MSFT, NFLX, NVDA, TSLA), to a smart contract on a private Ethereum network. The network utilized an IBFT 2.0 consensus mechanism with a 4-second block time. The application server and test harness were implemented in C# and run on a high-performance workstation (Intel i7-13700H with 64GB RAM) to ensure the submission client was not a bottleneck.

Each test run submitted exactly 1,000 transactions and measured the time from the first submission to the final confirmation. This fixed workload size allows for direct comparison of throughput and latency across architectures. The test harness verified that all transactions were successfully mined and confirmed, achieving 100% success rate across all architectures.

---

## References

[1] R. Meyes, M. Lu, C. W. de Puiseau, and T. Meisen, "Ablation studies in artificial neural networks," *arXiv preprint arXiv:1901.08644*, 2019.

[2] L. K. John, "Performance evaluation: Techniques, tools and benchmarks," *Electrical and Computer Engineering Department, The University of Texas at Austin*, 2007.

[3] J. Dean and L. A. Barroso, "The tail at scale," *Communications of the ACM*, vol. 56, no. 2, pp. 74–80, 2013.
