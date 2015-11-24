#!/bin/sh

if [ $# -eq 0 -o "-h" = "$1" -o "-help" = "$1" -o "--help" = "$1" ]; then
    cat <<EOHELP
Usage: $0 <public> <signed manifest>

sigtest.sh checks if a manifest is signed by the public key <public>. There is
no output, success or failure is indicated via the return code.

See also:
 * ecdsautils in https://github.com/tcatm/ecdsautils
 * http://gluon.readthedocs.org/en/latest/features/autoupdater.html

EOHELP
    exit 1
fi

public="$1"
manifest="$2"
upper="$(mktemp)"
lower="$(mktemp)"
ret=1

awk "BEGIN    { sep=0 }
    /^---\$/ { sep=1; next }
              { if(sep==0) print > \"$upper\";
                else       print > \"$lower\"}" \
    "$manifest"

if [ -e '/usr/local/bin/ecdsautil' ]; then
        ECMD='/usr/local/bin/ecdsautil verify'
elif [ -e '/usr/local/bin/ecdsasign' ]; then
        ECMD='/usr/local/bin/ecdsaverify -s'
fi

while read line
do
    if $ECMD "$line" -p "$public" "$upper"; then
        ret=0
        break
    fi
done < "$lower"

rm -f "$upper" "$lower"
exit $ret
