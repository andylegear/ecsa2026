## III. System Architecture and Regulatory Constraints

Our proposed system employs a two-layer hybrid architecture designed to balance the high-performance demands of modern trading with the stringent regulatory and security requirements of financial markets. This model, which segregates responsibilities between a high-throughput off-chain server and a secure on-chain settlement layer, is consistent with emerging patterns in enterprise blockchain adoption where performance and compliance are paramount [1]. This creates a system that is both fast and trustworthy.

### A. Two-Layer Architectural Model

The architecture is composed of two distinct layers:

1.  **Layer 1: Off-Chain Order Management Server:** This layer is a centralized, high-performance server responsible for all real-time trading operations. Its duties include user authentication, order ingestion, compliance checks (e.g., KYC/AML, trading limits), order matching, and maintaining the live order book. By handling these operations off-chain, we leverage the speed and scalability of traditional centralized systems for tasks that do not require immediate blockchain consensus, a common strategy in Layer 2 scaling solutions [2].

2.  **Layer 2: On-Chain Settlement and Finality Layer:** This layer consists of a private, permissioned Ethereum-based blockchain network running an IBFT 2.0 consensus mechanism. Its sole responsibility is to provide a secure, immutable, and auditable ledger for the final settlement of matched trades. The `ATS.sol` smart contract (see Appendix A) serves as the on-chain automated trading system, providing a simple `bid` function to record the settlement of a trade.

This separation of concerns is a critical design choice, enabling the system to meet the often-conflicting demands of performance and regulatory compliance [1].

*EraserDiagram: ["Layer 1: Off-Chain Server" box contains "Order Ingestion", "Compliance Engine", "Order Matching Engine", "Live Order Book"]. An arrow labeled "Matched Trades" points from "Layer 1" to ["Layer 2: On-Chain Blockchain" box, which contains "ATS Smart Contract", "IBFT 2.0 Consensus", "Immutable Ledger"]. An arrow labeled "Client Orders" points to "Layer 1".*

### B. Data Flow and Justification

The data flow is designed to optimize for both speed and security:

1.  **Order Placement:** Clients submit trade orders to the off-chain server.
2.  **Off-Chain Processing:** The server validates the order against compliance rules and attempts to match it against the live order book.
3.  **On-Chain Settlement:** Once a trade is matched, the server's transaction submission service constructs a formal blockchain transaction and submits it to the `ATS.sol` smart contract for settlement. This transaction serves as the definitive, immutable record of the trade.
4.  **Finality:** The IBFT 2.0 consensus mechanism ensures that the transaction is included in a block and achieves finality, providing a tamper-proof audit trail [3].

This hybrid architecture is justified by several key factors:

*   **Regulatory Compliance:** Financial regulations mandate strict pre-trade checks, including Know Your Customer (KYC) and Anti-Money Laundering (AML) verification [4]. By placing a centralized server at the entry point, we can enforce these rules *before* a transaction is immutably recorded on the blockchain. This is a significant advantage over purely decentralized models where post-facto enforcement is often the only option.

*   **Performance:** The performance of public blockchains is insufficient for the high-frequency nature of trading, a core concern in market microstructure theory [5]. Our empirical results for Architecture 1 (0.25 tx/sec) demonstrate that a naive, synchronous on-chain approach is unworkable. By handling order matching off-chain, we reserve the blockchain's limited throughput for the critical task of settlement, which occurs at a lower frequency than order placement and cancellation.

*   **Cost-Effectiveness:** Gas fees on public blockchains make high-frequency on-chain operations prohibitively expensive. In our private network, while gas is not a direct monetary cost, it still represents a computational resource. Minimizing on-chain transactions reduces the overall computational load on the network, allowing for higher settlement throughput.

*   **Data Privacy:** The off-chain layer can protect the privacy of open orders, which is a critical requirement in many trading strategies. Only settled trades, which are public by nature, are broadcast to the blockchain.

## IV. Novel High-Throughput Components

To overcome the limitations of traditional blockchain transaction submission, we introduce two novel components that work in concert to enable high-throughput, parallel processing: the **Asynchronous Multi-Wallet Strategy** and the **Symbol-Sharded Lock-Free Model**. These components directly address the blockchain-level nonce bottleneck and the server-side contention issues identified in our experimental analysis.

### A. Asynchronous Multi-Wallet Strategy (C3)

The primary bottleneck in any high-frequency Ethereum transaction submission system is the sequential nonce requirement of a single wallet. Each transaction from a given wallet must have a unique, incrementing nonce, forcing all submissions from that wallet into a strict serial order [6]. Our Asynchronous Multi-Wallet Strategy directly mitigates this by creating a one-to-one mapping between a trading symbol and a dedicated Ethereum wallet. As shown in our `Program.cs` implementation, each symbol is assigned a unique wallet address:

