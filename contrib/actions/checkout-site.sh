#!/bin/sh

set -e

GLUON_SITEDIR=site

if [ -n "${GLUON_SITE_URL}" ]; then

	echo "cloning ${GLUON_SITE_URL}"

	git clone "${GLUON_SITE_URL}" "${GLUON_SITEDIR}"

	if [ -n "$GLUON_SITE_BRANCH" ]; then
		echo "checking \"${GLUON_SITE_BRANCH}\" out"
		git -C "${GLUON_SITEDIR}" checkout "${GLUON_SITE_BRANCH}"
	fi

	echo "GLUON_SITEDIR=${GLUON_SITEDIR}" >> "$GITHUB_ENV"

	echo "site: $(git -C "${GLUON_SITEDIR}" describe)"

fi
