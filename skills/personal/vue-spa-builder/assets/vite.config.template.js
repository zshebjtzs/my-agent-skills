// 关于 vite.config.js 的部分写法：
// 此文件用于配置 Vite 构建，强制使用相对路径以支持离线运行
// 使用 vite-plugin-singlefile 将所有 JS/CSS 内联到 HTML 中，解决 file:// 协议 CORS 问题
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { viteSingleFile } from 'vite-plugin-singlefile'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    viteSingleFile(),  // 强制内联所有 JS/CSS，实现双击即开
  ],
  base: './',  // 必须为相对路径
  build: {
    target: 'es2015',
    // 图片等资源保持外部引用（图片加载不受 CORS 限制）
    assetsInlineLimit: 0,
  }
})