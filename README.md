# My Agent Skills

A version-controlled library of reusable agent Skills, paired with a searchable, bilingual documentation portal.

[**简体中文 README**](README.zh-CN.md) · **English README**

[**Browse the Skill Portal**](https://zshebjtzs.github.io/my-agent-skills/) · [简体中文门户](https://zshebjtzs.github.io/my-agent-skills/) · [English Portal](https://zshebjtzs.github.io/my-agent-skills/en/) · [**Source Repository**](https://github.com/zshebjtzs/my-agent-skills)

My Agent Skills brings locally maintained, community-sourced, and externally hosted Skills into one organized collection. Each Skill remains a self-contained directory, while the portal provides category browsing, full-text search, source links, previews, and downloadable ZIP archives.

## Contents

- [Overview](#overview)
- [Skill Portal](#skill-portal)
- [Collections](#collections)
- [Repository Structure](#repository-structure)
- [Using a Skill](#using-a-skill)
- [Contributing Skills](#contributing-skills)
  - [Submit a Local Skill](#1-submit-a-local-skill)
  - [Register an External Skill](#2-register-an-external-skill)
  - [Review and Publication](#3-review-and-publication)
- [Validation and Security](#validation-and-security)
- [Development](#development)
- [License](#license)

## Overview

| Capability | Implementation |
| --- | --- |
| Skill storage | Self-contained directories under `skills/` |
| Collections | Personal, Community, and Shared |
| External sources | Declarative manifest at `catalog/external-skills.json` |
| Documentation site | VitePress |
| Search | VitePress local search |
| Languages | Simplified Chinese and English portal interfaces |
| Downloads | One ZIP archive per Skill |
| Contributions | GitHub Issue Forms and GitHub Actions |
| Review policy | Pull requests are reviewed and merged manually |
| Hosting | GitHub Pages |

The repository is the source of truth. The website and downloadable archives are generated from the repository contents during the build; they are not maintained separately.

## Skill Portal

**Production site:** <https://zshebjtzs.github.io/my-agent-skills/>

The portal provides:

- **Category navigation** — browse Personal, Community, and Shared collections.
- **Local full-text search** — search the generated portal content without relying on a third-party search service.
- **Skill previews** — display a Skill's root `README.md` when available, otherwise its `SKILL.md`.
- **Source navigation** — inspect the corresponding directory in its source repository.
- **ZIP downloads** — download an individual Skill directory without downloading the entire collection.
- **Bilingual interface** — switch between Simplified Chinese and English navigation and site UI.

The portal interface is bilingual. Skill documents are presented from their source content and are not automatically translated.

### Portal links

- [Simplified Chinese](https://zshebjtzs.github.io/my-agent-skills/)
- [English](https://zshebjtzs.github.io/my-agent-skills/en/)
- [Personal Skills](https://zshebjtzs.github.io/my-agent-skills/skills/personal/)
- [Community Skills](https://zshebjtzs.github.io/my-agent-skills/skills/community/)
- [Shared Skills](https://zshebjtzs.github.io/my-agent-skills/skills/shared/)

## Collections

| Collection | Intended contents |
| --- | --- |
| `personal` | Skills maintained for individual workflows, preferences, and personal tooling. |
| `community` | Skills sourced from or contributed by the wider open-source community. Original attribution and licensing terms should be preserved. |
| `shared` | General-purpose Skills intended for reuse across projects, agents, or users. |

Local Skills are discovered recursively under their corresponding category directory. A directory is recognized as a Skill when it contains a `SKILL.md` file (case-insensitive filename matching).

External Skills are registered separately in `catalog/external-skills.json`. The catalog points to a directory in a public GitHub repository; the source files are fetched during the site build.

## Repository Structure

```text
my-agent-skills/
├── skills/
│   ├── personal/                 # Individually maintained Skills
│   ├── community/                # Community Skills and source submodules
│   └── shared/                   # Reusable shared Skills
├── catalog/
│   ├── external-skills.json      # Manifest of externally hosted Skills
│   └── README.md                 # External catalog schema and guidance
├── scripts/
│   ├── build-site.mjs            # Discovers Skills and generates portal pages/ZIPs
│   └── validate-catalog.mjs      # Validates the external Skill manifest
├── site/
│   └── .vitepress/               # VitePress configuration and theme
├── .github/
│   ├── ISSUE_TEMPLATE/           # Local and external Skill submission forms
│   ├── scripts/                  # ZIP validation and unit tests
│   └── workflows/                # Submission automation and Pages CI/CD
├── LICENSE
├── package.json
└── README.md
```

A typical local Skill directory can contain a `SKILL.md`, an optional visitor-facing `README.md`, and supporting files:

```text
skills/<category>/<skill-name>/
├── SKILL.md
├── README.md              # Optional; preferred for portal preview
├── scripts/               # Optional executable resources for the Skill user
├── references/            # Optional supporting documentation
└── assets/                # Optional supporting resources
```

The repository does not require every Skill to use this exact internal layout. Keep each Skill's instructions and supporting resources together, and document any runtime dependencies in that Skill's own documentation.

## Using a Skill

1. Open the [Skill Portal](https://zshebjtzs.github.io/my-agent-skills/).
2. Browse a collection or use the search field to find a Skill.
3. Read its preview and follow the source link when you need the complete context.
4. Download the Skill's ZIP archive.
5. Extract the directory and follow the target agent/client's documentation for installing or importing Skills.

A Skill may depend on a particular agent runtime, command-line tool, environment variable, or local dependency. Review its `SKILL.md` and supporting documentation before use. A ZIP download packages the Skill's files; it does not install dependencies or execute its scripts.

## Contributing Skills

Contributions are submitted through GitHub Issues. GitHub Actions validates the submission, creates a branch, commits the proposed files, opens a pull request, and posts the PR link back to the Issue.

**Submissions are not published immediately.** A maintainer reviews the pull request and merges it manually. The portal is updated after the change reaches `main` and the Pages workflow completes successfully.

### 1. Submit a Local Skill

Use the [Add a local Skill issue form](https://github.com/zshebjtzs/my-agent-skills/issues/new?template=add-local-skill.yml).

Choose exactly one of the following submission methods:

#### Method A: Form fields (JSON mode)

Provide:

- A Skill name.
- A target collection: `personal`, `community`, or `shared`.
- The complete, non-empty `SKILL.md` content.
- An optional `README.md`.
- Optional additional files as a JSON object mapping relative file paths to UTF-8 text contents.

Example for the additional-files field:

```json
{
  "scripts/check.py": "print('validation passed')",
  "references/notes.md": "# Notes\nSupporting information."
}
```

Limits:

- At most **30 files**.
- At most **45 KB** of combined UTF-8 text.
- Text files only.

#### Method B: ZIP upload

For a multi-file Skill, upload one `.zip` archive using the Issue form. The archive must contain exactly one non-empty `SKILL.md`, either at the archive root or inside one top-level project directory.

Current ZIP limits:

| Constraint | Limit |
| --- | ---: |
| Compressed archive | 10 MB |
| Total extracted content | 10 MB |
| Individual file | 2 MB |
| Number of files | 100 |
| File content | UTF-8 text only |

Binary assets are not supported by the current ZIP submission workflow. The validator rejects unsafe paths, symbolic links, special file types, encrypted archives, duplicate or case-conflicting paths, and `.git` content. A single top-level folder is normalized so that the submitted `SKILL.md` becomes the Skill root.

Do not combine ZIP upload with the JSON text fields. Select one method per Issue.

### 2. Register an External Skill

Use the [Add an external Skill issue form](https://github.com/zshebjtzs/my-agent-skills/issues/new?template=add-skill.yml).

Provide:

- A Skill display name.
- A target collection.
- The URL of a **public GitHub repository** (not a file or directory URL).
- The Skill directory path relative to that repository's root.
- An optional branch, tag, or commit. If omitted, the source repository's default branch is used.

The automation checks the source repository and creates a pull request that adds an entry to `catalog/external-skills.json`. During the site build, the selected source directory is fetched, its `README.md` or `SKILL.md` is rendered, and its files are packaged into a downloadable ZIP.

External source constraints in the current build:

- The source repository must be public and not archived.
- The selected directory must contain a `README.md` or `SKILL.md`.
- At most 500 files are packaged.
- The total downloaded source content is limited to 25 MB.

The build resolves the requested ref to a commit and uses that commit for the generated page and archive. This makes a published build reproducible even when the source branch later advances.

For the catalog schema and an example entry, see [catalog/README.md](catalog/README.md).

### 3. Review and Publication

The contribution lifecycle is:

```text
GitHub Issue
    │
    ▼
GitHub Actions validation
    │
    ▼
Create contribution branch and commit
    │
    ▼
Open Pull Request ──────► Comment PR link on the Issue
    │
    ▼
Maintainer reviews the changed files
    │
    ▼
Manual merge into main
    │
    ▼
Build and validate the portal
    │
    ▼
Deploy to GitHub Pages
```

The submission workflow does **not** auto-merge pull requests. Review the complete **Files changed** tab, including Skill instructions and supporting files, before merging. After a successful merge, the Pages workflow builds the site and deploys it to GitHub Pages.

## Validation and Security

The repository applies validation at multiple stages:

- **External catalog validation:** checks the manifest structure, unique IDs, category values, source type, repository identifier, and safe relative paths.
- **ZIP validation:** checks archive size, extracted size, file count, file size, path safety, file types, duplicate paths, encryption, and UTF-8 text content.
- **Automated tests:** the ZIP validator has a Python unit-test suite executed by the Pages workflow.
- **Build validation:** `npm run build` validates the external catalog and generates the VitePress site and Skill archives.
- **Human review:** contribution PRs remain open until a maintainer reviews and merges them.

Uploaded scripts are treated as Skill content: the submission workflow stores them as files and does not execute them. This does not guarantee that a Skill itself is safe to run. Review third-party instructions and scripts before installing or executing them, and inspect external sources before approving contributions.

## Development

### Requirements

- Node.js **22 or later**.
- npm.
- Git (including submodule support when working with community Skills that use Git submodules).

### Install dependencies

```bash
npm install
```

### Available commands

| Command | Description |
| --- | --- |
| `npm run dev` | Generate portal content and start the VitePress development server. |
| `npm run validate` | Validate `catalog/external-skills.json`. |
| `npm run build` | Validate the catalog, generate Skill pages and ZIP archives, then build the static site. |
| `npm run preview` | Preview the previously generated production build. |

Typical local workflow:

```bash
npm install
npm run dev
```

To run the production build:

```bash
npm run build
npm run preview
```

The build fetches external Skill sources from GitHub. A GitHub token can be supplied through `GITHUB_TOKEN` or `GH_TOKEN` to authenticate GitHub API requests and raise the available API rate limit. Do not commit personal access tokens or other secrets to the repository.

### Continuous integration and deployment

The [Pages workflow](.github/workflows/pages.yml):

- Runs on pushes to `main`, pull requests targeting `main`, and manual dispatch.
- Checks the ZIP validator's Python syntax and runs its unit tests.
- Installs Node.js 22 dependencies and runs the production build.
- Deploys to GitHub Pages for non-PR runs after the build succeeds.

The [submission workflow](.github/workflows/add-skill.yml) handles local and external Skill Issues and opens review PRs.

## License

The repository's own code, site configuration, and documentation are distributed under the [MIT License](LICENSE), unless a more specific notice applies.

Skills are not necessarily relicensed by the repository's root license. Community Skills, Git submodules, and externally sourced content may retain their original licenses and attribution requirements. Check the relevant Skill directory and upstream source before copying, modifying, or redistributing its contents.
