## IV. Experimental Results and Analysis

Our incremental ablation study yielded a clear narrative of performance bottlenecks and their respective solutions. The results, summarized in Table I and depicted in Figures 1, 2, and 3, demonstrate a systematic progression from a baseline architecture severely constrained by network latency to a highly optimized, high-throughput system. Each architectural stage provided a distinct lesson, validating our initial hypotheses and revealing the interplay between server-side and blockchain-level constraints.

| Arch | Key Feature | Throughput (tx/sec) | Avg Latency (s) | P99 Latency (s) | Avg Tx/Block |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Sync, Single-Wallet | 0.25 | 4.00 | 4.21 | 1.00 |
| 2 | Async, Single-Wallet | 13.22 | 2.92 | 4.91 | 52.63 |
| 3 | Multi-Thread, Async, Single-Wallet | 18.04 | 2.96 | 5.18 | 71.43 |
| 4 | Unsync Multi-Thread, Multi-Wallet | 24.16 | 27.21 | 28.97 | 111.11 |
| **5** | **Symbol-Sharded, Lock-Free (Proposed)** | **31.19** | **15.43** | **30.14** | **125.00** |

**Table I:** Summary of Performance Metrics Across Architectural Stages

### A. From Synchronous to Asynchronous: Overcoming Network Latency

The most dramatic performance improvement occurred in the transition from Architecture 1 to Architecture 2. By simply decoupling the submission thread from the synchronous wait for block confirmation, we increased throughput by over 50 times, from 0.25 tx/sec to 13.22 tx/sec. This initial step confirmed our primary hypothesis: in a naive implementation, the application is almost entirely idle, bottlenecked by the network's block time. The average latency also saw a modest improvement, dropping from 4.0s to 2.9s, as the asynchronous submission allowed for more efficient batching of transactions into blocks.

This finding validates a fundamental principle in high-performance systems design: decoupling operations from their latency-inducing dependencies can yield dramatic performance improvements [1]. The asynchronous pattern has been extensively studied in systems research and is recognized as a critical optimization for I/O-bound workloads [2].

### B. The Nonce Bottleneck: The Limits of Single-Wallet Parallelism

The move to a multi-threaded submission model in Architecture 3 provided a crucial insight into the constraints of the Ethereum Virtual Machine (EVM). Despite introducing parallel processing, throughput only increased by a modest 36%, from 13.22 tx/sec to 18.04 tx/sec. As hypothesized, the requirement for strictly sequential nonces for transactions from a single wallet became the new bottleneck. The application threads were effectively serialized at the blockchain level, competing to submit transactions with the correct next nonce. This result clearly demonstrates that true parallelization cannot be achieved without addressing the single-wallet nonce constraint.

This observation aligns with the principle of "Amdahl's Law," which states that the speedup of a system is limited by the portion of the workload that cannot be parallelized [3]. In this case, the nonce requirement creates a sequential bottleneck that limits parallelism to approximately 36%, regardless of how many threads we add.

### C. The Server-Side Crisis: A New Bottleneck Emerges

Architecture 4, which introduced a pool of wallets to circumvent the nonce issue, successfully increased throughput to 24.16 tx/sec. However, this came at the cost of a catastrophic rise in latency. The average transaction latency exploded from a stable ~3 seconds to over 27 seconds, with the P99 latency reaching nearly 29 seconds. This outcome validated our most critical hypothesis: removing the blockchain-level bottleneck simply shifts the contention point to the server.

This phenomenon is well-documented in systems research: optimizing one component often reveals previously hidden bottlenecks in other components [4]. Without a coordinating mechanism, the multiple threads began to fiercely compete for shared server-side resources, likely causing cache thrashing and lock convoying—phenomena extensively studied in concurrent systems research [5]. Transactions were queuing up within our own application, waiting for local resources long before they were even sent to the network.

The high P99 latency (28.972s) relative to the average (27.211s) indicates that most transactions were experiencing similar delays, suggesting a systemic bottleneck rather than occasional outliers. This is characteristic of lock contention, where threads are forced to wait for exclusive access to shared resources.

### D. The Proposed Solution: Symbol-Sharding and Lock-Free Queues

Our proposed architecture (Architecture 5) was designed specifically to solve the server-side contention crisis observed in Architecture 4. By introducing symbol-sharding and lock-free queues, we were able to achieve the highest throughput of all tested configurations at 31.19 tx/sec, a 29% improvement over Architecture 4. More importantly, this was achieved while cutting the average latency by 43%, from 27.2s down to 15.4s.

This demonstrates that partitioning the workload by a domain-specific key—in this case, the trading symbol—and processing those partitions in lock-free queues effectively mitigates the server-side resource competition. Lock-free data structures, based on compare-and-swap (CAS) operations, have been shown to provide significant latency and throughput improvements over traditional lock-based approaches in high-contention scenarios [6].

However, it is notable that the P99 latency remained high at ~30 seconds. This indicates that while the average case is significantly improved, tail latency remains an issue. We suspect that for highly contended symbols, the workload can still create temporary backlogs within a single shard, a challenge we leave for future work. The P99 latency being higher than the average suggests that certain symbols experience more contention than others, causing occasional transactions to experience significantly longer delays.

### E. Block Utilization and Economic Efficiency

Finally, our results show a direct correlation between architectural efficiency and network efficiency. As seen in Figure 3, the average number of transactions packed into each block rose in lockstep with our throughput improvements, from a trivial 1.0 tx/block in the baseline to a highly efficient 125.0 tx/block in our proposed architecture. This confirms that our optimizations effectively saturate the available block space, minimizing wasted capacity and leading to a more economically viable system. The gas usage per transaction remained stable across all architectures (ranging from 146,194 to 152,603 gas units), confirming that our performance gains were purely architectural and did not come at the cost of more complex or expensive on-chain operations.

---

## References

[1] D. E. Knuth, "The art of computer programming, volume 1: Fundamental algorithms," *Addison-Wesley*, 1968.

[2] J. L. Hennessy and D. A. Patterson, "Computer architecture: A quantitative approach," 6th ed., *Morgan Kaufmann*, 2017.

[3] G. M. Amdahl, "Validity of the single processor approach to achieving large scale computing capabilities," in *Proceedings of the Spring Joint Computer Conference*, 1967, pp. 483–485.

[4] L. A. Barroso, J. Dean, and U. Hölzle, "Web search for a planet: The Google cluster architecture," *IEEE Micro*, vol. 23, no. 2, pp. 22–28, 2003.

[5] M. Moir and N. Shavit, "Concurrent data structures," in *Handbook of Data Structures and Applications*, 2nd ed., 2018.

[6] T. Harris, "A pragmatic implementation of non-blocking linked-lists," in *Proceedings of the 15th International Conference on Distributed Computing*, 2001, pp. 300–314.
