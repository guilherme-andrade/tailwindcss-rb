import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'tailwindcss-rb',
  description: 'A Ruby-like library and compiler for Tailwind CSS',
  base: '/tailwindcss-rb/',
  lastUpdated: true,
  cleanUrls: true,
  
  head: [
    ['meta', { property: 'og:title', content: 'tailwindcss-rb' }],
    ['meta', { property: 'og:description', content: 'Build your own UI framework in Ruby with Tailwind CSS' }],
  ],

  themeConfig: {
    logo: '/logo.svg',
    
    nav: [
      { text: 'Guide', link: '/guide/getting-started' },
      { text: 'API', link: '/api/style' },
      { text: 'Examples', link: '/examples/components' },
      {
        text: 'v0.1.0',
        items: [
          { text: 'Changelog', link: 'https://github.com/guilherme-andrade/tailwindcss-rb/blob/main/CHANGELOG.md' },
          { text: 'Contributing', link: 'https://github.com/guilherme-andrade/tailwindcss-rb/blob/main/CONTRIBUTING.md' }
        ]
      }
    ],

    sidebar: {
      '/guide/': [
        {
          text: 'Getting Started',
          items: [
            { text: 'Introduction', link: '/guide/getting-started' },
            { text: 'Installation', link: '/guide/installation' },
            { text: 'Basic Usage', link: '/guide/basic-usage' },
            { text: 'Configuration', link: '/guide/configuration' }
          ]
        },
        {
          text: 'Core Concepts',
          items: [
            { text: 'Style Class', link: '/guide/style-class' },
            { text: 'Helpers', link: '/guide/helpers' },
            { text: 'Modifiers', link: '/guide/modifiers' },
            { text: 'Arbitrary Values', link: '/guide/arbitrary-values' }
          ]
        },
        {
          text: 'Advanced',
          items: [
            { text: 'Dark Mode', link: '/guide/dark-mode' },
            { text: 'Responsive Design', link: '/guide/responsive-design' },
            { text: 'Style Composition', link: '/guide/style-composition' },
            { text: 'Color Schemes', link: '/guide/color-schemes' }
          ]
        },
        {
          text: 'Deployment',
          items: [
            { text: 'Development Setup', link: '/guide/development' },
            { text: 'Production Build', link: '/guide/production' },
            { text: 'Heroku', link: '/guide/heroku' },
            { text: 'CDN Setup', link: '/guide/cdn' }
          ]
        }
      ],
      '/api/': [
        {
          text: 'API Reference',
          items: [
            { text: 'Style', link: '/api/style' },
            { text: 'Helpers', link: '/api/helpers' },
            { text: 'Configuration', link: '/api/configuration' },
            { text: 'Compiler', link: '/api/compiler' },
            { text: 'Asset Helper', link: '/api/asset-helper' }
          ]
        }
      ],
      '/examples/': [
        {
          text: 'Examples',
          items: [
            { text: 'Components', link: '/examples/components' },
            { text: 'Button Component', link: '/examples/button' },
            { text: 'Card Component', link: '/examples/card' },
            { text: 'Form Inputs', link: '/examples/forms' },
            { text: 'Alert Component', link: '/examples/alert' },
            { text: 'Layout Patterns', link: '/examples/layouts' }
          ]
        }
      ]
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/guilherme-andrade/tailwindcss-rb' }
    ],

    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © 2024 Guilherme Andrade'
    },

    editLink: {
      pattern: 'https://github.com/guilherme-andrade/tailwindcss-rb/edit/main/docs/:path',
      text: 'Edit this page on GitHub'
    },

    search: {
      provider: 'local'
    },

    carbonAds: undefined
  }
})