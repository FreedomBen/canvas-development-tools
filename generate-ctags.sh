#!/bin/bash

die ()
{
    echo "[ERROR]: $1"
    exit 1
}

$(which bundle >/dev/null 2>&1) || die "Bundle cannot be found"
[ -d app ] || die "Are you in the root directory of your canvas checkout?"

echo "Generating ctags"
ctags -R --exclude=.git --exclude=log --languages=ruby . $(bundle list --paths | xargs)
