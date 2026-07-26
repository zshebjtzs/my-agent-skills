---
agent_guidance: reference
description: 此文件为 Vite 配置的技术参考文档，AI 在修改 vite.config.js 时可查阅，但具体强制规则以 SKILL.md 为准。
---

## 强制配置项

```javascript
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { viteSingleFile } from 'vite-plugin-singlefile'

export default defineConfig({
  plugins: [
    vue(),
    viteSingleFile(),  // 强制内联所有 JS/CSS，解决 file:// 协议 CORS 问题
  ],
  base: './',   // 必须设置为相对路径，否则本地打开会加载不到资源
  build: {
    target: 'es2015',
    assetsInlineLimit: 0,  // 图片等资源保持外部引用（图片不受 CORS 限制）
  }
})
```

## 为什么必须用 base: './'？

- 默认 `base: '/'` 表示从根路径加载资源（如 `/js/app.js`），在 `file://` 协议下会被解析为 `file:///js/app.js`，无法找到文件。
- 设为 `'./'` 后，资源路径变为相对路径（如 `./js/app.js`），与 `index.html` 同目录，可正常加载。

## 为什么必须用 vite-plugin-singlefile？

- Chrome 在 `file://` 协议下禁止加载任何外部脚本（无论是否使用 `type="module"`），会触发 CORS 错误。
- `vite-plugin-singlefile` 将所有 JavaScript 和 CSS 内联到 `index.html` 中，使页面不依赖任何外部脚本文件，彻底解决 CORS 问题。
- 图片、字体等资源通过 `<img>` 或 CSS `url()` 加载，不受 CORS 限制，因此设置 `assetsInlineLimit: 0` 让它们保持外部引用，控制 HTML 文件大小。

## 其他常用配置

- `resolve.alias`：路径别名，如 `@` 指向 `src`。
- `css.preprocessorOptions`：全局 SCSS 变量等。
- `build.rollupOptions`：外部化依赖或分块策略。