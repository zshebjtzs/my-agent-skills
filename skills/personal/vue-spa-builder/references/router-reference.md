---
agent_guidance: reference
description: 此文件为 Vue Router 配置的技术参考文档，AI 在修改路由配置时可查阅，但具体强制规则以 SKILL.md 为准。
---

## 强制配置项

```javascript
import { createRouter, createWebHashHistory } from 'vue-router'
import Home from '../views/Home.vue'

const routes = [
  { path: '/', component: Home },
  // 其他路由...
]

const router = createRouter({
  history: createWebHashHistory(),   // 必须使用 Hash 模式
  routes
})

export default router
```

## 为什么必须用 Hash 模式？

- `createWebHistory()` 使用 HTML5 History API，需要服务器配置 fallback（如 Nginx 的 try_files），在本地 `file://` 协议下会 404。
- `createWebHashHistory()` 使用 URL 中的 `#` 号模拟路由，所有路径都对应同一个 `index.html`，双击即可工作。

## 注意事项

- URL 会带 `#` 号，不影响功能，但更适合作离线工具。
- 若用户有特别需求必须去除 `#`，则必须要求用户部署到 Web 服务器，不再符合本技能“双击即开”的目标。