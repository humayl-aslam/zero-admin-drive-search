# 📚 Zero-Admin SMB Resource Finder & Catalog

A high-performance, zero-installation search engine and directory navigator designed for locked-down corporate and educational network shares (SMB). 

Searches **100,000+ documents in under 15ms** and provides **true 1-click native file launching** (Word, PDF, PowerPoint) without requiring administrator privileges, Python, web servers, or third-party software installations.

---

## 🎯 The Problem
In enterprise and school environments:
1. **Severe Latency:** Windows File Explorer search over mapped network drives (`Z:\`) is notoriously slow, taking 5–15 minutes on large shares (400+ GB) and frequently freezing.
2. **Strict IT Policies:** Non-admin user accounts cannot install dedicated search tools (e.g., *Everything by Voidtools*), and corporate execution policies block external PowerShell scripts.
3. **Browser Security Sandbox:** Modern web browsers (Chrome/Edge) strictly block `file:///` hyperlinks with `ACCESS_DENIED`, preventing 1-click launching from internal web pages.

---

## 💡 The Solution
This project combines high-speed native Windows traversal with a lightweight JScript/HTA frontend:

* **Backend Engine (`Auto_Update_Index.ps1`):** Uses multi-threaded `robocopy` in list-only mode to crawl massive network trees in minutes. Streams records line-by-line via `[System.IO.StreamWriter]` directly into `data.js` to prevent memory crashes on 100k+ arrays.
* **Frontend Application (`Resource_Finder.hta`):** A self-contained Windows HTML Application (HTA) running modern Trident/IE engine emulation. Uses native `Shell.Application` and `WScript.Shell` ActiveX APIs to achieve instant 1-click execution of documents in their default desktop software.
* **Self-Locating Architecture:** Automatically detects its current running directory and remaps drive letters on the fly—works seamlessly whether mapped as `Z:\`, `P:\`, or accessed via direct UNC paths (`\\server\share`).

---

## ✨ Features
* **Sub-15ms Search:** Pre-indexes search strings into memory; filters 100k records instantaneously as you type.
* **Punctuation & Order Blind:** Forgiving keyword tokenizer ignores dashes, dots, and underscores (`grade 10 math` matches `Grade-10_Math[Final].docx`).
* **Interactive Folder Drilling:** 2-tier hierarchical catalog allows users to browse primary departments, inspect subfolder tallies, and scope search queries to specific folders.
* **Keyword Highlighting:** Matches are highlighted in yellow on the fly without performance degradation.
* **1-Click Clipboard Copy:** Instant path copying via native `window.clipboardData`.
* **Automated Sync:** Runs silently in the background via Windows Task Scheduler to capture daily file modifications.

---

## 🚀 Quick Start
1. Place `Resource_Finder.hta`, `Auto_Update_Index.ps1`, and `Reindex_Now.bat` into the root of your shared drive.
2. Run `Reindex_Now.bat` once to generate the initial `data.js` search index.
3. Double-click `Resource_Finder.hta` to start searching!

---

## 🔒 Security
* **Sandboxed Path Validation:** Strictly validates target paths to prevent directory traversal outside the active root share.
* **Format Whitelisting:** Enforces extension execution boundaries (only `.pdf`, `.docx`, and `.pptx` can be triggered).

---

## 📄 License
MIT License. Free for educational and commercial use.