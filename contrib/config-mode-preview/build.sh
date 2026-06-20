#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
#
# Build the static config-mode preview into ./out (relative to this script).
#
# Renders the wizard via generate.lua and copies in the real theme CSS and the
# gluon-web-model JavaScript, so the result is a self-contained static site.
#
# Lua resolution order: $LUA, lua, lua5.1, then `nix-shell -p lua5_1`.

set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
out="$here/out"

css="$root/package/gluon-config-mode-theme/files/lib/gluon/config-mode/www/static/gluon.css"
js="$root/package/gluon-web-model/javascript/gluon-web-model.js"

# Pick a Lua interpreter.
run_lua() {
	if [ -n "${LUA:-}" ]; then
		"$LUA" "$@"
	elif command -v lua >/dev/null 2>&1; then
		lua "$@"
	elif command -v lua5.1 >/dev/null 2>&1; then
		lua5.1 "$@"
	elif command -v nix-shell >/dev/null 2>&1; then
		nix-shell -p lua5_1 --run "lua $*"
	else
		echo "error: no Lua 5.1 interpreter found (set \$LUA, or install lua5.1 / nix)" >&2
		exit 1
	fi
}

mkdir -p "$out/static"

# generate.lua expects to run from the repository root (it globs package/...)
# and writes one HTML file per config-mode page into the given output dir.
( cd "$root" && run_lua "contrib/config-mode-preview/generate.lua" "$out" )

cp "$css" "$out/static/gluon.css"
cp "$js" "$out/static/gluon-web-model.js"

echo "Built preview in $out (open index.html)"
echo "Serve it with: python3 -m http.server -d $out 8000"
