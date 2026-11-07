import { defineConfig } from 'vitepress';

const repository = 'https://github.com/zshebjtzs/my-agent-skills';

export default defineConfig({
  title: 'My Agent Skills',
  description: 'A curated, searchable and downloadable library of agent skills.',
  base: '/my-agent-skills/',
  cleanUrls: false,
  markdown: { html: false },
  lastUpdated: true,
  locales: {
    root: {
      label: '简体中文',
      lang: 'zh-CN',
      title: 'My Agent Skills',
      description: '可搜索、可预览、可下载的 Agent Skills 技能库。',
      themeConfig: {
        siteTitle: 'MY AGENT SKILLS',
        nav: [
          { text: '首页', link: '/' },
          {
            text: '技能分类',
            items: [
              { text: '个人技能', link: '/skills/personal/' },
              { text: '社区技能', link: '/skills/community/' },
              { text: '共享技能', link: '/skills/shared/' }
            ]
          },
          { text: 'GitHub 仓库', link: repository }
        ],
        sidebar: [
          {
            text: '技能库',
            items: [
              { text: '个人技能', link: '/skills/personal/' },
              { text: '社区技能', link: '/skills/community/' },
              { text: '共享技能', link: '/skills/shared/' }
            ]
          }
        ],
        search: { provider: 'local' },
        outline: { level: [2, 3] },
        socialLinks: [{ icon: 'github', link: repository }],
        footer: {
          message: '基于 VitePress 构建 · 部署于 GitHub Pages',
          copyright: '各 Skill 内容仍遵循其原始许可证。'
        }
      }
    },
    '/en/': {
      label: 'English',
      lang: 'en-US',
      title: 'My Agent Skills',
      description: 'A curated, searchable and downloadable library of agent skills.',
      themeConfig: {
        siteTitle: 'MY AGENT SKILLS',
        nav: [
          { text: 'Home', link: '/en/' },
          {
            text: 'Categories',
            items: [
              { text: 'Personal', link: '/en/skills/personal/' },
              { text: 'Community', link: '/en/skills/community/' },
              { text: 'Shared', link: '/en/skills/shared/' }
            ]
          },
          { text: 'GitHub', link: repository }
        ],
        sidebar: [
          {
            text: 'Skill Library',
            items: [
              { text: 'Personal', link: '/en/skills/personal/' },
              { text: 'Community', link: '/en/skills/community/' },
              { text: 'Shared', link: '/en/skills/shared/' }
            ]
          }
        ],
        search: { provider: 'local' },
        outline: { level: [2, 3] },
        socialLinks: [{ icon: 'github', link: repository }],
        footer: {
          message: 'Built with VitePress · Hosted on GitHub Pages',
          copyright: 'Each Skill remains subject to its original license.'
        }
      }
    }
  }
});
