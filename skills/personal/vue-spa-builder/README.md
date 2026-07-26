---
agent_skip: true
description: 本文件仅供开发者阅读，AI agent 应跳过此文件，直接阅读 SKILL.md。
---

[English](./README_en.md) | 简体中文

# Vue SPA Builder

> 将 Vue 3 项目打包为**双击即用**的离线 HTML 应用，零配置、零依赖、零网络。

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Vue 3](https://img.shields.io/badge/Vue-3.4-green.svg)](https://vuejs.org/)
[![Vite](https://img.shields.io/badge/Vite-5.0-purple.svg)](https://vitejs.dev/)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)](https://docs.microsoft.com/en-us/powershell/)

---

## 📦 这是什么？

**Vue SPA Builder** 是一个面向 AI 辅助开发（Vibecoding）的技能包（Skill），用于指导 AI 和开发者将 Vue 3 单页应用（SPA）打包为**离线可用的静态 HTML 压缩包**。

任何人都可以下载、解压、双击 `index.html` 直接运行——**无需安装 Node.js，无需启动服务器，无需联网**。

---

## 🎯 解决什么问题？

| 场景 | 痛点 | 本方案 |
|------|------|--------|
| 你用 Vue 写了个小工具（JSON 格式化、时间戳转换、二维码生成等） | 想分享给同事，对方不愿装 Node.js | 打包成 `dist.zip`，对方解压即用 |
| 你维护一个开源项目 | 用户想快速体验，不想 clone 仓库装依赖 | 在 GitHub Releases 提供离线压缩包 |
| 你需要一个内部管理工具 | 没有服务器部署，纯前端 + localStorage 就够了 | 双击 `index.html` 即可使用 |

---

## ✨ 核心特性

- 🔧 **强制配置**：自动设置 `base: './'` 和 `createWebHashHistory()`，确保 `file://` 协议下正常加载
- 📦 **单文件打包**：集成 `vite-plugin-singlefile`，将所有 JS/CSS 内联到 HTML，彻底绕过 `file://` 协议的 CORS 限制
- 🧩 **一键创建项目**：`new-project.ps1` 交互式创建 Vue 3 项目，自动安装必须依赖（`vite-plugin-singlefile`）
- 🚀 **一键构建发布**：`build-and-pack.ps1` 执行构建、复制说明文件、打包为 `.zip`，自动更新 `.gitignore`
- 📝 **说明文件管理**：首次构建时由 AI 生成 README.txt，后续构建根据开发内容自动更新
- 🤖 **AI 铁律约束**：保留注释、禁止擅自重构 script、CSS 风格确认——防止 AI 引入无谓 Bug

---

## 📁 项目结构

```
vue-spa-builder/
├── README.md                  # 本文件（中文版）
├── README_en.md               # 英文版
├── SKILL.md                   # AI 技能定义（最高准则，AI 必读）
├── scripts/
│   ├── check-node.ps1         # 检查 Node.js 环境
│   ├── new-project.ps1        # 交互式创建 Vue 3 项目
│   └── build-and-pack.ps1     # 一键构建 + 打包
├── references/
│   ├── vite-config-reference.md
│   └── router-reference.md
└── assets/
    ├── vite.config.template.js
    └── router-index.template.js
```

---

## 🚀 快速开始

### 1. 创建新项目

```powershell
# 检查 Node.js 是否已安装
.\scripts\check-node.ps1

# 交互式创建 Vue 3 项目（自动安装 vite-plugin-singlefile）
.\scripts\new-project.ps1
```

按提示输入项目名称，选择需要的额外依赖（Pinia、Vue Router、Axios 等）。

### 2. 开发你的工具

在 `src/` 下写你的 Vue 组件，`npm run dev` 实时预览。

### 3. 构建 + 打包发布

```powershell
# 进入项目根目录，运行打包脚本
.\scripts\build-and-pack.ps1
```

输入版本号（如 `v1.0.0`），脚本自动完成构建、复制说明文件、打包 `.zip`。

生成的文件位于项目根目录的上一级：
- `项目名-版本号.zip` —— 离线发行包
- `Source Code.zip` —— 源码包（可选，加 `-SkipSourceZip` 跳过）

### 4. 发布到 GitHub Releases

将 `项目名-版本号.zip` 上传到 Release 页面，用户下载后解压双击 `index.html` 即可使用。

---

## 📋 依赖要求

| 角色 | 要求 |
|------|------|
| **开发者** | Node.js LTS + npm（用于开发和构建） |
| **最终用户** | 现代浏览器（Chrome / Edge 最新版） |

---

## ⚙️ 开发者注意事项

### PowerShell 脚本编码

本项目提供的 `.ps1` 脚本采用 **UTF-8 with BOM** 编码，脚本内容全部使用英文，以确保在 Windows PowerShell 5（默认版本）下正常解析，避免中文字符导致的语法错误。

如果你需要修改这些脚本，请：
1. 使用 VS Code 或支持 UTF-8 with BOM 的编辑器
2. 保存时选择 **UTF-8 with BOM** 编码
3. 保持所有注释和提示信息为英文

---

## 🤝 如何贡献

欢迎提交 Issue 或 Pull Request！特别欢迎：
- 补充更多实战坑点
- 优化 PowerShell 脚本
- 完善参考文档

---

## 📄 许可证

MIT © 2026 — 可自由使用、修改、分发。

---

**详细规则、铁律和脚本用法请务必阅读 [`SKILL.md`](./SKILL.md)。**