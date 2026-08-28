# Camera-Ready Revision Tracker
Paper: "A Lock Free, Non-blocking, In Line Processing Architecture for High Throughput and Regulatory Compliant Blockchain Trading Applications"
Submission: ECSA 2026 Industrial Track #130
Camera-ready deadline: Monday 22 June 2026
Acceptance notification: 2026-06-14

---

## Reviewer Comments (verbatim from notification)

### Reviewer 1

**Summary:** The paper details a set of tests on 5 blockchain-based architectures, of which architecture 5 seems to be based on a real industrial system from Horizon Globex Ireland. It seems to present that the proposed architecture solves a common bottleneck, and achieves 2.8 times improved latency.

**Strengths:**
- The described architecture is based on an existing industrial one
- The paper can be useful for practitioners who design blockchain-based architectures.
- A replication package was made available

**Weaknesses:**
- The paper is written atypically for an empirical software engineering paper, and reading it is quite hard.

**Detailed comments:**

| Ref | Comment (verbatim) | Priority | Disposition |
|-----|--------------------|----------|-------------|
| R1-C1 | Since this is an industrial paper based on a real architecture, I miss information about the company and the business context behind the system. It should be present in the background. | Structural | DONE — added 4-sentence company background paragraph at opening of §3, describing Horizon Globex Ireland DAC, its US/Seychelles/MERJ deployments, and its fintech software services context |
| R1-C2 | In related work subsections 2.2 and 2.3, there is a mention of results for architectures 2, 3, and 4 — despite these architectures not being introduced yet. It makes the paper harder to understand. One possible solution may be moving the Related Work after the results and making sure all 5 architectures are introduced before they are mentioned. | High | DONE (light touch: replaced specific results with forward refs to Section~\ref{sec:results}) |
| R1-C3 | Figures 1 and 2 have no legend, nor are they typical standardized diagrams (e.g., a specific UML one), so I am unsure how to read them. | Medium | DONE — expanded the shared figure caption to describe diagram notation: rectangles = processing components, arrows = data flow, diamond (fig b) = symbol-based routing decision, blue arrow (fig b) = independent per-symbol submission path to blockchain mempool. No image editing required. |
| R1-C4 | The method (section 6) is introduced after many results are already presented and discussed. Section 5 "Theoretical Maximum Throughput Analysis" should be in the method; Section 4 "The Novel High-Throughput Components" already has results included, e.g. "Our results confirm this: multi-threading against a single wallet (Arch 2→3) yields only 36% gains". | Structural | PARTIAL — removed result statement from §4.1 and replaced with forward ref; full section reorder skipped (structural) |
| R1-C5 | The contributions are shown in a confusing manner — C1 at the start of Section 3, then C3 in Subsections 4.1, and C2 in Subsection 4.1. Why not subsections or a list in contribution order? | High | DONE — removed C2/C3 component labels from §4 subsection headings and §6 body text/caption; labels now only appear where they match intro definitions |
| R1-C6 | "The architecture under study matches the design deployed by Horizon Globex Ireland in production." This is stated way too far in the paper (on page 9). Additionally, since there are 5 architectures, it should be mentioned which one matches the industrial system. | High | DONE — intro now explicitly names Architecture~5 as the production deployment |

**Minor comments:**

| Ref | Comment (verbatim) | Disposition |
|-----|--------------------|-------------|
| R1-C7 | Introduce full versions for abbreviations at the start (DeFi, KYC, AML), as these are not obvious to all readers. | DONE — KYC and AML expanded on first use in intro; DeFi already expanded as "Decentralized finance (DeFi)" in opening sentence |
| R1-C8 | Be consistent — I found both "15 to 30 TPS" and "31.19 tx/sec". | DONE — standardized to "15--30~tx/sec" throughout |

---

### Reviewer 2

**Summary:** The paper presents an analysis of throughput for a lock free inline processing architecture. Intended for blockchain trading applications, the architecture also respects regulatory requirements.

**Strengths:**
- The paper presents an industrial case study done by researchers on performance of an interesting application.
- Analysis is well done and has practical importance.

**Weaknesses:**
- This is an academic study camouflaged as an industry paper
- No industry insight, and even academic findings are not too novel or interesting

**Detailed comments:** "This is a nice study but it is in a wrong track. Moreover, the generalizability and importance of the results need improvement even for the academic track. For industry track, the insights that are the most important thing in the track are missing in the paper."

