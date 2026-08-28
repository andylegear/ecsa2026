# ECSA 2026 Industry Track — Paper, Poster & Presentation Artefacts

## About This Project

This repository contains the LaTeX sources, poster, and conference presentation for the paper:

> **"A Lock-Free, Non-blocking, In-line Processing Architecture for High Throughput and Regulatory Compliant Blockchain Trading Applications"**
> Andrew Le Gear, Jim Buckley, Tawny Whatmore, Ashish Sai
> ECSA 2026 Industry Track, Bolzano, Italy (paper ID 130)

The paper addresses a core tension in **Regulated DeFi (R-DeFi)**: blockchain trading systems need to be simultaneously high-throughput and regulatory compliant, but off-chain compliance checks (KYC/AML, trade surveillance) and on-chain settlement pull system design in opposite directions. Naive parallelisation is also constrained by Ethereum's strict per-account nonce ordering, which caps throughput gains and can shift bottlenecks into server-side lock contention rather than removing them.

To investigate this, five blockchain trading architecture variants were implemented and empirically benchmarked — from a sequential single-threaded baseline through to a **lock-free, symbol-sharded, multi-wallet design** (inspired by the LMAX Disruptor pattern from high-frequency trading), which achieved the highest throughput of the variants tested. The companion benchmarking codebase and empirical results live in a separate repository: [blockchain-trading-architectures](https://github.com/HorizonFintex/blockchain-trading-architectures).

**This repository is the writing/dissemination side of that work** — the academic paper, the conference poster, and the 10-minute Industry Track talk (slides + PDF/PPTX exports) built from it, rather than the benchmarking code itself.

## Repository Structure

| Path | Contents |
|---|---|
| `main.tex`, `sections/` | Main paper source (LNCS format) |
| `poster.tex` | Conference poster source |
| `ecsa2026-presentation/` | Slidev-based 10-minute talk (`slides.md`, `style.css`, PDF/PPTX exports) |
| `submission/` | Camera-ready and source packages submitted to ECSA 2026 |
| `sources/` | Working drafts/notes per paper section (intro, related work, methodology, results, threats, conclusions) |
| `revisions/` | Reviewer feedback and revision tracking |
| `references.bib`, `paper_references.bib` | Bibliography |

## LaTeX Setup for VS Code

This folder is also configured as a general-purpose LaTeX project for VS Code.

## 📋 Prerequisites

### 1. Install a LaTeX Distribution

You need a local LaTeX distribution (the "compiler") installed on your system:

| OS | Recommended Distribution | Download |
|---|---|---|
| **Windows** | MiKTeX | [miktex.org](https://miktex.org/download) |
| **macOS** | MacTeX or BasicTeX | [tug.org/mactex](https://www.tug.org/mactex/) |
| **Linux** | TeX Live | `sudo apt install texlive-full` (Debian/Ubuntu) |

> **Note for MiKTeX**: During installation, choose "Install missing packages on-the-fly" for automatic package management.

### 2. Install VS Code Extensions

Install the essential LaTeX Workshop extension (already recommended in this workspace):

```
ext install james-yu.latex-workshop
```

## 📁 Project Structure

```
├── .vscode/
│   └── settings.json    # LaTeX Workshop configuration
├── main.tex             # Main LaTeX document
├── references.bib       # Bibliography file
└── README.md            # This file
```

## 🚀 Getting Started

1. **Open** this folder in VS Code
2. **Open** `main.tex`
3. **Build** the document:
   - Press `Ctrl+Alt+B` (Windows/Linux) or `Cmd+Alt+B` (macOS)
   - Or save the file (auto-build is enabled)
   - Or use the green "Build" button in the LaTeX Workshop panel
4. **View** the PDF:
   - Press `Ctrl+Alt+V` (Windows/Linux) or `Cmd+Alt+V` (macOS)
   - Or click the "View PDF" button

## ⌨️ Useful Keyboard Shortcuts

| Action | Windows/Linux | macOS |
|---|---|---|
| Build LaTeX | `Ctrl+Alt+B` | `Cmd+Alt+B` |
| View PDF | `Ctrl+Alt+V` | `Cmd+Alt+V` |
| SyncTeX (PDF → Source) | `Ctrl+Click` in PDF | `Cmd+Click` in PDF |
| Forward SyncTeX (Source → PDF) | `Ctrl+Alt+J` | `Cmd+Alt+J` |
| Clean auxiliary files | `Ctrl+Alt+C` | `Cmd+Alt+C` |

## 🔧 Configuration

The `.vscode/settings.json` file contains:

- **Auto-build on save**: Documents compile automatically when you save
- **PDF viewer**: Opens in a VS Code tab (can change to external viewer)
- **SyncTeX**: Click in PDF to jump to source code
- **Auto-clean**: Removes auxiliary files after successful build
- **Multiple recipes**: pdflatex, xelatex, lualatex, and latexmk

## 📚 Adding Bibliography Citations

1. Add entries to `references.bib`
2. Include in your document:
   ```latex
   \bibliographystyle{plain}
   \bibliography{references}
   ```
3. Cite using `\cite{key}` where `key` is the BibTeX entry identifier

## 🎨 Recommended Extensions

- **LaTeX Workshop** - Core IDE features (required)
- **LaTeX Utilities** - Additional features like live snippets
- **LTeX** - Grammar and spell checking with LanguageTool
- **Code Spell Checker** - Simple offline spell checking

## 🔍 Troubleshooting

### Build fails with "pdflatex not found"
- Ensure your LaTeX distribution is installed and in your system PATH
- Restart VS Code after installing the distribution

### Missing packages
- MiKTeX: Enable "Install missing packages on-the-fly" in MiKTeX Console
- TeX Live: Run `tlmgr install <package-name>`

### PDF not updating
- Check the "Problems" panel for errors
- Try cleaning auxiliary files: `Ctrl+Alt+C`
- Rebuild: `Ctrl+Alt+B`

## 📖 Resources

- [LaTeX Workshop Documentation](https://github.com/James-Yu/LaTeX-Workshop/wiki)
- [LaTeX Wikibook](https://en.wikibooks.org/wiki/LaTeX)
- [Overleaf Documentation](https://www.overleaf.com/learn)
- [CTAN Package Repository](https://ctan.org/)
