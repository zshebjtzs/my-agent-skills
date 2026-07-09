#  My Agent Skills

> 个人 Agent Skill 集合 —— 涵盖通用工具、个人定制与社区精选

本仓库用于统一管理和备份我所有的 Agent Skills。这些技能有的来自开源社区，有的由我自行编写，涵盖了各类自动化、分析、生成等场景。通过版本控制和清晰分类，让我的“技能库”变得井然有序、易于复用和分享。

---

## 📂 目录结构

```text
my-agent-skills/
├── README.md                  # 项目说明（你正在阅读的文件）
├── skills/                    # 核心目录：存放所有技能
│   ├── shared/                # 跨项目、跨团队通用的通用技能
│   │   └── <skill-name>/      # 每个技能独立成目录
│   │       ├── SKILL.md       # 技能定义文件（必需）
│   │       ├── scripts/       # 辅助脚本（可选）
│   │       ├── references/    # 参考文档（可选）
│   │       └── assets/        # 静态资源，如图片（可选）
│   ├── personal/              # 个人专属定制技能
│   │   └── <skill-name>/
│   │       └── SKILL.md       # （其余目录结构同 shared）
│   └── community/             # 从开源社区收集的技能（保留原始许可）
│       └── <skill-name>/
│           └── SKILL.md
└── templates/                 # 技能模板，方便快速创建新技能
    └── <template-name>/
        └── SKILL.md
```

---

## 🚀 如何添加一个新技能

1. **选择分类**：根据技能用途或来源，放入 `skills/shared`、`skills/personal` 或 `skills/community`。
2. **创建技能目录**：在该分类下新建一个以技能命名的文件夹（例如 `my-awesome-skill`）。
3. **编写技能定义**：在目录中创建 `SKILL.md` 文件，至少包含如下元数据：
   ```markdown
   ---
   name: my-awesome-skill
   description: 描述这个技能做什么，适用于什么场景。
   version: 1.0.0
   author: your-github-username
   source: self-authored | open-source (请注明出处)
   ---

   # 详细指令
   在这里写下给 Agent 的具体执行步骤、提示词或逻辑。
   ```
4. **附加资源**（按需添加）：`scripts/`、`references/`、`assets/` 等子目录。
5. **更新索引**（可选）：如果仓库根目录下有 `SKILLS.md`，记得在此添加对新技能的简要介绍。

---

## 🧩 技能使用

每个技能都是自包含的，你可以直接将其复制到支持 Agent Skill 的客户端（如 Claude、AutoGPT 等）中加载。部分技能可能依赖外部脚本或环境变量，请参阅对应技能目录下的说明。

---

## 📄 许可证

本仓库整体采用 [MIT License](LICENSE) 开源。但请注意：
- `shared/` 和 `personal/` 下的自有技能默认遵循 MIT。
- `community/` 下的技能**保留其原始许可证**，请在使用时遵守原作者的许可条款。

---

## 🤝 贡献

目前本仓库仅用于个人管理，暂不接受外部贡献。但欢迎通过 [Issues](https://github.com/zshebjtzs/my-agent-skills/issues) 提供建议或问题反馈。

---

## 📌 后续计划

随着技能增多，我会在此补充详细索引和使用示例，让每个技能更容易被理解和复用。

---