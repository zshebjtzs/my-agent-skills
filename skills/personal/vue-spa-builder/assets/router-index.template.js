// src/router/index.js
// 此文件配置 Vue Router，强制使用 Hash 模式以支持离线运行
import { createRouter, createWebHashHistory } from 'vue-router'
// 请根据实际组件路径调整下面的导入
// import HomeView from '../views/HomeView.vue'

const routes = [
  // 示例路由
  // { path: '/', component: HomeView },
  // { path: '/about', component: () => import('../views/AboutView.vue') }
]

const router = createRouter({
  history: createWebHashHistory(),  // 必须使用 Hash 模式
  routes
})

export default router