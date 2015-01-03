#!/bin/sh

if [ $# -eq 0 -o "-h" = "$1" -o "-help" = "$1" -o "--help" = "$1" ]; then
	cat <<EOHELP
Usage: $0 <secret> <manifest>

sign.sh adds lines to a manifest to indicate the approval
of the integrity of the firmware as required for automated
updates. The first argument <secret> references a file harboring
the private key of a public-private key pair of a developer
that referenced by its public key in the site configuration.
The script may be performed multiple times to the same document
to indicate an approval by multiple developers.

See also
 * edcsautils on https://github.com/tcatm/ecdsautils

EOHELP
	exit 1
fi
 
SECRET=$1
 
manifest=$2
upper=$(mktemp)
lower=$(mktemp)
 
awk "BEGIN    { sep=0 }
     /^---\$/ { sep=1; next }
              { if(sep==0) print > \"$upper\";
                else       print > \"$lower\"}" \
    $manifest
 
ecdsasign $upper < $SECRET >> $lower
 
cat  $upper  > $manifest
echo ---    >> $manifest
cat  $lower >> $manifest
 
rm -f $upper $lower
