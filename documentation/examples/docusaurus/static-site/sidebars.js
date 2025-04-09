/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.
 */

// @ts-check

/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  // By default, Docusaurus generates a sidebar from the docs folder structure
  tutorialSidebar: [
    {
      type: 'category',
      label: 'Introduction',
      items: ['intro', 'getting-started'],
    },
    {
      type: 'category',
      label: 'Domains',
      items: [
        'domains/infrastructure',
        'domains/policy',
        'domains/configuration',
        'domains/security',
        'domains/resilience',
        'domains/monitoring',
        'domains/data',
        'domains/compliance',
        'domains/documentation',
        'domains/access',
      ],
    },
    {
      type: 'category',
      label: 'Best Practices',
      items: [
        'best-practices/version-control',
        'best-practices/automation',
        'best-practices/testing',
        'best-practices/security',
      ],
    },
    {
      type: 'category',
      label: 'Integration Patterns',
      items: [
        'integration/cicd',
        'integration/gitops',
        'integration/cross-domain',
      ],
    },
    {
      type: 'doc',
      id: 'contributing',
      label: 'Contributing',
    },
  ],
};

module.exports = sidebars;