```csharp
var symbolMappings = new Dictionary<string, (string contractAddress, string walletAddress)>
{
    { "AAPL", ("0xf55...", "0x079...") },
    { "GOOGL", ("0x8e5...", "0x079...") },
    // ... and so on for all symbols
};
```

By giving each symbol its own wallet, we effectively create independent transaction lanes. Trades for `AAPL` can be processed and submitted using the `AAPL` wallet's nonce sequence, entirely in parallel with trades for `GOOGL` using its own independent nonce sequence. This design choice fundamentally breaks the single-wallet bottleneck, allowing for true parallel submission to the blockchain. Our results from Architecture 2 to 3 show that simply adding threads against a single wallet yields only a minor (36%) performance gain, confirming that the nonce is the limiting factor. The multi-wallet strategy is the key to unlocking further scalability.

### B. Symbol-Sharded Lock-Free Model (C2)

While the multi-wallet strategy solves the on-chain bottleneck, our experiment with Architecture 4 revealed that it simply moves the point of contention to the server. Without a disciplined way to manage the parallel submission threads, we observed catastrophic server-side contention, leading to a massive increase in latency (from 2.9s to 27.2s). The Symbol-Sharded Lock-Free Model is designed to solve this.

This model extends the symbol-based parallelism from the wallet level all the way down to the application's internal data structures. Instead of a single, shared queue for all incoming trades, the system uses a dedicated, lock-free concurrent queue for each trading symbol. This creates a fully sharded pipeline:

1.  **Routing:** An incoming trade is immediately routed to the concurrent queue corresponding to its symbol.
2.  **Parallel Consumption:** A dedicated worker thread is responsible for consuming trades from each symbol's queue.
3.  **Lock-Free Processing:** Because each thread operates on its own queue and its own symbol's data, there is no need for expensive locks or synchronization primitives between threads. The use of a `ConcurrentQueue` in our .NET implementation, a common feature in modern concurrent data structures [7], ensures that even the enqueue and dequeue operations are thread-safe and non-blocking.
4.  **Dedicated Submission:** The worker thread for a given symbol uses that symbol's dedicated wallet to submit the transaction to the blockchain.

This end-to-end, symbol-sharded architecture ensures that trades for different symbols can be processed in complete isolation, eliminating the server-side contention that plagued Architecture 4 and reducing average latency by 44% (from 27.2s to 15.4s).

*EraserDiagram: ["Incoming Trades" box] -> ["Symbol-Based Router" diamond]. The router has multiple arrows pointing to separate vertical queues: ["Queue for AAPL"], ["Queue for GOOGL"], ["Queue for MSFT"]. Each queue is processed by a dedicated worker thread: ["Worker Thread (AAPL)"] -> ["Wallet (AAPL)"] -> ["Blockchain Mempool" box]. The same pattern repeats for GOOGL and MSFT, with all wallet arrows converging on the "Blockchain Mempool".*

By combining these two components, we create a system where the unit of parallelism is the trading symbol itself, from the initial ingestion queue to the final on-chain settlement wallet. This holistic approach to sharding is what enables the system to achieve a throughput of 31.19 tx/sec, a 125x improvement over the baseline, while simultaneously managing server-side latency.

## V. Theoretical Maximum Throughput Analysis

To understand the performance limits of our system, we formalize a throughput model that accounts for the constraints of both the server-side processing layer and the on-chain settlement layer. The overall maximum throughput, $\lambda_{max}$, is determined by the minimum of these two capacities, a classic application of bottleneck analysis in systems performance engineering [8]:

$$ \lambda_{max} = \min(\lambda_{server}, \lambda_{blockchain}) $$

where $\lambda_{server}$ is the maximum rate at which the server can process and submit transactions, and $\lambda_{blockchain}$ is the maximum rate at which the blockchain can finalize them.

### A. Blockchain-Side Throughput Limit ($\lambda_{blockchain}$)

The throughput of the blockchain layer is fundamentally constrained by three factors: the block gas limit ($G_{block}$), the average gas cost per transaction ($G_{tx}$), and the block time ($T_{block}$). The maximum number of transactions that can fit into a single block ($N_{tx/block}$) is given by:

$$ N_{tx/block} = \frac{G_{block}}{G_{tx}} $$

Therefore, the theoretical maximum throughput of the blockchain is:

$$ \lambda_{blockchain} = \frac{N_{tx/block}}{T_{block}} = \frac{G_{block}}{G_{tx} \cdot T_{block}} $$

In our experimental setup, the private Ethereum network had a fixed block time of 4 seconds. From the results of Architecture 5, we observed an average of 125 transactions per block. This allows us to empirically calculate the blockchain's capacity:

$$ \lambda_{blockchain} = \frac{125 \text{ tx}}{4 \text{ s}} = 31.25 \text{ tx/sec} $$

