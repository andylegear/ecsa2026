## V. Threats to Validity

In any empirical study, it is crucial to acknowledge the limitations that may affect the interpretation and generalizability of the findings. We follow the widely accepted framework for validity in empirical research, which categorizes threats into internal, construct, and external validity [1].

### A. Internal Validity

Internal validity refers to the confidence that the observed effects are indeed caused by our architectural changes, rather than by confounding variables [1]. We strengthened internal validity through our **incremental ablation study**, which allowed us to isolate the impact of each architectural modification. Furthermore, all experiments were conducted on a **dedicated, controlled testbed**, ensuring that external factors like network fluctuations or co-located processes did not interfere with the measurements. The consistent gas usage across architectures further suggests that the performance differences were not due to variations in on-chain computational cost.

### B. Construct Validity

Construct validity concerns how well our measurements capture the theoretical concepts they are intended to represent [1]. Our primary metrics—**throughput, latency, and block utilization**—are standard, well-understood indicators of system performance in distributed systems and blockchain research [2], which supports the validity of our constructs. However, our workload, while representative, is a simplification. It consists of a fixed number of atomic trades distributed evenly across symbols and does not model more complex, bursty trading patterns that might occur in a live environment. Therefore, while our metrics are valid, the specific performance numbers are tied to this particular workload.

### C. External Validity

External validity addresses the generalizability of our results to other populations, settings, and times [1]. The most significant threat to this study lies in the generalizability from our testbed to real-world systems. Our experiments were conducted on a **private Ethereum network with an IBFT 2.0 consensus mechanism and a fixed 4-second block time**. This environment is not representative of the public Ethereum mainnet, which features variable gas prices, unpredictable network congestion, and a different consensus model (Proof-of-Stake).

However, it is crucial to note that our research is not intended to optimize for the public mainnet. Rather, our work targets the significant and growing domain of **private and permissioned blockchains**, which are widely used in enterprise settings such as finance, supply chain, and healthcare [3]. These systems are specifically designed to provide a controlled environment with higher throughput and lower latency for business-critical applications [4]. Therefore, our choice of a private, permissioned testbed aligns directly with our target application domain.

While the fundamental principles we have identified—such as nonce management bottlenecks, server-side contention, and the benefits of sharding—should generalize to other blockchain systems, the precise quantitative improvements (e.g., the 125x throughput increase) are specific to our testbed conditions. As research on testbed evaluations has shown, results from controlled environments may not always translate directly to the complexities of different network configurations [5]. Future work should aim to validate these architectural patterns on other permissioned blockchain platforms, such as Hyperledger Fabric, to further establish their generalizability within the enterprise context.

---

## References

[1] W. R. Shadish, T. D. Cook, and D. T. Campbell, *Experimental and Quasi-Experimental Designs for Generalized Causal Inference*. Houghton Mifflin, 2002.

[2] J. L. Hennessy and D. A. Patterson, "Computer architecture: A quantitative approach," 6th ed., *Morgan Kaufmann*, 2017.

[3] R. Lewis, C. McPartland, and R. Ranjan, "Blockchain and financial market innovation," *Economic Perspectives*, vol. 41, no. 7, 2017.

[4] Hyperledger Foundation, "Hyperledger Fabric Documentation," [Online]. Available: https://hyperledger-fabric.readthedocs.io/.

[5] E. Allman, M. Allman, A. Falk, V. Paxson, and J. Salt, "Pitfalls for testbed evaluations of Internet systems," *ACM SIGCOMM Computer Communication Review*, vol. 40, no. 3, pp. 44–49, 2010.
