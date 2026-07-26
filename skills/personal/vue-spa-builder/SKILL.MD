---
name: vue-spa-builder
description: Vue 3 + Vite 单页应用（SPA）打包为离线可用的纯静态 HTML 压缩包，用于分发免安装、免 Node、免网络的 Windows 工具。涵盖项目创建、构建配置、路由模式强制设定、打包脚本、GitHub Release 发布规范。
---

# Vue SPA Builder —— 离线分发技能

> **本文件是 AI 协助开发本类项目时的最高行为准则。**
> AI 在每次任务开始时，必须先通读并严格遵守本文件所有条款。

---

## 1. 技能目标

将 Vue 3 + Vite 项目构建为一个**双击 `index.html` 即可在浏览器中离线运行**的纯静态网站（SPA），并打包成 `.zip` 压缩包，方便通过 GitHub Releases 或其他方式分享给他人，**接收方无需安装 Node.js、无需网络、无需任何服务器**。

---

## 2. 强制技术栈与配置（不可协商）

| 项目 | 强制要求 |
|------|----------|
| 前端框架 | Vue 3 + Vite |
| 组件 API | **必须使用组合式 API 和 `<script setup>` 语法** |
| 路由模式 | **必须使用 `createWebHashHistory()`**（原因：History 模式在 `file://` 协议下会 404） |
| 构建配置 | `vite.config.js` 中 **必须设置 `base: './'`**（相对路径，确保资源在本地加载） |
| 单文件打包 | **必须使用 `vite-plugin-singlefile`**（原因：`file://` 协议下浏览器禁止加载任何外部脚本，必须将所有 JS/CSS 内联到 HTML 中） |
| 状态管理 | 推荐 Pinia（可选） |
| HTTP 库 | 推荐 Axios（可选，但通常用于与后端交互） |
| 其他工具 | Vditor、KaTeX、Markdown 渲染等按需引入 |

> **违反以上任意一条强制项，构建后的产物将无法实现"双击即开"，AI 必须严格遵守。**

---

## 2.5 脚本编码要求（Windows PowerShell 兼容性）

所有 `.ps1` 脚本文件必须遵守以下规则，以确保在 Windows PowerShell 5（默认）下能正常执行：

| 规则 | 要求 |
|------|------|
| **脚本语言** | **必须使用纯英文**：所有注释、`Write-Host` 消息、`Read-Host` 提示必须使用英文，不得包含中文或其他非 ASCII 字符 |
| **文件编码** | **必须保存为 UTF-8 with BOM**：确保 PowerShell 5 能正确识别编码 |
| **理由** | PowerShell 5 默认使用 Windows-1252（ANSI）编码解析 `.ps1` 文件，UTF-8 编码的中文字符会被错误解析，导致语法解析失败（如"缺少右括号"等错误） |

> **AI 在创建或修改任何 `.ps1` 文件时，必须使用纯英文内容和 UTF-8 with BOM 编码。**

---

## 2.6 项目配置文件（`.skill-config.json`）

本技能在项目根目录维护一个 `.skill-config.json` 文件，用于存储构建相关的配置信息。该文件应被 `.gitignore` 忽略（由 `new-project.ps1` 自动添加）。

### 当前支持的字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `github.enabled` | boolean | 是否配置了 GitHub 仓库信息 |
| `github.username` | string | GitHub 用户名 |
| `github.repo` | string | 仓库名称 |

### 示例

```json
{
  "github": {
    "enabled": true,
    "username": "your-username",
    "repo": "your-tool-name"
  }
}
```

### AI 使用规则

- **首次构建时**：如果 `.skill-config.json` 存在且 `github.enabled` 为 `true`，AI 生成 `README.txt` 时**必须包含** GitHub 仓库地址，格式为 `https://github.com/用户名/仓库名`
- **未配置时**：AI 生成 `README.txt` 时**不包含** GitHub 地址行
- **用户补充时**：用户可随时说"添加 GitHub 信息：用户名 xxx，仓库 yyy"，AI 应创建或更新 `.skill-config.json` 文件，并在后续构建时生效
- **更改时**：用户可随时要求修改 GitHub 信息，AI 更新配置文件即可

---

## 3. 构建说明文件管理（发行包配套）

