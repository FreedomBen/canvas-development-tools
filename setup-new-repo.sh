#!/bin/bash

scripts=('add-custom-gems.sh' 'generate-ctags.sh')
abs_path="$HOME/gitclone/canvas-development-tools"
set_ruby_version="$abs_path/set-ruby-version.sh"

die ()
{
    echo "[ERROR]: $0: $1"
    exit 1
}

[ -d app ] || die "Are you in the root directory of your canvas checkout?"

[ -x "$set_ruby_version" ] || die "Could not find $set_ruby_version"
$set_ruby_version

cd .  # reload chruby settings now that we have a ruby version
gem install bundle
bundle install --without mysql
bundle update

for i in ${scripts[@]}; do
    echo "Running $i"
    full_path="$abs_path/$i"
    [ -x "$full_path" ] && $full_path
done


