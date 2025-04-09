# Sphinx API Documentation Example

This directory contains a sample Sphinx documentation project that demonstrates how to create API documentation using a Documentation as Code approach. It shows how to document Python code and generate professional-looking API documentation.

## Prerequisites

- Python 3.7 or higher
- pip (Python package manager)

## Installation

1. Install Sphinx and required extensions:
   ```bash
   pip install sphinx sphinx-rtd-theme
   ```

2. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/x-as-code.git
   cd x-as-code/documentation/examples/sphinx/api-docs
   ```

## Building Documentation

To build the documentation:

```bash
sphinx-build -b html . _build/html
```

The documentation will be generated in the `_build/html` directory.

## Local Development

For local development with automatic rebuilding:

```bash
sphinx-autobuild . _build/html
```

This will start a local server and automatically rebuild the documentation when changes are detected.

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
      - run: pip install sphinx sphinx-rtd-theme
      - run: sphinx-build -b html . _build/html
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./_build/html
```

## Project Structure

```
api-docs/
├── conf.py                 # Sphinx configuration file
├── source/                 # Documentation source files
│   ├── index.rst           # Documentation home page
│   ├── installation.rst    # Installation guide
│   ├── api.rst             # API reference
│   ├── _static/            # Static files (CSS, JavaScript, images)
│   └── _templates/         # Custom HTML templates
└── README.md               # Project README
```

## Customization

You can customize the look and feel of your documentation by modifying the `conf.py` file and adding custom CSS to the `source/_static` directory. See the [Sphinx documentation](https://www.sphinx-doc.org/) for more options.

## Auto-Documenting Python Code

This example demonstrates how to automatically generate API documentation from Python docstrings using the `sphinx.ext.autodoc` extension. Make sure your Python code has proper docstrings in either Google style, NumPy style, or reStructuredText format.
