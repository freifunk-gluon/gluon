#!/usr/bin/env bash

set -euo pipefail

# move into base directory, in case this script is not executed via `make container`
cd "$(dirname "$0")/.."

# normalize branch name to reflect a valid image name
BRANCH=$(git branch --show-current 2>/dev/null | sed 's/[^a-z0-9-]/_/ig')
TAG="gluon:${BRANCH:-latest}"

if [ "$(command -v podman)" ]
then
	podman build -t "${TAG}" contrib/docker
	podman run -it --rm -u "$(id -u):$(id -g)" --userns=keep-id --volume="$(pwd):/gluon" "${TAG}"
elif [ "$(command -v docker)" ]
then
	docker build -t "${TAG}" contrib/docker
	docker run -it --rm -u "$(id -u):$(id -g)" --volume="$(pwd):/gluon" -e HOME=/gluon "${TAG}"
else
	1>&2 echo "Please install either podman or docker. Exiting" >/dev/null
	exit 1
fi