为了向最终用户说明工具的用途和使用方法，本项目在发行包（`.zip`）中包含说明文件。该文件**存放于项目根目录**，构建时复制到 `dist/` 中一并打包。

### 3.1 文件列表

| 文件名 | 说明 |
|--------|------|
| `README.txt` | 简体中文说明（**默认必有**） |
| `README_zh.txt` | 简体中文说明（双语模式下的中文版） |
| `README_en.txt` | 英文说明（双语模式下的英文版） |

### 3.2 首次构建流程（AI 必须执行）

当 AI 检测到项目根目录**不存在**任何说明文件时，判定为"首次构建"。AI 必须：

1. **向用户询问**：
   > "This is the first build. Please select the readme language version:
   > A. Generate only `README.txt` (Simplified Chinese, single file)
   > B. Generate `README_zh.txt` + `README_en.txt` (Chinese + English, dual files)"

2. 根据用户选择，在**项目根目录**生成对应的说明文件，内容包含：
   - 项目名称（从 `package.json` 读取）
   - 版本号（用户输入的版本号）
   - GitHub 仓库地址（如果 `.skill-config.json` 中存在且 `github.enabled` 为 `true`，格式为 `https://github.com/用户名/仓库名`，否则省略此行）
   - 功能简介（根据项目实际功能撰写）
   - 使用方法："Extract the zip and double-click `index.html` to use in your browser"
   - 环境要求："Recommended to use latest Chrome/Edge browser"

3. **注意**：说明文件的内容应随项目实际情况撰写，不得使用空洞的占位文本。

### 3.3 后续构建流程（AI 必须执行）

当 AI 检测到项目根目录**已存在**说明文件时，判定为"后续构建"。AI 必须：

1. **不再询问**语言版本选择。
2. 根据**本轮开发的实际内容**（从对话上下文中获取），对说明文件进行**适度修改**：
   - 更新版本号
   - 新增功能描述
   - 修正已知问题说明
   - 调整不准确的描述
   - **如果 `.skill-config.json` 中的 GitHub 信息发生变化，同步更新说明文件中的仓库地址**
3. 修改完成后，保存到项目根目录。

### 3.4 中途更改语言版本或 GitHub 信息

- **语言版本**：用户可随时向 AI 提出更改语言版本（如"改成双语版"或"只要中文版"），AI 应在根目录创建缺失的文件或删除多余的文件，并告知用户下次构建时将按新配置打包。
- **GitHub 信息**：用户可随时说"添加/修改 GitHub 信息：用户名 xxx，仓库 yyy"，AI 应更新 `.skill-config.json`，并在下次构建时反映到说明文件中。

### 3.5 构建脚本的职责

`build-and-pack.ps1` 在 `npm run build` 完成后，会**检测根目录的说明文件**并将其**复制到 `dist/` 目录中**，然后打包。若根目录不存在任何说明文件，脚本会报错并退出。

---

## 4. 脚本工具（位于 `scripts/`）

本技能提供了多个 PowerShell 脚本，AI 可根据场景调用，或指导用户手动运行。

| 脚本文件 | 用途 | 何时使用 |
|---------|------|----------|
| `check-node.ps1` | 检查 Node.js 是否已安装，并输出版本号 | 在创建新项目或构建前，确保环境就绪 |
| `new-project.ps1` | 交互式创建新 Vue 3 项目（使用 Vite），让用户选择需要的额外依赖（Pinia、Router、Axios 等），并配置 `.gitignore` 忽略说明文件。**默认自动安装 `vite-plugin-singlefile`**，并询问 GitHub 仓库信息 | 用户从头开始一个新工具时 |
| `build-and-pack.ps1` | **主脚本**：执行 `npm run build`，将根目录的说明文件复制到 `dist/`，然后使用 `Compress-Archive` 将 `dist/` 打包为根目录同级 `.zip` 文件 | 每次准备发布新版本时 |

**AI 使用原则**：
- 若用户已有项目，只需构建打包，直接调用 `build-and-pack.ps1`。
- 若用户需要新建项目，先调用 `check-node.ps1` 确认环境，再调用 `new-project.ps1`。
- 所有脚本均设计为**用户手动执行**（双击或在终端运行），AI 可提供命令及参数说明。

