# Docusaurus Documentation Example

This directory contains a sample Docusaurus project that demonstrates how to create a modern documentation website using a Documentation as Code approach. Docusaurus is a static site generator that builds single-page applications with React.

## Prerequisites

- Node.js 16.14 or higher
- npm or yarn

## Installation

1. Install dependencies:
   ```bash
   npm install
   ```
   or
   ```bash
   yarn install
   ```

2. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/x-as-code.git
   cd x-as-code/documentation/examples/docusaurus/static-site
   ```

## Local Development

To start a local development server:

```bash
npm start
```
or
```bash
yarn start
```

This will start a local development server and open up a browser window. Most changes are reflected live without having to restart the server.

## Building for Production

To build the static files:

```bash
npm run build
```
or
```bash
yarn build
```

This will generate static content in the `build` directory that can be served using any static hosting service.

## CI/CD Integration

To integrate with GitHub Actions for automatic deployment:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches:
      - main

jobs:
  deploy:
    name: Deploy to GitHub Pages
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
          cache: yarn

      - name: Install dependencies
        run: yarn install --frozen-lockfile
      - name: Build website
        run: yarn build

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build
```

## Project Structure

```
static-site/
├── blog/                  # Blog posts
│   ├── 2021-08-26-welcome.md
│   └── authors.yml
├── docs/                  # Documentation
│   ├── intro.md           # Introduction page
│   └── getting-started.md # Getting started guide
├── src/                   # React source code
│   ├── components/        # React components
│   ├── css/               # CSS files
│   └── pages/             # React pages
├── static/                # Static files
│   └── img/               # Images
├── docusaurus.config.js   # Docusaurus configuration
├── sidebars.js            # Sidebar configuration
└── package.json           # Project dependencies
```

## Customization

Docusaurus is highly customizable. You can modify the theme, add plugins, and create custom React components. See the [Docusaurus documentation](https://docusaurus.io/) for more information.
