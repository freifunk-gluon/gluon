#!/bin/sh

set -e

if [ $# -eq 0 -o $# -gt 2 -o "-h" = "$1" -o "--help" = "$1" -o ! -r "$1" -o \( $# -eq 2 -a ! -r "$2" \) ]; then
	cat <<EOHELP
Usage: $0 [<secret>] <manifest>

sign.sh adds lines to a manifest to indicate the approval
of the integrity of the firmware as required for automated
updates. The first optional argument <secret> references a
file harboring the private key of a public-private key pair
of a developer that referenced by its public key in the site
configuration. If this parameter is missing, you will be
asked to type in secret key. The script may be performed
multiple times to the same document to indicate an approval
by multiple developers.

See also
 * edcsautils on https://github.com/tcatm/ecdsautils

EOHELP
	exit 1
fi

if [ $# -eq 1 ]; then
	stty -echo
	read -p "Type in secret key: " secret
	stty echo
	echo
	manifest="$1"
else
	secret="$1"
	manifest="$2"
fi

upper="$(mktemp)"
lower="$(mktemp)"

trap 'rm -f "$upper" "$lower"' EXIT

awk 'BEGIN    { sep=0 }
     /^---$/ { sep=1; next }
              { if(sep==0) print > "'"$upper"'";
                else       print > "'"$lower"'"}' \
    "$manifest"

if [ $# -eq 1 ]; then
	echo "$secret" | ecdsasign "$upper" >> "$lower"
else
	ecdsasign "$upper" < "$secret" >> "$lower"
fi

(
	cat  "$upper"
	echo ---
	cat  "$lower"
) > "$manifest"