---

## 5. 构建打包流程（标准步骤）

1. **确认 Node.js 已安装**（可运行 `node -v`）。
2. **进入项目根目录**（即 `package.json` 所在位置）。
3. **执行 `npm install`**（若依赖未安装）。
4. **确认说明文件存在**（若不存在，AI 必须先按 3.2 节流程生成）。
5. **修改路由模式**（强制）：
   - 在 `src/router/index.js` 中，将 `createWebHistory()` 替换为 `createWebHashHistory()`。
6. **修改构建配置**（强制）：
   - 在项目根目录创建或编辑 `vite.config.js`，必须包含：
     - `base: './'`
     - `vite-plugin-singlefile` 插件
     - `assetsInlineLimit: 0`（图片等资源保持外部引用）
7. **执行构建**：`npm run build`（生成 `dist/` 文件夹，所有 JS/CSS 内联到 `index.html`）。
8. **复制说明文件**：将根目录的 `README.txt`（以及 `README_zh.txt`、`README_en.txt`）复制到 `dist/` 目录中。
9. **打包分发**：使用 `Compress-Archive` 将 `dist/` 目录下的所有内容打包为 `.zip`（确保解压后直接看到 `index.html` 和说明文件），命名格式为 `项目英文名-版本号.zip`（版本号由用户手动输入），将压缩包放在项目根目录的**同级目录**（即 `../`），避免被 Git 追踪。同时可选择性打包源代码为 `Source Code.zip`。
10. **更新 `.gitignore`**：在根目录 `.gitignore` 中添加 `*.zip` 以及三个说明文件（脚本会自动处理）。

---

## 6. AI 开发铁律（每次修改必须遵守）

### 6.1 保留原有注释（不可违反）
- 修改任何 `.vue`、`.js`、`.css` 文件时，**必须原样保留文件中所有已有的注释**（包括 `<!-- -->`、`//`、`/* */`）。
- 即使认为注释多余或过时，也**不得删除或修改**，除非用户明确授权。
- **原因**：用户可能依赖注释进行维护，删除注释曾导致严重问题。

### 6.2 禁止擅自重构 script（不可违反）
- 如果用户只要求修改 **template** 或 **style**，**绝对不要**同时修改 `<script setup>` 中的业务逻辑、状态管理、API 调用。
- 如果确实需要调整 script 部分（如新增响应式变量），必须先**向用户说明并征得同意**，且仅修改必要的部分，不进行整体重构。
- **例外**：用户明确要求"重构脚本"或"优化代码结构"时，才可进行。

### 6.3 CSS 设计风格必须确认（强制流程）
- **在开始任何样式修改之前，AI 必须先向用户确认整体 CSS 设计风格**，包括但不限于：
  - 主色调、辅助色、背景色（浅色/深色/自定义）。
  - 字体体系（大小、字重、行高）。
  - 间距系统（如 4px、8px、16px 的倍数）。
  - 圆角大小（统一用 `--radius-sm/md/lg` 等变量）。
  - 阴影层级（卡片悬浮、弹窗等）。
  - 响应式断点（移动端/平板/桌面）。
- **确认方式**：AI 可提供一套默认的"简洁现代风"方案供用户选择，或让用户详细描述预期风格（可参考现有网站/设计稿）。
- **未获得用户确认前，不得编写或提交任何 CSS 代码**（包括 `<style>` 块和全局样式）。

### 6.4 依赖安装需授权
- 若需要安装新 npm 包，AI 必须**先告知用户包名、用途和版本**，获得同意后再执行 `npm install`。
- 禁止安装与当前任务无关的大型框架或过多依赖。
- **例外**：`vite-plugin-singlefile` 是本技能的强制依赖，`new-project.ps1` 会自动安装，无需逐次询问。

### 6.5 不确定时必追问
- 遇到任何不明确的业务逻辑、字段名、交互方式，AI 必须主动提问，不得臆测。
- 例如：用户说"加个排序"，AI 应追问"按什么字段？升序还是降序？默认排序是什么？"。

### 6.6 修改粒度与整合
- 对同一文件的**多处修改**（如替换多个颜色值、调整多个样式属性）**必须合并为一次编辑操作**，减少 Token 浪费。
- 若需修改多个文件，按逻辑分组逐步提交。

