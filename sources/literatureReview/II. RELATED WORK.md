## II. RELATED WORK

Our research into optimizing blockchain-backed trading architectures draws upon several established domains of computer science and finance. We position our work at the intersection of blockchain scalability, concurrent system design, and high-frequency trading principles. The following sections review key literature in these areas and situate our contributions within the broader academic context.

### A. Blockchain Throughput and Scalability

The performance limitations of public blockchains are well-documented. Initial quantitative analyses, such as the work by Bez et al. [1], established a baseline for Ethereum's throughput, attributing its low transaction processing capacity to the inherent trade-offs between decentralization, security, and scalability. Their work provides a theoretical model for the bottlenecks our baseline architecture (Architecture 1) empirically demonstrates at 0.25 transactions per second (tx/sec). Our findings extend this analysis by showing that targeted architectural optimizations can yield a 125-fold throughput improvement to over 31 tx/sec on the same underlying blockchain, directly addressing the scalability challenge they identify.

More recent comparative studies, like the one conducted by Ucbas et al. [2], have benchmarked various blockchain platforms, including Ethereum and Hyperledger Fabric, under controlled loads. Their work highlights the significant performance differences between platforms. Our research complements these platform-level comparisons by providing a granular, application-level analysis. By systematically testing five distinct architectures for a trading system, we isolate specific bottlenecks, such as nonce contention and server-side locking, that are often abstracted away in broader platform evaluations. Our results, showing a latency range from 2.9s to 27.2s depending on the architectural design, underscore the critical role of application architecture in achieving high performance.

Layer 2 scaling solutions, such as rollups and sidechains, represent a popular and parallel avenue of research for enhancing blockchain throughput [3]. These approaches typically move computation and state storage off-chain to reduce the burden on the main network. Our work is orthogonal but complementary to this research thrust. We focus on optimizing the Layer 1 application architecture itself, which can be used in conjunction with Layer 2 solutions to achieve even greater scalability. For instance, the symbol-sharded design we propose could be deployed within a Layer 2 rollup to maximize its processing capacity.

### B. Nonce Management and Transaction Contention

A significant bottleneck we identified in our experiments is transaction contention arising from Ethereum's nonce mechanism, which requires that transactions from a single account be processed in a strict, sequential order. Our results for Architectures 2 and 3, where introducing multi-threading yielded only a 36% throughput gain, empirically confirm that nonce contention is a primary limiting factor for parallelization. This finding aligns with theoretical models and security analyses of the Ethereum mempool, which highlight the challenges of high-volume transaction submission [4].

To address this, some researchers have proposed alternative concurrency models. Paimani's work on SonicChain, for example, introduces a "wait-free" approach using concurrency delegation and pseudo-static annotations to mitigate conflicts [5]. While this provides a path to reducing contention, our multi-wallet approach (Architectures 4 and 5) offers a more direct and aggressive partitioning strategy. By using multiple wallets, we effectively create independent nonce sequences, although, as our results for Architecture 4 show, this can shift the bottleneck to the server-side if not managed with appropriate concurrency controls.

### C. Concurrent Architectures for Financial Systems

Our approach to resolving server-side contention draws heavily from principles developed in the high-frequency trading (HFT) domain. The catastrophic 27.2s latency observed in our unsynchronized multi-wallet architecture (Architecture 4) is a classic symptom of resource contention, such as cache thrashing and lock convoying, which HFT systems are meticulously designed to avoid. The foundational work on lock-free data structures by Moir and Shavit [6] provides the theoretical underpinnings for the solution we implement in Architecture 5.

Specifically, we apply the principles of the LMAX Disruptor pattern, a high-performance inter-thread communication mechanism that uses a ring buffer and lock-free operations to achieve extremely low latency [7]. By implementing a symbol-sharded, lock-free queueing system, we were able to reduce the average transaction latency from 27.2s down to 15.4s, a 44% improvement. This empirically validates that techniques proven in traditional finance, as detailed in works by Bilokon and Gunduz [8] and Ng and Malik [9], can be successfully adapted to blockchain-based systems to overcome critical performance barriers.

### D. Blockchain-Based Trading and Decentralized Finance

The architecture of decentralized exchanges (DEXs) has evolved significantly, from on-chain order books to automated market makers (AMMs) [10]. However, many existing designs suffer from scalability limitations and are susceptible to fairness issues like Maximal Extractable Value (MEV), where miners or validators reorder transactions for their own financial gain [11].

