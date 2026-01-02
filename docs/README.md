# Docs

The docs are automatically built and deployed in the CI.
A temporary deployment of changed docs is created for every PR as well, accessible from the PR checks.

## Building docs

To build the docs locally, a Python environment is required.
For this, a [venv](https://docs.python.org/3/library/venv.html#creating-virtual-environments) is typically used.

This is set up using:

0. Create environment using `python -m venv .venv`
1. Activate the environment using `source ./.venv/bin/activate`
2. Install the requirements using `pip install -r requirements.txt`
3. Build the docs using `make html`
4. Serve the result on port 8000 using `python -m http.server -b 127.0.0.1 -d _build/html`
