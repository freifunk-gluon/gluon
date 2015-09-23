#!/bin/sh

if [ $# -eq 0 -o "-h" = "$1" -o "-help" = "$1" -o "--help" = "$1" ]; then
    cat <<EOHELP
Usage: $0 <public> <signed manifest>

sigtest.sh checks a signed manifest to be approved by the public key
passed in the file <public>.

See also:
 * ecdsautils in https://github.com/tcatm/ecdsautils
 * http://gluon.readthedocs.org/en/latest/features/autoupdater.html

EOHELP
    exit 1
fi
 
PUBLIC=$1
 
manifest=$2
upper=$(mktemp)
lower=$(mktemp)
 
awk "BEGIN    { sep=0 }
    /^---\$/ { sep=1; next }
              { if(sep==0) print > \"$upper\";
                else       print > \"$lower\"}" \
    $manifest
 
for line in $(cat $lower)
do
    ecdsaverify -s $line -p $(cat $PUBLIC|tr -d " \n") $upper
    stat=$?
    rm -f $upper $lower
    if [ 0 -eq $stat ]; then
        echo "[OK]"
        exit 0
    fi
done
echo "[Failure]"
exit 1