---

## 7. 关键专题：file:// 协议下的 CORS 限制

### 7.1 问题根源

**Chrome 及其他现代浏览器在 `file://` 协议下，禁止通过 `<script src="...">` 或 `<link rel="stylesheet" href="...">` 加载任何外部文件。** 无论是否使用 `type="module"`，无论是否使用 `nomodule` 降级方案，任何外部脚本或样式表都会被 CORS 策略拦截。

这是浏览器安全策略的硬性限制，**无法通过任何 Vite 配置绕过**。

错误表现：
```
Access to script at 'file:///.../assets/index-xxx.js' from origin 'null' has been blocked by CORS policy
```

### 7.2 唯一解决方案

**必须将所有 JavaScript 和 CSS 代码内联到 `index.html` 中**，使页面不依赖任何外部脚本或样式表文件。

使用 `vite-plugin-singlefile` 插件实现：

```javascript
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { viteSingleFile } from 'vite-plugin-singlefile'

export default defineConfig({
  plugins: [
    vue(),
    viteSingleFile(),  // Force inline all JS/CSS
  ],
  base: './',
  build: {
    target: 'es2015',
    assetsInlineLimit: 0,  // Keep images as external files (images are not subject to CORS)
  }
})
```

### 7.3 为什么图片可以保持外部引用？

图片、字体等资源通过 `<img src="...">` 或 CSS `url()` 加载，**不受 CORS 限制**，可以安全地作为外部文件存在。只有 `<script>` 和 `<link rel="stylesheet">` 受到 `file://` 协议的限制。

因此推荐配置 `assetsInlineLimit: 0`，只内联 JS/CSS，图片保持外部引用，以控制 `index.html` 的大小。

---

## 8. 常见坑点与教训（来自实战）

| # | 坑点 | 正确做法 |
|---|------|----------|
| 1 | **History 模式在本地报错** | 必须改用 `createWebHashHistory` |
| 2 | **资源路径错误导致空白** | 必须设置 `base: './'` |
| 3 | **用户缓存旧版资源** | 构建时文件名带 hash（Vite 默认已做），告知用户强制刷新（Ctrl+F5） |
| 4 | **压缩包解压后多一层 `dist` 文件夹** | 打包时打包 `dist/` 内部的内容而非 `dist/` 本身 |
| 5 | **.gitignore 未忽略 .zip** | 手动或脚本添加 `*.zip`，避免大文件进入仓库 |
| 6 | **用户打开页面显示空白且无报错** | 检查是否在 IE 或旧版浏览器中运行，建议使用最新 Chrome/Edge |
| 7 | **删除用户注释导致维护困难** | 牢记铁律 6.1，绝不删除注释 |
| 8 | **擅自重构 script 引入新 bug** | 牢记铁律 6.2，仅修改必须部分 |
| 9 | **未确认设计风格就写 CSS** | 牢记铁律 6.3，先确认后编码 |
| 10 | **新文件忘记写路径注释** | 每个新代码文件第一行注释完整相对路径（如 `// src/views/MyTool.vue`） |
| 11 | **发行包缺少说明文件** | 构建前确保根目录有说明文件，构建后复制到 `dist/` 中 |
| 12 | **双击 index.html 白屏，CORS 报错** | **必须使用 `vite-plugin-singlefile`** 将所有 JS/CSS 内联到 HTML 中。这是 `file://` 协议的硬性限制，任何外部脚本加载都会被拦截。图片等资源可保持外部引用 |

---

## 9. GitHub Release 发布规范（建议）

- 在 Release 页面提供**两个压缩包**：
  - `项目名-版本号.zip`（即构建后的 `dist/` 打包，用户下载即用）。
  - `Source Code.zip`（项目源代码，方便他人审查或二次开发，**可选**）。
- Release 说明中建议添加一句提示："If the old version appears after opening, press Ctrl+F5 to force refresh the cache."
- README.md 中应明确说明该项目为 Vue SPA，并注明使用方法（下载解压后双击 `index.html` 即可）。

---

## 10. 项目结构速查（典型）

