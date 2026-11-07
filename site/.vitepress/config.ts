import { defineConfig } from 'vitepress';

export default defineConfig({
  title: 'My Agent Skills',
  description: 'A curated, searchable and downloadable library of agent skills.',
  base: '/my-agent-skills/',
  cleanUrls: false,
  lastUpdated: true,
  themeConfig: {
    siteTitle: 'MY AGENT SKILLS',
    nav: [
      { text: 'Home', link: '/' },
      {
        text: 'Categories',
        items: [
          { text: 'Personal', link: '/skills/personal/' },
          { text: 'Community', link: '/skills/community/' },
          { text: 'Shared', link: '/skills/shared/' }
        ]
      },
      { text: 'GitHub', link: 'https://github.com/zshebjtzs/my-agent-skills' }
    ],
    sidebar: [
      {
        text: 'Skill Library',
        items: [
          { text: 'Personal', link: '/skills/personal/' },
          { text: 'Community', link: '/skills/community/' },
          { text: 'Shared', link: '/skills/shared/' }
        ]
      }
    ],
    search: { provider: 'local' },
    outline: { level: [2, 3] },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/zshebjtzs/my-agent-skills' }
    ],
    footer: {
      message: 'Built with VitePress · Hosted on GitHub Pages',
      copyright: 'Content remains subject to each Skill’s original license.'
    }
  }
});
