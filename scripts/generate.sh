#!/usr/bin/env bash

set -e

declare -a IN


for ((i = 1; i < $#; i++)); do
	IN[$i]="${!i}"
done

OUT="$(readlink -f "${!#}")"

for S in "${IN[@]}"; do (
	cd "$(dirname "$S")"
	NAME="$(basename "$S")"
	IFS='
'

	for FILE in $(find "$NAME" -type f); do
		D="$(dirname "$FILE")"

		mkdir -p "$OUT/$D"
		(cd "$GLUONDIR"; scripts/configure.pl scripts/generate.pl) < "$FILE" > "$OUT/$FILE"
		chmod --reference="$FILE" "$OUT/$FILE"
	done
); done