```
my-tool/
├── dist/                     # Build output (not committed to Git)
│   ├── index.html            # All JS/CSS inlined, ready to double-click
│   ├── favicon.svg           # Images and other resources remain as external files
│   ├── README.txt            # Copied from root during build
│   └── README_en.txt         # (optional)
├── src/
│   ├── assets/               # Static assets (images, fonts, etc.)
│   ├── components/           # Vue components
│   ├── router/               # Router config (must use Hash mode)
│   ├── stores/               # Pinia stores (optional)
│   ├── views/                # Page-level components
│   ├── App.vue
│   └── main.js
├── .skill-config.json        # Skill configuration (GitHub info, etc.) — ignored by .gitignore
├── README.txt                # Readme file (project root, ignored by .gitignore)
├── README_zh.txt             # (optional)
├── README_en.txt             # (optional)
├── index.html
├── package.json
├── vite.config.js            # Must include vite-plugin-singlefile
├── .gitignore                # Should include *.zip, README.txt, README_zh.txt, README_en.txt, .skill-config.json
└── README.md                 # Developer-facing project description (committed to Git)
```

---

## 11. 脚本使用示例（AI 指导用户）

**Scenario 1: User has an existing Vue project and wants to build and package**
> Please open PowerShell, navigate to your project root, and run `.\scripts\build-and-pack.ps1`. Enter the version number (e.g., v1.0.0) when prompted. The script will build and generate the release package. Add `-SkipSourceZip` if you don't want the source code package.

**Scenario 2: User wants to create a new Vue tool project**
> First run `.\scripts\check-node.ps1` to confirm Node.js is installed, then run `.\scripts\new-project.ps1` and select the dependencies you need (Vue Router, Pinia, etc.). You will also be asked whether you plan to open-source the project on GitHub — if yes, provide your username and repository name. `vite-plugin-singlefile` will be installed automatically. I'll help you configure the router and build settings.

**Scenario 3: AI-assisted development**
> AI will follow all rules in this skill, preserve comments, avoid refactoring script without permission, and confirm CSS design style before writing any styles.

---

## 12. 建议性功能（非铁律）

以下功能由 AI 默认提供，但开发者可随时要求移除：

### 12.1 语言快速切换（国际化）

- **功能描述**：在应用的首页/入口页面（路由 `path: '/'` 对应的视图组件）添加一个下拉菜单，用于切换界面语言（如中/英文），利用 Vue 的响应式特性实现**无刷新立即切换**。
- **技术实现**：使用 `vue-i18n`，语言包存放在 `src/locales/` 下，用户偏好保存在 `localStorage` 中。
- **适用场景**：需要面向多语言用户的工具类应用。
- **移除方式**：开发者明确表示不需要时，AI 应移除相关代码、依赖和语言包文件。
- **注意**：该功能**仅放置于首页**，不依赖全局布局组件。若项目只有一个页面，则直接放在该页面中。

---

## 13. 版本与更新记录

| 版本 | 日期 | 变更说明 |
|------|------|----------|
| 1.0.0 | 2026-07-21 | 初始版本，整合离线分发流程、铁律、脚本 |
| 1.1.0 | 2026-07-21 | 新增说明文件管理机制（README.txt 等），新增建议性功能章节（语言切换） |
| 1.2.0 | 2026-07-21 | 修复脚本错误处理（Compress-Archive try/catch）；新增 `-SkipSourceZip` 参数；优化 .gitignore 检测；修复 PS 5.1 编码问题；自动创建路由文件模板 |
| 1.3.0 | 2026-07-22 | **关键修复**：新增 `vite-plugin-singlefile` 强制依赖，解决 `file://` 协议下 CORS 导致的白屏问题；新增专题章节说明；更新配置模板 |
| 1.4.0 | 2026-07-26 | **Windows PowerShell 兼容性**：所有 `.ps1` 脚本改为纯英文内容 + UTF-8 with BOM 编码，解决 PowerShell 5 中文解析错误问题 |
| 1.5.0 | 2026-07-26 | 新增 `.skill-config.json` 配置文件，支持 GitHub 仓库信息记录；说明文件自动包含仓库地址；完善 `.gitignore` 模板 |

---

**AI 必须确认**：每次开始协助前，请确认已阅读并理解本文件全部内容，并在回答中声明"已遵守 vue-spa-builder 技能规则"。
