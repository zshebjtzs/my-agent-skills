---
agent_skip: true
description: 本文件仅供开发者阅读，AI agent 应跳过此文件，直接阅读 SKILL.md。
---
# Vue SPA Builder —— 离线分发技能包

> 将 Vue 3 + Vite 项目打包为**双击即开**的离线 HTML 应用，方便通过 GitHub Releases 分享给任何人，接收方无需安装 Node.js、无需网络、无需服务器。

---

## 这是什么？

这是一个面向 **AI 辅助开发（Vibecoding）** 的技能包（Skill），专门用于指导 AI（如 Cursor、Cline、Claude 等）和开发者快速构建、打包、发布 **纯前端 Vue 单页应用（SPA）**，并输出为可直接离线运行的静态压缩包。

## 解决什么问题？

- 你用 Vue 写了一个小工具（如 JSON 格式化、时间戳转换、Markdown 编辑器），想分享给同事或网友。
- 对方不想安装 Node.js，也不想配置服务器，只想下载后**双击 `index.html` 就能用**。
- 你希望每次发布新版本时，能一键完成构建 + 打包 + 生成规范的 Release 压缩包。

## 核心功能

- ✅ 强制配置 `vite.config.js` 为 `base: './'`（资源相对路径）
- ✅ 强制路由使用 `createWebHashHistory()`（解决 `file://` 协议下的 404）
- ✅ 提供 PowerShell 脚本：
  - `check-node.ps1` —— 检查 Node.js 环境
  - `new-project.ps1` —— 交互式创建 Vue 3 项目并自动配置强制项
  - `build-and-pack.ps1` —— 一键构建、打包为 `.zip`（含源码包），并更新 `.gitignore`
- ✅ 内嵌 AI 开发铁律（保留注释、不擅自重构 script、CSS 风格确认等）
- ✅ 提供 `assets/` 中的配置模板（`vite.config.js`、`router/index.js`）

## 适用场景

- 个人效率工具（数据处理、文本转换、图表展示等）
- 内部管理系统原型（无后端，纯前端 + localStorage）
- 开源项目通过 GitHub Releases 分发“绿色免安装版”

## 快速开始

1. 将本技能包复制到你的项目根目录，或作为独立仓库引用。
2. 阅读 `SKILL.md` 了解完整规则和脚本用法。
3. 运行 `scripts/` 下的脚本完成项目创建或打包：
   ```powershell
   .\scripts\build-and-pack.ps1
   ```
4. 生成的 `.zip` 文件位于项目根目录同级，可直接上传至 GitHub Release。

## 文件结构

```
vue-spa-builder/
├── README.md                # 本文件（技能包概述）
├── SKILL.md                 # 详细技能定义、铁律、脚本说明、坑点记录（AI 必读）
├── scripts/                 # PowerShell 自动化脚本
│   ├── build-and-pack.ps1
│   ├── check-node.ps1
│   └── new-project.ps1
├── references/              # 技术参考文档
│   ├── vite-config-reference.md
│   └── router-reference.md
└── assets/                  # 配置模板文件
    ├── vite.config.template.js
    └── router-index.template.js
```

## 依赖要求

- **开发者**：需安装 Node.js（建议 LTS 版本）和 npm。
- **最终用户**：无需任何环境，仅需现代浏览器（Chrome / Edge 最新版）。

## 如何贡献

欢迎提交 Issue 或 Pull Request，尤其欢迎补充更多坑点记录或优化脚本逻辑。

## 许可证

MIT（可自由使用、修改、分发）。

---

**详细规则、铁律和脚本用法请务必阅读 [`SKILL.md`](./SKILL.md)。**