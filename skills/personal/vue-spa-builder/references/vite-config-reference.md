---
agent_guidance: reference
description: 此文件为 Vite 配置的技术参考文档，AI 在修改 vite.config.js 时可查阅，但具体强制规则以 SKILL.md 为准。
---

## 强制配置项

```javascript
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  base: './',   // 必须设置为相对路径，否则本地打开会加载不到资源
  // 其他可选配置：
  server: {
    port: 3000,
    open: true
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    // 文件名 hash 默认已开启，用于缓存控制
  }
})
```

## 为什么必须用 base: './'？

- 默认 `base: '/'` 表示从根路径加载资源（如 `/js/app.js`），在 `file://` 协议下会被解析为 `file:///js/app.js`，无法找到文件。
- 设为 `'./'` 后，资源路径变为相对路径（如 `./js/app.js`），与 `index.html` 同目录，可正常加载。

## 其他常用配置

- `resolve.alias`：路径别名，如 `@` 指向 `src`。
- `css.preprocessorOptions`：全局 SCSS 变量等。
- `build.rollupOptions`：外部化依赖或分块策略。