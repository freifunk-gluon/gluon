#!/bin/bash
set -uo pipefail

# validate_site.sh checks if the site.conf is valid json
GLUON_REPO="https://github.com/rubo77/gluon"
GLUON_BRANCH='ssid-changer'
GLUON_PACKAGES_REPO="https://github.com/freifunk-gluon/packages"
GLUON_PACKAGES_BRANCH='master'

P="$(pwd)"
echo "####### check if lua5.1 is installed ..."
which lua5.1 
if [ "$?" == 1 ]; then
  echo lua5.1 not present!
  echo install with sudo apt install lua5.1
  exit 1
fi

CONFIGS="site.conf"
if [ -d "domains" ]; then
  CONFIGS="$CONFIGS "domains/*
fi

for c in $CONFIGS; do
  echo "####### validating lua $c ..."
  GLUON_SITEDIR="." GLUON_SITE_CONFIG="$c" lua5.1 tests/site_config.lua
  if [ "$?" == 1 ]; then
    exit 1
  else
    echo "OK: $c"
  fi
done

for BASHFILE in "$P"/*.sh; do
    [ -f "$BASHFILE" ] || continue
  echo "####### validating $BASHFILE ..."
  bash -n "$BASHFILE"
  if [ "$?" == 0 ]; then
    echo "OK: $BASHFILE"
  fi
done

echo "####### validating $P/modules ..."
GLUON_SITE_FEEDS="none"
source "$P/modules"
testpath=/tmp/site-validate
rm -Rf "$testpath"
mkdir -p "$testpath/packages"
cd "$testpath/packages"
if [ "$GLUON_SITE_FEEDS" != "none" ]; then
  for feed in $GLUON_SITE_FEEDS; do
    echo "####### checking PACKAGES_${feed^^}_REPO ..."
    repo_var="PACKAGES_${feed^^}_REPO"
    commit_var="PACKAGES_${feed^^}_COMMIT"
    branch_var="PACKAGES_${feed^^}_BRANCH"
    repo="${!repo_var}"
    commit="${!commit_var}"
    branch="${!branch_var}"
    if [ "$repo" == "" ]; then
      echo "repo $repo_var missing"
      exit 1
    fi
    if [ "$commit" == "" ]; then
      echo "commit $commit_var missing"
      exit 1
    fi
  	if [ "$branch" == "" ]; then
      echo "branch $branch_var missing"
      exit 1
    fi
    git clone -b "$branch" --depth 1000 --single-branch "$repo" "$feed"
    if [ "$?" != "0" ]; then exit 1; fi
    cd "$feed"
    echo "git checkout $commit"
    git checkout "$commit"
    if [ "$?" != "0" ]; then exit 1; fi
    cd -
  done
fi

echo "####### Lua linter check for all package feeds ..."
~/.luarocks/bin/luacheck --config "$P/tests/.luacheckrc" "$testpath/packages"

echo "####### downloading $GLUON_PACKAGES_REPO ..."
git clone -b "$GLUON_PACKAGES_BRANCH" --depth 1  --single-branch "$GLUON_PACKAGES_REPO"

echo "####### downloading gluon ..."
cd "$testpath"
git init gluon
cd gluon
git remote add origin "$GLUON_REPO"
git config core.sparsecheckout true
echo "package/*" >> .git/info/sparse-checkout
git pull --depth 1 origin "$GLUON_BRANCH"
cp -a package/ "$testpath/packages"
cd "$testpath/packages/package"

echo "####### validating GLUON_SITE_PACKAGES from $P/site.mk ..."
# ignore non-gluon packages and standard gluon features
sed '0,/^GLUON_LANGS/d' "$P/site.mk" | sed '/GLUON_TARGET/,$d' | egrep -v '(#|G|iwinfo|iptables|haveged|vim|socat|tar|mesh-batman-adv-1[45]|web-advanced|web-wizard)'> "$testpath"/site.mk.sh
sed -i 's/\s\\$//g;/^$/d' "$testpath"/site.mk.sh
sed -i 's/gluon-mesh-batman-adv-1[45]/gluon-mesh-batman-adv/g' "$testpath"/site.mk.sh
sed -i 's/gluon-config-mode-geo-location-with-map/gluon-config-mode-geo-location/g' $testpath/site.mk.sh
cat "$testpath"/site.mk.sh |
while read packet; do
  if [ "$packet" != "" ]; then
    echo -n "# $packet"
    FOUND="$(find "$testpath/packages/" -type d -name "$packet")"
    if [ "$FOUND" '!=' '' ]; then
      echo " found in $(echo "$FOUND"|sed 's|'"$testpath/packages"'||g')"
    else
      # check again with prefix gluon-
      FOUND="$(find "$testpath/packages/" -type d -name "gluon-$packet")"
      if [ "$FOUND" '!=' '' ]; then
        echo " found as FEATURE in $(echo "$FOUND"|sed 's|'"$testpath/packages"'||g')"
      else
        echo
        echo "ERROR: $packet missing"
        exit 1
      fi
    fi
  fi
done
