# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- (Placeholder for upcoming features)

### Changed
- (Placeholder for upcoming breaking changes)

### Fixed
- (Placeholder for upcoming bug fixes)

---

## [1.5.0] — 2026-07-26

### Added
- `.skill-config.json` configuration file for storing GitHub repository info
- GitHub info injection into readme files during first and subsequent builds
- Interactive GitHub configuration during `new-project.ps1` project creation
- `CHANGELOG.md` with Release Checklist template

### Changed
- `.gitignore` now includes `.skill-config.json`
- `SKILL.md` updated with configuration documentation

### Fixed
- Fixed missing `.skill-config.json` in `.gitignore` (Phase 5)

---

## [1.4.0] — 2026-07-26

### Added
- All `.ps1` scripts converted to pure English with UTF-8 with BOM encoding
- PowerShell 5 compatibility guarantee

### Changed
- All Chinese comments and user-facing messages replaced with English

### Fixed
- Windows PowerShell 5 parsing errors caused by UTF-8 Chinese characters

---

## [1.3.0] — 2026-07-22

### Added
- `vite-plugin-singlefile` as mandatory dependency
- Dedicated chapter on `file://` protocol CORS restrictions
- Post-build validation recommendations

### Changed
- Updated `vite.config.template.js` with `vite-plugin-singlefile` and `assetsInlineLimit: 0`

### Fixed
- `file://` protocol CORS issue causing blank white screen on double-click

---

## [1.2.0] — 2026-07-21

### Added
- `-SkipSourceZip` parameter to skip source code packaging
- Automatic router file creation from template when Vue Router is selected

### Changed
- `.gitignore` detection now uses `Select-String` regex matching for robustness
- `Compress-Archive` operations now use `try/catch` for proper error handling
- `Copy-Item` operations now have error handling
- All file writes use `UTF-8 without BOM` encoding (PS 5.1 compatible)

### Fixed
- `$LASTEXITCODE` not capturing `Compress-Archive` errors
- `Resolve-Path` crashing on new file creation
- Template filename mismatch (`router-index.js.template` → `router-index.template.js`)

---

## [1.1.0] — 2026-07-21

### Added
- Readme file management for release packages (`README.txt`, `README_zh.txt`, `README_en.txt`)
- Language switching as a suggested feature (non-mandatory)

### Changed
- Project structure updated to include readme files

---

## [1.0.0] — 2026-07-21

### Added
- Initial release
- Core skill definition: Vue 3 + Vite offline SPA packaging
- Three PowerShell scripts: `check-node.ps1`, `new-project.ps1`, `build-and-pack.ps1`
- Mandatory configurations: `base: './'` and `createWebHashHistory()`
- AI development rules: preserve comments, no script refactoring, CSS style confirmation
- GitHub Release publishing guidelines


## 📋 Release Checklist

Before cutting a new release, verify:

- [ ] `SKILL.md` version number updated
- [ ] `CHANGELOG.md` updated with changes
- [ ] All `.ps1` scripts use pure English + UTF-8 with BOM
- [ ] `README.md` and `README_en.md` are synced
- [ ] `vite.config.template.js` is up to date
- [ ] `router-index.template.js` is up to date
- [ ] `.gitignore` rules include: `*.zip`, `README.txt`, `README_zh.txt`, `README_en.txt`, `.skill-config.json`
- [ ] Build test on a fresh project passes
- [ ] Double-click `dist/index.html` works without CORS errors
- [ ] GitHub Release created with both `<projectName>-<version>.zip` and `Source Code.zip`