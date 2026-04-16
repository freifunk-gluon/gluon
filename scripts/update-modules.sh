#!/usr/bin/env bash
# shellcheck enable=check-unassigned-uppercase

set -eo pipefail

# move to basedir, in case the script is not executed via `make update-modules`
cd "$(dirname "$0")/.." || exit 1

# shellcheck source=./modules
source ./modules

function switch_to_branch() {
	local BRANCH="$1"
	git switch -c "${BRANCH}" || git switch "${BRANCH}"
}

function get_default_branch() {
	local REPO_URL="$1"
	git ls-remote --symref "${REPO_URL}" HEAD | awk '/^ref:/ { sub(/refs\/heads\//, "", $2); print $2 }'
}

function get_module_info() {
	local MODULE_NAME=$1
	local MODULE_DATA=$2

	_DATA_KEY=${MODULE_NAME^^}_${MODULE_DATA}
	echo "${!_DATA_KEY}"
}

function get_commit_message() {
	local MODULE_NAME="$1"
	local MODULE_PATH="$2"
	local LOCAL_HEAD="$3"
	local REMOTE_HEAD="$4"

	# prepare the commit message
	# shellcheck disable=SC2001
	MODULE=$(echo "${MODULE_NAME,,}" | sed 's/packages_//')
	TITLE="modules: update ${MODULE}"
	MESSAGE="$(mktemp)"
	{
		echo "${TITLE}"
		printf '\n\n'
		git -C "${MODULE_PATH}" log --oneline --no-decorate --no-merges "${LOCAL_HEAD}..${REMOTE_HEAD}" | cat
	} > "$MESSAGE"

	cat "$MESSAGE"
}

function update_module() {
	local MODULE_NAME="$1"
	local MODULE_PATH="$2"

	local COMMIT_MESSAGE
	local LOCAL_HEAD
	local REMOTE_URL
	local REMOTE_BRANCH
	local REMOTE_HEAD

	REMOTE_URL="$(get_module_info "${MODULE_NAME}" "REPO")"
	REMOTE_BRANCH="$(get_module_info "${MODULE_NAME}" "BRANCH")"
	LOCAL_HEAD="$(get_module_info "${MODULE_NAME}" "COMMIT")"

	if [ "${REMOTE_BRANCH}" ]; then
		REMOTE_REF="refs/heads/${REMOTE_BRANCH}"
	else
		REMOTE_REF="HEAD"
	fi

	# fetch the commit id for the HEAD of the module
	REMOTE_HEAD="$(git ls-remote "${REMOTE_URL}" "${REMOTE_REF}" | awk '{ print $1 }')"

	# skip ahead if the commit id did not change
	[ "$LOCAL_HEAD" = "$REMOTE_HEAD" ] && return 0

	# switch to local working branch, if we found changes
	[ "$(git branch --show-current)" != "${LOCAL_BRANCH}" ] && switch_to_branch "${LOCAL_BRANCH}"

	# fetch branch from remote
	git -C "${MODULE_PATH}" fetch "${REMOTE_URL}" "${REMOTE_REF}"

	# get the commit message
	COMMIT_MESSAGE="$(get_commit_message "${MODULE_NAME}" "${MODULE_PATH}" "${LOCAL_HEAD}" "${REMOTE_HEAD}")"

	# modify modules file
	sed -i "s/${LOCAL_HEAD}/${REMOTE_HEAD}/" ./modules

	# commit the changes
	git commit -F - -- ./modules <<<"${COMMIT_MESSAGE}"
}

git diff --quiet ./modules || {
	1>&2 echo "Your modules file is dirty, aborting."
	exit 1
}

# Checkout update branch, create if it does not exist
CURRENT_DATE=$(date +%Y%m%d-%H%M%S)
LOCAL_BRANCH=$(git branch --show-current)
[[ $LOCAL_BRANCH != *-updates-${CURRENT_DATE} ]] && LOCAL_BRANCH+=-updates-${CURRENT_DATE}

update_module "openwrt" "./openwrt"

for MODULE in ${GLUON_FEEDS}; do
	update_module "PACKAGES_${MODULE}" "packages/${MODULE,,}"
done
