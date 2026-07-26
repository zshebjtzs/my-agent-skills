---
agent_skip: true
description: This file is for human developers only. AI agents should skip this file and read SKILL.md directly.
---

English | [简体中文](./README.md)

# Vue SPA Builder

> Package Vue 3 applications into **double-click-to-run** offline HTML bundles. Zero configuration, zero dependencies, zero network required.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Vue 3](https://img.shields.io/badge/Vue-3.4-green.svg)](https://vuejs.org/)
[![Vite](https://img.shields.io/badge/Vite-5.0-purple.svg)](https://vitejs.dev/)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)](https://docs.microsoft.com/en-us/powershell/)

---

## 📦 What is this?

**Vue SPA Builder** is a skill package designed for AI-assisted development (Vibecoding). It guides AI assistants and human developers to build and package Vue 3 single-page applications (SPAs) into **offline-ready static HTML archives**.

Anyone can download, unzip, and double-click `index.html` to run the application—**no Node.js installation, no server setup, no internet connection required**.

---

## 🎯 Problem Statement

| Scenario | The Pain Point | This Solution |
|----------|---------------|----------------|
| You built a handy Vue tool (JSON formatter, timestamp converter, QR generator) | Sharing it with colleagues who don't want to install Node.js | Package as `dist.zip` — they unzip and double-click |
| You maintain an open-source project | Users want a quick demo without cloning the repo and installing dependencies | Provide offline archives via GitHub Releases |
| You need an internal admin panel | No server to deploy on — pure frontend + localStorage is sufficient | Double-click `index.html` and it just works |

---

## ✨ Key Features

- 🔧 **Forced Configuration**: Automatically sets `base: './'` and `createWebHashHistory()` to ensure proper loading under the `file://` protocol
- 📦 **Single-File Bundling**: Integrates `vite-plugin-singlefile` to inline all JS/CSS into HTML, completely bypassing `file://` CORS restrictions
- 🧩 **One-Click Project Creation**: `new-project.ps1` interactively bootstraps a Vue 3 project with mandatory dependencies (`vite-plugin-singlefile`) pre-installed
- 🚀 **One-Click Build & Package**: `build-and-pack.ps1` runs the build, copies readme files, packages as `.zip`, and updates `.gitignore` automatically
- 📝 **Readme Management**: AI generates README.txt on first build and updates it on subsequent builds based on development context
- 🤖 **AI Guardrails**: Preserve comments, no unauthorized script refactoring, CSS style confirmation — preventing AI from introducing bugs

---

## 📁 Project Structure

```
vue-spa-builder/
├── README.md                  # This file (English version)
├── README_zh.md               # Chinese version
├── SKILL.md                   # AI skill definition (the ultimate authority — AI must read this)
├── scripts/
│   ├── check-node.ps1         # Check Node.js environment
│   ├── new-project.ps1        # Interactively create a Vue 3 project
│   └── build-and-pack.ps1     # One-click build + package
├── references/
│   ├── vite-config-reference.md
│   └── router-reference.md
└── assets/
    ├── vite.config.template.js
    └── router-index.template.js
```

---

## 🚀 Quick Start

### 1. Create a New Project

```powershell
# Verify Node.js is installed
.\scripts\check-node.ps1

# Interactively create a Vue 3 project (vite-plugin-singlefile auto-installed)
.\scripts\new-project.ps1
```

Follow the prompts to enter a project name and select optional dependencies (Pinia, Vue Router, Axios, etc.).

### 2. Build Your Tool

Write your Vue components in `src/`, and use `npm run dev` for live preview.

### 3. Build + Package for Release

```powershell
# Navigate to your project root, then run:
.\scripts\build-and-pack.ps1
```

Enter a version number (e.g., `v1.0.0`). The script will build the project, copy readme files, and produce a `.zip` archive.

Output files are placed in the parent directory of your project root:
- `project-name-version.zip` — the offline release package
- `Source Code.zip` — source code archive (optional; add `-SkipSourceZip` to skip)

### 4. Publish to GitHub Releases

Upload `project-name-version.zip` to your Release page. Users download, unzip, and double-click `index.html` — that's it.

---

## 📋 Requirements

| Role | Requirement |
|------|-------------|
| **Developer** | Node.js LTS + npm (for development and building) |
| **End User** | A modern browser (latest Chrome / Edge recommended) |

---

## ⚙️ Developer Notes

### PowerShell Script Encoding

All `.ps1` scripts in this package are saved with **UTF-8 with BOM** encoding and contain only English text. This ensures compatibility with Windows PowerShell 5 (the default version on most Windows systems), avoiding parsing errors caused by non-ASCII characters.

If you need to modify these scripts:
1. Use an editor that supports UTF-8 with BOM (e.g., VS Code)
2. Save with **UTF-8 with BOM** encoding
3. Keep all comments and user-facing messages in English

---

## 🤝 Contributing

Issues and Pull Requests are welcome! Contributions of particular interest include:
- Additional real-world pitfalls and lessons learned
- PowerShell script improvements
- Documentation enhancements

---

## 📄 License

MIT © 2026 — Free to use, modify, and distribute.

---

**For detailed rules, AI guardrails, and script usage, please read [`SKILL.md`](./SKILL.md).**