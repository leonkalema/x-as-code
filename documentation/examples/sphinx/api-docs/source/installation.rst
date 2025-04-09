Installation
============

This guide will help you install the X-as-Code API library.

Prerequisites
------------

Before installing the X-as-Code API, make sure you have the following prerequisites:

* Python 3.7 or higher
* pip (Python package manager)
* Virtual environment (recommended)

Installation from PyPI
---------------------

The simplest way to install the X-as-Code API is from PyPI:

.. code-block:: bash

    pip install x-as-code-api

Installation from Source
----------------------

To install from source:

1. Clone the repository:

   .. code-block:: bash

       git clone https://github.com/yourusername/x-as-code.git
       cd x-as-code/api

2. Install the package:

   .. code-block:: bash

       pip install -e .

Development Installation
----------------------

For development purposes, install additional dependencies:

.. code-block:: bash

    pip install -e ".[dev]"

Verification
-----------

To verify that the installation was successful, run:

.. code-block:: bash

    python -c "import xascode; print(xascode.__version__)"

Next Steps
---------

Once you have installed the X-as-Code API, you can proceed to the :doc:`usage` section to learn how to use the API.
