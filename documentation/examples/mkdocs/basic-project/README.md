# MkDocs Example Project

This directory contains a sample MkDocs project that demonstrates Documentation as Code principles. It shows how to structure a documentation project that can be managed using version control and automated build processes.

## Prerequisites

- Python 3.6 or higher
- pip (Python package manager)

## Installation

1. Install MkDocs and the Material theme:
   ```bash
   pip install mkdocs mkdocs-material
   ```

2. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/x-as-code.git
   cd x-as-code/documentation/examples/mkdocs/basic-project
   ```

## Local Development

1. Start the local development server:
   ```bash
   mkdocs serve
   ```

2. Open your browser and navigate to `http://127.0.0.1:8000/`

3. Make changes to the Markdown files in the `docs/` directory and see the changes reflected immediately

## Building Documentation

To build the static site:

```bash
mkdocs build
```

The site will be generated in the `site/` directory.

## CI/CD Integration

To integrate with CI/CD pipelines, you can add the following to your GitHub Actions workflow:

```yaml
name: Build and Deploy Documentation
on:
  push:
    branches:
      - main
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
        with:
          python-version: 3.x
      - run: pip install mkdocs-material
      - run: mkdocs gh-deploy --force
```

## Project Structure

```
basic-project/
├── docs/                       # Documentation source files
│   ├── index.md                # Home page
│   ├── getting-started/        # Getting started section
│   │   ├── installation.md     # Installation guide
│   │   └── quick-start.md      # Quick start guide
│   └── ...                     # Other documentation files
├── mkdocs.yml                  # MkDocs configuration file
└── README.md                   # Project README
```

## Customization

You can customize the look and feel of your documentation by modifying the `mkdocs.yml` file. See the [MkDocs documentation](https://www.mkdocs.org/) and [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) for more options.
