// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

const lightCodeTheme = require('prism-react-renderer/themes/github');
const darkCodeTheme = require('prism-react-renderer/themes/dracula');

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'X-as-Code Documentation',
  tagline: 'Everything as Code for Modern DevOps',
  favicon: 'img/favicon.ico',

  // Set the production url of your site here
  url: 'https://yourusername.github.io',
  // Set the /<baseUrl>/ pathname under which your site is served
  baseUrl: '/x-as-code/',

  // GitHub pages deployment config
  organizationName: 'yourusername', // Usually your GitHub org/user name
  projectName: 'x-as-code', // Usually your repo name

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internalization, you can use this field to set useful
  // metadata like html lang
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          editUrl:
            'https://github.com/yourusername/x-as-code/tree/main/documentation/examples/docusaurus/static-site/',
        },
        blog: {
          showReadingTime: true,
          editUrl:
            'https://github.com/yourusername/x-as-code/tree/main/documentation/examples/docusaurus/static-site/',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      navbar: {
        title: 'X-as-Code',
        logo: {
          alt: 'X-as-Code Logo',
          src: 'img/logo.svg',
        },
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'tutorialSidebar',
            position: 'left',
            label: 'Documentation',
          },
          {to: '/blog', label: 'Blog', position: 'left'},
          {
            href: 'https://github.com/yourusername/x-as-code',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Docs',
            items: [
              {
                label: 'Introduction',
                to: '/docs/intro',
              },
              {
                label: 'Getting Started',
                to: '/docs/getting-started',
              },
            ],
          },
          {
            title: 'Community',
            items: [
              {
                label: 'Stack Overflow',
                href: 'https://stackoverflow.com/questions/tagged/x-as-code',
              },
              {
                label: 'Discord',
                href: 'https://discord.gg/example',
              },
              {
                label: 'Twitter',
                href: 'https://twitter.com/example',
              },
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'Blog',
                to: '/blog',
              },
              {
                label: 'GitHub',
                href: 'https://github.com/yourusername/x-as-code',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} X-as-Code Project. Built with Docusaurus.`,
      },
      prism: {
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
        additionalLanguages: ['bash', 'diff', 'json', 'yaml', 'hcl'],
      },
    }),
};

module.exports = config;
