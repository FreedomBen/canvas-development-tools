#!/bin/sh

die ()
{
    echo "[ERROR]: $1"
    exit 1
}

[ -d Gemfile.d ] || die "Not in correct place.  Could not find Gemfile.d dir"

cat << __EOF__ > Gemfile.d/ben.rb
gem 'awesome_print'
gem 'colorize'
__EOF__

