#!/bin/bash

scripts=('add-custom-gems.sh' 'generate-ctags.sh' 'set-ruby-version.sh')
abs_path="$HOME/gitclone/canvas-development-tools"

die ()
{
    echo "[ERROR]: $1"
    exit 1
}

[ -d app ] || die "Are you in the root directory of your canvas checkout?"

for i in ${scripts[@]}; do
    echo "Running $i"
    full_path="$abs_path/$i"
    [ -x "$full_path" ] && $full_path
done

