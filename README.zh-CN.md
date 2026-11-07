# My Agent Skills

[English README](README.md) · **简体中文 README**

一个采用版本控制管理的可复用 Agent Skills 集合，并配套提供支持搜索的双语文档门户。

[**浏览 Skill 门户**](https://zshebjtzs.github.io/my-agent-skills/) · [简体中文门户](https://zshebjtzs.github.io/my-agent-skills/) · [English Portal](https://zshebjtzs.github.io/my-agent-skills/en/) · [**源代码仓库**](https://github.com/zshebjtzs/my-agent-skills)

My Agent Skills 将本地维护、社区来源以及托管于外部仓库的 Skills 整合到一个结构清晰的集合中。每个 Skill 都保留为独立目录，门户则提供分类浏览、全文搜索、源代码链接、内容预览和 ZIP 压缩包下载。

## 目录

- [项目概览](#项目概览)
- [Skill 门户](#skill-门户)
- [集合分类](#集合分类)
- [仓库结构](#仓库结构)
- [使用 Skill](#使用-skill)
- [贡献 Skill](#贡献-skill)
  - [提交本地 Skill](#1-提交本地-skill)
  - [登记外部 Skill](#2-登记外部-skill)
  - [审核与发布](#3-审核与发布)
- [验证与安全](#验证与安全)
- [开发指南](#开发指南)
- [许可证](#许可证)

## 项目概览

| 能力 | 实现方式 |
| --- | --- |
| Skill 存储 | 存放于 `skills/` 下的独立目录 |
| 集合分类 | Personal、Community 和 Shared |
| 外部来源 | 通过 `catalog/external-skills.json` 声明式清单管理 |
| 文档网站 | VitePress |
| 搜索 | VitePress 本地搜索 |
| 语言 | 简体中文和英文门户界面 |
| 下载 | 每个 Skill 均可单独下载为 ZIP 压缩包 |
| 贡献方式 | GitHub Issue Forms 和 GitHub Actions |
| 审核策略 | 通过 Pull Request 人工审核和合并 |
| 托管平台 | GitHub Pages |

本仓库是项目内容的唯一事实来源。网站和可下载压缩包均在构建期间根据仓库内容生成，不需要分别维护。

## Skill 门户

**线上站点：** <https://zshebjtzs.github.io/my-agent-skills/>

门户提供以下功能：

- **分类导航** —— 按 Personal、Community 和 Shared 集合浏览 Skills。
- **本地全文搜索** —— 搜索生成后的门户内容，无需依赖第三方搜索服务。
- **Skill 内容预览** —— 优先展示 Skill 根目录下的 `README.md`；如果不存在，则展示其 `SKILL.md`。
- **源代码导航** —— 跳转到对应源代码仓库中的目录。
- **ZIP 下载** —— 单独下载某个 Skill 的完整目录，无需下载整个集合。
- **双语界面** —— 在简体中文和英文导航及站点界面之间切换。

双语支持针对门户界面。Skill 文档直接展示其源文件内容，不会被自动翻译。

### 门户链接

- [简体中文](https://zshebjtzs.github.io/my-agent-skills/)
- [English](https://zshebjtzs.github.io/my-agent-skills/en/)
- [Personal Skills](https://zshebjtzs.github.io/my-agent-skills/skills/personal/)
- [Community Skills](https://zshebjtzs.github.io/my-agent-skills/skills/community/)
- [Shared Skills](https://zshebjtzs.github.io/my-agent-skills/skills/shared/)

## 集合分类

| 集合 | 内容定位 |
| --- | --- |
| `personal` | 为个人工作流、偏好和个人工具维护的 Skills。 |
| `community` | 来源于开源社区或由社区贡献的 Skills。应保留原始署名和许可证条款。 |
| `shared` | 面向不同项目、Agent 或用户复用的通用 Skills。 |

本地 Skills 会在对应分类目录下递归发现。当某个目录中包含名为 `SKILL.md` 的文件时（文件名匹配不区分大小写），该目录就会被识别为一个 Skill。

外部 Skills 则单独登记在 `catalog/external-skills.json` 中。清单中的每个条目指向一个公开 GitHub 仓库内的指定目录；构建网站时才会获取对应源文件。

## 仓库结构

```text
my-agent-skills/
├── skills/
│   ├── personal/                 # 个人维护的 Skills
│   ├── community/                # 社区 Skills 和源代码子模块
│   └── shared/                   # 可复用的共享 Skills
├── catalog/
│   ├── external-skills.json      # 外部托管 Skills 的清单
│   └── README.md                 # 外部清单的结构规范与说明
├── scripts/
│   ├── build-site.mjs            # 发现 Skills 并生成门户页面和 ZIP 压缩包
│   └── validate-catalog.mjs      # 验证外部 Skill 清单
├── site/
│   └── .vitepress/               # VitePress 配置和主题
├── .github/
│   ├── ISSUE_TEMPLATE/           # 本地和外部 Skill 提交表单
│   ├── scripts/                  # ZIP 验证脚本及其单元测试
│   └── workflows/                # 提交自动化和 Pages CI/CD 工作流
├── LICENSE
├── package.json
└── README.md
```

一个典型的本地 Skill 目录可以包含 `SKILL.md`、可选的面向访问者的 `README.md`，以及其他辅助文件：

```text
skills/<category>/<skill-name>/
├── SKILL.md
├── README.md              # 可选；门户预览时优先展示
├── scripts/               # 可选；供 Skill 使用者执行的脚本资源
├── references/            # 可选；辅助文档
└── assets/                # 可选；辅助资源
```

仓库并不强制每个 Skill 都采用上述内部目录结构。建议将每个 Skill 的指令和辅助资源放在一起，并在该 Skill 自身的文档中说明运行时依赖。

## 使用 Skill

1. 打开 [Skill 门户](https://zshebjtzs.github.io/my-agent-skills/)。
2. 浏览不同集合，或使用搜索框查找目标 Skill。
3. 阅读内容预览；如需完整上下文，可通过源代码链接查看原始文件。
4. 下载该 Skill 的 ZIP 压缩包。
5. 解压目录，并按照目标 Agent 或客户端的文档完成安装或导入。

某个 Skill 可能依赖特定的 Agent 运行时、命令行工具、环境变量或本地依赖。使用前请阅读其 `SKILL.md` 及辅助文档。ZIP 下载只负责打包 Skill 文件，不会自动安装依赖，也不会执行其中的脚本。

## 贡献 Skill

贡献者通过 GitHub Issues 提交内容。GitHub Actions 会验证提交内容、创建分支、提交文件、创建 Pull Request，并在对应 Issue 中回复 PR 链接。

**提交内容不会立即发布。** 维护者需要先审核 Pull Request 并手动合并。变更进入 `main` 且 Pages 工作流成功完成后，门户才会更新。

### 1. 提交本地 Skill

使用 [Add a local Skill Issue 表单](https://github.com/zshebjtzs/my-agent-skills/issues/new?template=add-local-skill.yml)。

以下两种提交方式必须二选一：

#### 方式 A：表单字段（JSON 模式）

需要提供：

- Skill 名称。
- 目标集合：`personal`、`community` 或 `shared`。
- 完整且非空的 `SKILL.md` 内容。
- 可选的 `README.md`。
- 可选的附加文件：使用 JSON 对象将相对文件路径映射到 UTF-8 文本内容。

附加文件字段示例：

```json
{
  "scripts/check.py": "print('validation passed')",
  "references/notes.md": "# Notes\nSupporting information."
}
```

限制：

- 文件数量最多 **30 个**。
- UTF-8 文本总量最多 **45 KB**。
- 仅支持文本文件。

#### 方式 B：上传 ZIP

对于包含多个文件的 Skill，可以通过 Issue 表单上传一个 `.zip` 压缩包。压缩包中必须且只能包含一个非空的 `SKILL.md`，它可以位于压缩包根目录，也可以位于唯一的顶层项目目录中。

当前 ZIP 上传限制：

| 限制项 | 上限 |
| --- | ---: |
| 压缩包大小 | 10 MB |
| 解压后总内容大小 | 10 MB |
| 单个文件大小 | 2 MB |
| 文件数量 | 100 个 |
| 文件内容 | 仅支持 UTF-8 文本 |

当前 ZIP 提交流程不支持二进制资源。验证器会拒绝不安全路径、符号链接、特殊文件类型、加密压缩包、重复或大小写冲突的路径，以及包含 `.git` 的内容。若压缩包只有一个顶层文件夹，系统会自动规范化目录结构，使提交后的 `SKILL.md` 位于 Skill 根目录。

不要同时填写 ZIP 上传和 JSON 文本字段。每个 Issue 只能选择一种提交方式。

### 2. 登记外部 Skill

使用 [Add an external Skill Issue 表单](https://github.com/zshebjtzs/my-agent-skills/issues/new?template=add-skill.yml)。

需要提供：

- Skill 展示名称。
- 目标集合。
- **公开 GitHub 仓库**的 URL（不能填写文件或目录 URL）。
- Skill 目录相对于该仓库根目录的路径。
- 可选的分支、标签或 commit。如果不填写，则使用源仓库的默认分支。

自动化流程会检查源仓库，并创建一个向 `catalog/external-skills.json` 添加条目的 Pull Request。构建网站时，系统会获取指定的源目录、展示其中的 `README.md` 或 `SKILL.md`，并将相关文件打包为可下载的 ZIP 压缩包。

当前构建流程对外部来源的限制：

- 源仓库必须公开且未归档。
- 指定目录必须包含 `README.md` 或 `SKILL.md`。
- 打包文件数量最多为 500 个。
- 下载的源文件总量不超过 25 MB。

构建流程会将指定的 ref 解析为一个 commit，并使用该 commit 生成页面和压缩包。因此，即使源仓库的分支之后继续更新，已经发布的构建产物仍然具有可复现性。

清单结构和条目示例请参阅 [catalog/README.md](catalog/README.md)。

### 3. 审核与发布

贡献流程如下：

```text
GitHub Issue
    │
    ▼
GitHub Actions 验证提交内容
    │
    ▼
创建贡献分支并提交文件
    │
    ▼
创建 Pull Request ──────► 在 Issue 中回复 PR 链接
    │
    ▼
维护者审核变更文件
    │
    ▼
手动合并到 main
    │
    ▼
构建并验证门户
    │
    ▼
部署到 GitHub Pages
```

提交工作流**不会自动合并** Pull Request。合并前，维护者应检查完整的 **Files changed** 页面，包括 Skill 指令和辅助文件。成功合并后，Pages 工作流会构建网站并将其部署到 GitHub Pages。

## 验证与安全

本仓库在多个阶段实施验证：

- **外部清单验证：** 检查清单结构、ID 唯一性、分类取值、来源类型、仓库标识符以及相对路径安全性。
- **ZIP 验证：** 检查压缩包大小、解压后大小、文件数量、单文件大小、路径安全性、文件类型、重复路径、加密状态和 UTF-8 文本内容。
- **自动化测试：** ZIP 验证器配有 Python 单元测试套件，并由 Pages 工作流执行。
- **构建验证：** `npm run build` 会验证外部清单，并生成 VitePress 网站和 Skill 压缩包。
- **人工审核：** 贡献 PR 必须经过维护者审核和合并。

上传的脚本会被视为 Skill 内容：提交工作流只会将它们保存为文件，不会执行这些脚本。但这并不意味着 Skill 本身一定安全。安装或执行第三方 Skill 前，请先检查其指令和脚本；审核贡献时，也应检查外部来源。

## 开发指南

### 环境要求

- Node.js **22 或更高版本**。
- npm。
- Git（如果需要处理使用 Git submodule 的社区 Skills，还需要支持子模块操作）。

### 安装依赖

```bash
npm install
```

### 可用命令

| 命令 | 说明 |
| --- | --- |
| `npm run dev` | 生成门户内容并启动 VitePress 开发服务器。 |
| `npm run validate` | 验证 `catalog/external-skills.json`。 |
| `npm run build` | 验证清单、生成 Skill 页面和 ZIP 压缩包，然后构建静态网站。 |
| `npm run preview` | 预览此前生成的生产构建产物。 |

典型的本地开发流程：

```bash
npm install
npm run dev
```

执行生产构建：

```bash
npm run build
npm run preview
```

构建时会从 GitHub 获取外部 Skill 来源。可以通过 `GITHUB_TOKEN` 或 `GH_TOKEN` 环境变量提供 GitHub Token，用于认证 GitHub API 请求并提高可用 API 速率限制。请勿将个人访问令牌或其他机密信息提交到仓库。

### 持续集成与部署

[Pages 工作流](.github/workflows/pages.yml)会执行以下操作：

- 在推送到 `main`、目标为 `main` 的 Pull Request，以及手动触发时运行。
- 检查 ZIP 验证器的 Python 语法，并运行其单元测试。
- 安装 Node.js 22 依赖并执行生产构建。
- 对非 PR 运行，在构建成功后部署到 GitHub Pages。

[提交工作流](.github/workflows/add-skill.yml)负责处理本地和外部 Skill 的 Issue，并创建供人工审核的 PR。

## 许可证

除非存在更具体的声明，本仓库自身的代码、站点配置和文档均采用 [MIT License](LICENSE) 发布。

根目录的许可证不意味着所有 Skills 都自动采用相同许可证。Community Skills、Git submodules 和外部来源内容可能继续遵循其原始许可证及署名要求。在复制、修改或重新分发相关内容前，请检查对应 Skill 目录和上游来源中的许可说明。
