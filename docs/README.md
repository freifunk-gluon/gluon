# Docs

The docs are build and automatically deployed in the CI.
A temporary deployment of changed docs is created for every PR as well, accessible from the PR checks.

## Building docs

To build the docs locally, a python environment is required.

1. Install the requirements using `pip install -r requirements.txt`
2. Build the docs using `make html`
3. Serve the result on port 8000 using `python -m http.server -b 127.0.0.1 -d _build/html`