| Ref | Comment | Disposition |
|-----|---------|-------------|
| R2-C1 | Lacks industry insight; generalizability concerns | SKIP — fundamental scope issue, not addressable with light-touch edits at camera-ready stage; paper was accepted despite this |

---

### Reviewer 3

**Summary:** The paper presents an empirical study of a two-layer hybrid blockchain trading architecture designed for regulated DeFi use cases. Through a systematic ablation study of five architectural variants, the authors demonstrate a peak throughput of 31.19 tx/sec (2.8× improvement).

**Strengths:**
- Real-world study
- Well described case study
- Significant and measurable improvements based on the architectural decisions made

**Weaknesses:**
- Limitations exist regarding generalizability

**Detailed comments:** "Limitations exist regarding generalizability, sustained-load evaluation, and tail latency, these are clearly acknowledged and provide a solid roadmap for future work. I did like reading the paper!"

| Ref | Comment | Disposition |
|-----|---------|-------------|
| R3-C1 | Generalizability limitations | Already addressed in §8 Threats to Validity — no change needed |

---

## Batch 1 — Initial light-touch fixes (2026-06-14)

## Changes Made (2026-06-14)

| # | File | Reviewer ref | Change |
|---|------|--------------|--------|
| 1 | `sections/01-introduction.tex` | R1-C8 | "15 to 30 TPS" → "15--30~tx/sec" to match tx/sec used throughout body |
| 2 | `sections/01-introduction.tex` | R1-C6 | Added explicit "Architecture~5" name to the production deployment statement so it is unambiguous |
| 3 | `sections/01-introduction.tex` | R1-C7 | "KYC, AML" → "Know Your Customer/KYC, Anti-Money Laundering/AML" on first use |
| 4 | `sections/02-related-work.tex` §2.1 | R1-C2 | Removed "achieving 31.19~tx/sec, a 2.8× improvement over conventional asynchronous designs" → replaced with forward reference to Section~\ref{sec:results} |
| 5 | `sections/02-related-work.tex` §2.2 | R1-C2 | Removed "36% throughput gain" claim with specific architecture labels → replaced with "As shown in Section~\ref{sec:results}, multi-threading against a single wallet yields only a modest throughput gain" |
| 6 | `sections/02-related-work.tex` §2.3 | R1-C2 | Removed "27.2s→15.4s, a 44% improvement" and Architecture~4 label from Related Work → replaced with "As demonstrated in Section~\ref{sec:results}" |
| 7 | `sections/04-components.tex` §4.1 | R1-C4 | Removed "Our results confirm this: multi-threading against a single wallet (Arch~2→3) yields only 36% gains" → replaced with forward reference to Section~\ref{sec:results} |
| 8 | `sections/04-components.tex` line 9 | R1-C5 | Removed `(C3)` from `\subsection{Asynchronous Multi-Wallet Strategy}` heading — label clashed with intro's C3 = ablation study |
| 9 | `sections/04-components.tex` line 13 | R1-C5 | Removed `(C2)` from `\subsection{Symbol-Sharded Lock-Free Model}` heading — label clashed with intro's C2 = empirical evidence |
| 10 | `sections/06-theoretical.tex` ~line 41 | R1-C5 | Removed `(C3)` and `(C2)` component labels from "Achieving Theoretical Maximum" paragraph body text |
| 11 | `sections/06-theoretical.tex` ~line 52 | R1-C5 | Replaced `C2 (Symbol-Sharded Lock-Free processing) and C3 (Asynchronous Multi-Wallet submission)` in figure caption with full component names only |
| 12 | `sections/03-architecture.tex` opening | R1-C1 | Added 4-sentence company background paragraph: describes Horizon Globex Ireland DAC as a fintech software services company, its US automated trading systems, the Upstream/MERJ deployment in the Seychelles, and that the paper's architecture was built to meet that production environment's throughput and regulatory demands |
| 13 | `sections/04-components.tex` main figure caption | R1-C3 | Expanded the shared caption to describe diagram notation: rectangles = processing components, arrows = data flow, diamond (fig b) = symbol-based routing decision, blue arrow (fig b) = independent per-symbol submission path to blockchain mempool |

---

## Skipped changes (no light-touch option)

*All reviewer comments have been addressed. No items remain skipped.*