Our symbol-sharded architecture directly addresses these challenges. By creating isolated, per-symbol processing queues, we not only improve scalability but also enhance fairness. Within each shard, transactions are processed in a deterministic, first-in-first-out (FIFO) manner, which inherently mitigates the potential for MEV strategies like front-running and sandwich attacks that rely on arbitrary transaction reordering. Recent analyses of the Ethereum blockchain have shown that such favoritism in transaction ordering is a systemic issue [12]. Our work provides a concrete architectural solution that promotes a more equitable and predictable trading environment.

### E. Sharding and Data Partitioning

Sharding is a well-established technique for scaling distributed databases and is now being actively developed for blockchains like Ethereum 2.0. Early research in this area, such as the work by Fynn and Pedone [13], explored various methods for partitioning blockchain state and highlighted the significant overhead associated with cross-shard communication. Our approach leverages a domain-specific partitioning strategy—sharding by trading symbol—which is more efficient for a trading workload than generic graph-based partitioning methods.

Our work is also highly complementary to research on optimizing cross-shard communication. Kudzin et al. [14] have proposed novel data structures to compress transaction data in rollups, thereby increasing the number of cross-shard transactions that can fit into a single block. While their work focuses on the communication between shards, our work optimizes the processing *within* a shard. A system that combines both our symbol-sharded architecture and their cross-shard compression techniques could achieve a new level of performance and scalability for decentralized trading.

---

### References

[1] M. Bez, G. Fornari, and T. Vardanega, "The scalability challenge of ethereum: An initial quantitative analysis," in *2019 IEEE International Conference on Service-Oriented System Engineering (SOSE)*, 2019.

[2] Y. Ucbas, A. Eleyan, M. Hammoudeh, and M. Alohaly, "Performance and scalability analysis of Ethereum and Hyperledger Fabric," *IEEE Access*, vol. 11, 2023.

[3] H. Song, Z. Qu, and Y. Wei, "Advancing blockchain scalability: An introduction to layer 1 and layer 2 solutions," in *2024 IEEE 2nd International Conference on Blockchain and Cryptocurrency*, 2024.

[4] Y. Wang et al., "Understanding Ethereum mempool security under asymmetric DoS by symbolized stateful fuzzing," in *Proceedings of the 33rd USENIX Security Symposium*, 2024.

[5] K. Paimani, "SonicChain: A wait-free, pseudo-static approach toward concurrency in blockchains," *arXiv preprint arXiv:2102.09073*, 2021.

[6] M. Moir and N. Shavit, "Concurrent data structures," in *Handbook of Data Structures and Applications*, 2nd ed., 2018.

[7] M. Thompson et al., "LMAX Disruptor," *LMAX Exchange*. [Online]. Available: https://lmax-exchange.github.io/disruptor/

[8] P. Bilokon and B. Gunduz, "C++ design patterns for low-latency applications including high-frequency trading," *arXiv preprint arXiv:2309.04259*, 2023.

[9] H. Ng and J. Karlsson Malik, "Improving performance of a trading system through lock-free programming," Master's thesis, Diva Portal, 2018.

[10] J. Xu, K. Paruch, S. Cousaert, and Y. Feng, "SoK: Decentralized exchanges (DEX) with automated market maker (AMM) protocols," *ACM Computing Surveys*, vol. 56, no. 5, 2023.

[11] Z. Alipanahloo, A. S. Hafid, and K. Zhang, "Maximum extractable value (MEV) mitigation approaches in Ethereum and Layer-2 chains: A comprehensive survey," *IEEE Access*, vol. 12, 2024.

[12] D. Mancino, A. Leporati, M. Viviani, and G. Denaro, "Decentralization or favoritism? An analysis of Ethereum transactions and maximal extractable value strategies," in *2025 IEEE International Conference on Blockchain and Cryptocurrency (ICBC)*, 2025.

[13] E. Fynn and F. Pedone, "Challenges and pitfalls of partitioning blockchains," in *2018 48th Annual IEEE/IFIP International Conference on Dependable Systems and Networks Workshops (DSN-W)*, 2018.

[14] A. Kudzin, K. Toyoda, S. Takayama, and A. Ishigame, "Scaling Ethereum 2.0's cross-shard transactions with refined data structures," *Cryptography*, vol. 6, no. 4, 2022.
