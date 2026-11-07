# My Agent Skills

> 个人 Agent Skill 集合 —— 涵盖通用工具、个人定制与社区精选

本仓库用于统一管理和备份我所有的 Agent Skills。这些技能有的来自开源社区，有的由我自行编写，涵盖了各类自动化、分析、生成等场景。通过版本控制和清晰分类，让我的“技能库”变得井然有序、易于复用和分享。

---

## 📂 目录结构

```text
my-agent-skills/
├── README.md
├── skills/
│   ├── shared/
│   ├── personal/
│   └── community/
├── catalog/
│   └── external-skills.json
├── scripts/
├── site/
└── .github/
```

---

## 🚀 添加 Skill

### 添加本地 Skill（自动化）

在仓库的 **Issues → New issue → Add a local Skill** 提交：

- Skill 名称与分类。
- 完整的 `SKILL.md` 内容（必填）。
- 可选的 `README.md`。
- 可选的附加文本文件（以 JSON 对象提交相对路径和文件内容）。

GitHub Actions 会自动生成 `skills/{category}/{slug}/` 目录和文件，并创建 PR。审核、合并后网站自动更新。无需手动编辑仓库或 commit。

> Issue 表单适合文本型 Skill。附件总计限制为 30 个文件、45 KB 文本；更大的 Skill（例如包含二进制资源或大量脚本）请使用外部仓库引用流程。

### 引用外部 Skill

在仓库的 **Issues → New issue → Add an external Skill** 提交来源仓库和 Skill 目录。GitHub Actions 会自动向 `catalog/external-skills.json` 添加条目并创建 PR；审核、合并后网站自动更新。

---

## 🌐 Skill Portal

本仓库同时托管 VitePress 静态网站，部署在 GitHub Pages：

- 按 Personal、Community、Shared 分类浏览。
- 在线阅读 Skill 的 README / SKILL.md。
- 搜索名称、简介和正文。
- 下载单个 Skill 的完整目录 ZIP（不包含仓库其他目录或 Git 元数据）。
- 外部 Skill 在构建时读取并缓存，页面访问不依赖实时跨域请求。

### 本地开发

需要 Node.js 22 或更高版本：

```bash
npm install
npm run dev
npm run build
npm run preview
```

外部 Skill 定义位于 `catalog/external-skills.json`。每个外部条目指向一个公开 GitHub 仓库及仓库内的 Skill 目录。

---

## 🧩 技能使用

每个技能都是自包含的，你可以直接将其复制到支持 Agent Skill 的客户端中加载。部分技能可能依赖外部脚本或环境变量，请参阅对应技能目录下的说明。

---

## 📄 许可证

本仓库整体采用 [MIT License](LICENSE) 开源。但请注意：

- `shared/` 和 `personal/` 下的自有技能默认遵循 MIT。
- `community/` 下的技能保留其原始许可证，请遵守原作者的许可条款。