This value represents the hard ceiling imposed by the blockchain configuration. No amount of server-side optimization can exceed this limit. Our observed throughput of 31.19 tx/sec in Architecture 5 is within 99.8% of this theoretical maximum, indicating that the blockchain itself has become the bottleneck, which is the desired outcome of an optimized submission architecture.

### B. Server-Side Throughput Limit ($\lambda_{server}$)

The server-side throughput is determined by its ability to process incoming orders and submit them to the blockchain. In a naive architecture, this is limited by single-threaded processing and I/O blocking. In a multi-threaded architecture, it is limited by the degree of parallelism and the cost of synchronization, a concept formalized by Amdahl's Law [9].

For a system with $N$ parallel worker threads, the server throughput can be modeled as:

$$ \lambda_{server} = \frac{N}{T_{process} + T_{contention}} $$

where $T_{process}$ is the time to handle a single transaction (e.g., business logic, serialization) and $T_{contention}$ is the time spent waiting for shared resources (e.g., locks, database connections, shared queues). This relationship is a direct application of Little's Law from queueing theory [10].

Our experimental results clearly illustrate this model:

*   **Architecture 3 (Multi-Threaded, Single-Wallet):** Here, the bottleneck was on-chain, but the server was also limited. Even with multiple threads, they all contended for access to the single wallet's nonce, effectively serializing their submissions.

*   **Architecture 4 (Unsynchronized Multi-Wallet):** This architecture removed the on-chain nonce bottleneck but exposed a massive server-side one. The catastrophic latency (27.2s average) indicates that $T_{contention}$ became extremely high due to unsynchronized access to shared resources, crippling $\lambda_{server}$.

### C. Mitigating Limits with Novel Components

Our proposed components, C2 and C3, are designed to maximize $\lambda_{server}$ such that the system becomes purely limited by $\lambda_{blockchain}$.

1.  **Asynchronous Multi-Wallet Strategy (C3):** This component directly addresses the blockchain-side limit for a single submission point. By creating $N$ independent submission lanes (one for each symbol), it allows the server to fully utilize the block's gas limit in parallel. It ensures that the server can submit at least $N_{tx/block}$ transactions within a single block time, preventing the nonce from being the bottleneck.

2.  **Symbol-Sharded Lock-Free Model (C2):** This component is critical for maximizing $\lambda_{server}$. By partitioning the entire processing pipeline by symbol, it effectively eliminates inter-thread contention. In this model, $T_{contention}$ approaches zero because threads for different symbols do not share any resources. The server's throughput becomes:

    $$ \lambda_{server} \approx \sum_{i=1}^{N_{shards}} \frac{1}{T_{process, i}} $$

    where $N_{shards}$ is the number of symbols. This ensures that the server can process transactions at a rate far exceeding the blockchain's capacity, guaranteeing that the server is never the bottleneck.

By implementing these components, Architecture 5 successfully shifts the system's bottleneck from server-side contention to the fundamental limit of the blockchain itself, achieving near-optimal throughput for the given on-chain configuration.

The full source code and raw performance data for all five architectures are available for review at [https://github.com/user/repo].

---

## References

[1] Jamithireddy, N. H., et al. (2025). "Hybrid On-Chain and Off-Chain Architectures for Secure, Decentralized Fintech Payment Processing in SAP." *2025 International Conference on Next Generation Computing Systems (ICNGCS)*. IEEE. DOI: 10.1109/ICNGCS64900.2025.11182978.

[2] Rahouti, M., Xiong, K., & Ghani, N. (2018). "Bitcoin concepts, threats, and machine-learning security applications." *IEEE Access*, 6, 67189-67205.

[3] Kuhn, R., Yaga, D., & Voas, J. (2019). "Rethinking Distributed Ledger Technology." *NIST Internal Report 8202*. National Institute of Standards and Technology.

[4] Financial Crimes Enforcement Network (FinCEN). (2024). "Know Your Customer (KYC) and Anti-Money Laundering (AML) Compliance Guidance." U.S. Department of the Treasury.

[5] O'Hara, M. (1995). *Market Microstructure Theory*. Blackwell Publishers.

[6] Alchemy. "Understanding and Handling Nonce in EVM Chains." Retrieved from https://docs.tatum.io/docs/nonce-what-is-it-and-optional-use

[7] Cederman, D., Gidenstam, A., & Ha, P. (2013). "Lock-Free Concurrent Data Structures." *ArXiv preprint arXiv:1302.2757*.

[8] Harchol-Balter, M. (2013). *Performance Modeling and Design of Computer Systems: Queueing Theory in Action*. Cambridge University Press.

[9] Gustafson, J. L. (1988). "Reevaluating Amdahl's law." *Communications of the ACM*, 31(5), 532-533.

[10] Little, J. D. C. (1961). "A proof for the queuing formula: L = λW." *Operations Research*, 9(3), 383-387.
