#!/bin/sh

if [ $# -eq 0 -o "-h" = "$1" -o "-help" = "$1" -o "--help" = "$1" ]; then
	cat <<EOHELP
Usage: $0 <secret> <manifest>
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
