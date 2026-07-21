// 关于 vite.config.js 的部分写法：
// 此文件用于配置 Vite 构建，强制使用相对路径以支持离线运行
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  base: './',  // 必须为相对路径
  // 可按需添加其他配置，如 server、build 等
})